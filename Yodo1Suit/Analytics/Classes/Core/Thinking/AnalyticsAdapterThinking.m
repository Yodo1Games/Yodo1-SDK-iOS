//
//  AnalyticsAdapterThinking.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014 yodo1. All rights reserved.
//

#import "AnalyticsAdapterThinking.h"
#import <ThinkingSDK/ThinkingSDK.h>
#import "Yodo1AnalyticsManager.h"
#import "Yodo1Registry.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"

#define Yodo1ThinkingServerUrl @"https://c1.yodo1.com/"

NSString* const YODO1_THINKING_APP_ID     = @"ThinkingAppId";
NSString* const YODO1_THINKING_SERVER_URL = @"ThinkingServerUrl";

@implementation AnalyticsAdapterThinking

+ (AnalyticsType)analyticsType {
    return AnalyticsTypeThinking;
}

+ (void)load {
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (void)dealloc {
    
}

- (id)initWithConfig:(AnalyticsInitConfig *)initConfig {
    self = [super init];
    if (self) {
        if(initConfig == nil) {
            return self;
        }
        
        if (initConfig.debugEnabled) {
            //Log TAG: [THINKING]
            [TDAnalytics enableLog:YES];
        }
        
        NSString* appId = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_THINKING_APP_ID];
        NSAssert(appId != nil, @"Thinking AppId is not set.");
        
        NSString* configURL = Yodo1ThinkingServerUrl;
        
        TDConfig *tdConfig = [TDConfig new];
        tdConfig.appid = appId;
        tdConfig.serverUrl = configURL;
        
        [TDAnalytics startAnalyticsWithConfig:tdConfig];
        
        //设置访客ID
        [TDAnalytics setDistinctId:Yodo1Tool.shared.keychainDeviceId];
        
        [TDAnalytics setSuperProperties:@{
            @"gameKey":initConfig.gameKey,
            @"device_id":Yodo1Tool.shared.keychainDeviceId,
            @"publishChannelCode":Yodo1Tool.shared.publishChannelCodeValue,
            @"sdkVersion":Yodo1Tool.shared.sdkVersionValue,
            @"channel_code":Yodo1Tool.shared.paymentChannelCodeValue
        }];
        
        [TDAnalytics enableAutoTrack:TDAutoTrackEventTypeAll];
    }
    return self;
}

/// ThinkingData  set  account id
/// - Parameter userId: The unique identifier of the user
- (void)login:(NSString * _Nonnull)userId {
    [TDAnalytics login:userId];//索引存在--重置 索引不存在--设置
    [TDAnalytics userSet:@{@"playerId": userId}];
}

- (void)trackEvent:(NSString * _Nonnull)eventName eventValues:(NSDictionary * _Nullable)eventValues {
    if (eventValues == nil) {
        [TDAnalytics track:eventName];
    } else {
        [TDAnalytics track:eventName properties:eventValues];
    }
}

@end
