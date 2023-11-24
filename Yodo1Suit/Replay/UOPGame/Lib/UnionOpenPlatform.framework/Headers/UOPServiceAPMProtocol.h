//
//  UOPServiceAPMProtocol.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/20.
//

#ifndef UOPServiceAPMProtocol_h
#define UOPServiceAPMProtocol_h
#import <UnionOpenPlatform/UOPSingletonService.h>

@protocol UOPServiceAPMProtocol <UOPSingletonService>

/// 设置deviceID
- (void)setDeviceID:(nonnull NSString *)deviceID;

/// 自定义错误上报
/// - exceptionType 错误类型，不可为空
/// - customParams  自定义的现场信息，可在平台详情页中展示
/// - filters 自定义的筛选项，可在平台列表页中筛选
- (void)trackCustomException:(nonnull NSString *)exceptionType customParams:(NSDictionary<NSString *, id> * _Nullable)customParams filters:(NSDictionary<NSString *,id> * _Nullable)filters;

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

#endif /* UOPServiceAPMProtocol_h */
