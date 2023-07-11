//
//  Yodo1PurchaseManager.h
//
//  Created by yixian huang on 2017/7/24.
//
//

#ifndef Yodo1PurchaseManager_h
#define Yodo1PurchaseManager_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1UCenter.h"
#import "Yodo1Product.h"

NS_ASSUME_NONNULL_BEGIN



typedef enum {
    PaymentFail = 0,
    PaymentSuccess = 1,
    PaymentCancel = 2,
    PaymentVerifyOrderFail = 3
}PaymentState;

typedef enum {
    PaymentErrorCodeUnKnow = -2,            //Error code indicating that an unknown or unexpected error occurred.
    PaymentErrorCodeNotNetwork = -1,        //Error code indicating that no network
    PaymentErrorCodeFail = 0,               //
    PaymentErrorCodeSuccess = 1,            //
    PaymentErrorCodeCancelled = 2,          //Error code indicating that the user canceled a payment request.
    PaymentErrorCodeVerifyOrderFail = 3,    //Error code indicating that failed to verify order by IAP payment.
    PaymentErrorCodeCannelForPrivacy = 4,   //Error code indicating that purchase cancelled when the user click the Terms of Service and Privacy Agreement buttons.
    PaymentErrorCodeUserLoginFail = 103,    //Error code indicating that the user is not logged in Yodo1 ucenter
    PaymentErrorCodeLossOrderId = 203,      //丢失订单
    PaymentErrorCodeUserFail = 205,         //设备不允许支付
    PaymentErrorCodeCreateOrder = 206,      //Failed to create the order from IAP payment
    PaymentErrorCodeOwn = 208,              //用户已经拥有该商品
    PaymentErrorCodeInvalidProductId = 209, //Error code indicating that the product identifier is invalid.
    PaymentErrorCodeAppleFail = 210,
}PaymentErrorCode;

typedef enum {
    Default = 0,
    Visible,
    Hide
}PromotionVisibility;

@class Yodo1Product;
@class PaymentObject;

typedef void (^PaymentCallback) (PaymentObject* payemntObject);
typedef void (^RestoreCallback)(NSArray* productIds,NSString* response);
typedef void (^LossOrderCallback)(NSArray* productIds,NSString* response);
typedef void (^FetchStorePromotionOrderCallback) (NSArray<NSString *> *  storePromotionOrder, BOOL success, NSString*  error);
typedef void (^FetchStorePromotionVisibilityCallback) (PromotionVisibility storePromotionVisibility, BOOL success, NSString*  error);
typedef void (^UpdateStorePromotionOrderCallback) (BOOL success, NSString*  error);
typedef void (^UpdateStorePromotionVisibilityCallback)(BOOL success, NSString*  error);
typedef void (^ProductsInfoCallback) (NSArray<Yodo1Product*> *productInfo);

/**
 *@brief
 *  查询订阅信息接口
 *@param success YES查询订阅信息成功，NO查询订阅信息失败。
 *@param subscriptions 订阅信息
 *@param serverTime 当前服务器时间
 *@error 错误信息
 */
typedef void (^QuerySubscriptionCallback)(NSArray* subscriptions, NSTimeInterval serverTime, BOOL success,NSString* _Nullable error);

/**
 *@brief
 *   苹果支付订单验证票据回调方法
 *@param uniformProductId 产品ID
 *@param response json格式 @{@"productIdentifier":@"苹果产品id",
 *  @"transactionIdentifier":@"订单号",@"transactionReceipt":@"验证票据"}
 */
typedef void (^ValidatePaymentBlock) (NSString *uniformProductId,NSString* response);

@interface PaymentObject : NSObject
@property (nonatomic, strong) NSString* uniformProductId;
@property (nonatomic, strong) NSString* orderId;
@property (nonatomic, strong) NSString* channelOrderid;
@property (nonatomic, assign) PaymentState paymentState;
@property (nonatomic, strong) NSString* response;
@property (nonatomic, strong) NSError* error;
@end

@class YD1User;

@interface Yodo1PurchaseManager : NSObject

+ (instancetype)shared;

- (void)willInit;

@property (nonatomic,assign)__block BOOL isLogined;
@property (nonatomic,strong)__block YD1User* user;

/// 苹果支付票据回调
@property (nonatomic,copy)ValidatePaymentBlock  validatePaymentBlock;

/**
 *  根据channelProductId 获取uniformProductId
 */
- (NSString *)uniformProductIdWithChannelProductId:(NSString *)channelProductId;

/**
 *  创建订单号和订单，返回订单号
 */
- (void)createOrderIdWithUniformProductId:(NSString *)uniformProductId
                                    extra:(NSString*)extra
                                 callback:(void (^)(bool success, NSString * orderid, NSError* error))callback;

/**
 * 购买产品
 * extra 是字典json字符串 @{@"channelUserid":@""}
 */
- (void)paymentWithUniformProductId:(NSString *)uniformProductId
                              extra:(NSString*)extra
                           callback:(PaymentCallback)callback;

/**
 *  恢复购买
 */
- (void)restorePayment:(RestoreCallback)callback;

/**
 *  查询漏单
 */
- (void)queryLossOrder:(LossOrderCallback)callback;

/**
 *  查询订阅
 */
- (void)querySubscriptions:(BOOL)excludeOldTransactions
                  callback:(QuerySubscriptionCallback)callback;

/**
 *  获取产品信息
 */
- (void)productWithUniformProductId:(NSString*)uniformProductId
                           callback:(ProductsInfoCallback)callback;

/**
 *  获取所有产品信息
 */
- (void)products:(ProductsInfoCallback)callback;

/**
 *  获取促销订单
 */
- (void)fetchStorePromotionOrder:(FetchStorePromotionOrderCallback) callback;

/**
 *  获取促销活动订单可见性
 */
- (void)fetchStorePromotionVisibilityForProduct:(NSString*)uniformProductId
                                       callback:(FetchStorePromotionVisibilityCallback)callback;
/**
 *  更新促销活动订单
 */
- (void)updateStorePromotionOrder:(NSArray<NSString *> *)uniformProductIdArray
                         callback:(UpdateStorePromotionOrderCallback)callback;

/**
 *  更新促销活动可见性
 */
- (void)updateStorePromotionVisibility:(BOOL)visibility
                               product:(NSString*)uniformProductId
                              callback:(UpdateStorePromotionVisibilityCallback)callback;

/**
 *  准备继续购买促销
 */
- (void)readyToContinuePurchaseFromPromot:(PaymentCallback)callback;

/**
 *  取消购买
 */
- (void)cancelPromotion;

/**
 *  获取促销产品
 */
- (Yodo1Product*)promotionProduct;

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
 * 激活码/优惠券
 */
- (void)verifyWithActivationCode:(NSString *)activationCode
                    callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSDictionary* _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
#endif /* Yodo1PurchaseManager_h */
