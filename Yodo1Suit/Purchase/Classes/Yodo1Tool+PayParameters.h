//
//  Yodo1Tool+OpsParameters.h
//  Yodo1UCManager
//
//  Created by yixian huang on 2020/5/6.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Tool.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1Tool (PayParameters)

- (NSString *)paymentDomain;
- (NSString *)generateOrderIdURL;
- (NSString *)createOrderURL;
- (NSString *)getOrderStatusURL;
- (NSString *)reportOrderStatusURL;
- (NSString *)queryLossOrdersURL;
- (NSString *)querySubscriptionsURL;
- (NSString *)clientCallbackURL;
- (NSString *)clientNotifyForSyncUnityStatusURL;
- (NSString *)verifyAppStoreIAPURL;
- (NSString *)sendGoodsSuccessURL;
- (NSString *)sendGoodsFailURL;

@end

NS_ASSUME_NONNULL_END
