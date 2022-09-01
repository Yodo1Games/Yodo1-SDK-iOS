//
//  Yodo1UAAdapterBase.h
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1UA.h"
#import "Yodo1KeyInfo.h"

#define Yodo1UALOG(fmt, ...) NSLog((@"[Yodo1 UA] %s [Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define Y_UA_AGE_RESTRICTED_USER        @"y_ua_age_restricted_user"
#define Y_UA_HAS_USER_CONSENT           @"y_ua_has_user_consent"
#define Y_UA_DO_NOT_SELL                @"y_ua_do_not_sell"

#define UA_CLASS_TYPE                   @"UA_Type"

#define Y_UA_INAPP_EVENT_PURCHASE       @"y_ua_purchase"

#define Y_UA_INAPP_EVENT_CONTENT_ID     @"y_ua_content_id"
#define Y_UA_INAPP_EVENT_CONTENT_TYPE   @"y_ua_content_type"
#define Y_UA_INAPP_EVENT_REVENUE        @"y_ua_revenue"
#define Y_UA_INAPP_EVENT_CURRENCY       @"y_ua_currency"
#define Y_UA_INAPP_EVENT_QUANTITY       @"y_ua_quantity"
#define Y_UA_INAPP_EVENT_ORDER_ID       @"y_ua_order_id"

#define Y_UA_DEEPLINK_OPEN_URL          @"y_ua_deeplink_open_url"
#define Y_UA_DEEPLINK_USER_ACTIVITY     @"y_ua_deeplink_user_activity"
#define UA_DEEPLINK                     @"ua_deeplink"

@protocol Yodo1UAAdapterBaseDelegate <NSObject>
//get deeplink result
- (void)getDeeplinkResult:(NSDictionary *)result;
@end

@interface Yodo1UAAdapterBase : NSObject

@property (nonatomic, weak) id<Yodo1UAAdapterBaseDelegate> delegate;

- (id)initWithAnalytics:(UAInitConfig*)initConfig;

- (void)setCustomUserId:(NSString *)userId;

- (void)setAdditionalData:(NSDictionary *)customData;

- (void)trackEvent:(NSString *)eventName withValues:(NSDictionary *)eventData;

/**
 * Validating purchases
 */
- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId;

- (void)setDeeplink;

- (void)useReceiptValidationSandbox:(BOOL)isConsent;

- (void)setDebugLog:(BOOL)debugLog;

@end
