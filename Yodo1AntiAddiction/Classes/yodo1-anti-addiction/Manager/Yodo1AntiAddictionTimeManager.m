//
//  Yodo1AntiAddictionTimeManager.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/5.
//

#import "Yodo1AntiAddictionTimeManager.h"
#import "Yodo1AntiAddictionRulesManager.h"
#import "Yodo1AntiAddictionUserManager.h"
#import "Yodo1AntiAddictionDatabase.h"
#import "Yodo1AntiAddictionNet.h"
#import "Yodo1Reachability.h"
#import "Yodo1Model.h"
#import "Yodo1Toast.h"

#import "Yodo1AntiAddictionUtils.h"
#import "Yodo1AntiAddictionDialogVC.h"

typedef enum: NSInteger {
    CheckActionNone = 0,
    CheckActionNotification = 1,
    CheckActionStop = 2
} CheckAction;

@implementation Yodo1AntiAddictionTimeManager {
    
    dispatch_source_t timer; // 计时器
    
    NSTimeInterval serverTime; // 服务器时间
    NSTimeInterval serverTimer; // 获取服务器时间后的计时
    
    NSMutableSet *notifyList;
}

+ (Yodo1AntiAddictionTimeManager *)manager {
    static Yodo1AntiAddictionTimeManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1AntiAddictionTimeManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        notifyList = [NSMutableSet set];
        
        // 监听网络变化
        __weak __typeof(self)weakSelf = self;
        [Yodo1Reachability reachability].notifyBlock = ^(Yodo1Reachability *reachability) {
            [weakSelf didNeedGetAppTime];
        };
        // 监听进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNeedGetAppTime) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopTimer];
}

- (void)didNeedGetAppTime {
    [self getAppTime:NO success:nil failure:nil];
}

#pragma mark - Public
/// 开启计时
- (void)startTimer {
    // 当前有计时不会开启新的计时
    if ([self isTimer]) {
        return;
    }
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    // 无登录用户不会开启计时
    if (user == nil) {
        return;
    }
    // 成年人不会开启计时
    if (user.certificationStatus == UserCertificationStatusAault) {
        return;
    }
    // 在获取服务器时间后开启计时
    [self getAppTime:YES success:^ {
        [self _startTimer];
    } failure:^{
        [self _startTimer];
    }];
}

- (void)_startTimer {
    
    Yodo1AntiAddictionRules *rules = [Yodo1AntiAddictionRulesManager manager].currentRules;
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    
    // 查询本地数据 没有则创建一条
    NSString *date = [Yodo1AntiAddictionUtils dateString:[self getNowDate]];
    _record = [self get:user.accountId date:user.certificationStatus == UserCertificationStatusMinor ? date : nil];
    if (_record) {
        // 如果有本地数据 且为游客 每15天重置试玩时间
        if (user.certificationStatus == UserCertificationStatusNot) {
            NSTimeInterval interval = [self getNowTime] - _record.createTime;
            if ((interval / (3600 * 24)) >= rules.guestModeConfig.effectiveDay) {
                _record.leftTime = rules.guestModeConfig.playingTime;
                _record.playingTime = 0;
                _record.awaitTime = 0;
            }
        }
    } else {
        _record = [[Yodo1AntiAddictionRecord alloc] init];
        _record.accountId = user.accountId;
        _record.date = date;
        _record.createTime = [self getNowTime];
        _record.playingTime = 0;
        _record.awaitTime = 0;
        
        // 初始可玩时间
        if (user.certificationStatus == UserCertificationStatusNot) {
            _record.leftTime = rules.guestModeConfig.playingTime;
        } else {
            NSTimeInterval holidayTime = 10800;
            NSTimeInterval regularTime = 5400;
            for (GroupPlayingTime *range in rules.groupPlayingTimeList) {
                if ([Yodo1AntiAddictionUtils age:user.age inRange:range.ageRange]) {
                    holidayTime = range.holidayTime;
                    regularTime = range.regularTime;
                }
            }
            NSString *today = [Yodo1AntiAddictionUtils dateString:[self getNowDate]];
            BOOL isHoliday = [[Yodo1AntiAddictionRulesManager manager].holidays indexOfObject:today] != NSNotFound;
            NSTimeInterval duration = isHoliday ? holidayTime : regularTime;
            _record.leftTime = duration;
        }
        
        [self insert:_record];
    }
    
    
    
    NSTimeInterval delay = 0.0f; // 延迟时间
    NSTimeInterval interval = 1.0f; // 间隔时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 设置延时
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    // 设置计时
    dispatch_source_set_timer(timer, startDelayTime, interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    // 处理事件
    __weak __typeof(self)weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf handleTimer];
    });
    
    if (_record.awaitTime > 0) {
        // 如果有未上报的时间则上报一次时间 然后开始计时
        [self postPlayTime:YES time:_record.awaitTime success:^{
            dispatch_resume(self -> timer);
        } failure:^{
            dispatch_resume(self -> timer);
        }];
    } else {
        // 获取可玩时间后开始计时
        [self getPlayTime:YES success:^{
            dispatch_resume(self -> timer);
        } failure:^{
            dispatch_resume(self -> timer);
        }];
    }
}

- (void)stopTimer {
    if (timer != nil) {
        dispatch_source_cancel(timer);
    }
    timer = nil;
    [notifyList removeAllObjects];
    if (_record.awaitTime > 0) { // 上报一次时间
        [self postPlayTime:NO time:_record.awaitTime success:nil failure:nil];
    }
}

- (BOOL)isTimer {
    return timer != nil;
}

- (NSTimeInterval)getNowTime {
    return serverTime + serverTimer;
}

- (NSDate *)getNowDate {
    return [NSDate dateWithTimeIntervalSince1970: [self getNowTime]];
}

#pragma mark - Method
/// 处理计时
- (void)handleTimer {
    Yodo1AntiAddictionRules *rules = [Yodo1AntiAddictionRulesManager manager].currentRules;
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    id<Yodo1AntiAddictionDelegate> delegate = [Yodo1AntiAddictionHelper shared].delegate;
    
    // 先检查是否在禁玩时间
    CheckAction forbidden = [self checkForbiddenTime];
    if (forbidden != CheckActionNone) {
        
        dispatch_async(dispatch_get_main_queue(),^{
            if (forbidden == CheckActionNotification) {
                // 提醒
                if (self->notifyList.count == 0) {
                    if (Yodo1AntiAddictionHelper.shared.enterBackground) {
                        return;
                    }
                    Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
                    event.eventCode = Yodo1AntiAddictionEventCodeMinorForbiddenTime;
                    event.action = Yodo1AntiAddictionActionResumeGame;
                    event.title = @"提示";
                    event.content = rules.antiPlayingTimeMsg.beforeMsg;
                    if (delegate && [delegate respondsToSelector:@selector(onTimeLimitNotify:title:message:)]) {
                        if (![delegate onTimeLimitNotify:event title:event.title message:event.content]) {
                            [[Yodo1AntiAddictionUtils getTopWindow] makeToast:event.content duration:0.2 position:Yodo1CSToastPositionTop];
                        }
                    }
                    [self->notifyList addObject:event];
                }
            } else if (forbidden == CheckActionStop) {
                // 结束
                Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
                event.eventCode = Yodo1AntiAddictionEventCodeMinorForbiddenTime;
                event.action = Yodo1AntiAddictionActionEndGame;
                event.title = @"提示";
                event.content = rules.antiPlayingTimeMsg.message;
                
                // 禁玩时段的通知 通过onTimeLimitNotify接口返回
                if (delegate && [delegate respondsToSelector:@selector(onTimeLimitNotify:title:message:)]) {
                    if (![delegate onTimeLimitNotify:event title:event.title message:event.content]) {
                        [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleTimeDisable error:nil];
                    }
                }
            }
        });
        // 如果已在禁玩时间 停止计时
        if (forbidden == CheckActionStop) {
            [self stopTimer];
            return;
        }
    }
    
    // 检测是否已到可玩时间
    CheckAction end = [self checkEndTime];
    if (end != CheckActionNone) {
        
        dispatch_async(dispatch_get_main_queue(),^{
            if (end == CheckActionNotification) {
                if (Yodo1AntiAddictionHelper.shared.enterBackground) {
                    return;
                }
                // 提醒
                if (self->notifyList.count == 0) {
                    Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
                    if (user.certificationStatus == UserCertificationStatusMinor) {
                        event.eventCode = Yodo1AntiAddictionEventCodeMinorPlayedTime;
                        event.action = Yodo1AntiAddictionActionResumeGame;
                        event.title = @"提示";
                        event.content = rules.playingTimeMsg.beforeMsg;
                        if (delegate && [delegate respondsToSelector:@selector(onTimeLimitNotify:title:message:)]) {
                            if (![delegate onTimeLimitNotify:event title:event.title message:event.content]) {
                                [[Yodo1AntiAddictionUtils getTopWindow] makeToast:event.content duration:0.2 position:Yodo1CSToastPositionTop];
                            }
                        }
                    } else {
                        event.eventCode = Yodo1AntiAddictionEventCodeGuestPlayedTime;
                        event.action = Yodo1AntiAddictionActionResumeGame;
                        event.title = @"提示";
                        event.content = rules.guestModeMsg.beforeMsg;
                        if (delegate && [delegate respondsToSelector:@selector(onTimeLimitNotify:title:message:)]) {
                            if (![delegate onTimeLimitNotify:event title:event.title message:event.content]) {
                                [[Yodo1AntiAddictionUtils getTopWindow] makeToast:event.content duration:0.2 position:Yodo1CSToastPositionTop];
                            }
                        }
                    }
                    [self->notifyList addObject:event];
                }
            } else if (end == CheckActionStop) {
                // 结束
                Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
                if (user.certificationStatus == UserCertificationStatusMinor) {
                    event.eventCode = Yodo1AntiAddictionEventCodeMinorPlayedTime;
                    event.action = Yodo1AntiAddictionActionEndGame;
                    event.title = @"提示";
                    event.content = rules.playingTimeMsg.message;
                    if (delegate && [delegate respondsToSelector:@selector(onTimeLimitNotify:title:message:)]) {
                        if (![delegate onTimeLimitNotify:event title:event.title message:event.content]) {
                            [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleTimeOverstep error:nil];
                        }
                    }
                } else {
                    event.eventCode = Yodo1AntiAddictionEventCodeGuestPlayedTime;
                    event.action = Yodo1AntiAddictionActionEndGame;
                    event.title = @"提示";
                    event.content = rules.guestModeMsg.message;
                    if (delegate && [delegate respondsToSelector:@selector(onTimeLimitNotify:title:message:)]) {
                        if (![delegate onTimeLimitNotify:event title:event.title message:event.content]) {
                            [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleVisitorOver error:nil];
                        }
                    }
                }
            }
        });
        
        if (end == CheckActionStop) {
            [self stopTimer];
            return;
        }
    }
    
    serverTimer += 1;
    _record.awaitTime += 1;
    _record.playingTime += 1;
    _record.leftTime -= 1;
    
    if (_record.leftTime <= 0) {
        _record.leftTime = 0;
    }
    
    // 每10秒保存一次本地数据
    NSInteger leftTime = _record.leftTime;
    if (leftTime % 10 == 0) {
        [self update:_record];
    }
    
    // 每5分钟上报一次数据
    if (_record.awaitTime > 30) {
        [self postPlayTime:NO time:_record.awaitTime success:nil failure:nil];
    } else if (_record.awaitTime == 0) {
        [self getPlayTime:NO success:nil failure:nil];
    }
    
    // 每隔30分钟更新一次规则
    if (leftTime % 1800 == 0) {
        [self updateRule];
    }
}

//
- (CheckAction)checkForbiddenTime {
    
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    Yodo1AntiAddictionRules *rules = [Yodo1AntiAddictionRulesManager manager].currentRules;

    NSDate *serverTime = [self getNowDate];
    NSInteger current = [Yodo1AntiAddictionUtils timeToInt:[Yodo1AntiAddictionUtils dateString:serverTime format:@"HH:mm"]];
    
    if (user.certificationStatus == UserCertificationStatusMinor) {
        // 查询是否在可玩时段内
        NSArray<NSString *> *limtRange;
        for (GroupAntiPlayingTimeRange *range in rules.groupAntiPlayingTimeRangeList) {
            if ([Yodo1AntiAddictionUtils age:user.age inRange:range.ageRange]) {
                limtRange = range.antiPlayingTimeRange;
                break;
            }
        }
        
        if (limtRange) {
            NSRange timeRange = NSMakeRange(0, 0);
            for (NSString *time in limtRange) {
                NSRange range = [Yodo1AntiAddictionUtils time:current inRange:time];
                if (range.location != 0 && range.length != 0) {
                    timeRange = range;
                } 
            }
            // 没有匹配可玩时间，直接认为是在非可玩时段
            if (timeRange.location == 0 && timeRange.length == 0) {
                return CheckActionStop;
            }
            if (current >= timeRange.location && current <= timeRange.location + timeRange.length) {
                if (NSMaxRange(timeRange) == current) {
                    return CheckActionStop;
                } else if (NSMaxRange(timeRange) - current < 10) {
                    return CheckActionNotification;
                }
            } else {
                return CheckActionStop;
            }
        } else {
            // 没有匹配年龄，直接认为是在非可玩时段
            return CheckActionStop;
        }
    }
    return CheckActionNone;
}

- (CheckAction)checkEndTime {
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    Yodo1AntiAddictionRules *rules = [Yodo1AntiAddictionRulesManager manager].currentRules;
    NSTimeInterval residue = 600;
    if (user.certificationStatus == UserCertificationStatusMinor) {
        // 匹配可玩时间
        NSTimeInterval holidayTime = 10800;
        NSTimeInterval regularTime = 5400;
        for (GroupPlayingTime *range in rules.groupPlayingTimeList) {
            if ([Yodo1AntiAddictionUtils age:user.age inRange:range.ageRange]) {
                holidayTime = range.holidayTime;
                regularTime = range.regularTime;
            }
        }
        
        NSString *today = [Yodo1AntiAddictionUtils dateString:[self getNowDate]];
        BOOL isHoliday = [[Yodo1AntiAddictionRulesManager manager].holidays indexOfObject:today] != NSNotFound;
        NSTimeInterval duration = isHoliday ? holidayTime : regularTime;
        
        if (duration - _record.playingTime <= 0 || _record.leftTime <= 0) {
            return CheckActionStop;
        } else if (duration - _record.playingTime <= residue || (_record.leftTime <= residue && _record.leftTime > 0)) {
            return CheckActionNotification;
        }
    } else {
        NSTimeInterval duration = rules.guestModeConfig.playingTime;
        if (duration - _record.playingTime <= 0 || _record.leftTime <= 0) {
            return CheckActionStop;
        } else if (duration - _record.playingTime <= residue || (_record.leftTime <= residue && _record.leftTime > 0)) {
            return CheckActionNotification;
        }
    }
    return CheckActionNone;
}


/// 获取服务器时间
/// start 是否器开始计时的第一次请求
- (void)getAppTime:(BOOL)start success:(void (^)(void))success failure:(void (^)(void))failure {

    [[Yodo1AntiAddictionNet manager] GET:@"time/getAppTime" parameters:nil success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        if (res.success && res.data) {
            id time = res.data[@"currentTime"];
            if (time) {
                NSTimeInterval serverTime = [time longLongValue] / 1000;
                self -> serverTime = serverTime;
                self -> serverTimer = 0;
                if (success) {
                    success();
                }
            } else {
                self -> serverTime = [NSDate date].timeIntervalSince1970;
                self -> serverTimer = 0;
                if (failure) {
                    failure();
                }
            }
        } else {
            self -> serverTime = [NSDate date].timeIntervalSince1970;
            self -> serverTimer = 0;
            if (failure) {
                failure();
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError * error) {
        self -> serverTime = [NSDate date].timeIntervalSince1970;
        self -> serverTimer = 0;
        if (failure) {
            failure();
        }
    }];
}

/// 获取已完时间
- (void)getPlayTime:(BOOL)start success:(void (^)(void))success failure:(void (^)(void))failure {
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    if (user == nil || user.certificationStatus == UserCertificationStatusAault) {
        return;
    }
    
    [[Yodo1AntiAddictionNet manager] GET:@"time/getPlayingTime" parameters:@{@"businessType" : (user.certificationStatus == UserCertificationStatusMinor ? @1 : @2)} success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        if (res.success && res.data && self->_record) {
            // 服务器时间
            id serverTime = res.data[@"currentTimer"];
            if (serverTime) {
                self -> serverTime = [serverTime longLongValue] / 1000;
                self -> serverTimer = 0;
            }
            
            // 已玩时间
            id playingTime = res.data[@"playingTime"];
            if (playingTime) {
                self->_record.playingTime = [playingTime doubleValue];
            }
            
            // 剩余时间
            id leftTime = res.data[@"leftTime"];
            if (leftTime) {
                self->_record.leftTime = [leftTime doubleValue];
            }
            [self update:self->_record];
            
            if (success) {
                success();
            }
        } else {
            self -> serverTime = [NSDate date].timeIntervalSince1970;
            self -> serverTimer = 0;
            if (failure) {
                failure();
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError * error) {
        self -> serverTime = [NSDate date].timeIntervalSince1970;
        self -> serverTimer = 0;
        if (failure) {
            failure();
        }
    }];
}

/// 上报时间
- (void)postPlayTime:(BOOL)start time:(NSTimeInterval)time success:(void (^)(void))success failure:(void (^)(void))failure {
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    if (user == nil) {
        return;
    }
    
    NSString *date = [Yodo1AntiAddictionUtils dateString:[self getNowDate]];
    NSString *sign = [Yodo1AntiAddictionUtils md5String:[NSString stringWithFormat:@"anti%@", date]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"businessType"] = user.certificationStatus == UserCertificationStatusMinor ? @1 : @2;
    parameters[@"happenDate"] = date;
    parameters[@"playingTime"] = @((NSInteger)time);
    parameters[@"sign"] = sign;
    
    [[Yodo1AntiAddictionNet manager] POST:@"time/reportPlayingTime" parameters:parameters success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        if (res.success && res.data) {
            
            // 服务器时间
            id serverTime = res.data[@"currentTimer"];
            if (serverTime) {
                self -> serverTime = [serverTime longLongValue] / 1000;
                self -> serverTimer = 0;
            }
            
            // 已玩时间
            id playingTime = res.data[@"playingTime"];
            if (playingTime) {
                self->_record.playingTime = [playingTime doubleValue];
                NSTimeInterval awaitTime = self->_record.awaitTime - time;
                if (awaitTime < 0) {
                    awaitTime = 0;
                }
                self->_record.awaitTime = awaitTime;
            }
            
            // 剩余时间
            id leftTime = res.data[@"leftTime"];
            if (leftTime) {
                self->_record.leftTime = [leftTime doubleValue];
            }
            [self update:self->_record];
            if (success) {
                success();
            }
        } else {
            self -> serverTime = [NSDate date].timeIntervalSince1970;
            self -> serverTimer = 0;
            if (failure) {
                failure();
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self -> serverTime = [NSDate date].timeIntervalSince1970;
        self -> serverTimer = 0;
        if (failure) {
            failure();
        }
    }];
}
/// 更新规则
- (void)updateRule {
    [[Yodo1AntiAddictionRulesManager manager] requestRules:nil failure:nil];
}

#pragma mark - 数据库操作
- (Yodo1AntiAddictionRecord *)get:(NSString *)accountId date:(NSString *)date {
    
    NSMutableString *where = [NSMutableString string];
    NSMutableArray *args = [NSMutableArray array];
    [where appendString:@"accountId = ?"];
    [args addObject:accountId];
    if (date) {
        [where appendString:@" AND "];
        [where appendString:@"date = ?"];
        [args addObject:date];
    }
    
    Yodo1FMResultSet *result = [[Yodo1AntiAddictionDatabase shared] query:NSStringFromClass([Yodo1AntiAddictionRecord class]) projects:nil where:where args:args order:nil];
    if ([result next]) {
        return [Yodo1AntiAddictionRecord yodo1_modelWithDictionary:result.resultDictionary];
    }
    return nil;
}

- (BOOL)insert:(Yodo1AntiAddictionRecord *)record {
    
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    content[@"accountId"] = record.accountId;
    if (record.date) content[@"date"] = record.date;
    content[@"createTime"] = @(record.createTime);
    content[@"leftTime"] = @(record.leftTime);
    content[@"playingTime"] = @(record.playingTime);
    content[@"awaitTime"] = @(record.awaitTime);
    
    return [[Yodo1AntiAddictionDatabase shared] insertInto:NSStringFromClass([Yodo1AntiAddictionRecord class]) content:content];
}

- (BOOL)update:(Yodo1AntiAddictionRecord *)record {
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    content[@"createTime"] = @(record.createTime);
    content[@"leftTime"] = @(record.leftTime);
    content[@"playingTime"] = @(record.playingTime);
    content[@"awaitTime"] = @(record.awaitTime);
    
    NSLog(@"更新一次计时 - %@", content);
    
    NSMutableString *where = [NSMutableString string];
    NSMutableArray *args = [NSMutableArray array];
    [where appendString:@"accountId = ?"];
    [args addObject:record.accountId];
    [where appendString:@" AND "];
    if (record.date) {
        [where appendString:@"date = ?"];
        [args addObject:record.date];
    } else {
        [where appendString:@"date IS NULL"];
    }
    
    return [[Yodo1AntiAddictionDatabase shared] update:NSStringFromClass([Yodo1AntiAddictionRecord class]) content:content where:where args:args];
}

- (BOOL)delete:(NSString *)accountId date:(NSString *)date {
    
    NSMutableString *where = [NSMutableString string];
    NSMutableArray *args = [NSMutableArray array];
    [where appendString:@"accountId = ?"];
    [args addObject:_record.accountId];
    [where appendString:@" AND "];
    if (date) {
        [where appendString:@"date = ?"];
        [args addObject:_record.date];
    } else {
        [where appendString:@"date IS NULL"];
    }
    
    return [[Yodo1AntiAddictionDatabase shared] deleteFrom:NSStringFromClass([Yodo1AntiAddictionRecord class]) where:where args:args];
}

@end
