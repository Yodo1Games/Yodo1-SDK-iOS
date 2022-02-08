//
//  AnalyticsAdapterThinking.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014 yodo1. All rights reserved.
//

#import "AnalyticsAdapterThinking.h"
#import "ThinkingAnalyticsSDK.h"
#import "Yodo1AnalyticsManager.h"
#import "Yodo1Registry.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yd1OnlineParameter.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"

NSString* const YODO1_ANALYTICS_TA_APPKEY       = @"ThinkingAppId";
NSString* const YODO1_ANALYTICS_TA_SERVERURL    = @"ThinkingServerUrl";

@implementation AnalyticsAdapterThinking
{
    double _currencyAmount;//现金金额
    double _virtualCurrencyAmount;//虚拟币金额
    NSString* _iapId;//物品id
    BOOL isThinkingSwitch;
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

        NSNumber* bThinkig = (NSNumber*)[Yodo1Tool.shared.cached objectForKey:@"ThinkingDataSwitch"];
        isThinkingSwitch = [bThinkig boolValue];
        
#ifndef YODO1_ADS
        NSString* appId = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_ANALYTICS_TA_APPKEY];
        NSString* configURL = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_ANALYTICS_TA_SERVERURL];
        
        TDConfig *config = [TDConfig new];
        config.appid = appId;
        config.configureURL = configURL;
        
        [ThinkingAnalyticsSDK startWithConfig:config];
        
        isThinkingSwitch = YES;
#endif
        
#ifdef DEBUG
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
#endif
        
        
    }
    return self;
}

- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{
    if (eventData && isThinkingSwitch) {
        [ThinkingAnalyticsSDK.sharedInstance track:eventName properties:eventData];
    }
}

#pragma mark- DplusMobClick

- (void)track:(NSString *)eventName
{
    if (isThinkingSwitch) {
        [ThinkingAnalyticsSDK.sharedInstance track:eventName];
    }
}

- (void)track:(NSString *)eventName property:(NSDictionary *) property
{
    if (isThinkingSwitch) {
        [ThinkingAnalyticsSDK.sharedInstance track:eventName properties:property];
    }
}

- (void)registerSuperProperty:(NSDictionary *)property
{
    if (isThinkingSwitch) {
        [ThinkingAnalyticsSDK.sharedInstance setSuperProperties:property];
    }
}

- (void)unregisterSuperProperty:(NSString *)propertyName
{
    if (isThinkingSwitch) {
        [ThinkingAnalyticsSDK.sharedInstance unsetSuperProperty:propertyName];
    }
}

- (NSString *)getSuperProperty:(NSString *)propertyName
{
    return @"";
}

- (NSDictionary *)getSuperProperties
{
    return [ThinkingAnalyticsSDK.sharedInstance currentSuperProperties];
}

- (void)clearSuperProperties
{
    [ThinkingAnalyticsSDK.sharedInstance clearSuperProperties];
    
}

- (void)dealloc
{
    
}

@end
