//
//  UOPTrackerConfig.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UOPTrackerConfig : NSObject

@property (nonatomic, strong) NSDictionary *launchOptions;

#pragma mark - 可选属性
/// 火山引擎应用id，如不设置，默认为SDK的appid
@property (nonatomic, copy) NSString *appID;
/// 默认是"App Store"
@property (nonatomic, copy) NSString *channel;

/// 调试模式
/// @discussion 日志是否输出至控制台，仅在工程环境为DEBUG下生效，默认为NO；Release环境下为NO；
@property (nonatomic, assign) BOOL isDebug;
/// 日志上报是否不加密
/// @discussion 在工程环境为DEBUG，且debug=yes时可配置。允许通过抓包查看上报原始数据。默认为NO；
@property (nonatomic, assign) BOOL logNoEncrypt;

@end

NS_ASSUME_NONNULL_END
