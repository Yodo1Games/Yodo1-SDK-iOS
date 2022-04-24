//
//  Yodo1AntiAddictionUserManager.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/4.
//

#import "Yodo1AntiAddictionUserManager.h"
#import "Yodo1Model.h"
#import "Yodo1YYCache.h"
#import "Yodo1Tool.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yd1UCenter.h"
#import "Yd1UCenterManager.h"
#import "Yodo1AntiAddictionDatabase.h"
#import "Yodo1AntiAddictionNet.h"
#import "Yodo1AntiAddictionHelper.h"
#import "Yodo1AntiAddictionUtils.h"

#define TABLE_NAME NSStringFromClass([Yodo1AntiAddictionUser class])

@implementation Yodo1AntiAddictionUserManager

+ (Yodo1AntiAddictionUserManager *)manager {
    static Yodo1AntiAddictionUserManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1AntiAddictionUserManager alloc] init];
    });
    return sharedInstance;
}

- (BOOL)isGuestUser {
    return _currentUser.certificationStatus == UserCertificationStatusNot || _currentUser.age == -1;
}

#pragma mark - 网络请求
- (void)get:(NSString *)accountId success:(void (^)(Yodo1AntiAddictionUser *))success failure:(void (^)(NSError *))failure {
    
    // 查询已存在的用户信息，如果没有则保存一条
    Yodo1AntiAddictionUser *antiUser = [self query:accountId];
    if (!antiUser) {
        antiUser = [[Yodo1AntiAddictionUser alloc] init];
        antiUser.accountId = accountId;
        antiUser.certificationStatus = UserCertificationStatusNot;
        [self insert:antiUser];
    }
    
    BOOL isLogined = [Yd1UCenterManager shared].isLogined;
    YD1User *yd1User = [Yd1UCenterManager shared].user;
    // 如果UserCenter已登录
    if (isLogined && yd1User && [yd1User.yid isEqualToString:antiUser.yid]) {
        antiUser.yid = yd1User.yid;
        antiUser.uid = yd1User.uid;
        [self update:antiUser];
    }
    // 如果要登录的用户和当前登录的用户不一致，则停止计时
    if (![antiUser isEqual:_currentUser]) {
        [[Yodo1AntiAddictionHelper shared] stopTimer];
    }
    
    if (antiUser.yid) {
        [self getCertificationInfo:antiUser success:success failure:failure];
    } else {
        [[Yd1UCenter shared] deviceLoginWithPlayerId:antiUser.accountId callback:^(YD1User *user, NSError *error) {
#ifdef DEBUG
            NSLog(@"-------------user of info---------------------");
            NSLog(@"accountId:%@",antiUser.accountId);
            NSLog(@"yid:%@",user.yid);
            NSLog(@"uid:%@",user.uid);
            NSLog(@"ucuid:%@",user.ucuid);
            NSLog(@"-------------user of info---------------------");
            
#endif
            if (!error) {
                
                [Yd1UCenterManager shared].user = user;
                [Yd1UCenterManager shared].isLogined = YES;
                [Yd1OpsTools.cached setObject:user forKey:@"yd1User"];
                antiUser.yid = user.yid;
                antiUser.uid = user.uid;
                [self getCertificationInfo:antiUser success:success failure:failure];
            } else {
                if (failure) {
                    failure(error);
                }
            }
        }];
    }
}

- (void)getCertificationInfo:(Yodo1AntiAddictionUser *)user success:(void (^)(Yodo1AntiAddictionUser *))success failure:(void (^)(NSError *))failure {
    
    _currentUser = user;
    [[Yodo1AntiAddictionNet manager] GET:@"certification/info" parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:response];
        id data = res.data;
        if (res.success && data) {
            user.age = [data[@"age"] integerValue];
            user.inWhiteList = [data[@"hasInWhiteList"] boolValue];
            user.certificationStatus = [data[@"status"] integerValue];
            user.certificationTime = [NSDate date].timeIntervalSince1970;
            [self update:user];
            if (success) {
                success(user);
            }
        } else {
            if (success) {
                success(user);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (success) {
            success(user);
        }
    }];
}

- (void)post:(NSString *)name identify:(NSString *)identify success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    
    [[Yodo1AntiAddictionNet manager] POST:@"certification/info" parameters:@{@"name": name, @"idCard" : identify} success:^(NSURLSessionDataTask *task, id response) {
        Yodo1AntiAddictionUser *user = self.currentUser;
        
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:response];
        id data = res.data;
        if (res.success && data) {
            NSInteger status = [data[@"status"] integerValue];
            if (status >= 0) {
                user.age = [data[@"age"] integerValue];
                user.inWhiteList = [data[@"hasInWhiteList"] boolValue];
                user.certificationStatus = status;
                user.certificationTime = [NSDate date].timeIntervalSince1970;
                [self update:user];
            }
            if (success) {
                success(data);
            }
        } else {
            if (failure) {
                failure([Yodo1AntiAddictionUtils errorWithCode:res.code msg:res.message]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - 数据库操作
- (Yodo1AntiAddictionUser *)query:(NSString *)accountId {
    Yodo1FMResultSet *result = [[Yodo1AntiAddictionDatabase shared] query:TABLE_NAME projects:nil where:@"accountId = ?" args:@[accountId] order:nil];
    
    if ([result next]) {
        return [Yodo1AntiAddictionUser yodo1_modelWithDictionary:result.resultDictionary];
    }
    return nil;
}

- (BOOL)insert:(Yodo1AntiAddictionUser *)user {
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    content[@"accountId"] = user.accountId;
    if (user.uid) content[@"uid"] = user.uid;
    if (user.yid) content[@"yid"] = user.yid;
    content[@"age"] = @(user.age);
    content[@"inWhiteList"] = @(user.inWhiteList);
    content[@"certificationStatus"] = @(user.certificationStatus);
    content[@"certificationTime"] = @(user.certificationTime);
    return [[Yodo1AntiAddictionDatabase shared] insertInto:TABLE_NAME content:content];
}

- (BOOL)update:(Yodo1AntiAddictionUser *)user {
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    if (user.uid) content[@"uid"] = user.uid;
    if (user.yid) content[@"yid"] = user.yid;
    content[@"age"] = @(user.age);
    content[@"inWhiteList"] = @(user.inWhiteList);
    content[@"certificationStatus"] = @(user.certificationStatus);
    content[@"certificationTime"] = @(user.certificationTime);
    return [[Yodo1AntiAddictionDatabase shared] update:TABLE_NAME content:content where:@"accountId = ?" args:@[user.accountId]];
}

- (BOOL)delete:(NSString *)accountId {
    return [[Yodo1AntiAddictionDatabase shared] deleteFrom:TABLE_NAME where:@"accountId = ?" args:@[accountId]];
}

@end
