//
//  AnalyticsAdapter.h
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1AnalyticsManager.h"

#define Y_DEEPLINK_OPEN_URL          @"y_deeplink_open_url"
#define Y_DEEPLINK_USER_ACTIVITY     @"y_deeplink_user_activity"
#define Y_AF_DEEPLINK                @"appsflyer_deeplink"
#define Y_AF_ID                      @"appsflyer_id"
#define Y_DEEPLINK_RESULT            @"y_deeplink_result"

@protocol Yodo1AdapterBaseDelegate <NSObject>
//get deeplink result
- (void)getDeeplinkResult:(NSDictionary *)result;
@end

@interface AnalyticsAdapter : NSObject

@property (nonatomic, weak) id<Yodo1AdapterBaseDelegate> delegate;

typedef void (^InviteUrlCallBack) (NSString *url, int code, NSString *errorMsg);

- (id)initWithConfig:(AnalyticsInitConfig*)initConfig;

- (void)track:(NSString*)eventName properties:(NSDictionary*)eventData;

//AppsFlyer Event
- (void)trackAppsFlyer:(NSString *)eventName
            properties:(NSDictionary *)eventData;

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

/**
 *  AppsFlyer User invite attribution
 */
- (void)generateInviteUrlWithLinkGenerator:(NSDictionary *)linkDic CallBack:(InviteUrlCallBack)callBack;

- (void)setDeeplink;

/**
 *  AppsFlyer logInvite AFEventInvite
 */
- (void)logInviteAppsFlyerWithEventData:(NSDictionary *)eventData;

@end
