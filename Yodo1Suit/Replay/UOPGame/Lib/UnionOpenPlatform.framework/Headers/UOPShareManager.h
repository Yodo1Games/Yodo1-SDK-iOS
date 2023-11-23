//
//  UOPShareManager.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/7.
//

#import <Foundation/Foundation.h>
#import <UnionOpenPlatform/UOPShareBaseContent.h>
#import <UnionOpenPlatform/UOPShareResponse.h>

NS_ASSUME_NONNULL_BEGIN

@interface UOPShareManager : NSObject

+ (instancetype)sharedManager;

/// 对目标分享平台执行初始化
/// @param appKey 初始化key值，抖音平台为 ClientKey
/// @param type 指定分享平台
+ (void)registerAppKey:(NSString *)appKey
           forPlatform:(UOPThirdShareType)type;

/// 执行分享操作
/// @param content 分享内容
/// @param completion 分享行为完成回调
- (void)shareContent:(UOPShareBaseContent *)content completion:(void(^)(UOPShareResponse *))completion;

#pragma mark - handle URL

/// 能力初始化
/// @attention 建议在 application:didFinishLaunchingWithOptions 中调用本接口
/// @param launchOptions 为系统方法 application:didFinishLaunchingWithOptions 中的 options
+ (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/// 打开第三方平台
/// @attention 必须在主线程中调用；必须在application:openURL:url options:中调用该接口；
/// @param   url         第三方应用打开APP时传递过来的URL
/// @param   options     第三方应用打开APP时传递过来的options
/// @return  成功返回YES，失败返回NO。
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

/// 打开第三方平台
/// @discussion 兼容旧版本接口
/// @attention 必须在主线程中调用；必须在application:openURL:sourceApplication:annotation:中调用该接口；
/// @param   url                     第三方应用打开APP时传递过来的URL
/// @param   sourceApplication       第三方应用打开APP时传递过来的sourceApplication
/// @paran   annotation              第三方应用打开APP是传递过来的annotation
/// @return  成功返回YES，失败返回NO。
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

#pragma mark - cancel share process

/// 取消文件下载，放弃分享
/// @discussion 当通过链接分享视频或者图片的时候需要下载，调用该接口取消下载过程，放弃分享
+ (void)cancelDownloadProcess;

/// 清除缓存文件
/// @discussion 当通过链接分享视频或者图片的时候会下载至沙盒，调用该接口清理之前下载的缓存
+ (void)cleanSandbox;

#pragma mark - Optional

/// 目标分享平台是否可用
/// @param type 指定分享平台
/// @discussion 抖音平台分享已经内置该逻辑，接入方可以不用调用本接口
+ (BOOL)isPlatformAvailable:(UOPThirdShareType)type;

/// 目标分享平台是否已安装
/// @param type 指定分享平台
/// @discussion 抖音平台分享已经内置该逻辑，接入方可以不用调用本接口
+ (BOOL)isAppInstalled:(UOPThirdShareType)type;

@end

NS_ASSUME_NONNULL_END
