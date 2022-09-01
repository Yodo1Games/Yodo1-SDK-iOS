//
//  Yodo1UA.h
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@protocol Yodo1UADeeplinkDelegate <NSObject>
//get deeplink result
- (void)getDeeplinkResult:(NSDictionary *)result;
@end

@interface UAInitConfig : NSObject

@property (nonatomic,strong) NSString *appsflyerDevKey;
@property (nonatomic,strong) NSString *appleId;

@end

typedef NS_ENUM(NSInteger, UAType) {
    UATypeAppsFlyer,
};

@interface Yodo1UA : NSObject

/**
 *  deeplink delegate
 *
 */
@property (nonatomic, weak) id<Yodo1UADeeplinkDelegate> delegate;

/**
 *  Yodo1AnalyticsManager单例
 *
 *  @return Yodo1AnalyticsManager实例
 */
+ (Yodo1UA*)sharedInstance;

/**
 *  Get SDK version information
 *
 */
- (NSString *)getSdkVersion;

- (void)setAgeRestrictedUser:(BOOL)isChild;
- (void)setHasUserConsent:(BOOL)isConsent;
- (void)setDoNotSell:(BOOL)isNotSell;


- (void)initWithInfoPlist;

/**
 *  根据统计分析类型，初始化。
 *
 */
- (void)initWithConfig:(UAInitConfig*)initConfig;


- (void)setCustomUserId:(nonnull NSString *)userId;

- (void)setAdditionalData:(nullable NSDictionary *)customData;

/**
 *  Tracking in-app events, the SDK lets you log user actions happening in the context of your app.
 *
 *  @param eventName  The event name(Necessary)
 *  @param eventData  The event data(Optional)
 */
- (void)trackEvent:(nonnull NSString *)eventName withValues:(nullable NSDictionary *)eventData;

/**
 *  Validating purchases, SDK provides verification for in-app purchases. The validateAndLogInAppPurchase method takes care of validating and logging the purchase event.
 *  Upon successful validation, a NSDictionary is returned with the receipt validation data (provided by Apple servers).
 */
- (void)validateAndTrackInAppPurchase:(nonnull NSString*)productIdentifier
                                price:(nonnull NSString*)price
                             currency:(nonnull NSString*)currency
                        transactionId:(nonnull NSString*)transactionId;

#pragma mark - Deeplink

/**
 *  订阅openURL
 *
 *  @param url                    生命周期中的openurl
 *  @param options           生命周期中的options
 */
- (void)handleOpenUrl:(nonnull NSURL *)url options:(nullable NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

/**
 *  订阅continueUserActivity
 *
 *  @param userActivity                    生命周期中的userActivity
 */
- (void)continueUserActivity:(nonnull NSUserActivity *)userActivity;

- (void)useReceiptValidationSandbox:(BOOL)isConsent;

- (void)setDebugLog:(BOOL)debugLog;

@end
