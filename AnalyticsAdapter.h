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
- (void)eventAppsFlyerAnalyticsWithName:(NSString *)eventName
                       eventData:(NSDictionary *)eventData;

//AppsFlyer
- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId;

/**
 *  AppsFlyer Apple 内付费使用自定义事件上报
 */
- (void)eventAndTrackInAppPurchase:(NSString*)revenue
                          currency:(NSString*)currency
                          quantity:(NSString*)quantity
                         contentId:(NSString*)contentId
                         receiptId:(NSString*)receiptId;

/**
 *  AppsFlyer and ThinkingData set user id
 */
- (void)login:(NSString *)userId;

@end
