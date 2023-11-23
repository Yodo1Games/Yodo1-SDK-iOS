//
//  UOPTracker.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/17.
//

#import <Foundation/Foundation.h>
#import <UnionOpenPlatform/UOPTrackerConfig.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSString*, id> *_Nonnull (^UOPAutoTrackCustomHeaderBlock)(void);

@interface UOPTracker : NSObject

+ (instancetype)shareInstance;

/// 初始化
- (void)startWithConfig:(UOPTrackerConfig *)conf;

/// 注册完成后回调，error有值表示失败，成功后可以获取到installID 和 deviceID
- (void)addRegisterComplete:(void (^)(NSError *error))complete;

/// 设置公共属性，一次启动设置一次即可，不要重复设置
- (void)setCustomHeaderValue: (nullable id)value forKey: (NSString *)key;

/*! @abstract 添加自定义上报信息
 @discussion 需要在[UOPTracker startWithConfig:]之前设置
 @discussion 一次启动设置一次即可，不要重复设置
 @discussion 非持久化，重启需重新设置
 @discussion 返回值即上报信息，每次上报都会包含返回值字典信息，上报信息需可序列化，可使用[NSJSONSerialization isValidJSONObject:] 检查
 [UOPTracker setCustomHeaderBlock:^NSDictionary<NSString *,id> * _Nonnull{
    return @{@"is_tester":@YES,
           @"user_id":@"tester_1001",
           };
 }];
 */
- (void)setCustomHeaderBlock: (UOPAutoTrackCustomHeaderBlock)customHeaderBlock;

/// 删除CustomHeader中的一条KV。
- (void)removeCustomHeaderValueForKey: (NSString *)key;

/// 通用埋点方法，游戏可以使用该接口进行埋点
- (void)trackEvent: (NSString *)event params: (NSDictionary *)params;

/// 埋点通用方法，通过此方法埋点时会带上SDK内的公参信息
- (void)trackSDKEvent:(NSString * _Nonnull)event params:(NSDictionary * _Nullable)params;

- (void)trackAlogEvent: (NSString *)event params: (NSDictionary *)params;

#pragma mark - 用户登录态变化调用
/// 设置用户唯一id
- (void)setCurrentUserUniqueID: (NSString *)userUniqueID;
/// 清空userUniqueId
- (void)clearUserUniqueId;

#pragma mark - schemeHandler
/// 如果是iOS 13以上，重写UISceneDelegate的回调方法 -scene:openURLContexts:
/// 如果iOS版本低于13，则重写UIApplicationDelegate的回调方法 -application:openURL:options:
- (BOOL)handleURL: (NSURL *)url scene: (id _Nullable)scene;

#pragma mark - 设备信息
/// 安装id
- (NSString *_Nullable)installID;
/// 设备id
- (NSString *_Nullable)deviceID;

@end

NS_ASSUME_NONNULL_END
