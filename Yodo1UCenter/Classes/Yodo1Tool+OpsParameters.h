//
//  Yodo1Tool+OpsParameters.h
//  Yodo1UCManager
//
//  Created by yixian huang on 2020/5/6.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Tool.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1Tool (OpsParameters)
/// ops 
- (NSString *)ucapDomain;
- (NSString *)deviceLoginURL;

- (NSString *)paymentDomain;
- (NSString *)generateOrderIdURL;
- (NSString *)verifyAppStoreIAPURL;
- (NSString *)querySubscriptionsURL;
- (NSString *)sendGoodsOverURL;
- (NSString *)sendGoodsOverFaultURL;
- (NSString *)reportOrderStatusURL;
- (NSString *)clientCallbackURL;
- (NSString *)createOrderURL;
- (NSString *)clientNotifyForSyncUnityStatusURL;
- (NSString *)offlineMissordersURL;

@end

NS_ASSUME_NONNULL_END
