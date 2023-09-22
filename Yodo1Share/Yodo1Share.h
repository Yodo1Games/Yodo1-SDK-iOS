//
//  Yodo1SNS.h
//  localization_sdk
//
//  Created by huafei qu on 13-5-4.
//  Copyright (c) 2015年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1ShareContent.h"

#define Y_SHARE_VERSION                  @"1.0.4"

FOUNDATION_EXPORT NSString * _Nonnull const kYodo1QQAppId;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1QQUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1WechatAppId;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1WechatUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1SinaWeiboAppKey;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1SinaWeiboUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1FacebookAppId;
FOUNDATION_EXPORT NSString * _Nonnull const kYodo1FacebookDisplayName;

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1SMContent : NSObject
@property (nonatomic,assign) NSInteger shareType;     //对单个平台分享模式有效
@property (nonatomic,assign) NSInteger contentType;   //分享样式<link,image>
@property (nonatomic,strong) NSString *contentTitle;       //仅对qq和微信有效
@property (nonatomic,strong) NSString *contentText;        //分享描述
@property (nonatomic,strong) NSString *contentImage;       //分享图片
@property (nonatomic,strong) NSString *contentUrl;         //分享URL
@property (nonatomic,strong) NSString *gameLogo;   //game of Logo
@property (nonatomic,assign) float gameLogoX;      //game of logo X偏移量
@property (nonatomic,strong) NSString *qrLogo;      //二维码logo
@property (nonatomic,strong) NSString *qrText;      //二维码右边的文本
@property (nonatomic,assign) float qrTextX;         //文字X偏移量
@property (nonatomic,assign) float qrImageX;        //二维码偏移量
@end


@interface Yodo1Share: NSObject

@property(nonatomic,assign) BOOL isYodo1Shared;/*当前正在分享的是不是Yodo1的分享，区别于别的平台，比如KTPlay*/
@property(nonatomic,assign) BOOL isLandscapeOrPortrait;/*支持横竖屏切换，默认NO*/

+ (nonnull Yodo1Share*)sharedInstance;

/**
 read all config from Info.plist
 */
- (void)initWithPlist;
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

NS_ASSUME_NONNULL_END
