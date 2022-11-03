//
//  Yodo1AnalyticsManager.h
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@protocol Yodo1DeeplinkDelegate <NSObject>
//get deeplink result
- (void)getDeeplinkResult:(NSDictionary *)result;
@end

@interface AnalyticsInitConfig : NSObject
@property (nonatomic,strong) NSString *appsflyerCustomUserId;//AppsFlyer自定义UserId
@end

typedef NS_ENUM(NSInteger, AnalyticsType) {
    AnalyticsTypeAppsFlyer,     //AppsFlyer 数据统计
    AnalyticsTypeThinking,         //Thinking
};

typedef void (^Yodo1InviteUrlCallBack) (NSString *url, int code, NSString *errorMsg);

@interface Yodo1AnalyticsManager : NSObject

@property (nonatomic, weak) id<Yodo1DeeplinkDelegate> delegate;

/**
 *  Yodo1AnalyticsManager单例
 *
 *  @return Yodo1AnalyticsManager实例
 */
+ (Yodo1AnalyticsManager*)sharedInstance;

/**
 *  根据统计分析类型，初始化。
 *
 */

- (void)initializeAnalyticsWithConfig:(AnalyticsInitConfig*)initConfig;

/**
 *  使用之前，先初始化initWithAnalytics
 *
 *  @param eventName  事件id(必须)
 *  @param eventData  事件数据(必须)
 */
- (void)eventAnalytics:(NSString*)eventName
             eventData:(NSDictionary*)eventData;

/**
 *  使用appsflyer 自定义事件
 *  @param eventName  事件id(必须)
 *  @param eventData  事件数据(必须)
 */
- (void)eventAppsFlyerAnalyticsWithName:(NSString *)eventName 
                       eventData:(NSDictionary *)eventData;

/**
 *  AppsFlyer Apple 内付费验证和事件统计
 */
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
