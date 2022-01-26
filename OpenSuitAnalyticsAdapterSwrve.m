//
//  OpenSuitAnalyticsAdapterSwrve.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "OpenSuitAnalyticsAdapterSwrve.h"
#import "Yodo1Registry.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "SwrveSDK.h"

NSString* const OPENSUIT_ANALYTICS_SWRVE_APPID       = @"SwrveAppId";
NSString* const OPENSUIT_ANALYTICS_SWRVE_API_KEY     = @"SwrveApiKey";

@implementation OpenSuitAnalyticsAdapterSwrve

+ (OpenSuitAnalyticsType)analyticsType {
    return OpenSuitAnalyticsTypeSwrve;
}

+ (void)load
{
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (id)initWithAnalytics:(OpenSuitAnalyticsInitConfig *)initConfig {
    self = [super init];
    if (self) {
        NSString* appId = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_SWRVE_APPID];
        NSString* apiKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_SWRVE_API_KEY];
        NSAssert(appId != nil||apiKey != nil, @"Swrve Appid或apiKey 没有设置");
        SwrveConfig* config = [[SwrveConfig alloc] init];
        config.stack = SWRVE_STACK_EU;
        [SwrveSDK sharedInstanceWithAppID:[appId intValue] apiKey:apiKey config:config];
        NSString* useId = [SwrveSDK userID];
        if (useId) {
            [[NSUserDefaults standardUserDefaults]setObject:useId forKey:@"YODO1_SWRVE_USEID"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        NSLog(@"Swrve of useId:%@",useId);
    }
    return self;
}

- (void)swrveEventAnalyticsWithName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{
    if (eventData) {
        [SwrveSDK event:eventName payload:eventData];
    } else {
        [SwrveSDK event:eventName];
    }
}

- (void)swrveUserUpdate:(NSDictionary *)eventData {
    int status = [SwrveSDK userUpdate:eventData];
    if (status == SWRVE_SUCCESS) {
#ifdef DEBUG
        NSLog(@"[Yodo1] Swrve User update success！");
#endif
    }else if (status == SWRVE_FAILURE){
#ifdef DEBUG
        NSLog(@"[Yodo1] Swrve User update fail！");
#endif
    }
}

- (void)swrveTransactionProcessed:(SKPaymentTransaction*) transaction
                 productBought:(SKProduct*) product
{
    int status = [SwrveSDK iap:transaction product:product];
    if (status == SWRVE_SUCCESS) {
#ifdef DEBUG
        NSLog(@"[Yodo1] Swrve iap 验证成功！");
#endif
    }else if (status == SWRVE_FAILURE){
#ifdef DEBUG
        NSLog(@"[Yodo1] Swrve iap 验证失败！");
#endif
    }
}

- (void)dealloc {
   
}

@end
