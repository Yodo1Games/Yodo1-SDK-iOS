//
//  Yodo1PurchaseAPI.h
//
//  Created by yixian huang on 2017/7/24.
//
//

#ifndef Yodo1PurchaseAPI_h
#define Yodo1PurchaseAPI_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1UCenter.h"
#import "Yodo1Product.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1Transaction : NSObject

// IAP Payment订单号
@property (nonatomic,strong)NSString *orderId;
// 订单号(苹果transaction_id)
@property (nonatomic,strong)NSString *channelOrderid;

// 产品ID
@property (nonatomic,strong)NSString *productId;
// 道具代码(同IAP代码)
@property (nonatomic,strong)NSString *item_code;
// 默认0 商品类型,0-非消耗品;1-消耗品;2-自动订阅;3-非自动订阅
@property (nonatomic,assign)int product_type;

// 例如idfa等设备id
@property (nonatomic,strong)NSString *deviceid;

// 苹果验证收据
@property (nonatomic,strong)NSString *trx_receipt;
// true为连接沙盒环境，不传或其他为正式环境
@property (nonatomic,strong)NSString *is_sandbox;
// 附加信息
@property (nonatomic,strong)NSString *extra;
//@property (nonatomic,strong)NSString *channelCode;            // 渠道号 - AppStore
// 是否获得所有数据
@property (nonatomic,strong)NSString *exclude_old_transactions;
// 失败订单的三方返回code
@property (nonatomic,strong)NSString *statusCode;
// 三方返回的msg，可空
@property (nonatomic,strong)NSString *statusMsg;

@end

@interface SubscriptionProductInfo : NSObject

@property (nonatomic, retain) NSString* uniformProductId;       //通用产品id
@property (nonatomic, retain) NSString* channelProductId;       //渠道产品id:比如91的产品id，AppStore的产品
@property (nonatomic, assign) NSTimeInterval expiresTime;       //过期时间
@property (nonatomic, assign) NSTimeInterval purchase_date_ms;  //购买时间

- (id)initWithUniformProductId:(NSString*)uniformProductId
              channelProductId:(NSString*)channelProductId
                       expires:(NSTimeInterval)expiresTime
                  purchaseDate:(NSTimeInterval)purchaseDateMs;
@end

@interface Yodo1PurchaseAPI : NSObject

@property(nonatomic,strong)NSString* gameAppKey;
@property(nonatomic,strong)NSString* regionCode;
@property(nonatomic,strong)Yodo1Transaction* transaction;

+ (instancetype)shared;

- (void)init:(NSString *)appKey regionCode:(NSString *)regionCode;

/// Generate an order id from IAP payment
///
/// - Parameter callback: NSString *orderId - An order id that generate by IAP payment, NSError *error - An error when failed to generate an order id from IAP payment
- (void)generateOrderId:(void (^)(NSString* _Nullable orderId, NSError* _Nullable error))callback;

/**
 *  创建订单
 */
- (void)createOrder:(NSDictionary*) parameter
           callback:(void (^)(BOOL success, NSError* error))callback;

/**
 *  App Store verify IAP
 */
- (void)verifyOrder:(Yodo1Transaction *)transaction
               user:(YD1User *)user
           callback:(void (^)(BOOL verifySuccess,NSString* response,NSError* error))callback;

/**
 *  上报订单已支付成功接口
 */
- (void)reportOrderSuccess:(Yodo1Transaction *)transaction
                  callback:(void (^)(BOOL success,NSString* error))callback;

/**
 *  上报支付失败接口
 */
- (void)reportOrderFail:(Yodo1Transaction *)transaction
               callback:(void (^)(BOOL success,NSString* error))callback;

/**
 *  客户端通知服务端已同步unity接口
 */
- (void)clientNotifyToServer:(NSArray *)orderIds
                    callback:(void (^)(BOOL success,NSArray* notExistOrders,NSArray* notPayOrders,NSString* error))callback;


/**
 * 查询订阅
 */
- (void)querySubscriptions:(Yodo1Transaction *)transaction
                  callback:(void (^)(BOOL success,NSString* _Nullable response,NSError* _Nullable error))callback;

/**
 * 通知已发货成功
 */
- (void)sendGoodsSuccess:(NSString *)orderIds
                callback:(void (^)(BOOL success,NSString* error))callback;

/**
 * 通知已发货失败
 */
- (void)sendGoodsFail:(NSString *)orderIds
             callback:(void (^)(BOOL success,NSString* error))callback;


/**
 *  查询漏单接口（单机版，支持SDK V4.0）
 */
- (void)queryLossOrders:(YD1User *)user
               callback:(nonnull void (^)(BOOL success, NSArray * _Nonnull missorders, NSString* _Nonnull error))callback;

/**
 *  查询订单状态
 */
- (void)queryOrderStatus:(NSString *)orderId
                callback:(nonnull void (^)(BOOL success, NSString * _Nonnull status, NSString* _Nonnull error))callback;

@end

NS_ASSUME_NONNULL_END
#endif /* Yodo1PurchaseAPI_h */
