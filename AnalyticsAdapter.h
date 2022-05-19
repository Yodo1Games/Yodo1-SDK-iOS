//
//  AnalyticsAdapter.h
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1AnalyticsManager.h"

@interface AnalyticsAdapter : NSObject

- (id)initWithAnalytics:(AnalyticsInitConfig*)initConfig;

- (void)eventWithAnalyticsEventName:(NSString*)eventName
                          eventData:(NSDictionary*)eventData;

//AppsFlyer Event
- (void)eventAdAnalyticsWithName:(NSString *)eventName
                       eventData:(NSDictionary *)eventData;

- (void)startLevelAnalytics:(NSString*)level;

- (void)finishLevelAnalytics:(NSString*)level;

- (void)failLevelAnalytics:(NSString*)level
               failedCause:(NSString*)cause;

- (void)userLevelIdAnalytics:(int)level;

- (void)chargeRequstAnalytics:(NSString*)orderId
                        iapId:(NSString*)iapId
               currencyAmount:(double)currencyAmount
                 currencyType:(NSString *)currencyType
        virtualCurrencyAmount:(double)virtualCurrencyAmount
                  paymentType:(NSString *)paymentType;

- (void)chargeSuccessAnalytics:(NSString *)orderId
                        source:(int)source;

- (void)rewardAnalytics:(double)virtualCurrencyAmount
                 reason:(NSString *)reason
                 source:(int)source;

- (void)purchaseAnalytics:(NSString *)item
               itemNumber:(int)number
   priceInVirtualCurrency:(double)price;

- (void)useAnalytics:(NSString *)item
              amount:(int)amount
               price:(double)price;

- (void)beginEvent:(NSString *)eventId;

- (void)endEvent:(NSString *)eventId;

- (void)track:(NSString *)eventName;

- (void)track:(NSString *)eventName
     property:(NSDictionary *) property;

- (void)registerSuperProperty:(NSDictionary *)property;

- (void)unregisterSuperProperty:(NSString *)propertyName;

- (NSDictionary *)getSuperProperties;

- (void)clearSuperProperties;

//AppsFlyer
- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId;

@end
