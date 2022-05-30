//
//  AnalyticsAdapter.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "AnalyticsAdapter.h"


@implementation AnalyticsAdapter

- (id)initWithAnalytics:(AnalyticsInitConfig*)initConfig
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData{}

- (void)eventAppsFlyerAnalyticsWithName:(NSString *)eventName
                       eventData:(NSDictionary *)eventData{}

- (void)startLevelAnalytics:(NSString*)level{}

- (void)finishLevelAnalytics:(NSString*)level{}

- (void)failLevelAnalytics:(NSString*)level
               failedCause:(NSString*)cause{}

- (void)userLevelIdAnalytics:(int)level{}

- (void)chargeRequstAnalytics:(NSString*)orderId
                        iapId:(NSString*)iapId
               currencyAmount:(double)currencyAmount
                 currencyType:(NSString *)currencyType
        virtualCurrencyAmount:(double)virtualCurrencyAmount
                  paymentType:(NSString *)paymentType{}

- (void)chargeSuccessAnalytics:(NSString *)orderId
                        source:(int)source{}

- (void)rewardAnalytics:(double)virtualCurrencyAmount
                 reason:(NSString *)reason
                 source:(int)source{}

- (void)purchaseAnalytics:(NSString *)item
               itemNumber:(int)number
   priceInVirtualCurrency:(double)price{}

- (void)useAnalytics:(NSString *)item
              amount:(int)amount
               price:(double)price{}

- (void)track:(NSString *)eventName
     property:(NSDictionary *) property{}

- (void)registerSuperProperty:(NSDictionary *)property{}

- (void)unregisterSuperProperty:(NSString *)propertyName{}

- (NSDictionary *)getSuperProperties{return nil;}

- (void)clearSuperProperties{}

- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId{}

/**
 *  AppsFlyer Apple 内付费使用自定义事件上报
 */
- (void)eventAndTrackInAppPurchase:(NSString*)revenue
                          currency:(NSString*)currency
                          quantity:(NSString*)quantity
                         contentId:(NSString*)contentId
                         receiptId:(NSString*)receiptId{}

- (void)setThinkingDataAccountId:(NSString *)accountId {}
- (void)setAppsFlyerCustomUserId:(NSString *)userId {}


@end
