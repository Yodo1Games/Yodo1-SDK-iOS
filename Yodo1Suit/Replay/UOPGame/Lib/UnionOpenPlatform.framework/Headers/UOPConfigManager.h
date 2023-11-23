//
//  UOPConfigManager.h
//  UOPGameSDK
//
//  Created by ByteDance on 2020/12/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UOPGameUnionMode) {
    UOPGameUnionModeUnionCP = 1     // 联运模式，默认
};

@interface UOPConfigManager : NSObject

+ (instancetype)sharedConfiguration;

/// 应用id
@property (nonatomic, copy) NSString *appId;
/// 渠道
/// @discussion 初始化默认已赋值'App Store'，无特殊情况无需修改
@property (nonatomic, copy) NSString *channel;

/// SDK接入模式
/// @abstract 抖音联运模式设置为 UOPGameUnionModeUnionCP；
/// @see UOPGameUnionMode
/// @discussion 对入参有疑问的，可以在服务台答疑；
@property (nonatomic, assign) NSInteger unionMode;

/************ 调试接口  ************/

/// 调试模式
/// @discussion YES则日志输出至控制台，仅在调试时使用，Release版本请勿设置为YES;
@property (nonatomic, assign, getter=isDebug) BOOL debug;

/// 日志上报是否加密
/// @discussion debug=yes时配置才生效，仅在调试时使用，Release版本请勿设置为YES；
@property (nonatomic, assign) BOOL logNoEncrypt;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
