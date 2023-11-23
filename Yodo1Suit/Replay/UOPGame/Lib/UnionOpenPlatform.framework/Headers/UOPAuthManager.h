//
//  UOPAuthManager.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UnionOpenPlatform/UOPAuthRequest.h>
#import <UnionOpenPlatform/UOPAuthResponse.h>

NS_ASSUME_NONNULL_BEGIN

#define UOPLoginEnumString(enum)       ([@(enum) stringValue])

typedef NS_ENUM(NSInteger, UOPThirdAuthType) {
    UOPThirdAuthTypeNotSupport = -1,
    UOPThirdAuthTypeDouyin
};

@interface UOPAuthManager : NSObject

+ (void)authPlatform:(UOPThirdAuthType)type
             request:(UOPAuthRequest *)request
              result:(void(^)(UOPAuthResponse *))result;

+ (void)registerAppKey:(NSString *)appKey
          forPlatform:(UOPThirdAuthType)type;

#pragma mark - handle URL

/**
 *  打开第三方平台,在9.0后 必须在application:openURL:url options:中调用该接口
 * @attention 必须在主线程中调用
 *
 * @param   url         第三方应用打开APP时传递过来的URL
 * @param   options     第三方应用打开APP时传递过来的options
 * @return  成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

/**
 *  打开第三方平台,在8.0系统中 必须在application:openURL:sourceApplication:annotation:中调用该接口
 * @attention 必须在主线程中调用
 *
 * @param   url                     第三方应用打开APP时传递过来的URL
 * @param   sourceApplication       第三方应用打开APP时传递过来的sourceApplication
 * @paran   annotation              第三方应用打开APP是传递过来的annotation
 * @return  成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/**
 *  @param launchOptions 就是启动application:didFinishLaunchingWithOptions中的options
 *  @return 第三方SDK处理结果回调
 */
+ (BOOL)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
