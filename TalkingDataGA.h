//
//  TalkingDataGA.h
//  TalkingDataGA
//
//  Created by Biao Hou on 11-11-14.
//  Copyright (c) 2011年 tendcloud. All rights reserved.
//

#import <Foundation/Foundation.h>


// 账户类型
typedef enum {
    kProfileAnonymous       = 0,    // 匿名账户
    kProfileRegistered      = 1,    // 显性注册账户
    kProfileSinaWeibo       = 2,    // 新浪微博
    kProfileQQ              = 3,    // QQ账户
    kProfileTencentWeibo    = 4,    // 腾讯微博
    kProfileND91            = 5,    // 91账户
    kProfileTypeWeiXin      = 6,    // 微信
    kProfileType1           = 11,   // 预留1
    kProfileType2           = 12,   // 预留2
    kProfileType3           = 13,   // 预留3
    kProfileType4           = 14,   // 预留4
    kProfileType5           = 15,   // 预留5
    kProfileType6           = 16,   // 预留6
    kProfileType7           = 17,   // 预留7
    kProfileType8           = 18,   // 预留8
    kProfileType9           = 19,   // 预留9
    kProfileType10          = 20    // 预留10
} TDGAProfileType;

// 性别
typedef enum {
    kGenderUnknown          = 0,    // 未知
    kGenderMale             = 1,    // 男
    kGenderFemale           = 2     // 女
} TDGAGender;

typedef NS_ENUM(NSUInteger, TDGAVendorIdType) {
    TDGAVendorIdTypeZX      = 1,   // 卓信
    TDGAVendorIdTypeGX      = 2,   // 广协
};




@interface TalkingDataGA: NSObject

/**
 *  @method getDeviceId 获取设备id
 */
+ (NSString *)getDeviceId;

+ (void)setVendorID:(NSString *)vendorID ofType:(TDGAVendorIdType)type;

/**
 *  @method setVerboseLogDisabled 设置不显示日志  如发布时不需显示日志，应当最先调用该方法
 */
+ (void)setVerboseLogDisabled;

/**
 *  @method backgroundSessionEnabled
 *  开启后台使用时长统计，需在SDK初始化之前调用。
 */
+ (void)backgroundSessionEnabled;

/**
 *	@method	onStart     初始化统计实例     请在application:didFinishLaunchingWithOptions:方法里调用
 *	@param 	appId       appId           类型:NSString     应用的唯一标识，统计后台注册得到
 *  @param 	channelId   渠道名(可选)      类型:NSString     如“app store”
 */
+ (void)onStart:(NSString *)appId withChannelId:(NSString *)channelId;

/**
 *	@method	onEvent     自定义事件
 *	@param 	eventId     事件ID    类型:NSString
 *	@param 	eventData   事件参数   类型:键值对(key只支持NSString, value支持NSString和NSNumber)
 */
+ (void)onEvent:(NSString *)eventId eventData:(NSDictionary *)eventData;

/**
 *  @method setLatitude 设置经纬度
 *  @param  latitude    纬度      类型:double
 *  @param  longitude   经度      类型:double
 */
+ (void)setLatitude:(double)latitude longitude:(double)longitude;


@end





@interface TDGAProfile : NSObject

/**
 *	@method	setProfile  设置账户
 *	@param 	profileId   账户ID    类型:NSString
 */
+ (TDGAProfile *)setProfile:(NSString *)profileId;

/**
 *	@method	setProfileName  设置账户名称
 *	@param 	profileName     账户名称    类型:NSString
 */
- (void)setProfileName:(NSString *)profileName;

/**
 *	@method	setProfileType  设置账户类型
 *	@param 	profileType     账户类型        类型TDGAProfileType
 */
- (void)setProfileType:(TDGAProfileType)profileType;

/**
 *	@method	setLevel    设置账户等级
 *	@param 	level       升级之后的等级     类型:int
 */
- (void)setLevel:(int)level;

/**
 *	@method	setGender   设置性别
 *	@param 	gender      性别      类型:TDGAGender
 */
- (void)setGender:(TDGAGender)gender;

/**
 *	@method	setAge  设置年龄
 *	@param 	age     年龄      类型:int
 */
- (void)setAge:(int)age;

/**
 *	@method	setGameServer   设置区服
 *	@param  gameServer      区服      类型:NSString
 */
- (void)setGameServer:(NSString *)gameServer;

@end





@interface TDGAMission : NSObject

/**
 *	@method	onBegin     开始一项任务
 *	@param 	missionId   任务名称    类型:NSString
 */
+ (void)onBegin:(NSString *)missionId;

/**
 *	@method	onCompleted 完成一项任务
 *	@param 	missionId   任务名称    类型:NSString
 */
+ (void)onCompleted:(NSString *)missionId;

/**
 *	@method	onFailed    一项任务失败
 *	@param 	missionId   任务名称    类型:NSString
 *	@param 	cause       失败原因    类型:NSString
 */
+ (void)onFailed:(NSString *)missionId failedCause:(NSString *)cause;

@end





@interface TDGAVirtualCurrency : NSObject

/**
 *	@method	onChargeRequst          虚拟币充值请求
 *	@param 	orderId                 订单id        类型:NSString
 *	@param 	iapId                   充值包id      类型:NSString
 *	@param 	currencyAmount          现金金额      类型:double
 *	@param 	currencyType            币种          类型:NSString
 *	@param 	virtualCurrencyAmount   虚拟币金额    类型:double
 *	@param 	paymentType             支付类型      类型:NSString
 */
+ (void)onChargeRequst:(NSString *)orderId
                 iapId:(NSString *)iapId
        currencyAmount:(double)currencyAmount
          currencyType:(NSString *)currencyType
 virtualCurrencyAmount:(double)virtualCurrencyAmount
           paymentType:(NSString *)paymentType;

/**
 *	@method	onChargeRequst          虚拟币充值请求
 *	@param 	orderId                 订单id        类型:NSString
 */
+ (void)onChargeSuccess:(NSString *)orderId;

/**
 *  @method onReward                虚拟币赠送
 *  @param  virtualCurrencyAmount   虚拟币金额         类型:double
 *  @param  reason                  赠送虚拟币的原因    类型:NSString
 */
+ (void)onReward:(double)virtualCurrencyAmount reason:(NSString *)reason;

@end





@interface TDGAItem : NSObject

/**
 *	@method	onPurchase  虚拟物品购买
 *	@param 	item        道具           类型:NSString
 *	@param 	number      道具个数        类型:int
 *	@param 	price       道具单价        类型:double
 */
+ (void)onPurchase:(NSString *)item itemNumber:(int)number priceInVirtualCurrency:(double)price;

/**
 *	@method	onPurchase  虚拟物品消耗
 *	@param 	item        道具           类型:NSString
 *	@param 	number      道具个数        类型:int
 */
+ (void)onUse:(NSString *)item itemNumber:(int)number;

@end
