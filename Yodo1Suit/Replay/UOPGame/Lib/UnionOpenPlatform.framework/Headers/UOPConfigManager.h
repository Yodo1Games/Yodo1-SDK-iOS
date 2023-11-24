//
//  UOPConfigManager.h
//  UOPGameSDK
//
//  Created by ByteDance on 2020/12/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UOPGameUnionMode) {
    UOPGameUnionModeDefault = 0, // 普通模式
    UOPGameUnionModeLive = 1, // 直播联运模式，默认
    UOPGameUnionModeCPS = 2 // CPS模式
};


@interface UOPConfigManager : NSObject

+ (instancetype)sharedConfiguration;

/// 应用id
@property (nonatomic, copy) NSString *appId;
/// 应用名称（英文）
/// @discussion 游戏完善资料后的 appName，联系技术支持获取
@property (nonatomic, copy) NSString *appName;
/// 渠道
/// @discussion 初始化默认已赋值'App Store'，无特殊情况无需修改
@property (nonatomic, copy) NSString *channel;
/// 联运模式
/// @discussion 初始化默认已赋值 UOPGameUnionModeLive，无特殊情况无需修改，不确定取值可以询问技术支持
@property (nonatomic, assign) UOPGameUnionMode unionMode;

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
