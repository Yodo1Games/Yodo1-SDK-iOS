//
//  Yodo1AntiAddictionHelper.h
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/9.
//

#import <Foundation/Foundation.h>
#import "Yodo1AntiAddiction.h"

NS_ASSUME_NONNULL_BEGIN

#define Yodo1AntiAddictionChannel @"appstore"

@interface Yodo1AntiAddictionHelper : NSObject

@property (nonatomic, assign) BOOL autoTimer; // 自动开启计时
@property (nonatomic, weak, readonly) id<Yodo1AntiAddictionDelegate> delegate;
@property (nonatomic, copy, readonly) Yodo1AntiAddictionSuccessful certSucdessfulCallback;
@property (nonatomic, copy, readonly) Yodo1AntiAddictionFailure certFailureCallback;
@property (nonatomic, assign) BOOL isOnline;// 是否在线
@property (nonatomic, assign) BOOL systemSwitch;//在线开关
@property (nonatomic, assign) BOOL enterGameFlag;//进游戏
@property (nonatomic, assign) BOOL enterBackground;//进后台
@property (nonatomic, assign) BOOL isChinaIP;
@property (nonatomic, assign) BOOL isCheckedIP;

+ (Yodo1AntiAddictionHelper *)shared;

/// 初始化
- (void)init:(NSString *)appKey channel:(NSString *)channel regionCode:(NSString *)regionCode delegate: (id<Yodo1AntiAddictionDelegate>)delegate;

/// 获取SDK版本
- (NSString *)getSdkVersion;

/// 开启计时, 如果当前正在计时中则会忽略
- (void)startTimer;
/// 停止计时，同时会上报时间
- (void)stopTimer;
/// 是否正在计时
- (BOOL)isTimer;

- (BOOL)isGuestUser;

- (BOOL)successful:(id _Nullable)data;
- (BOOL)failure:(NSError * _Nullable)error;

/// 验证玩家防沉迷信息
/// accountId 玩家账号ru
/// 如果 autoTimer == YES游客及未成年会自动开启计时
- (void)verifyCertificationInfo:(NSString *)accountId success:(Yodo1AntiAddictionSuccessful)success failure:(Yodo1AntiAddictionFailure)failure;

///是否已限制消费
- (void)verifyPurchase:(NSInteger)money success:(Yodo1AntiAddictionSuccessful)success failure:(Yodo1AntiAddictionFailure)failure;

///上报消费信息 - 支付信息&商品信息
- (void)reportProductReceipts:(NSArray<Yodo1AntiAddictionProductReceipt *> *)receipts success:(Yodo1AntiAddictionSuccessful)success failure:(Yodo1AntiAddictionFailure)failure;

///上线行为
- (void)online:(OnBehaviourResult)callback;


///下线行为
- (void)offline:(OnBehaviourResult)callback;

///判断是否是中国大陆
- (BOOL)isChineseMainland;

@end

NS_ASSUME_NONNULL_END
