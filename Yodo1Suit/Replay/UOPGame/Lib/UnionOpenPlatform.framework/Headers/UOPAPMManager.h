//
//  UOPAPMManager.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2020/12/23.
//

#import <Foundation/Foundation.h>
#import <UnionOpenPlatform/UOPAPMConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface UOPAPMManager : NSObject

+ (instancetype)sharedManager;
/// 初始化配置
- (void)startWithConfig:(UOPAPMConfig *)apmConfig;
/// 设置设备id，如果有接入APPLog，可以通过 UOPTracker 获取
- (void)setDeviceID:(NSString *)deviceID;

/*! @abstract 记录一个事件
 @param eventName 事件名称
 @param metrics 事件相关指标信息，字典只能有一级，value为数值类型
 @param dimension 事件相关维度信息，字典只能有一级，可在平台上用于对指标的分组和筛选
 @param extraValue 额外信息，一些环境、用户信息等，可以在DID追查中的原始日志查看
 */
- (void)trackAPMEvent:(nonnull NSString *)eventName
              metrics:(nullable NSDictionary <NSString *, NSNumber *> *)metrics
            dimension:(nullable NSDictionary <NSString *, NSString *> *)dimension
           extraValue:(nullable NSDictionary *)extraValue;

@end

NS_ASSUME_NONNULL_END
