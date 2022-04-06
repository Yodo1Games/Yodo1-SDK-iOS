//
//  Yd1UCenter.h
//
//  Created by yixian huang on 2017/7/24.
//
//

#ifndef Yd1UCenter_h
#define Yd1UCenter_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YD1User : NSObject <NSSecureCoding>
/// 玩家Id
@property(nonatomic,strong)NSString* playerid;
/// 玩家昵称
@property(nonatomic,strong)NSString* nickname;
/// ucuid
@property(nonatomic,strong)NSString* ucuid;

/// 用户在每个游戏中对应的id
@property(nonatomic,strong)NSString* yid;
/// 用户的唯一id
@property(nonatomic,strong)NSString* uid;
/// token
@property(nonatomic,strong)NSString* token;
/// 标志用户是否联网登记实名制信息;0为未联网登记, 1为联网验证登记
@property(nonatomic,assign)int isOLRealName;
/// 标志用户是否本地登记实名制信息;0为未本地登记，1为本地验证登记
@property(nonatomic,assign)int isRealName;
/// 是否是新用户
@property(nonatomic,assign)int isnewuser;
/// 是否是新注册的用户
@property(nonatomic,assign)int isnewyaccount;
/// extra
@property(nonatomic,strong)NSString* extra;

@end

@interface YD1ItemInfo : NSObject
/// 产品ID
@property (nonatomic,strong)NSString *productId;
/// payment订单号
@property (nonatomic,strong)NSString *orderId;
/// 订单号(苹果transaction_id)
@property (nonatomic,strong)NSString *channelOrderid;
/// 不传默认0 商品类型,0-不可消耗;1-可消耗;2-自动订阅;3-非自动订阅
@property (nonatomic,assign)int product_type;
/// 是否获得所有数据
@property (nonatomic,strong)NSString *exclude_old_transactions;
/// 道具代码(同IAP代码)
@property (nonatomic,strong)NSString *item_code;
/// playerid
@property (nonatomic,strong)NSString *playerid;
/// 用户id
@property (nonatomic,strong)NSString *uid;
/// yid
@property (nonatomic,strong)NSString *yid;
/// 登录时，返回的ucuid（登陆uc的情况使用）
@property (nonatomic,strong)NSString *ucuid;
/// 例如idfa等设备id
@property (nonatomic,strong)NSString *deviceid;
/// 苹果验证收据
@property (nonatomic,strong)NSString *trx_receipt;
/// true为连接沙盒环境，不传或其他为正式环境
@property (nonatomic,strong)NSString *is_sandbox;
/// 附加信息
@property (nonatomic,strong)NSString *extra;
/// 渠道号 - AppStore
@property (nonatomic,strong)NSString *channelCode;
/// 失败订单的三方返回code
@property (nonatomic,strong)NSString *statusCode;
/// 三方返回的msg，可空
@property (nonatomic,strong)NSString *statusMsg;

@end

@interface SubscriptionInfo : NSObject
///通用产品id
@property (nonatomic, retain) NSString* uniformProductId;
///渠道产品id:比如91的产品id，AppStore的产品
@property (nonatomic, retain) NSString* channelProductId;
///过期时间
@property (nonatomic, assign) NSTimeInterval expiresTime;
///购买时间
@property (nonatomic, assign) NSTimeInterval purchase_date_ms;

- (id)initWithUniformProductId:(NSString*)uniformProductId
              channelProductId:(NSString*)channelProductId
                       expires:(NSTimeInterval)expiresTime
                  purchaseDate:(NSTimeInterval)purchaseDateMs;
@end

@interface Yd1UCenter:NSObject

@property(nonatomic,strong)NSString* regionCode;
@property(nonatomic,strong)YD1ItemInfo* itemInfo;

+ (instancetype)shared;

/**
 *  设备登录
 *  @param playerId 是玩家id
 */
- (void)deviceLoginWithPlayerId:(NSString *)playerId
                       callback:(void(^)(YD1User* _Nullable user, NSError* _Nullable  error))callback;

/**
 *  创建订单号
 */
- (void)generateOrderId:(void (^)(NSString* _Nullable orderId,NSError* _Nullable error))callback;

/**
 *  创建订单
 */
- (void)createOrder:(NSDictionary*) parameter
           callback:(void (^)(int error_code,NSString* error))callback;

/**
 *  App Store verify IAP
 */
- (void)verifyAppStoreIAPOrder:(YD1ItemInfo *)itemInfo
                      callback:(void (^)(BOOL verifySuccess,NSString* response,NSError* error))callback;

/**
 * 查询订阅
 */
- (void)querySubscriptions:(YD1ItemInfo *)itemInfo
                  callback:(void (^)(BOOL success,NSString* _Nullable response,NSError* _Nullable error))callback;

/**
 * 通知已发货成功
 */
- (void)sendGoodsOver:(NSString *)orderIds
             callback:(void (^)(BOOL success,NSString* error))callback;


/**
 * 通知已发货失败
 */
- (void)sendGoodsOverForFault:(NSString *)orderIds
                     callback:(void (^)(BOOL success,NSString* error))callback;

/**
 *  上报订单已支付成功接口
 */
- (void)clientCallback:(YD1ItemInfo *)itemInfo callbakc:(void (^)(BOOL success,NSString* error))callback;

/**
 *  上报支付失败接口
 */
- (void)reportOrderStatus:(YD1ItemInfo *)itemInfo callbakc:(void (^)(BOOL success,NSString* error))callback;

/**
 *  客户端通知服务端已同步unity接口
 */
- (void)clientNotifyForSyncUnityStatus:(NSArray *)orderIds
                              callback:(void (^)(BOOL success,NSArray* notExistOrders,NSArray* notPayOrders,NSString* error))callback;

/**
 *  查询漏单接口（单机版，支持SDK V4.0）
 */
- (void)offlineMissorders:(YD1ItemInfo *)itemInfo
                 callback:(void (^)(BOOL success,NSArray* missorders,NSString* error))callback;

/**
 * 激活码/优惠券
 */
- (void)verifyActivationcode:(NSString *)code
                    callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSString* _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
#endif /* Yd1UCenter_h */
