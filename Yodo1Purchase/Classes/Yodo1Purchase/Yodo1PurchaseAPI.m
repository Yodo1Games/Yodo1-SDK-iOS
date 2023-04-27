//
//  Yodo1PurchaseAPI.m
//  Yodo1PurchaseAPI
//
//  Created by yixian huang on 2017/7/24.
//

#import "Yodo1PurchaseAPI.h"
#import "Yodo1AFNetworking.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+PayParameters.h"
#import "Yodo1KeyInfo.h"

@implementation Yodo1Transaction
@end

@implementation SubscriptionProductInfo

- (id)initWithUniformProductId:(NSString*)m_uniformProductId
              channelProductId:(NSString*)m_channelProductId
                       expires:(NSTimeInterval)m_expiresTime
                  purchaseDate:(NSTimeInterval)m_purchaseDateMs {
    self = [super init];
    if (self) {
        self.uniformProductId = m_uniformProductId == nil ? @"ERROR_PRODUCT_NOT_FOUND":m_uniformProductId;
        self.channelProductId = m_channelProductId;
        self.expiresTime = m_expiresTime;
        self.purchase_date_ms = m_purchaseDateMs;
    }
    return self;
}
@end

@interface Yodo1PurchaseAPI() {
    
}

@end

@implementation Yodo1PurchaseAPI

+ (instancetype)shared {
    return [Yodo1Base.shared cc_registerSharedInstance:self block:^{
        YD1LOG(@"%s",__PRETTY_FUNCTION__);
        [Yodo1PurchaseAPI.shared willInit];
    }];
}

- (void)willInit {
    if (_transaction == nil) {
        _transaction = [[Yodo1Transaction alloc]init];
        _transaction.deviceid = Yd1OpsTools.keychainDeviceId;
        _transaction.extra = @"";
        _transaction.is_sandbox = @"false";
        _transaction.statusCode = @"1";
        _transaction.statusMsg = @"";
        _transaction.exclude_old_transactions = @"false";
    }
    _gameAppKey = [Yodo1KeyInfo.shareInstance configInfoForKey:@"GameKey"]? :@"";
    _regionCode = [Yodo1KeyInfo.shareInstance configInfoForKey:@"RegionCode"]? :@"";
}

/// Generate an order id from IAP payment, please check here(https://confluence.yodo1.com/display/OPP/generateOrderId) for the details
///
/// - Parameter callback: NSString *orderId - An order id that generate by IAP payment, NSError *error - An error when failed to generate an order id from IAP payment
- (void)generateOrderId:(void (^)(NSString * _Nullable, NSError * _Nullable))callback {
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* timestamp = Yd1OpsTools.nowTimeTimestamp;
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",timestamp]];
    NSDictionary* data = @{
        Yd1OpsTools.timeStamp:timestamp
    };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.generateOrderIdURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* errorMsg = @"";
        NSString* orderId = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            errorMsg = [response objectForKey:Yd1OpsTools.error];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.data]) {
            NSDictionary* m_data = (NSDictionary*)[response objectForKey:Yd1OpsTools.data];
            if ([[m_data allKeys]containsObject:@"orderId"]) {
                orderId = (NSString *)[m_data objectForKey:@"orderId"];
            }
            if (callback) {
                callback(orderId, nil);
            }
        }else{
            if (callback) {
                callback(nil, [NSError errorWithDomain:@"com.yodo1.payment" code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorMsg}]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        if (callback) {
            callback(nil, error);
        }
    }];
}

/**
 *  save订单号
 */
- (void)saveOrderId:(NSString *)orderId withProductId:(NSString *)productIdentifier {
    
    //保存orderId
    NSString* oldOrderIdStr = [Yd1OpsTools keychainWithService:productIdentifier];
    NSArray* oldOrderId = (NSArray *)[Yd1OpsTools JSONObjectWithString:oldOrderIdStr error:nil];
    NSMutableArray* newOrderId = [NSMutableArray array];
    if (oldOrderId) {
        [newOrderId setArray:oldOrderId];
    }
    [newOrderId addObject:orderId];
    NSString* orderidJson = [Yd1OpsTools stringWithJSONObject:newOrderId error:nil];
    [Yd1OpsTools saveKeychainWithService:productIdentifier str:orderidJson];
}

/**
 *  假如error_code:0 error值代表剩余可
 *  花费金额不为0，则是具体返回信息
 *  Create an order id in IAP payment, please check here(https://confluence.yodo1.com/pages/viewpage.action?pageId=24061090) for the details
 */
- (void)createOrder:(NSDictionary*) parameter callback:(void (^)(BOOL success, NSError *))callback {
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* orderId = [parameter objectForKey:@"orderId"];
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",orderId]];
    
    NSDictionary* productInfo = [parameter objectForKey:@"product"];
    
    NSString* itemCode = [parameter objectForKey:@"itemCode"];
    NSString* orderMoney = [parameter objectForKey:@"orderMoney"];
    NSString* uid = [parameter objectForKey:@"uid"];
    NSString* yid = [parameter objectForKey:@"yid"];
    NSString* ucuid = [parameter objectForKey:@"ucuid"];
    NSString* playerId = [parameter objectForKey:@"playerId"];
    NSString* gameName = [parameter objectForKey:@"gameName"];
    NSString* gameType = [parameter objectForKey:@"gameType"];
    NSString* gameVersion = [parameter objectForKey:@"gameVersion"];
    NSString* gameExtra = [parameter objectForKey:@"gameExtra"];
    NSString* channelVersion = [parameter objectForKey:@"channelVersion"];
    
    NSString* extra = [parameter objectForKey:@"extra"];
    NSDictionary* extraDic = (NSDictionary *)[Yd1OpsTools JSONObjectWithString:extra error:nil];
    NSString* channelUserid = @"";
    if (extraDic && [[extraDic allKeys]containsObject:@"channelUserid"]) {
        channelUserid = [extraDic objectForKey:@"channelUserid"];
    }
    
    NSDictionary* deviceInfo = @{
        @"platform":UIDevice.currentDevice.systemName,
        @"originalSystemVersion":UIDevice.currentDevice.systemVersion,
        @"osVersion":UIDevice.currentDevice.systemVersion,
        @"deviceType":UIDevice.currentDevice.model,
        @"manufacturer":@"Apple",
        @"wifi":Yd1OpsTools.networkType,
        @"carrier":Yd1OpsTools.networkOperatorName,
    };
    NSDictionary* data = @{
        @"game_appkey":self.gameAppKey,
        @"region_code":self.regionCode,
        @"channel_code":Yodo1Tool.shared.paymentChannelCodeValue,
        @"pr_channel_code":Yodo1Tool.shared.publishChannelCodeValue,
        @"channel_version":channelVersion,
        @"paymentChannelVersion":Yodo1Tool.shared.sdkVersionValue,
        @"sdkType":Yodo1Tool.shared.sdkTypeValue,
        @"sdkVersion":Yodo1Tool.shared.sdkVersionValue,
        @"orderid":orderId,
        @"order_money":orderMoney,
        @"item_code":itemCode,
        @"uid":uid,
        @"ucuid":ucuid,
        @"yid":yid,
        @"playerId":playerId,
        @"gameName":gameName,
        @"gameBundleId":Yd1OpsTools.appBid,
        @"game_version":gameVersion,
        @"game_type":gameType,
        @"game_extra":gameExtra,
        @"extra":extra,
        @"deviceid":Yd1OpsTools.keychainDeviceId,
        @"deviceInfo":deviceInfo,
        @"productInfo":productInfo,
        @"channelUserid":channelUserid
    };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.createOrderURL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* errorMsg = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            errorMsg = [response objectForKey:Yd1OpsTools.error];
        }
        if (callback) {
            if (errorCode == 0) {
                callback(YES, nil);
            } else {
                callback(NO, [NSError errorWithDomain:@"com.yodo1.payment" code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorMsg}]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        if (callback) {
            callback(NO, error);
        }
    }];
}

- (NSError *)errorWithMsg:(NSString *)msg errorCode:(int)errorCode {
    return [NSError errorWithDomain:@"com.yodo1.payment"
                               code:errorCode
                           userInfo:@{NSLocalizedDescriptionKey:msg? :@""}];
}


/// Verify an order by IAP payment, please check here(https://confluence.yodo1.com/pages/viewpage.action?pageId=24071455) for the details
/// Validating receipts with the App Store: https://developer.apple.com/documentation/storekit/in-app_purchase/original_api_for_in-app_purchase/validating_receipts_with_the_app_store?language=objc
///
/// - Parameters:
///   - transaction: Yodo1Transaction
///   - user: YD1User
///   - callback: <#callback description#>
- (void)verifyOrder:(Yodo1Transaction *)transaction
               user:(YD1User *) user
           callback:(nonnull void (^)(BOOL, NSString * _Nonnull, NSError * _Nonnull))callback {
    if (!transaction) {
        callback(false,@"",[self errorWithMsg:@"order Ids is empty!" errorCode:-1]);
        return;
    }
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",transaction.orderId]];
    NSDictionary* data = @{
        Yd1OpsTools.gameAppKey:self.gameAppKey,
        Yd1OpsTools.regionCode:self.regionCode? :@"",
        Yd1OpsTools.channelCode:Yodo1Tool.shared.paymentChannelCodeValue,
        Yd1OpsTools.orderId:transaction.orderId? :@"",
        @"channelOrderid":transaction.channelOrderid? :@"",
        @"item_code":transaction.item_code? :@"",
        @"product_type":[NSNumber numberWithInt:transaction.product_type],
        @"exclude_old_transactions":transaction.exclude_old_transactions? :@"false",
        @"uid":user.uid? :@"",
        @"ucuid":user.ucuid? :@"",
        @"deviceid":transaction.deviceid? :@"",
        @"trx_receipt":transaction.trx_receipt? :@"",
        @"is_sandbox":transaction.is_sandbox? :@"",
        @"extra":transaction.extra? :@"",
    };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.verifyAppStoreIAPURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        YD1LOG(@"%@",responseObject);
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        callback(errorCode == 0?true:false,[Yd1OpsTools stringWithJSONObject:response error:nil],[self errorWithMsg:error errorCode:errorCode]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error);
        callback(false,@"",error);
    }];
}


/// Get the subscription products, please check here(https://confluence.yodo1.com/display/OPP/appStore+querySubscriptions) for the details
/// - Parameters:
///   - transaction: Yodo1Transaction
///   - callback: <#callback description#>
- (void)querySubscriptions:(Yodo1Transaction *)transaction callback:(nonnull void (^)(BOOL, NSString * _Nullable, NSError * _Nullable))callback {
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    if (!transaction.trx_receipt) {
        NSError* error = [NSError errorWithDomain:@"com.yodo1.querySubscriptions"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey:@"receipt is nil!"}];
        callback(false,transaction.orderId,error);
        return;
    }
    NSString* eightReceipt = [transaction.trx_receipt substringToIndex:8];
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",eightReceipt]];
    NSDictionary* data = @{
        Yd1OpsTools.gameAppKey:self.gameAppKey,
        Yd1OpsTools.regionCode:self.regionCode,
        Yd1OpsTools.channelCode:Yodo1Tool.shared.paymentChannelCodeValue,
        @"trx_receipt":transaction.trx_receipt,
        @"exclude_old_transactions":transaction.exclude_old_transactions
    };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.querySubscriptionsURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        YD1LOG(@"%@",responseObject);
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* errorMsg = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            errorMsg = [response objectForKey:Yd1OpsTools.error];
        }
        if (errorCode == 0) {
            NSString* responseString = [Yd1OpsTools stringWithJSONObject:response error:nil];
            callback(true,responseString,nil);
        } else {
            NSError* error = [NSError errorWithDomain:@"com.yodo1.querySubscriptions"
                                                 code:errorCode
                                             userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            callback(false,transaction.orderId,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error);
        callback(false,nil,error);
    }];
}

- (void)sendGoodsSuccess:(NSString *)orderIds callback:(void (^)(BOOL, NSString * _Nonnull))callback {
    if (!orderIds || orderIds.length < 1) {
        callback(false,@"order Ids is empty!");
        return;
    }
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"yodo1%@",orderIds]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:orderIds forKey:@"orderids"];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager GET:Yd1OpsTools.sendGoodsSuccessURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if (errorCode == 0) {
            callback(true,@"");
        } else {
            callback(false,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        callback(false,error.localizedDescription);
    }];
}

- (void)sendGoodsFail:(NSString *)orderIds
             callback:(void (^)(BOOL success,NSString* error))callback {
    if (!orderIds || orderIds.length < 1) {
        callback(false,@"order Ids is empty!");
        return;
    }
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"yodo1%@",orderIds]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:orderIds forKey:@"orderids"];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager GET:Yd1OpsTools.sendGoodsFailURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if (errorCode == 0) {
            callback(true,@"");
        } else {
            callback(false,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        callback(false,error.localizedDescription);
    }];
}

- (void)reportOrderSuccess:(Yodo1Transaction *)transaction callback:(void (^)(BOOL, NSString * _Nonnull))callback {
    if (!transaction) {
        callback(false,@"item info is empty!");
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"yodo1%@",transaction.orderId]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:transaction.orderId forKey:@"orderid"];
    [parameters setObject:transaction.extra forKey:@"extra"];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager GET:Yd1OpsTools.clientCallbackURL
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if (errorCode == 0) {
            callback(true,error);
        } else {
            callback(false,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        callback(false,error.localizedDescription);
    }];
}


/// Report the order's status to IAP payment, please see here(https://confluence.yodo1.com/pages/viewpage.action?pageId=24064396) for the details
/// - Parameters:
///   - transaction: Yodo1Transaction
///   - callback: <#callback description#>
- (void)reportOrderFail:(Yodo1Transaction *)transaction callback:(void (^)(BOOL, NSString * _Nonnull))callback {
    if (!transaction) {
        callback(false,@"item info is empty!");
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",transaction.orderId]];
    NSDictionary* data = @{
        @"orderId":transaction.orderId? :@"",
        @"channelCode":Yodo1Tool.shared.paymentChannelCodeValue,
        @"channelOrderid":transaction.channelOrderid? :@"",
        @"statusCode":transaction.statusCode,
        @"statusMsg":transaction.statusMsg? :@""
    };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.reportOrderStatusURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if (errorCode == 0) {
            callback(true,error);
        } else {
            callback(false,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        callback(false,error.localizedDescription);
    }];
}

- (void)clientNotifyToServer:(NSArray *)orderIds
                    callback:(nonnull void (^)(BOOL, NSArray * _Nonnull, NSArray * _Nonnull, NSString * _Nonnull))callback {
    if (!orderIds || [orderIds count] < 1) {
        callback(false,@[],@[],@"order Ids is empty!");
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* timestamp = [Yd1OpsTools nowTimeTimestamp];
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",timestamp]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:orderIds forKey:@"orderIds"];
    [data setObject:timestamp forKey:@"timestamp"];
    [parameters setObject:data forKey:@"data"];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.clientNotifyForSyncUnityStatusURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        NSMutableArray* notExistOrders = [NSMutableArray array];
        NSMutableArray* notPayOrders = [NSMutableArray array];
        if ([[response allKeys]containsObject:@"data"]) {
            NSDictionary* data = [response objectForKey:@"data"];
            if (data && [[data allKeys]containsObject:@"notExistOrders"]) {
                NSArray* notExist = [data objectForKey:@"notExistOrders"];
                [notExistOrders setArray:notExist];
            }
            if (data && [[data allKeys]containsObject:@"notPayOrders"]) {
                NSArray* notPay = [data objectForKey:@"notPayOrders"];
                [notPayOrders setArray:notPay];
            }
        }
        if (errorCode == 0) {
            callback(true,notExistOrders,notPayOrders,@"");
        } else {
            callback(false,notExistOrders,notPayOrders,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        callback(false,@[],@[],error.localizedDescription);
    }];
}

- (void)queryLossOrders:(Yodo1Transaction *)transaction
                   user:(YD1User *)user
               callback:(nonnull void (^)(BOOL success, NSArray * _Nonnull missorders,NSString* _Nonnull error))callback {
    if (!user.uid) {
        callback(false,@[],@"uid  is nil!");
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@", user.uid]];
    NSDictionary* data = @{
        @"uid":user.uid,
        @"gameAppkey":self.gameAppKey,
        @"regionCode":self.regionCode,
        @"channelCode":Yodo1Tool.shared.paymentChannelCodeValue
    };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.queryLossOrdersURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        NSMutableArray* orders = [NSMutableArray array];
        if ([[response allKeys]containsObject:@"data"]) {
            NSArray* data = [response objectForKey:@"data"];
            if ([data count] > 0) {
                [orders setArray:data];
            }
        }
        
        if (errorCode == 0) {
            callback(true,orders,error);
        } else {
            callback(false,orders,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        callback(false,@[],error.localizedDescription);
    }];
}

/**
 *  查询订单状态
 */
- (void)queryOrderStatus:(NSString *)orderId
                callback:(nonnull void (^)(BOOL success, NSString * _Nonnull status, NSString* _Nonnull error))callback {
    if (!orderId || [orderId length] < 1) {
        callback(false, @"", @"order Ids is empty!");
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@", orderId]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSDictionary* data = @{
        @"orderid":orderId,
        @"extra":@""
    };
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.getOrderStatusURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        NSString* status = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if ([[response allKeys]containsObject:@"status"]) {
            status = [response objectForKey:@"status"];
        }
        NSMutableArray* orders = [NSMutableArray array];
        if ([[response allKeys]containsObject:@"data"]) {
            NSArray* data = [response objectForKey:@"data"];
            if ([data count] > 0) {
                [orders setArray:data];
            }
        }
        
        if (errorCode == 0) {
            callback(true,status,error);
        } else {
            callback(false,status,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.description);
        callback(false,@"",error.localizedDescription);
    }];
}

@end
