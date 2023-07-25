//
//  Yodo1Manager.h
//
//  Created by shon wang on 13-8-13.
//  Copyright (c) 2013年 游道易. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDKConfig : NSObject

/// Unique identifier for your game
@property (nonatomic,copy) NSString* appKey;

/// Optional, If your game has multiple environments, you can use `RegionCode` to initialize the SDK. You can think of these environments as different regions for your game. Using `RegionCode` allows you to set up different server callbacks for your different backends
@property (nonatomic,copy) NSString* regionCode;

@property (nonatomic,strong) NSString *appsflyerCustomUserId DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1AnalyticsManager sharedInstance] login:]");

@end

@interface Yodo1Manager : NSObject

@property (nonatomic, strong) SDKConfig *config;

+ (Yodo1Manager*)shared;

- (void)initWithAppKey:(NSString *)appKey;

- (void)initWithConfig:(SDKConfig*)sdkConfig;

/**
 * 激活码/优惠券
 */
- (void)verifyWithActivationCode:(NSString *)activationCode
                    callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSDictionary* _Nullable error))callback;

@end
NS_ASSUME_NONNULL_END
