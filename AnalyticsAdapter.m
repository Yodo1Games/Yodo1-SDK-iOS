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

/**
 *  AppsFlyer and ThinkingData set user id
 */
- (void)login:(NSString *)userId{}

/**
 *  AppsFlyer User invite attribution
 */
- (void)generateInviteUrlWithLinkGenerator:(NSDictionary *)linkDic CallBack:(InviteUrlCallBack)callBack{}

- (void)setDeeplink{}

/**
 *  AppsFlyer logInvite AFEventInvite
 */
- (void)logInviteAppsFlyerWithEventData:(NSDictionary *)eventData{}

@end
