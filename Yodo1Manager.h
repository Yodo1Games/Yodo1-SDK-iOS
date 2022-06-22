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
@property (nonatomic,strong) NSString *appsflyerCustomUserId;//AppsFlyer,ThinkingData自定义UserId

@end

@interface Yodo1Manager : NSObject

//初始化:数据统计，Yodo1Track激活统计，视频广告
//插屏广告，Banner广告，SNS分享，MoreGame
+ (void)initSDKWithConfig:(SDKConfig*)sdkConfig;

@end
