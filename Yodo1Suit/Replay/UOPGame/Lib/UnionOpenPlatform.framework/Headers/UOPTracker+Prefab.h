//
//  UOPTracker+Prefab.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/17.
//

#import <UnionOpenPlatform/UOPTracker.h>

NS_ASSUME_NONNULL_BEGIN

// 调用前须知
// 1. 方法仅在 UOPManager 初始化完成之后的调用才有实际上报
// 2. 方法调用时 UOPManager 还未完成初始化，不会导致崩溃
// 3. 如果调用时机和 UOPManager 初始化时机产生冲突，建议优先保障 UOPManager 初始化在idfa请求时机之后(例如idfa的请求时机在游戏角色创建之后的，那建议保持在idfa请求完成之后再初始化，放弃角色创建的埋点上报)

@interface UOPTracker (Prefab)

/// 启动游戏
/// @discussion 内部已经处理，无需手动上报
+ (void)trackGameLaunch API_DEPRECATED("初始化已自动上报，无需手动调用", ios(9.0, API_TO_BE_DEPRECATED));

/// 角色注册
/// @param accountType 账号类型，0-游客，1-非游客
/// @param method 注册方式，@"douyin"、@"wechat"、@"qq"、@"mobile"、@”weibo“
/// @param isSuccess 注册结果
+ (void)trackRegister:(NSInteger)accountType
               method:(NSString *)method
               userID:(NSString *)userID
            isSuccess:(BOOL)isSuccess;
/*
 注册方式字段非以上渠道的可以厂商自定义字符串上报；
 如果账号是在服务器完成注册，用户没有注册角色的操作，那就在首次登录时执行上报；
 */

/// 登录请求前
/// @param accountType 账号类型，0-游客，1-非游客
/// @param method 注册方式，@"douyin"、@"wechat"、@"qq"、@"mobile"、@”weibo“
/// @discussion 注册方式字段非以上渠道的可以厂商自定义字符串上报；在登录阶段获取不到该字段的可以传空；
+ (void)trackLoginRequestWithAccountType:(NSInteger)accountType
                                  method:(nullable NSString *)method;

/// 登录结果
/// @param accountType 账号类型，0-游客，1-非游客
/// @param method 注册方式，@"douyin"、@"wechat"、@"qq"、@"mobile"、@”weibo“
/// @param userID 用户唯一标识
/// @param isSuccess 登录结果
+ (void)trackLoginResultWithAccountType:(NSInteger)accountType
                                 method:(nullable NSString *)method
                                 userID:(NSString *)userID
                              isSuccess:(BOOL)isSuccess;
/*
 注册方式字段非以上渠道的可以厂商自定义字符串上报；
 登录失败导致某些字段获取不到的，可以传空字符串@"";
 */

/// 玩游戏的时长
/// @param accountType 账号类型，0-游客，1-非游客
/// @param userID 用户唯一标识
/// @param duration 上报时长，单位：秒
+ (void)trackPlaySessionWithAccountType:(NSInteger)accountType
                                 userID:(NSString *)userID
                               duration:(NSInteger)duration;

/// 支付请求前
/// @param accountType 账号类型，0-游客，1-非游客
/// @param userID 用户唯一标识
/// @param contentType 商品类型，@”coin“
/// @param productID 商品id
/// @param productName 商品名称
/// @param contentNumber 商品数量
/// @param currency 币种，@"CNY"
/// @param totalAmount 货币金额，单位：分，不可为0
+ (void)trackPayRequestWithAccountType:(NSInteger)accountType
                                userID:(NSString *)userID
                           contentType:(NSString *)contentType
                             productID:(NSString *)productID
                           productName:(NSString *)productName
                         contentNumber:(NSUInteger)contentNumber
                              currency:(NSString *)currency
                           totalAmount:(unsigned long long)totalAmount;
/*
 1. contentType 的具体传值可以由厂商自定义，用于游戏内区分商品类型，非空全小写英语；
 2. currency 币种是用于计算价格单位的，国内发行游戏均为CNY；
 */

/// 支付结果
/// @param accountType 账号类型，0-游客，1-非游客
/// @param userID 用户唯一标识
/// @param orderID 订单号
/// @param payChannel 支付渠道，@"App Store"
/// @param merchantID 商户id
/// @param contentType 商品类型，@”coin“
/// @param productID 商品id
/// @param productName 商品名称
/// @param contentNumber 商品数量
/// @param currency 币种，@"CNY"
/// @param totalAmount 商品货币金额，单位：分，不可为0
/// @param acturallyAmount 实际支付金额，单位：分，一般等于支付金额
/// @param isSuccess 支付结果
+ (void)trackPayResultWithAccountType:(NSInteger)accountType
                               userID:(NSString *)userID
                              orderID:(NSString *)orderID
                           payChannel:(NSString *)payChannel
                           merchantID:(NSString *)merchantID
                          contentType:(NSString *)contentType
                            productID:(NSString *)productID
                          productName:(NSString *)productName
                        contentNumber:(NSUInteger)contentNumber
                             currency:(NSString *)currency
                          totalAmount:(unsigned long long)totalAmount
                      acturallyAmount:(NSInteger)acturallyAmount
                            isSuccess:(BOOL)isSuccess;
/*
 1. contentType 的具体传值可以由厂商自定义，用于游戏内区分商品类型，非空全小写英语；
 2. currency 币种是用于计算价格单位的，国内发行游戏均为CNY；
 3. orderID 需要和服务端上报的保持一致，建议使用苹果内购返回的订单号；
 4. merchantID 商户ID使用初始化的appid即可；
 5. totalAmount 为商品的原价；acturallyAmount 实际支付金额为折后价格，没有打折则等于 totalAmount；
 */

@end

NS_ASSUME_NONNULL_END
