//
//  Yodo1AntiAddictionRulesManager.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/4.
//

#import "Yodo1AntiAddictionRulesManager.h"
#import "Yodo1AntiAddictionNet.h"
#import "Yodo1Model.h"
#import "Yodo1Tool.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AntiAddictionUtils.h"
#import "Yodo1AntiAddictionLog.h"

#define kAntiAddictionRules @"Yodo1AntiAddictionRules" // 规则
#define kAntiAddictionHolidays @"Yodo1AntiAddictionHolidays" // 节假日列表
#define kAntiAddictionHolidayRules @"Yodo1AntiAddictionHolidayRules" // 节假日规则

@implementation Yodo1AntiAddictionRulesManager

+ (Yodo1AntiAddictionRulesManager *)manager {
    static Yodo1AntiAddictionRulesManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1AntiAddictionRulesManager alloc] init];
    });
    return sharedInstance;
}

- (void)requestRules:(void (^ _Nullable)(id _Nullable))success failure:(void (^ _Nullable)(NSError * _Nonnull))failure {
    
    _currentRules = (Yodo1AntiAddictionRules *)[Yd1OpsTools.cached objectForKey:kAntiAddictionRules];
    if (!_currentRules) {
        NSString *path = [[Yodo1AntiAddictionUtils bundle] pathForResource:@"Yodo1AntiAddictionRules" ofType:@"plist"];
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
        _currentRules = [Yodo1AntiAddictionRules yodo1_modelWithDictionary:data];
    }
    
    [[Yodo1AntiAddictionNet manager] GET:@"config/info" parameters:nil success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        Yodo1AntiAddictionRules *rules = [Yodo1AntiAddictionRules yodo1_modelWithJSON:res.data];
        if (rules) {
            NSString * st =  [Yodo1AntiAddictionUtils stringWithJSONObject:res.data error:nil];
            Yodo1AntiAddictionLog(@"获取规则 - %@ \n",st);
            self->_currentRules = rules;
            [Yd1OpsTools.cached setObject:rules forKey:kAntiAddictionRules];
        }
        if (success) {
            success(rules);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 节假日规则
- (void)requestHolidayRules:(void (^ _Nullable)(id _Nullable))success failure:(void (^ _Nullable)(NSError * _Nonnull))failure {
    
    _holidayRules = (Yodo1AntiAddictionHolidayRules *)[Yd1OpsTools.cached objectForKey:kAntiAddictionHolidayRules];
    if (!_holidayRules) {
        NSString *path = [[Yodo1AntiAddictionUtils bundle] pathForResource:@"Yodo1AntiAddictionHolidayRules" ofType:@"plist"];
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
        _holidayRules = [Yodo1AntiAddictionHolidayRules yodo1_modelWithDictionary:data];
    }
    [[Yodo1AntiAddictionNet manager] GET:@"config/holiday" parameters:nil success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        if (res.success && res.data) {
            Yodo1AntiAddictionHolidayRules *rules = [Yodo1AntiAddictionHolidayRules yodo1_modelWithJSON:res.data];
            if (rules) {
                [Yd1OpsTools.cached setObject:rules forKey:kAntiAddictionHolidayRules];
            }
            Yodo1AntiAddictionLog(@"获取节假日规则 - %@ \n", [Yodo1AntiAddictionUtils stringWithJSONObject:res.data error:nil]);
        }
        if (success) {
            success(res.data);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


/// 节假日列表
- (void)requestHolidayList:(void (^ _Nullable)(id _Nullable))success failure:(void (^ _Nullable)(NSError * _Nonnull))failure {
    
    _holidays = (NSArray *)[Yd1OpsTools.cached objectForKey:kAntiAddictionHolidays];
    if (!_holidays) {
        NSString *path = [[Yodo1AntiAddictionUtils bundle] pathForResource:@"Yodo1AntiAddictionHolidays" ofType:@"plist"];
        _holidays = [NSArray arrayWithContentsOfFile:path];
    }
    
    [[Yodo1AntiAddictionNet manager] GET:@"config/holidays" parameters:nil success:^(NSURLSessionDataTask *task, id data) {
        Yodo1AntiAddictionResponse *res = [Yodo1AntiAddictionResponse yodo1_modelWithJSON:data];
        if (res.success && res.data) {
            NSArray *records = res.data[@"records"];
            if (records) {
                [Yd1OpsTools.cached setObject:records forKey:kAntiAddictionHolidays];
                Yodo1AntiAddictionLog(@"获取节假日列表 - %@", records);
            }
        }
        if (success) {
            success(res.data);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
