//
//  AnalyticsAdapterThinking.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014 yodo1. All rights reserved.
//

#import <AppTrackingTransparency/AppTrackingTransparency.h>

#import "AnalyticsAdapterThinking.h"
#import "ThinkingAnalyticsSDK.h"
#import "Yodo1AnalyticsManager.h"
#import "Yodo1Registry.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"

#define Yodo1PublishVersion @"6.1.2"
#define Yodo1ThinkingServerUrl @"https://c1.yodo1.com/"

NSString* const YODO1_ANALYTICS_TA_APPKEY       = @"ThinkingAppId";
NSString* const YODO1_ANALYTICS_TA_SERVERURL    = @"ThinkingServerUrl";

@implementation AnalyticsAdapterThinking
{
    double _currencyAmount;//现金金额
    double _virtualCurrencyAmount;//虚拟币金额
    NSString* _iapId;//物品id
}

+ (AnalyticsType)analyticsType
{
    return AnalyticsTypeThinking;
}

+ (void)load
{
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (id)initWithAnalytics:(AnalyticsInitConfig *)initConfig
{
    self = [super init];
    if (self) {
        
        NSString* appId = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_ANALYTICS_TA_APPKEY];
        
        NSAssert(appId != nil, @"Thinking AppId is not set.");
        
        NSString* configURL = Yodo1ThinkingServerUrl;
        
        TDConfig *config = [TDConfig new];
        config.appid = appId;
        config.configureURL = configURL;
        
        [ThinkingAnalyticsSDK startWithConfig:config];
        
        //设置访客ID
        [ThinkingAnalyticsSDK.sharedInstance identify:Yodo1Tool.shared.keychainDeviceId];
        
        NSString* bundleId = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        [ThinkingAnalyticsSDK.sharedInstance user_setOnce:@{@"channel":@"appstore"}];
        [ThinkingAnalyticsSDK.sharedInstance setSuperProperties:@{@"gameKey":[[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"], @"gameBundleId":bundleId, @"publishChannelCode":@"appstore", @"sdkVersion":Yodo1PublishVersion}];
        
        // 自动埋点 关闭
        [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:
        ThinkingAnalyticsEventTypeAppStart |
        ThinkingAnalyticsEventTypeAppEnd |
        ThinkingAnalyticsEventTypeAppViewScreen |
        ThinkingAnalyticsEventTypeAppClick |
        ThinkingAnalyticsEventTypeAppInstall |
        ThinkingAnalyticsEventTypeAppViewCrash
        ];
        
        NSInteger debug = [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] integerValue];
        if (debug) {
            [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
        }
    }
    return self;
}

- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{
    if (eventData) {
        [ThinkingAnalyticsSDK.sharedInstance track:eventName properties:eventData];
    }
}

- (void)dealloc
{
    
}

/**
 *  ThinkingData  set  account id
 */
- (void)login:(NSString *)userId {
    [ThinkingAnalyticsSDK.sharedInstance login:userId];
}

@end
