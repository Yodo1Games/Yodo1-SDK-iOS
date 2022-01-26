//
//  OpenSuitAnalyticsAdapterUmeng.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "OpenSuitAnalyticsAdapterUmeng.h"
#import <UMCommon/UMCommon.h>
#import <UMAnalyticsGame/MobClickGameAnalytics.h>
#import <UMCommon/MobClick.h>
#import "OpenSuitAnalyticsManager.h"
#import "Yodo1Registry.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yd1OnlineParameter.h"
#import "Yodo1Tool+Commons.h"

NSString* const OPENSUIT_ANALYTICS_UMENG_APPKEY  = @"UmengAnalytics";
NSString* const kOpenSuitChargeRequstAnalytics = @"kChargeRequstAnalytics";

@implementation OpenSuitAnalyticsAdapterUmeng
{
    double _currencyAmount;//现金金额
    double _virtualCurrencyAmount;//虚拟币金额
    NSString* _iapId;//物品id
    // BOOL isUSOrIN;
}

+ (OpenSuitAnalyticsType)analyticsType
{
    return OpenSuitAnalyticsTypeUmeng;
}

+ (void)load
{
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (id)initWithAnalytics:(OpenSuitAnalyticsInitConfig *)initConfig
{
    self = [super init];
    if (self) {
        //判断是否是Mas SDK
        // if ([Yd1OnlineParameter.shared.publishType hasPrefix:@"mas_"]) {
        //     NSString* umengAppKey = @"";
        //     NSString* umengEnableLog = @"off";
        //     umengAppKey = [Yd1OnlineParameter.shared stringConfigWithKey:@"UMENG_APPKEY" defaultValue:@""];
        //     umengEnableLog = [Yd1OnlineParameter.shared stringConfigWithKey:@"UMENG_LOG_ENABLED" defaultValue:umengEnableLog];
            
        //     BOOL isLogEnabled = [umengEnableLog isEqualToString:@"on"]?YES:NO;
        //     //美国 US 印度 IN
        //     // && [[Yodo1Tool.shared language]isEqualToString:@"en"]
        //     //&& [[Yodo1Tool.shared language]isEqualToString:@"hi"]))
        //     if (([[Yodo1Tool.shared countryCode]isEqualToString:@"US"])
        //         ||([[Yodo1Tool.shared countryCode]isEqualToString:@"IN"] )) {
        //         //不初始化
        //         isUSOrIN = true;
        //     } else {
        //         if (![umengAppKey isEqualToString:@""]) {
        //             [UMConfigure setLogEnabled:isLogEnabled];
        //             [UMConfigure initWithAppkey:umengAppKey channel:@"AppStore"];
        //         }
        //         isUSOrIN = false;
        //     }
        // } else {
    #ifdef DEBUG
            [UMConfigure setLogEnabled:YES];
    #endif
            NSString* appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_UMENG_APPKEY];
            NSAssert(appKey != nil, @"友盟 appKey 没有设置");
            [UMConfigure initWithAppkey:appKey channel:@"AppStore"];
        // }
    }
    return self;
}

- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{
    // if (isUSOrIN) {
    //     return;
    // }
    if (eventData) {
        [MobClick event:eventName attributes:eventData];
    }
}

- (void)startLevelAnalytics:(NSString*)level
{
    // if (isUSOrIN) {
    //     return;
    // }
    if (level) {
        [MobClickGameAnalytics startLevel:level];
    }
}

- (void)finishLevelAnalytics:(NSString*)level
{
    // if (isUSOrIN) {
    //     return;
    // }
    if (level) {
        [MobClickGameAnalytics finishLevel:level];
    }
}

- (void)failLevelAnalytics:(NSString*)level  failedCause:(NSString*)cause
{
    // if (isUSOrIN) {
    //     return;
    // }
    if (level) {
        [MobClickGameAnalytics failLevel:level];
    }
}

- (void)userLevelIdAnalytics:(int)level
{
    // if (isUSOrIN) {
    //     return;
    // }
    [MobClickGameAnalytics setUserLevelId:level];
}

//虚拟货币请求
- (void)chargeRequstAnalytics:(NSString*)orderId
                        iapId:(NSString*)iapId
               currencyAmount:(double)currencyAmount
                 currencyType:(NSString *)currencyType
        virtualCurrencyAmount:(double)virtualCurrencyAmount
                  paymentType:(NSString *)paymentType
{
    // if (isUSOrIN) {
    //     return;
    // }
    _currencyAmount = currencyAmount;
    _virtualCurrencyAmount = virtualCurrencyAmount;
    _iapId = iapId;
    
    if (orderId) {
        NSDictionary*dic1 = @{orderId:[NSNumber numberWithDouble:currencyAmount]};
        NSDictionary*dic2 = @{orderId:[NSNumber numberWithDouble:virtualCurrencyAmount]};
        NSDictionary*dic3 = @{orderId:iapId==nil?@"":iapId};
        NSArray* arr = @[dic1,dic2,dic3];
        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:kOpenSuitChargeRequstAnalytics];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    NSString* userId = [Yodo1Commons idfvString];
    NSString* amount = [NSString stringWithFormat:@"%f",virtualCurrencyAmount];
    [MobClick event:@"__submit_payment" attributes:@{@"userid":userId,@"orderid":orderId,@"item":iapId,@"amount":amount}];
}

//虚拟货币交易成功
- (void)chargeSuccessAnalytics:(NSString *)orderId source:(int)source
{
    // if (isUSOrIN) {
    //     return;
    // }
    if (orderId) {
        NSArray* arr = [[NSUserDefaults standardUserDefaults] objectForKey:kOpenSuitChargeRequstAnalytics];
        if ([arr count] >0) {
            for (int i = 0; i<[arr count]; i++) {
                NSDictionary* dic = [arr objectAtIndex:i];
                if ([[dic allKeys]containsObject:orderId]) {
                    if (i==0) {
                        _currencyAmount = [[dic objectForKey:orderId]doubleValue];
                    }else if(i==1){
                        _virtualCurrencyAmount = [[dic objectForKey:orderId]doubleValue];
                    }else if (i==2){
                        _iapId = (NSString*)[dic objectForKey:orderId];
                    }
                }
            }
        }
        
        [MobClickGameAnalytics pay:_currencyAmount source:0 coin:_virtualCurrencyAmount];
        NSString* userId = [Yodo1Commons idfvString];
        NSString* amount = [NSString stringWithFormat:@"%f",_virtualCurrencyAmount];
        [MobClick event:@"__finish_payment"
             attributes:@{@"userid":(userId?userId:@""),@"orderid":orderId,@"item":(_iapId?_iapId:@""),@"amount":(amount?amount:@"")}];
    }
}

//玩家获虚拟币奖励
- (void)rewardAnalytics:(double)virtualCurrencyAmount reason:(NSString *)reason source:(int)source
{
    // if (isUSOrIN) {
    //     return;
    // }
    [MobClickGameAnalytics bonus:virtualCurrencyAmount source:0];
}

//玩家支付货币购买道具.
- (void)purchaseAnalytics:(NSString *)item itemNumber:(int)number priceInVirtualCurrency:(double)price
{
    // if (isUSOrIN) {
    //     return;
    // }
    [MobClickGameAnalytics buy:item amount:number price:price];
}

//道具消耗统计
- (void)useAnalytics:(NSString *)item amount:(int)amount price:(double)price
{
    // if (isUSOrIN) {
    //     return;
    // }
    [MobClickGameAnalytics use:item amount:amount price:price];
}

- (void)beginEvent:(NSString *)eventId {
    // if (isUSOrIN) {
    //     return;
    // }
    [MobClick beginEvent:eventId];
}

- (void)endEvent:(NSString *)eventId {
    // if (isUSOrIN) {
    //     return;
    // }
    [MobClick endEvent:eventId];
}

#pragma mark- DplusMobClick

- (void)track:(NSString *)eventName
{
#ifdef DEBUG
    NSLog(@"track deprecated!");
#endif
}

- (void)track:(NSString *)eventName property:(NSDictionary *) property
{
#ifdef DEBUG
    NSLog(@"track of property deprecated!");
#endif
}

- (void)registerSuperProperty:(NSDictionary *)property
{
#ifdef DEBUG
    NSLog(@"registerSuperProperty deprecated!");
#endif
}

- (void)unregisterSuperProperty:(NSString *)propertyName
{
#ifdef DEBUG
    NSLog(@"unregisterSuperProperty deprecated!");
#endif
}

- (NSString *)getSuperProperty:(NSString *)propertyName
{
#ifdef DEBUG
    NSLog(@"getSuperProperty deprecated!");
#endif
    return @"";
}

- (NSDictionary *)getSuperProperties
{
#ifdef DEBUG
    NSLog(@"getSuperProperties deprecated!");
#endif
    return @{};
}

- (void)clearSuperProperties
{
#ifdef DEBUG
    NSLog(@"clearSuperProperties deprecated!");
#endif
}

- (void)dealloc
{
    
}

@end
