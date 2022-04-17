//
//  Yodo1Manager.h
//  localization_sdk_sample
//
//  Created by shon wang on 13-8-13.
//  Copyright (c) 2013年 游道易. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SDKConfig : NSObject

@property (nonatomic,copy) NSString* appKey;
@property (nonatomic,copy) NSString* regionCode;//可以传入@"",不能传入nil
@property (nonatomic,strong) NSMutableArray *gaCustomDimensions01;//GA统计自定义维度
@property (nonatomic,strong) NSMutableArray *gaCustomDimensions02;
@property (nonatomic,strong) NSMutableArray *gaCustomDimensions03;
@property (nonatomic,strong) NSMutableArray *gaResourceCurrencies;
@property (nonatomic,strong) NSMutableArray *gaResourceItemTypes;
@property (nonatomic,strong) NSString *appsflyerCustomUserId;//AppsFlyer自定义UserId
@end

@interface Yodo1Manager : NSObject

//初始化:数据统计，Yodo1Track激活统计，视频广告
//插屏广告，Banner广告，SNS分享，MoreGame
+ (void)initSDKWithConfig:(SDKConfig*)sdkConfig;

//处理SNS客户端返回的信息为确保SNS（微信，QQ，新浪微博等）功能正确使用
//需要在游戏AppDelegate的openURL方法中调用此方法。
+ (void)handleOpenURL:(NSURL *)url sourceApplication:(NSString*)sourceApplication;

@end
