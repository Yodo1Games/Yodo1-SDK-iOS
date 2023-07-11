//
//  AnalyticsAdapter.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "AnalyticsAdapter.h"

@implementation AnalyticsAdapter

- (id)initWithConfig:(AnalyticsInitConfig*)initConfig
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)login:(NSString * _Nonnull)userId {}

- (void)trackEvent:(NSString * _Nonnull)eventName eventValues:(NSDictionary * _Nullable)eventValues {}

#pragma mark - UA in-app events

- (void)trackUAEvent:(NSString *_Nonnull)eventName eventValues:(NSDictionary * _Nullable)eventValues {}

- (void)trackAdRevenue:(Yodo1AdRevenue* _Nonnull)adRevenue{}

- (void)trackIAPRevenue:(Yodo1IAPRevenue* _Nonnull)iapRevenue{}

- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId {}

- (void)eventAndTrackInAppPurchase:(NSString*)revenue
                          currency:(NSString*)currency
                          quantity:(NSString*)quantity
                         contentId:(NSString*)contentId
                         receiptId:(NSString*)receiptId {}

#pragma mark - Deep Link

- (void)handleOpenUrl:(NSURL * _Nonnull)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *_Nullable)options {}
- (void)continueUserActivity:(NSUserActivity * _Nonnull)userActivity {}

#pragma mark - User Invite

/**
 *  AppsFlyer User invite attribution
 */
- (void)generateInviteUrlWithLinkGenerator:(NSDictionary *_Nonnull)linkDic CallBack:(InviteUrlCallBack _Nonnull)callBack {}

/**
 *  AppsFlyer logInvite AFEventInvite
 */
- (void)logInviteAppsFlyerWithEventData:(NSDictionary * _Nonnull)eventData {}

@end
