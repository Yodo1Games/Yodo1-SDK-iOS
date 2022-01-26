//
//  OpenSuitAnalyticsAdapterUmeng.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "OpenSuitAnalyticsAdapterFirebase.h"
#import "OpenSuitAnalyticsManager.h"
#import "Yodo1Registry.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yd1OnlineParameter.h"
#import "Yodo1Tool+Commons.h"
#import "Firebase.h"

@implementation OpenSuitAnalyticsAdapterFirebase
{

}

+ (OpenSuitAnalyticsType)analyticsType
{
    return OpenSuitAnalyticsTypeFirebase;
}

+ (void)load
{
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (id)initWithAnalytics:(OpenSuitAnalyticsInitConfig *)initConfig
{
    self = [super init];
    if (self) {
        [FIRApp configure];
    }
    return self;
}

- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{

}

- (void)startLevelAnalytics:(NSString*)level
{

}

- (void)finishLevelAnalytics:(NSString*)level
{

}

- (void)failLevelAnalytics:(NSString*)level  failedCause:(NSString*)cause
{
    
}

- (void)userLevelIdAnalytics:(int)level
{
    
}

- (void)dealloc
{
    
}

@end
