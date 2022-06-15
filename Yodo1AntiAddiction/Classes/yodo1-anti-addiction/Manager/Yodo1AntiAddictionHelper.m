//
//  Yodo1AntiAddictionHelper.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/9.
//

#import "Yodo1AntiAddictionHelper.h"

#import "Yd1OnlineParameter.h"
#import "Yodo1Model.h"

#import "Yodo1AntiAddictionDatabase.h"
#import "Yodo1AntiAddictionNet.h"
#import "Yodo1AntiAddictionUtils.h"
#import "Yodo1AntiAddictionRulesManager.h"
#import "Yodo1AntiAddictionUserManager.h"
#import "Yodo1AntiAddictionTimeManager.h"
#import "Yodo1AntiAddictionMainVC.h"
#import "Yodo1AntiAddictionDialogVC.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1AntiAddictionBehaviour.h"


/// code:成功:200, 失败:-1,用户登录错误:-2,网络错误:-100
/// response: 服务器返回内容
typedef void (^OnBehaviourCallback)(int code,id response);

@interface Yodo1AntiAddictionHelper() {
    
}

@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *regionCode;
@property (nonatomic, strong) Yodo1AntiAddictionBehaviour *behaviour;

@end

@implementation Yodo1AntiAddictionHelper

+ (Yodo1AntiAddictionHelper *)shared {
    static Yodo1AntiAddictionHelper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1AntiAddictionHelper alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 监听进入前台
        [NSNotificationCenter.defaultCenter  addObserver:self
                                                selector:@selector(onlineBehaviour) name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
        // 监听进入后台
        [NSNotificationCenter.defaultCenter  addObserver:self
                                                selector:@selector(offlineBehaviour) name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
        // 监听销毁APP
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(appTerminate) name:UIApplicationWillTerminateNotification
                                                 object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:UIApplicationWillEnterForegroundNotification
                                                object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:UIApplicationDidEnterBackgroundNotification
                                                object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:UIApplicationWillTerminateNotification
                                                object:nil];
}


- (Yodo1AntiAddictionBehaviour *)behaviour {
    if (_behaviour == nil) {
        _behaviour = [[Yodo1AntiAddictionBehaviour alloc]init];
    }
    return  _behaviour;
}

- (void)onlineBehaviour {
    if (self.enterGameFlag && !self.isOnline) {
        __weak typeof(self) weakSelf = self;
        [self online:^(BOOL result, NSString * _Nonnull content) {
            if (result) {
                //不必有特殊处理
                [weakSelf startTimer];
            } else {
                //通知游戏上线失败
                if (Yodo1AntiAddiction.shared.disconnection) {
                    Yodo1AntiAddiction.shared.disconnection(@"提示", @"网速不给力，请确保网络通畅后重试");
                }
            }
        }];
    }
}

- (void)offlineBehaviour {
    if (self.isOnline) {
        __weak typeof(self) weakSelf = self;
        [self offline:^(BOOL result, NSString * _Nonnull content) {
            NSLog(@"enter Background, auto-offline. result = %d,%@",result,content);
            [weakSelf stopTimer];
            weakSelf.enterBackground = YES;
        }];
    }
}

- (void)appTerminate {
    if (self.isOnline) {
        [self stopTimer];
        [self offline:^(BOOL result, NSString * _Nonnull content) {
            NSLog(@"appTerminate, auto-offline. result = %d,%@",result,content);
        }];
    }
}

- (void)init:(NSString *)appKey channel:(NSString *)channel regionCode:(NSString *)regionCode delegate:(id<Yodo1AntiAddictionDelegate>)delegate {
    _delegate = delegate;
    _autoTimer = YES;
    _regionCode = regionCode ? regionCode : @"00000000";
    _systemSwitch = NO;
    
    [[Yd1OnlineParameter shared] initWithAppKey:appKey channelId:channel];
    [Yodo1AntiAddictionDatabase shared];
    [Yodo1AntiAddictionNet manager];
    [self checkIP:appKey];
    __weak __typeof(self)weakSelf = self;
    // 获取防沉迷规则 获取失败则使用本地默认
    [[Yodo1AntiAddictionRulesManager manager] requestRules:^(id data) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onInitFinish:message:)]) {
            [self.delegate onInitFinish:YES message:@"初始化方沉迷系统成功"];
        }
        [weakSelf checkIP:appKey];
        weakSelf.systemSwitch = [Yodo1AntiAddictionRulesManager manager].currentRules.switchStatus;
        [Yodo1AntiAddictionTimeManager.manager didNeedGetAppTime];
    } failure:^(NSError * error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onInitFinish:message:)]) {
            [self.delegate onInitFinish:NO message:error.localizedDescription];
        }
    }];
    
    [[Yodo1AntiAddictionRulesManager manager] requestHolidayList:nil failure:nil];
    [[Yodo1AntiAddictionRulesManager manager] requestHolidayRules:nil failure:nil];
}

- (NSString *)getSdkVersion {
    if (!_version) {
        NSString *path = [[Yodo1AntiAddictionUtils bundle] pathForResource:@"Yodo1AntiAddictionInfo" ofType:@"plist"];
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
        _version = info[@"version"];
        if (!_version) {
            _version = @"1.0.0";
        }
    }
    return _version;
}

- (void)checkIP:(NSString *)gameKey {
    if (self.isChina) {
        return;
    }
    NSURL* url = [NSURL URLWithString:@"https://ais.yodo1api.com/ais/config/checkIp"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString* timestamp = Yodo1Tool.shared.nowTimeTimestamp;
    NSString* sign = [Yodo1Tool.shared signMd5String:[NSString stringWithFormat:@"%@yodo1",timestamp]];
    NSDictionary* param = @{@"game_key":gameKey,
                            @"timestamp":timestamp,
                            @"sign":sign};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:param
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if ([[responseObject allKeys]containsObject:@"data"]) {
                NSDictionary* data = responseObject[@"data"];
                if ([[data allKeys]containsObject:@"isChina"]) {
                    self->_isChina = [data[@"isChina"]boolValue];
                    if (self->_isChina) {
                        NSLog(@"It's China!");
                    }
                }
            }
            NSLog(@"responseObject:%@",responseObject);
        } else {
            self->_isChina = NO;
        }
    }];
    [dataTask resume];
}

- (void)startTimer {
    [[Yodo1AntiAddictionTimeManager manager] startTimer];
}

- (void)stopTimer {
    [[Yodo1AntiAddictionTimeManager manager] stopTimer];
}

- (BOOL)isTimer {
    return [[Yodo1AntiAddictionTimeManager manager] isTimer];
}

- (BOOL)isGuestUser {
    return [[Yodo1AntiAddictionUserManager manager] isGuestUser];
}

- (BOOL)successful:(id _Nullable)data {
    if (_certSucdessfulCallback) {
        return _certSucdessfulCallback(data);
    } else {
        return NO;
    }
}

- (BOOL)failure:(NSError * _Nullable)error {
    if (_certFailureCallback) {
        return _certFailureCallback(error);
    } else {
        return NO;
    }
}

- (void)verifyCertificationInfo:(NSString *)accountId success:(Yodo1AntiAddictionSuccessful)success failure:(Yodo1AntiAddictionFailure)failure {
    if (!self.systemSwitch) {
        Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
        event.eventCode = Yodo1AntiAddictionEventCodeNone;
        event.action = Yodo1AntiAddictionActionResumeGame;
        success(event);
        return;
    }
    if (!self.isChineseMainland) {
        Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
        event.eventCode = Yodo1AntiAddictionEventCodeNone;
        event.action = Yodo1AntiAddictionActionResumeGame;
        success(event);
        return;
    }
    
    _certSucdessfulCallback = success;
    _certFailureCallback = failure;
    
    [[Yodo1AntiAddictionUserManager manager] get:accountId success:^(Yodo1AntiAddictionUser *user) {
        if (user.certificationStatus != UserCertificationStatusNot && user.age != -1) {
            Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
            event.eventCode = Yodo1AntiAddictionEventCodeNone;
            event.action = Yodo1AntiAddictionActionResumeGame;
            if (self->_certSucdessfulCallback) {
                self->_certSucdessfulCallback(event);
            }
            // 自动开启计时
            if (self.autoTimer) {
                [self startTimer];
            }
        } else {
            // 未实名
            [Yodo1AntiAddictionUtils showVerifyUI];
        }
    } failure:^(NSError *error) {
        // 发生错误一律认为未实名
        if ([Yodo1AntiAddictionUtils isNetError:error]) {
            [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleError error:[Yodo1AntiAddictionUtils convertError:error].localizedDescription];
        } else {
            [Yodo1AntiAddictionUtils showVerifyUI];
        }
    }];
}

///是否已限制消费
- (void)verifyPurchase:(NSInteger)money success:(Yodo1AntiAddictionSuccessful)success failure:(Yodo1AntiAddictionFailure)failure {
    if (!self.systemSwitch) {
        success(@{@"hasLimit": @(NO), @"alertMsg": @"AntiAddiction of switch is off!"});
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"money"] = @(money);
    parameters[@"currency"] = @"CNY";
    
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    if (user.certificationStatus == UserCertificationStatusNot) {
        BOOL show = success && success(@{@"hasLimit" : @(true), @"alertMsg": @"根据国家规定：游客体验模式无法购买物品"});
        if (!show) {
            [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleBuyDisable error:nil];
        }
        return;
    }
    
    ///hyx 是否已限制消费 /ais/money/info
    [[Yodo1AntiAddictionNet manager] GET:@"money/info" parameters:parameters success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        if (res && res.success && res.data) {
            
            id hasLimit = res.data[@"hasLimit"];
            BOOL limit = hasLimit ? [hasLimit boolValue] : false; // 是否被限制
            
            id alertMsg = res.data[@"alertMsg"];
            NSString *msg = (alertMsg && ![alertMsg isKindOfClass:[NSNull class]]) ? alertMsg : res.message;
            
            BOOL show = false;
            if (success) {
                show = success(@{@"hasLimit": @(limit), @"alertMsg": msg});
            }
            
            if (!show && limit) {
                [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleBuyOverstep error:msg];
            }
        } else {
            if (failure) {
                failure([Yodo1AntiAddictionUtils errorWithCode:res.code msg:res.message]);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure([Yodo1AntiAddictionUtils convertError:error]);
        }
    }];
}

- (void)reportProductReceipts:(NSArray<Yodo1AntiAddictionProductReceipt *> *)receipts success:(Yodo1AntiAddictionSuccessful)success failure:(Yodo1AntiAddictionFailure)failure {
    if (!self.systemSwitch) {
        success(@"AntiAddiction of switch is off!");
        return;
    }
    if (receipts.count == 0) {
        return;
    }
    for (Yodo1AntiAddictionProductReceipt *receipt in receipts) {
        if (!receipt.region) {
            receipt.region = _regionCode;
        }
    }
    
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    //成年人不上报
    if (user.certificationStatus == UserCertificationStatusAault) {
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"groupReceiptAndGoodsInfo"] = [receipts yodo1_modelToJSONObject];
    
    long long timestamp = [NSDate date].timeIntervalSince1970 * 1000;
    parameters[@"sign"] = [Yodo1AntiAddictionUtils md5String:[NSString stringWithFormat:@"anti%@", @(timestamp)]];
    parameters[@"timestamp"] = @(timestamp);
    ///hyx 上报消费信息 - 支付信息&商品信息 /ais/money/receipt
    [[Yodo1AntiAddictionNet manager] POST:@"money/receipt" parameters:parameters success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        if (res && res.success) {
            if (success) {
                success(res.data);
            }
        } else {
            if (failure) {
                failure([Yodo1AntiAddictionUtils errorWithCode:res.code msg:res.message]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure([Yodo1AntiAddictionUtils convertError:error]);
        }
    }];
}

- (void)online:(OnBehaviourResult)callback {
    //1.防沉迷开关关闭状态的话直接回调成功
    if (!self.systemSwitch) {
        if (callback) {
            callback(YES,@"AntiAddiction of switch is off!");
        }
        return;
    }
    //2.玩家已处于在线状态直接回调成功
    if (self.isOnline) {
        if (callback) {
            callback(YES,@"");
        }
        return;
    }
    //3.玩家没有进行实名制或游客模式登录回调失败
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    if (!user|| !user.yid || [user.yid isEqualToString:@""]) {
        callback(NO,@"请先登录并获取实名信息后重试");
        return;
    }
    self.behaviour.yid = user.yid;
    self.behaviour.uid = user.uid;
    self.behaviour.behaviorType = 1;
    self.behaviour.userType = user.certificationStatus == UserCertificationStatusNot ? 2 : 1;
    
    NSTimeInterval interval = [Yodo1AntiAddictionTimeManager.manager getNowTime];
    NSLog(@"interval:%lf",interval);
    self.behaviour.happenTimestamp = interval;
    self.behaviour.sessionId = @"";
    self.behaviour.deviceId = Yodo1Tool.shared.keychainDeviceId;
    
    __weak __typeof(self)weakSelf = self;
    // 4.上报本次上线行为之前，应先处理之前上报失败的行为
    [self reportBeforeOfflineBehaviour:self.behaviour
                              callback:^(BOOL result, NSString * _Nonnull content) {
        if (result) {
            [weakSelf reportCNUserBehavior:weakSelf.behaviour
                                  callback:^(int code, id response) {
                if (code == 200) {
                    Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:response];
                    if (res.success && res.data) {
                        id sessionId = res.data[@"sessionId"];
                        if (sessionId) {
                            NSLog(@"sessionId:%@",sessionId);
                            if ([sessionId isKindOfClass:[NSNull class]]) {
                                sessionId = @"";
                            }
                            weakSelf.behaviour.sessionId = sessionId;
                            [weakSelf update:weakSelf.behaviour];
                        }
                        weakSelf.isOnline = YES;
                        callback(YES,res.message);
                    }else{
                        callback(NO,@"上线请求失败，账户异常");
                    }
                }else{
                    callback(NO,@"上线请求失败，请检查网络情况");
                }
            }];
        }else{
            if (callback) {
                callback(NO,@"上线请求失败，请检查网络情况");
            }
        }
    }];
    
}

- (void)offline:(OnBehaviourResult)callback {
    if (!self.systemSwitch) {
        if (callback) {
            callback(YES,@"Yodo1AntiAddiction offline, anti switchStatus = false, return");
        }
        NSLog(@"Yodo1AntiAddiction offline, anti switchStatus = false, return");
        return;
    }
    if (!self.isOnline) {
        if (callback) {
            callback(YES,@"Yodo1AntiAddiction call offline, player is offline, not-repeated");
        }
        NSLog(@"Yodo1AntiAddiction call offline, player is offline, not-repeated");
        return;
    }
    
    if (self.behaviour == nil) {
        if (callback) {
            callback(NO,@"用户为空");
        }
        NSLog(@"Yodo1AntiAddiction call offline, failed, sessionid is null");
        return;
    }
    if ([self.behaviour.sessionId isEqualToString:@""]) {
        if (callback) {
            callback(NO,@"sessionId为空");
        }
        NSLog(@"Yodo1AntiAddiction call offline, failed, sessionid is null");
        return;
    }
    
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    if (!user|| !user.yid || [user.yid isEqualToString:@""]) {
        callback(NO,@"请先登录并获取实名信息后重试");
        return;
    }
    __weak __typeof(self)weakSelf = self;
    self.behaviour.yid = user.yid;
    self.behaviour.uid = user.uid;
    self.behaviour.behaviorType = 0;
    self.behaviour.userType = user.certificationStatus == UserCertificationStatusNot ? 2 : 1;//2 是游客
    self.behaviour.happenTimestamp = [Yodo1AntiAddictionTimeManager.manager getNowTime];
    self.behaviour.sessionId = self.behaviour.sessionId;
    self.behaviour.deviceId = Yodo1Tool.shared.keychainDeviceId;
    
    [self reportCNUserBehavior:self.behaviour callback:^(int code, id response) {
        NSLog(@"user offline, reportBehaviour content:%@",response);
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:response];
        if (code == 200) {
            if (res.success && res.data) {
                weakSelf.behaviour.sessionId = @"";
                callback(YES,res.message);
            }
        } else {
            //保存未成功的
            [weakSelf update:weakSelf.behaviour];
            callback(NO,@"下线请求失败，请检查网络情况");
        }
        weakSelf.isOnline = NO;
    }];
}

///上报时应整理之前未上报的下线行为。
- (void)reportBeforeOfflineBehaviour:(Yodo1AntiAddictionBehaviour*)behaviour
                            callback:(OnBehaviourResult)callback {
    Yodo1AntiAddictionBehaviour* beforeBehaviour = [self query:behaviour.uid yid:behaviour.yid];
    if(beforeBehaviour == nil){
        callback(YES,@"");
        return;
    }
    
    if ([beforeBehaviour.sessionId isEqualToString:@""]) {
        [self delete:beforeBehaviour.sessionId];
        callback(YES,@"");
        return;
    }
    
    [self reportCNUserBehavior:beforeBehaviour callback:^(int code, id response) {
        if (code == 200) {
            callback(YES,@"");
        } else {
            callback(NO,@"请求失败，请检查网络情况");
        }
    }];
}

///hyx 上报已玩时间, 成年用户不需要上报 /ais/time/reportPlayingTime
/// 上报用户行为
- (void)reportCNUserBehavior:(Yodo1AntiAddictionBehaviour*)behaviour
                    callback:(OnBehaviourCallback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"happenTimestamp"] = [NSNumber numberWithInteger:behaviour.happenTimestamp];
    parameters[@"deviceId"] = [Yodo1AntiAddictionUtils md5String:behaviour.deviceId];
    parameters[@"sessionId"] = behaviour.sessionId;
    parameters[@"behaviorType"] = [NSNumber numberWithInteger:behaviour.behaviorType];
    parameters[@"userType"] = [NSNumber numberWithInteger:behaviour.userType];
    
    NSLog(@"parameters:%@",parameters);
    
    [[Yodo1AntiAddictionNet manager] POST:@"behavior/info" parameters:parameters success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        if (res.success && res.data) {
            callback((int)res.code,data);
        }else{
            callback(-1,@"");
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (callback) {
            callback(-100,error.localizedDescription);
        }
    }];
}

- (BOOL)isChineseMainland {
    if (!self.isChina) {//大陆IP
        return NO;
    }
    if (![Yodo1Tool.shared.language isEqualToString:@"zh-Hans"]) {//简体中文
        return NO;
    }
    return YES;
}

#pragma mark - 数据库操作
- (Yodo1AntiAddictionBehaviour *)query:(NSString *)uid yid:(NSString *)yid {
    FMResultSet *result = [[Yodo1AntiAddictionDatabase shared] query:BEHAVIOUR_TABLE projects:nil where:@"uid = ? AND yid = ?" args:@[uid,yid] order:nil];
    
    if ([result next]) {
        return [Yodo1AntiAddictionBehaviour yodo1_modelWithDictionary:result.resultDictionary];
    }
    return nil;
}

- (BOOL)insert:(Yodo1AntiAddictionBehaviour *)user {
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    if (user.uid) content[@"uid"] = user.uid;
    if (user.yid) content[@"yid"] = user.yid;
    content[@"sessionId"] = user.sessionId;
    content[@"deviceId"] = user.deviceId;
    content[@"happenTimestamp"] = @(user.happenTimestamp);
    content[@"behaviorType"] = @(user.behaviorType);
    content[@"userType"] = @(user.userType);
    return [[Yodo1AntiAddictionDatabase shared] insertInto:BEHAVIOUR_TABLE content:content];
}

- (BOOL)update:(Yodo1AntiAddictionBehaviour *)user {
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    if (user.uid) content[@"uid"] = user.uid;
    if (user.yid) content[@"yid"] = user.yid;
    content[@"sessionId"] = user.sessionId;
    content[@"deviceId"] = user.deviceId;
    content[@"happenTimestamp"] = @(user.happenTimestamp);
    content[@"behaviorType"] = @(user.behaviorType);
    content[@"userType"] = @(user.userType);
    return [[Yodo1AntiAddictionDatabase shared] update:BEHAVIOUR_TABLE content:content where:@"sessionId = ?" args:@[user.sessionId]];
}

- (BOOL)delete:(NSString *)sessionId {
    return [[Yodo1AntiAddictionDatabase shared] deleteFrom:BEHAVIOUR_TABLE where:@"sessionId = ?" args:@[sessionId]];
}

@end
