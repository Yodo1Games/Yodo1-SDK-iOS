//
//  OpenSuitAnalyticsAdapterTalkingData.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "OpenSuitAnalyticsAdapterTalkingData.h"
#import "Yodo1Registry.h"
#import "TalkingDataGA.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"

NSString* const kOpenSuitAnalyticsTallingDataAppKey   =  @"TalkingDataAppId";
NSString* const kOpenSuitAnalyticsChannelId = @"AppStore";

@implementation OpenSuitAnalyticsAdapterTalkingData
{
    TDGAProfile* account;
}

+ (OpenSuitAnalyticsType)analyticsType
{
    return OpenSuitAnalyticsTypeTalkingData;
}

+ (void)load
{
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (id)initWithAnalytics:(OpenSuitAnalyticsInitConfig *)initConfig
{
    self = [super init];
    if (self) {
        NSString* appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:kOpenSuitAnalyticsTallingDataAppKey];
        
        NSAssert(appKey != nil, @"Talking Data appKey 没有设置");
        
        [TalkingDataGA onStart:appKey withChannelId:kOpenSuitAnalyticsChannelId];
        account = [TDGAProfile setProfile:[Yodo1Commons idfvString]];
    }
    return self;
}

/**
 1) NSDictionary的Value目前仅支持字符串（NSString）和数字（NSNumber）类型，
 key类型必须是NSString。如果value为NSString，TalkingData会统计每种value出现的次数；
 如果为NSNumber类型，那么TalkingData会统计value的总和/平均值。
 2）    eventId、Dictionary的key和NSString类型的value，分别最多支持32个字符。
 */
- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{
    if(eventData == nil)NSLog(@"talkingdata 事件统计 eventdata为空，统计不上！");
    [TalkingDataGA onEvent:eventName eventData:eventData];
}

- (void)startLevelAnalytics:(NSString*)level
{
    if (level) {
        [TDGAMission onBegin:level];
    }
}

- (void)finishLevelAnalytics:(NSString*)level
{
    if (level) {
        [TDGAMission onCompleted:level];
    }
}

- (void)failLevelAnalytics:(NSString*)level failedCause:(NSString*)cause
{
    if (level) {
        [TDGAMission onFailed:level failedCause:cause];
    }
}

- (void)userLevelIdAnalytics:(int)level
{
    if (account) {
        [account setLevel:level];
    }else{
        NSLog(@"[-- Yodo1 --] : Talkingdata没设置Account用户");
    }
}

//虚拟货币请求
- (void)chargeRequstAnalytics:(NSString*)orderId
                        iapId:(NSString*)iapId
               currencyAmount:(double)currencyAmount
                 currencyType:(NSString *)currencyType
        virtualCurrencyAmount:(double)virtualCurrencyAmount
                  paymentType:(NSString *)paymentType
{
    //TalkingDataGA
    [TDGAVirtualCurrency onChargeRequst:orderId
                                  iapId:iapId
                         currencyAmount:currencyAmount
                           currencyType:currencyType
                  virtualCurrencyAmount:virtualCurrencyAmount
                            paymentType:kOpenSuitAnalyticsChannelId
     ];
    
}

//虚拟货币充值成功
- (void)chargeSuccessAnalytics:(NSString *)orderId source:(int)source
{
    [TDGAVirtualCurrency onChargeSuccess:orderId];
}

//虚拟货币赠送
- (void)rewardAnalytics:(double)virtualCurrencyAmount reason:(NSString *)reason source:(int)source
{
    [TDGAVirtualCurrency onReward:virtualCurrencyAmount reason:reason];
}

//虚拟物品购买
- (void)purchaseAnalytics:(NSString *)item itemNumber:(int)number priceInVirtualCurrency:(double)price;
{
    [TDGAItem onPurchase:item itemNumber:number priceInVirtualCurrency:price];
}

//虚拟物品消耗
- (void)useAnalytics:(NSString *)item amount:(int)amount price:(double)price
{
    [TDGAItem onUse:item itemNumber:amount];
}

- (void)dealloc
{
}

- (NSString*)talkingDataDeviceId
{
    return [TalkingDataGA getDeviceId];
}

@end
