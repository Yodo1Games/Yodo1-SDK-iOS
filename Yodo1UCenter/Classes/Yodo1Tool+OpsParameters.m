//
//  Yodo1Tool+OpsParameters.m
//  Yodo1UCManager
//
//  Created by yixian huang on 2020/5/6.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Tool+OpsParameters.h"

#define __PRODUCT_EVN__  0

@implementation Yodo1Tool (OpsParameters)

- (NSString *)ucapDomain {
#if __PRODUCT_EVN__ == 1 //测试环境
    return @"https://api-ucap-test.yodo1.com/uc_ap";
#elif __PRODUCT_EVN__ == 2 //准生产
    return @"https://uc-ap-stg.yodo1api.com/uc_ap";
#else
    return @"https://uc-ap.yodo1api.com/uc_ap";
#endif
}

- (NSString *)deviceLoginURL {
    return @"channel/device/login";
}

- (NSString *)paymentDomain {
#if __PRODUCT_EVN__ == 1 //测试环境
    return @"https://api-payment-test.yodo1.com";
#elif __PRODUCT_EVN__ == 2 //准生产
    return @"https://payment-stg.yodo1api.com";
#else
    return @"https://payment.yodo1api.com";
#endif
}

- (NSString *)generateOrderIdURL {
    return @"payment/order/generateOrderId";
}

- (NSString *)verifyAppStoreIAPURL {
    return @"payment/channel/appStore/payVerify";
}

- (NSString *)querySubscriptionsURL {
    return @"payment/channel/appStore/querySubscriptions";
}

- (NSString *)sendGoodsOverURL {
    return @"payment/order/sendGoodsOver";
}

- (NSString *)sendGoodsOverFaultURL {
    return @"payment/order/sendGoodsOverForFault";
}

- (NSString *)reportOrderStatusURL {
    return @"payment/order/reportOrderStatus";
}

- (NSString *)clientCallbackURL {
    return @"payment/order/ClientCallback";
}

- (NSString *)createOrderURL {
    return @"payment/order/create";
}

- (NSString *)clientNotifyForSyncUnityStatusURL {
    return @"payment/order/clientNotifyForSyncUnityStatus";
}

- (NSString *)offlineMissordersURL {
    return @"payment/order/offlineMissorders";
}

@end
