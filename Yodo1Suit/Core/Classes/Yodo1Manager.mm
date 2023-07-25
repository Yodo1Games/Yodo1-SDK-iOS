//
//  Yodo1Manager.m
//  localization_sdk_sample
//
//  Created by shon wang on 13-8-13.
//  Copyright (c) 2013年 游道易. All rights reserved.
//

#import "Yodo1Manager.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1UnityTool.h"
#import "Yd1OnlineParameter.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1AFHTTPSessionManager.h"

#import "Yodo1AnalyticsManager.h"

#ifdef YODO1_UCCENTER
#import "Yodo1PurchaseManager.h"
#endif

#define Yodo1Debug [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] integerValue]

@implementation SDKConfig

@end

static BOOL isInitialized = false;

@interface Yodo1Manager()

@end

@implementation Yodo1Manager

+ (Yodo1Manager *)shared {
    static Yodo1Manager* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1Manager alloc] init];
    });
    return _instance;
}

- (void)initWithAppKey:(NSString *)appKey {
    SDKConfig* config = [[SDKConfig alloc] init];
    config.appKey = appKey;
    [self initWithConfig:config];
}

- (void)initWithConfig:(SDKConfig*)sdkConfig {
    self.config = sdkConfig;
    if (self.config == nil) {
        YD1LOG(@"[Yodo1 SDK] Failed to initialize SDK with nil config");
        return;
    }
    NSAssert(self.config.appKey != nil, @"appKey is not set!");
    
    if (self.config.appKey == nil || self.config.appKey.length <= 0) {
        YD1LOG(@"[Yodo1 SDK] Failed to initialize SDK with invalid config.appKey");
        return;
    }
    
    if (isInitialized) {
        YD1LOG(@"[Yodo1 SDK] has already been initialized! && Appkey = %@", self.config.appKey);
        return;
    }
    isInitialized = YES;
    
    //初始化在线参数
    [Yd1OnlineParameter.shared initWithAppKey:self.config.appKey channelId:Yodo1Tool.shared.publishChannelCodeValue];
    
    //初始化统计SDK
    AnalyticsInitConfig* analyticsConfig = [[AnalyticsInitConfig alloc] init];
    analyticsConfig.gameKey = self.config.appKey;
    analyticsConfig.debugEnabled = [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] boolValue];
    //    analyticsConfig.appsflyerCustomUserId = self.config.appsflyerCustomUserId;
    [[Yodo1AnalyticsManager sharedInstance] initializeWithConfig:analyticsConfig];
    
    [[Yodo1UCenter shared] init:self.config.appKey regionCode:self.config.regionCode];

#ifdef YODO1_UCCENTER
    //初始化应用内购买
    [Yodo1PurchaseManager.shared init:self.config.appKey regionCode:self.config.regionCode];
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:kYodo1OnlineConfigFinishedNotification
                                                 object:nil];
}

/**
 * 激活码/优惠券
 */
- (void)verifyWithActivationCode:(NSString *)activationCode
                        callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSDictionary* _Nullable error))callback {
    
    if (!isInitialized) {
        callback(false,@{}, @{@"error":@"The SDK is not initialized"});
        return;
    }
    
    if (!activationCode || activationCode.length < 1) {
        callback(false,@{}, @{@"error":@"code is empty!"});
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]init];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString *urlString = [NSString stringWithFormat:@"https://activationcode.yodo1api.com/activationcode/activateWithReward?game_appkey=%@&channel_code=%@&activation_code=%@&dev_id=%@",
                           self.config.appKey, Yodo1Tool.shared.paymentChannelCodeValue, activationCode, Yd1OpsTools.keychainDeviceId];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode] intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if (errorCode == 0) {
            callback(true,response,NULL);
        } else {
            callback(false,@{},response);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(false,@{},@{@"error": error.localizedDescription});
    }];
    
}


@end
