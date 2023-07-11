//
//  Yodo1AnalyticsManager.h
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1AdRevenue.h"
#import "Yodo1IAPRevenue.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Optional delegate that will get informed about tracking results.
 */
@protocol Yodo1UADelegate <NSObject>

@optional
/**
 * @brief Optional delegate method that gets called when a deep link is about to be opened by the SDK.
 */
- (void)yodo1DeeplinkResult:(NSDictionary * _Nonnull)result;

@end

typedef void (^Yodo1InviteUrlCallBack) (NSString *url, int code, NSString *errorMsg);

/**
 * @brief Yodo1 analytics configuration object class.
 */
@interface AnalyticsInitConfig : NSObject

@property (nonatomic,strong, nonnull) NSString * gameKey;
@property (nonatomic, assign) BOOL debugEnabled;
@property (nonatomic,strong, nullable) NSString *appsflyerCustomUserId;

@end

typedef NS_ENUM(NSInteger, AnalyticsType) {
    AnalyticsTypeThinking,
    AnalyticsTypeAdjust,
    AnalyticsTypeAppsFlyer,
};

/**
 * @brief The main interface to  Analytics and UA.
 */
@interface Yodo1AnalyticsManager : NSObject

@property (nonatomic, weak) id<Yodo1UADelegate> delegate;

/**
 *  Yodo1AnalyticsManager单例
 *
 *  @return Yodo1AnalyticsManager实例
 */
+ (Yodo1AnalyticsManager*)sharedInstance;

- (void)initializeWithPlist;

- (void)initializeWithConfig:(AnalyticsInitConfig*)initConfig;

/**
 *  根据统计分析类型，初始化。
 *
 */
- (void)initializeAnalyticsWithConfig:(AnalyticsInitConfig*)initConfig DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1AnalyticsManager sharedInstance] initializeWithConfig:]");

/**
 *  使用之前，先初始化initWithAnalytics
 *
 *  @param eventName  事件id(必须)
 *  @param eventValues  事件数据(必须)
 */
- (void)eventAnalytics:(NSString*)eventName
             eventData:(NSDictionary*)eventValues DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1AnalyticsManager sharedInstance] trackEvent:]");

- (void)trackEvent:(NSString *)eventName eventValues:(NSDictionary *)eventValues;

#pragma mark - UA
/**
 *  使用appsflyer 自定义事件
 *  @param eventName  事件id(必须)
 *  @param eventValues  事件数据(必须)
 */
- (void)eventAppsFlyerAnalyticsWithName:(NSString *)eventName 
                              eventData:(NSDictionary *)eventValues DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1AnalyticsManager sharedInstance] trackUAEvent:]");

- (void)trackUAEvent:(NSString *)eventName eventValues:(NSDictionary *)eventValues;

- (void)trackAdRevenue:(Yodo1AdRevenue *)adRevenue;

- (void)trackIAPRevenue:(Yodo1IAPRevenue *)iapRevenue;

/**
 *  AppsFlyer Apple 内付费验证和事件统计
 */
- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1AnalyticsManager sharedInstance] trackIAPRevenue:]");

/**
 *  AppsFlyer Apple 内付费使用自定义事件上报
 */
- (void)eventAndTrackInAppPurchase:(NSString*)revenue
                          currency:(NSString*)currency
                          quantity:(NSString*)quantity
                         contentId:(NSString*)contentId
                         receiptId:(NSString*)receiptId DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1AnalyticsManager sharedInstance] trackIAPRevenue:]");

/**
 *  AppsFlyer User invite attribution
 */
- (void)generateInviteUrlWithLinkGenerator:(NSDictionary *)linkDic CallBack:(Yodo1InviteUrlCallBack)callBack;

/**
 *  AppsFlyer logInvite AFEventInvite
 */
- (void)logInviteAppsFlyerWithEventData:(NSDictionary *)eventData;

/**
 *  AppsFlyer and ThinkingData set user id
 */
- (void)login:(NSString *)userId;

#pragma mark - lifecycle

/**
 *  订阅openURL
 *
 *  @param url                    生命周期中的openurl
 *  @param options           生命周期中的options
 */
- (void)handleOpenUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

/**
 *  订阅continueUserActivity
 *
 *  @param userActivity                    生命周期中的userActivity
 */
- (void)continueUserActivity:(nonnull NSUserActivity *)userActivity;

@end

NS_ASSUME_NONNULL_END
