//
//  Yodo1Tool+OpsParameters.m
//  Yodo1UCManager
//
//  Created by yixian huang on 2020/5/6.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Tool+PayParameters.h"

#define __PRODUCT_TEST__  0

@implementation Yodo1Tool (PayParameters)

- (NSString *)paymentDomain {
#if __PRODUCT_TEST__ == 1 //测试环境
    return @"https://api-payment-test.yodo1.com";
#elif __PRODUCT_TEST__ == 2 //准生产
    return @"https://payment-stg.yodo1api.com";
#else
    return @"https://payment.yodo1api.com";
#endif
}

- (NSString *)generateOrderIdURL {
    return @"payment/order/generateOrderId";
}

- (NSString *)createOrderURL {
    return @"payment/order/create";
}

- (NSString *)getOrderStatusURL {
    return @"payment/order/getOrderStatus";
}

//修改订单日志，不会修改订单状态
- (NSString *)reportOrderStatusURL {
    return @"payment/order/reportOrderStatus";
}

//获取掉单Orders
- (NSString *)queryLossOrdersURL {
    return @"payment/order/offlineMissorders";
}

//查询订阅商品
- (NSString *)querySubscriptionsURL {
    return @"payment/channel/appStore/querySubscriptions";
}

//修改订单状态
- (NSString *)clientCallbackURL {
    return @"payment/order/ClientCallback";
}

//
- (NSString *)clientNotifyForSyncUnityStatusURL {
    return @"payment/order/clientNotifyForSyncUnityStatus";
}

//和Apple商店验证订单
- (NSString *)verifyAppStoreIAPURL {
    return @"payment/channel/appStore/payVerify";
}

//通知服务端商品发给玩家成功
- (NSString *)sendGoodsSuccessURL {
    return @"payment/order/sendGoodsOver";
}

//通知服务端商品发给玩家失败
- (NSString *)sendGoodsFailURL {
    return @"payment/order/sendGoodsOverForFault";
}

@end
