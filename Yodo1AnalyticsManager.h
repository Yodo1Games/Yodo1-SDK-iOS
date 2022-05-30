//
//  Yodo1AnalyticsManager.h
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface AnalyticsInitConfig : NSObject
@property (nonatomic,strong) NSString *appsflyerCustomUserId;//AppsFlyer自定义UserId
@property (nonatomic,strong) NSString *thinkingDataAccountId;//ThinkingData自定义AccountId
@end

typedef NS_ENUM(NSInteger, AnalyticsType) {
    AnalyticsTypeAppsFlyer,     //AppsFlyer 数据统计
    AnalyticsTypeThinking,         //Thinking
};

@interface Yodo1AnalyticsManager : NSObject
@property(nonatomic,class,assign,readonly,getter=isEnable) BOOL enable;

/**
 *  Yodo1AnalyticsManager单例
 *
 *  @return Yodo1AnalyticsManager实例
 */
+ (Yodo1AnalyticsManager*)sharedInstance;

/**
 *  根据统计分析类型，初始化。
 *
 */
- (void)initializeAnalyticsWithConfig:(AnalyticsInitConfig*)initConfig;

/**
 *  使用之前，先初始化initWithAnalytics
 *
 *  @param eventName  事件id(必须)
 *  @param eventData  事件数据(必须)
 */
- (void)eventAnalytics:(NSString*)eventName
             eventData:(NSDictionary*)eventData;

/**
 *  使用appsflyer 自定义事件
 *  @param eventName  事件id(必须)
 *  @param eventData  事件数据(必须)
 */
- (void)eventAppsFlyerAnalyticsWithName:(NSString *)eventName 
                       eventData:(NSDictionary *)eventData;
/**
 *  进入关卡/任务
 *
 *  @param level 关卡/任务
 */
- (void)startLevelAnalytics:(NSString*)level DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 *  完成关卡/任务
 *
 *  @param level 关卡/任务
 */
- (void)finishLevelAnalytics:(NSString*)level DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 *  未通过关卡
 *
 *  @param level 关卡/任务
 *  @param cause 未通过原因
 */
- (void)failLevelAnalytics:(NSString*)level failedCause:(NSString*)cause DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 *  设置玩家等级
 *
 *  @param level 等级
 */
- (void)userLevelIdAnalytics:(int)level DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 *  花费人民币去购买虚拟货币请求
 *
 *  @param orderId               订单id    类型:NSString
 *  @param iapId                 充值包id   类型:NSString
 *  @param currencyAmount        现金金额    类型:double
 *  @param currencyType          币种      类型:NSString 比如：参考 例：人民币CNY；美元USD；欧元EUR等
 *  @param virtualCurrencyAmount 虚拟币金额   类型:double
 *  @param paymentType           支付类型    类型:NSString 比如：“支付宝”“苹果官方”“XX支付SDK”
 */
- (void)chargeRequstAnalytics:(NSString*)orderId
                        iapId:(NSString*)iapId
               currencyAmount:(double)currencyAmount
                 currencyType:(NSString *)currencyType
        virtualCurrencyAmount:(double)virtualCurrencyAmount
                  paymentType:(NSString *)paymentType DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 *  花费人民币去购买虚拟货币成功
 *
 *  @param orderId 订单id     类型:NSString
 *  @param source  支付渠道   1 ~ 99的整数, 其中1..20 是预定义含义,其余21-99需要在网站设置
 数值	含义
 1	App Store
 2	支付宝
 3	网银
 4	财付通
 5	移动通信
 6	联通通信
 7	电信通信
 8	paypal
 */
- (void)chargeSuccessAnalytics:(NSString *)orderId source:(int)source DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 *  游戏中获得虚拟币
 *
 *  @param virtualCurrencyAmount 虚拟币金额         类型:double
 *  @param reason                赠送虚拟币的原因    类型:NSString
 *  @param source                奖励渠道	取值在 1~10 之间。“1”已经被预先定义为“系统奖励”，2~10 需要在网站设置含义          类型：int
 */
- (void)rewardAnalytics:(double)virtualCurrencyAmount reason:(NSString *)reason source:(int)source DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 *  虚拟物品购买/使用虚拟币购买道具
 *
 *  @param item   道具           类型:NSString
 *  @param number 道具个数        类型:int
 *  @param price  道具单价        类型:double
 */
- (void)purchaseAnalytics:(NSString *)item itemNumber:(int)number priceInVirtualCurrency:(double)price DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 *   虚拟物品消耗/玩家使用虚拟币购买道具
 *
 *  @param item   道具名称
 *  @param amount 道具数量
 *  @param price  道具单价
 */
- (void)useAnalytics:(NSString *)item amount:(int)amount price:(double)price DEPRECATED_MSG_ATTRIBUTE("The API has been deprecated.");

/**
 * 设置属性 键值对 会覆盖同名的key
 * 将该函数指定的key-value写入dplus专用文件；APP启动时会自动读取该文件的所有key-value，并将key-value自动作为后续所有track事件的属性。
 */
- (void)registerSuperProperty:(NSDictionary *)property;

/**
 *
 * 从dplus专用文件中删除指定key-value
 @param propertyName 属性名
 */
- (void)unregisterSuperProperty:(NSString *)propertyName;

/**
 * 返回Dplus专用文件中的所有key-value；如果不存在，则返回空。
 */
- (NSDictionary *)getSuperProperties;

/**
 *清空Dplus专用文件中的所有key-value。
 */
- (void)clearSuperProperties;

/**
 *  AppsFlyer Apple 内付费验证和事件统计
 */
- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId;

/**
 *  AppsFlyer Apple 内付费使用自定义事件上报
 */
- (void)eventAndTrackInAppPurchase:(NSString*)revenue
                          currency:(NSString*)currency
                          quantity:(NSString*)quantity
                         contentId:(NSString*)contentId
                         receiptId:(NSString*)receiptId;


/**
 *  订阅openURL
 *
 *  @param url                    生命周期中的openurl
 *  @param options           生命周期中的options
 */
- (void)handleOpenUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

/**
 *  订阅continueUserActivity
 *
 *  @param userActivity                    生命周期中的userActivity
 */
- (void)continueUserActivity:(nonnull NSUserActivity *)userActivity;

- (void)setThinkingDataAccountId:(NSString *)accountId;
- (void)setAppsFlyerCustomUserId:(NSString *)userId;

@end
