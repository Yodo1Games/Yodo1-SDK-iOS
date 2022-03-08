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
@property (nonatomic,strong) NSMutableArray *gaCustomDimensions01;//GA统计自定义维度
@property (nonatomic,strong) NSMutableArray *gaCustomDimensions02;
@property (nonatomic,strong) NSMutableArray *gaCustomDimensions03;
@property (nonatomic,strong) NSMutableArray *gaResourceCurrencies;
@property (nonatomic,strong) NSMutableArray *gaResourceItemTypes;
@property (nonatomic,strong) NSString *appsflyerCustomUserId;//AppsFlyer自定义UserId
@end

typedef NS_ENUM(NSInteger, AnalyticsType) {
    AnalyticsTypeUmeng,         //友盟数据统计
    AnalyticsTypeTalkingData,   //TalkingData数据统计
    AnalyticsTypeGameAnalytics, //GameAnalytics数据统计
    AnalyticsTypeAppsFlyer,     //AppsFlyer 数据统计
    AnalyticsTypeSwrve,          //Swrve统计
    AnalyticsTypeThinking,         //Thinking
    AnalyticsTypeFirebase,         //Firebase
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

/*
 * appsFlyer安装判断
 */
- (BOOL)isAppsFlyerInstalled;

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
- (void)eventAdAnalyticsWithName:(NSString *)eventName 
                       eventData:(NSDictionary *)eventData;
/**
 *  进入关卡/任务
 *
 *  @param level 关卡/任务
 */
- (void)startLevelAnalytics:(NSString*)level;

/**
 *  完成关卡/任务
 *
 *  @param level 关卡/任务
 */
- (void)finishLevelAnalytics:(NSString*)level;

/**
 *  未通过关卡
 *
 *  @param level 关卡/任务
 *  @param cause 未通过原因
 */
- (void)failLevelAnalytics:(NSString*)level failedCause:(NSString*)cause;

/**
 *  设置玩家等级
 *
 *  @param level 等级
 */
- (void)userLevelIdAnalytics:(int)level;

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
                  paymentType:(NSString *)paymentType;

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
- (void)chargeSuccessAnalytics:(NSString *)orderId source:(int)source;

/**
 *  游戏中获得虚拟币
 *
 *  @param virtualCurrencyAmount 虚拟币金额         类型:double
 *  @param reason                赠送虚拟币的原因    类型:NSString
 *  @param source                奖励渠道	取值在 1~10 之间。“1”已经被预先定义为“系统奖励”，2~10 需要在网站设置含义          类型：int
 */
- (void)rewardAnalytics:(double)virtualCurrencyAmount reason:(NSString *)reason source:(int)source;

/**
 *  虚拟物品购买/使用虚拟币购买道具
 *
 *  @param item   道具           类型:NSString
 *  @param number 道具个数        类型:int
 *  @param price  道具单价        类型:double
 */
- (void)purchaseAnalytics:(NSString *)item itemNumber:(int)number priceInVirtualCurrency:(double)price;

/**
 *   虚拟物品消耗/玩家使用虚拟币购买道具
 *
 *  @param item   道具名称
 *  @param amount 道具数量
 *  @param price  道具单价
 */
- (void)useAnalytics:(NSString *)item amount:(int)amount price:(double)price;

#pragma mark- 友盟计时事件

- (void)beginEvent:(NSString *)eventId;

- (void)endEvent:(NSString *)eventId;

#pragma mark- DplusMobClick接口

/** Dplus增加事件
 @param eventName 事件名
 */
- (void)track:(NSString *)eventName;

/** Dplus增加事件
 @param eventName 事件名
 @param propertyKey 自定义属性key
 @param propertyValue 自定义属性Value
 */
- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
                 propertyValue:(NSString *)propertyValue;

/** Dplus增加事件 重载
 @param eventName 事件名
 @param propertyKey 自定义属性key
 @param propertyValue 自定义属性Value
 */
- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
              propertyIntValue:(int)propertyValue;

/** Dplus增加事件 重载
 @param eventName 事件名
 @param propertyKey 自定义属性key
 @param propertyValue 自定义属性Value
 */
- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
            propertyFloatValue:(float)propertyValue;

/** Dplus增加事件 重载
 @param eventName 事件名
 @param propertyKey 自定义属性key
 @param propertyValue 自定义属性Value
 */
- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
           propertyDoubleValue:(double)propertyValue;

/** Dplus增加事件:提交之前保存增加事件属性(一次性提交)
 @param eventName 事件名
 */
- (void)submitTrackWithEventName:(NSString *)eventName;

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
 *
 * 返回dplus专用文件中key对应的value；如果不存在，则返回空。
 @param propertyName 属性名
 @return NSString
 */
- (NSString *)getSuperProperty:(NSString *)propertyName;

/**
 * 返回Dplus专用文件中的所有key-value；如果不存在，则返回空。
 */
- (NSDictionary *)getSuperProperties;

/**
 *清空Dplus专用文件中的所有key-value。
 */
- (void)clearSuperProperties;

#pragma mark- GameAnalytics接口
/**
 *  GameAnalytics 设置维度01类型
 **/
- (void)setGACustomDimension01:(NSString*)dimension01;
/**
 *  GameAnalytics 设置维度02类型
 **/
- (void)setGACustomDimension02:(NSString*)dimension02;

/**
 *  GameAnalytics 设置维度03类型
 **/
- (void)setGACustomDimension03:(NSString*)dimension03;

/**
 *  AppsFlyer Apple 内付费验证和事件统计
 */
- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId;

/**
 *  Swrve 事件统计
 */
- (void)swrveEventAnalyticsWithName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData;

/**
 *  Swrve 更新用户数据事件
 */
- (void)swrveUserUpdate:(NSDictionary *)eventData;

/**
 *  Swrve 内付费验证和事件统计
 */
- (void)swrveTransactionProcessed:(SKPaymentTransaction*) transaction
                    productBought:(SKProduct*) product;


/**
 *  订阅openURL
 *
 *  @param application  生命周期中的application
 *  @param url                    生命周期中的openurl
 *  @param options           生命周期中的options
 */
- (void)SubApplication:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

/**
 *  订阅continueUserActivity
 *
 *  @param application                      生命周期中的application
 *  @param userActivity                    生命周期中的userActivity
 *  @param restorationHandler       生命周期中的restorationHandler
 */
- (void)SubApplication:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler;

@end
