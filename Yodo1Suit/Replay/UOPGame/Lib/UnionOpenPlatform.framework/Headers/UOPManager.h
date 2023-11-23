//
//  UOPManager.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/21.
//

#import <Foundation/Foundation.h>
#import <UnionOpenPlatform/UOPConfigManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface UOPManager : NSObject

+ (instancetype)sharedManager;

/// 联运服务初始化
/// @param config 联运服务配置
/// @param launchOptions AppDelegate启动时的launchOptions
/// @param complete 初始化完成回调
- (void)startConfig:(UOPConfigManager *)config
      launchOptions:(NSDictionary *)launchOptions
           complete:(void (^)(NSError * _Nullable err))complete;

/// sdk 版本号
@property (nonatomic, copy, readonly) NSString *sdkVersion;
/// sdk 名称
@property (nonatomic, copy, readonly) NSString *sdkName;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
