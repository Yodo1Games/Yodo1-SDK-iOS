//
//  Yodo1SNS.h
//  localization_sdk
//
//  Created by huafei qu on 13-5-4.
//  Copyright (c) 2015年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1ShareConstant.h"

FOUNDATION_EXPORT NSString * _Nonnull const kYodo1QQAppId;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1QQUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1WechatAppId;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1WechatUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1SinaWeiboAppKey;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1SinaWeiboUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1FacebookAppId;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1FacebookDisplayName;

@interface Yodo1Share: NSObject

@property(nonatomic,assign) BOOL isYodo1Shared;/*当前正在分享的是不是Yodo1的分享，区别于别的平台，比如KTPlay*/
@property(nonatomic,assign) BOOL isLandscapeOrPortrait;/*支持横竖屏切换，默认NO*/

+ (nonnull Yodo1Share*)sharedInstance;

/**
 初始化qq,微信
 
 @param shareAppIds appId字典
 如：@{kYodo1QQAppId:@"qqAppId",kYodo1WechatAppId:@"wechatAppId"}
 */
- (void)initWithConfig:(nullable NSDictionary*)shareAppIds;

- (void)showSocial:(nonnull ShareContent *)content
             block:(nullable ShareCompletionBlock)completionBlock;

- (BOOL)application:(nullable UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nullable NSDictionary *)options;

// Still need this for iOS8
- (BOOL)application:(nullable UIApplication *)application
            openURL:(nonnull NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation;
/**
 *  检查是否安装新浪，微信，QQ客户端,facebook 服务是否有效
 *
 *  @param shareType Yodo1ShareType
 *
 *  @return YES安装了客户端或服务有效 可以分享！
 */
- (BOOL)isInstalledWithType:(Yodo1ShareType)shareType;

- (nonnull NSString *)getSdkVersion;

- (void)setDebugLog:(BOOL)debugLog;

@end
