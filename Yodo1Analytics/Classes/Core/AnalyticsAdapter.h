//
//  AnalyticsAdapter.h
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1AnalyticsManager.h"
#import "Yodo1AdRevenue.h"
#import "Yodo1IAPRevenue.h"

#define Y_DEEPLINK_OPEN_URL          @"y_deeplink_open_url"
#define Y_DEEPLINK_USER_ACTIVITY     @"y_deeplink_user_activity"
#define Y_AF_DEEPLINK                @"appsflyer_deeplink"
#define Y_AF_ID                      @"appsflyer_id"
#define Y_DEEPLINK_RESULT            @"y_deeplink_result"

NS_ASSUME_NONNULL_BEGIN

@protocol Yodo1UAAdapterDelegate <NSObject>

- (void)yodo1DeeplinkResult:(NSDictionary *_Nonnull)result;
@end

@interface AnalyticsAdapter : NSObject

@property (nonatomic, weak) id<Yodo1UAAdapterDelegate> delegate;

typedef void (^InviteUrlCallBack) (NSString * _Nullable url, int code, NSString * _Nullable errorMsg);

- (id _Nullable )initWithConfig:(AnalyticsInitConfig* _Nonnull)initConfig;

/// AppsFlyer and ThinkingData set user id
/// - Parameter userId: The unique identifier of the user
- (void)login:(NSString * _Nonnull)userId;


/// Use this method to track an events with multiple values.
/// - Parameters:
///   - eventName: Event name
///   - eventData: Contains dictionary of values for handling by backend
- (void)trackEvent:(NSString * _Nonnull)eventName eventValues:(NSDictionary * _Nullable)eventValues;

#pragma mark - UA in-app events
/// Use this method to track an events with multiple values for AppsFlyer.
/// - Parameters:
///   - eventName: Event name
///   - eventData: Contains dictionary of values for handling by backend
- (void)trackUAEvent:(NSString *_Nonnull)eventName eventValues:(NSDictionary * _Nullable)eventValues;

- (void)trackAdRevenue:(Yodo1AdRevenue*_Nonnull)adRevenue;

- (void)trackIAPRevenue:(Yodo1IAPRevenue*_Nonnull)iapRevenue;

/// To log and validate in app purchases you can call this method from the completeTransaction: method on your `SKPaymentTransactionObserver`.
/// - Parameters:
///   - productIdentifier: The product identifier
///   - price: The product price
///   - currency: The product currency
///   - transactionId: The purchase transaction Id
- (void)validateAndTrackInAppPurchase:(NSString* _Nonnull)productIdentifier
                                price:(NSString* _Nonnull)price
                             currency:(NSString* _Nonnull)currency
                        transactionId:(NSString* _Nonnull)transactionId;


- (void)eventAndTrackInAppPurchase:(NSString* _Nonnull)revenue
                          currency:(NSString* _Nonnull)currency
                          quantity:(NSString* _Nonnull)quantity
                         contentId:(NSString* _Nonnull) contentId
                         receiptId:(NSString* _Nonnull)receiptId;

#pragma mark - Deep Link
- (void)handleOpenUrl:(NSURL * _Nonnull)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *_Nullable)options;
- (void)continueUserActivity:(NSUserActivity * _Nonnull)userActivity;

#pragma mark - User Invite
/**
 *  AppsFlyer User invite attribution
 */
- (void)generateInviteUrlWithLinkGenerator:(NSDictionary * _Nonnull)linkDic CallBack:(InviteUrlCallBack _Nonnull)callBack;

/**
 *  AppsFlyer logInvite AFEventInvite
 */
- (void)logInviteAppsFlyerWithEventData:(NSDictionary * _Nonnull)eventData;

@end

NS_ASSUME_NONNULL_END
