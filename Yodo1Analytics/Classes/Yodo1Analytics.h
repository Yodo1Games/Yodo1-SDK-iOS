//
//  Yodo1Analytics.h
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface AnalyticsInitConfig : NSObject

@property (nonatomic,strong) NSString* game_key;
@property (nonatomic,strong) NSString* td_app_id;

@end

@interface Yodo1Analytics : NSObject

/**
 *  Yodo1Analytics单例
 *
 *  @return Yodo1Analytics实例
 */
+ (nonnull Yodo1Analytics*)sharedInstance;

/**
 *  初始化
 *
 */
- (void)initWithConfig:(nullable AnalyticsInitConfig *)config;

/**
 *  Tracking in-app events, the SDK lets you log user actions happening in the context of your app.
 *
 *  @param eventName  The event name(Necessary)
 *  @param eventData  The event data(Optional)
 */
- (void)trackEvent:(nonnull NSString *)eventName withValues:(nullable NSDictionary *)eventData;

/**
 *  ThinkingData  set  identify / distinct_id
 */
//- (void)identify:(nonnull NSString *)identify;

/**
 *  get  ThinkingData distinctId
 */
- (nonnull NSString *)getDistinctId;


/**
 *  get  ThinkingData DeviceId
 */
- (nonnull NSString *)getDeviceId;

/**
 *  ThinkingData  set  account id
 */
- (void)login:(nonnull NSString *)accountId;

/**
 *  ThinkingData logout
 */
- (void)logout;

/**
 *  Get SDK version information
 *
 */
- (nonnull NSString *)getSdkVersion;

- (void)setDebugLog:(BOOL)debugLog;

@end
