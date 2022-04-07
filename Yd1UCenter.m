//
//  Yd1UCenter.m
//  Yd1UCenter
//
//  Created by yixian huang on 2017/7/24.
//

#import "Yd1UCenter.h"
#import "Yodo1AFNetworking.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yd1OnlineParameter.h"
#import "Yodo1Tool+OpsParameters.h"
#import "Yodo1Model.h"
#import "Yodo1KeyInfo.h"

@implementation YD1User

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _playerid = [decoder decodeObjectForKey:@"playerid"];
        _nickname = [decoder decodeObjectForKey:@"nickname"];
        _ucuid = [decoder decodeObjectForKey:@"ucuid"];
        _yid = [decoder decodeObjectForKey:@"yid"];
        _uid = [decoder decodeObjectForKey:@"uid"];
        _token = [decoder decodeObjectForKey:@"token"];
        _isOLRealName = [decoder decodeIntForKey:@"isOLRealName"];
        _isRealName = [decoder decodeIntForKey:@"isRealName"];
        _isnewuser = [decoder decodeIntForKey:@"isnewuser"];
        _isnewyaccount = [decoder decodeIntForKey:@"isnewyaccount"];
        _extra = [decoder decodeObjectForKey:@"extra"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (self.playerid) {
        [coder encodeObject:self.playerid forKey:@"playerid"];
    }
    if (self.nickname) {
        [coder encodeObject:self.nickname forKey:@"nickname"];
    }
    if (self.ucuid) {
        [coder encodeObject:self.ucuid forKey:@"ucuid"];
    }
    [coder encodeObject:self.yid forKey:@"yid"];
    [coder encodeObject:self.uid forKey:@"uid"];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeInt:self.isOLRealName forKey:@"isOLRealName"];
    [coder encodeInt:self.isRealName forKey:@"isRealName"];
    [coder encodeInt:self.isnewuser forKey:@"isnewuser"];
    [coder encodeInt:self.isnewyaccount forKey:@"isnewyaccount"];
    if (self.extra) {
        [coder encodeObject:self.extra forKey:@"extra"];
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}
@end

@implementation YD1ItemInfo
@end

@implementation SubscriptionInfo

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

@interface Yd1UCenter () {
    
}

@end

@implementation Yd1UCenter

+ (instancetype)shared {
    return [Yodo1Base.shared cc_registerSharedInstance:self block:^{
        ///初始化
        YD1LOG(@"%s",__PRETTY_FUNCTION__);
        [Yd1UCenter.shared willInit];
    }];
}

- (void)willInit {
    if (_itemInfo == nil) {
        _itemInfo = [[YD1ItemInfo alloc]init];
        _itemInfo.deviceid = Yd1OpsTools.keychainDeviceId;
        _itemInfo.extra = @"";
        _itemInfo.is_sandbox = @"false";
        _itemInfo.statusCode = @"1";
        _itemInfo.statusMsg = @"";
        _itemInfo.exclude_old_transactions = @"false";
    }
}

- (NSString *)regionCode {
    if (_regionCode == nil) {
        _regionCode = @"";
    }
    return _regionCode;
}

- (void)deviceLoginWithPlayerId:(NSString *)playerId
                       callback:(void(^)(YD1User* _Nullable user, NSError* _Nullable  error))callback {
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.ucapDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* deviceId = Yd1OpsTools.keychainDeviceId;
    if (playerId && [playerId length] > 0) {
        deviceId = playerId;
    }
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"yodo1.com%@%@",deviceId,Yd1OParameter.appKey]];
    NSDictionary* data = @{
        Yd1OpsTools.gameAppKey:Yd1OParameter.appKey ,Yd1OpsTools.channelCode:Yd1OParameter.channelId,Yd1OpsTools.deviceId:deviceId,Yd1OpsTools.regionCode:self.regionCode };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.deviceLoginURL
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
        if ([[response allKeys]containsObject:Yd1OpsTools.data]) {
            NSDictionary* m_data = (NSDictionary*)[response objectForKey:Yd1OpsTools.data];
            YD1User* user = [YD1User yodo1_modelWithDictionary:m_data];
            if (callback) {
                callback(user,nil);
            }
        }else{
            if (callback) {
                callback(nil,[NSError errorWithDomain:@"com.yodo1.ucenter" code:errorCode userInfo:@{NSLocalizedDescriptionKey:error}]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.localizedDescription);
        if (callback) {
            callback(nil,error);
        }
    }];
}

- (void)generateOrderId:(void (^)(NSString * _Nullable, NSError * _Nullable))callback {
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
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
    [manager POST:Yd1OpsTools.generateOrderIdURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        NSString* orderId = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.data]) {
            NSDictionary* m_data = (NSDictionary*)[response objectForKey:Yd1OpsTools.data];
            if ([[m_data allKeys]containsObject:@"orderId"]) {
                orderId = (NSString *)[m_data objectForKey:@"orderId"];
            }
            if (callback) {
                callback(orderId,nil);
            }
        }else{
            if (callback) {
                callback(nil,[NSError errorWithDomain:@"com.yodo1.ucenter" code:errorCode userInfo:@{NSLocalizedDescriptionKey:error}]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.localizedDescription);
        if (callback) {
            callback(nil,error);
        }
    }];
}

/**
 *  假如error_code:0 error值代表剩余可
 *  花费金额不为0，则是具体返回信息
 */
- (void)createOrder:(NSDictionary*) parameter
           callback:(void (^)(int, NSString * _Nonnull))callback {
    
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
        @"game_appkey":Yd1OParameter.appKey,
        @"channel_code":Yd1OParameter.channelId,
        @"region_code":self.regionCode,
        @"sdkType":Yd1OParameter.publishType,
        @"sdkVersion":Yd1OParameter.publishVersion,
        @"pr_channel_code":@"AppStore",
        @"orderid":orderId,
        @"item_code":itemCode,
        @"uid":uid,
        @"ucuid":ucuid,
        @"yid":yid,
        @"playerId":playerId,
        @"channel_version":channelVersion,
        @"order_money":orderMoney,
        @"gameName":gameName,
        @"game_version":gameVersion,
        @"game_type":gameType,
        @"game_extra":gameExtra,
        @"extra":extra,
        @"deviceid":Yd1OpsTools.keychainDeviceId,
        @"gameBundleId":Yd1OpsTools.appBid,
        @"paymentChannelVersion":Yd1OParameter.publishVersion,
        @"deviceInfo":deviceInfo,
        @"productInfo":productInfo,
        @"channelUserid":channelUserid
    };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.createOrderURL
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
        if (callback) {
            callback(errorCode,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.localizedDescription);
        if (callback) {
            callback((int)error.code,error.localizedDescription);
        }
    }];
}

- (NSError *)errorWithMsg:(NSString *)msg errorCode:(int)errorCode {
    return [NSError errorWithDomain:@"com.yodo1.payment"
                               code:errorCode
                           userInfo:@{NSLocalizedDescriptionKey:msg? :@""}];
}

- (void)verifyAppStoreIAPOrder:(YD1ItemInfo *)itemInfo callback:(nonnull void (^)(BOOL, NSString * _Nonnull, NSError * _Nonnull))callback {
    if (!itemInfo) {
        callback(false,@"",[self errorWithMsg:@"order Ids is empty!" errorCode:-1]);
        return;
    }
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",itemInfo.orderId]];
    NSDictionary* data = @{
        Yd1OpsTools.gameAppKey:Yd1OParameter.appKey? :@"",
        Yd1OpsTools.channelCode:Yd1OParameter.channelId? :@"",
        Yd1OpsTools.regionCode:self.regionCode? :@"",
        Yd1OpsTools.orderId:itemInfo.orderId? :@"",
        @"channelOrderid":itemInfo.channelOrderid? :@"",
        @"exclude_old_transactions":itemInfo.exclude_old_transactions? :@"false",
        @"product_type":[NSNumber numberWithInt:itemInfo.product_type],
        @"item_code":itemInfo.item_code? :@"",
        @"uid":itemInfo.uid? :@"",
        @"ucuid":itemInfo.ucuid? :@"",
        @"deviceid":itemInfo.deviceid? :@"",
        @"trx_receipt":itemInfo.trx_receipt? :@"",
        @"is_sandbox":itemInfo.is_sandbox? :@"",
        @"extra":itemInfo.extra? :@"",
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

- (void)querySubscriptions:(YD1ItemInfo *)itemInfo callback:(nonnull void (^)(BOOL, NSString * _Nullable, NSError * _Nullable))callback {
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    if (!itemInfo.trx_receipt) {
        NSError* error = [NSError errorWithDomain:@"com.yodo1.querySubscriptions"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey:@"receipt is nil!"}];
        callback(false,itemInfo.orderId,error);
        return;
    }
    NSString* eightReceipt = [itemInfo.trx_receipt substringToIndex:8];
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",eightReceipt]];
    NSDictionary* data = @{
        Yd1OpsTools.gameAppKey:Yd1OParameter.appKey,
        Yd1OpsTools.channelCode:Yd1OParameter.channelId,
        Yd1OpsTools.regionCode:self.regionCode,
        @"trx_receipt":itemInfo.trx_receipt,
        @"exclude_old_transactions":itemInfo.exclude_old_transactions
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
            callback(false,itemInfo.orderId,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error);
        callback(false,nil,error);
    }];
}

- (void)sendGoodsOver:(NSString *)orderIds callback:(void (^)(BOOL, NSString * _Nonnull))callback {
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
    [manager GET:Yd1OpsTools.sendGoodsOverURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
        YD1LOG(@"%@",error);
        callback(false,error.localizedDescription);
    }];
}

- (void)sendGoodsOverForFault:(NSString *)orderIds
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
    [manager GET:Yd1OpsTools.sendGoodsOverFaultURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
        YD1LOG(@"%@",error);
        callback(false,error.localizedDescription);
    }];
}

- (void)clientCallback:(YD1ItemInfo *)itemInfo callbakc:(void (^)(BOOL, NSString * _Nonnull))callback {
    if (!itemInfo) {
        callback(false,@"item info is empty!");
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"yodo1%@",itemInfo.orderId]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:itemInfo.orderId forKey:@"orderid"];
    [parameters setObject:itemInfo.extra forKey:@"extra"];
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
        YD1LOG(@"%@",error);
        callback(false,error.localizedDescription);
    }];
}

- (void)reportOrderStatus:(YD1ItemInfo *)itemInfo callbakc:(void (^)(BOOL, NSString * _Nonnull))callback {
    if (!itemInfo) {
        callback(false,@"item info is empty!");
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",itemInfo.orderId]];
    NSDictionary* data = @{
        @"orderId":itemInfo.orderId,
        @"channelCode":itemInfo.channelCode? :@"AppStore",
        @"channelOrderid":itemInfo.channelOrderid,
        @"statusCode":itemInfo.statusCode,
        @"statusMsg":itemInfo.statusMsg? :@""
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
        YD1LOG(@"%@",error);
        callback(false,error.localizedDescription);
    }];
}

- (void)clientNotifyForSyncUnityStatus:(NSArray *)orderIds
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
    [manager POST:Yd1OpsTools.clientNotifyForSyncUnityStatusURL
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
        YD1LOG(@"%@",error);
        callback(false,@[],@[],error.localizedDescription);
    }];
}

- (void)offlineMissorders:(YD1ItemInfo *)itemInfo
                 callback:(nonnull void (^)(BOOL success, NSArray * _Nonnull missorders,NSString* _Nonnull error))callback {
    if (!itemInfo.uid) {
        callback(false,@[],@"uid  is nil!");
        return;
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"payment%@",itemInfo.uid]];
    NSDictionary* data = @{
        @"uid":itemInfo.uid,
        @"gameAppkey":Yd1OnlineParameter.shared.appKey,
        @"channelCode":Yd1OnlineParameter.shared.channelId,
        @"regionCode":Yd1UCenter.shared.regionCode
    };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
    [manager POST:Yd1OpsTools.offlineMissordersURL
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
        YD1LOG(@"%@",error);
        callback(false,@[],error.localizedDescription);
    }];
}

/**
 * 激活码/优惠券
 */
- (void)verifyActivationcode:(NSString *)code
                    callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSString* _Nullable error))callback {
    
    if (!code || code.length < 1) {
        callback(false,@{}, @"code is empty!");
        return;
    }
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.paymentDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString *appKey = @"";
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://activationcode.yodo1api.com/activationcode/activateWithReward?game_appkey=%@&channel_code=%@&activation_code=%@&dev_id=%@", appKey, @"appstore", code, Yd1OpsTools.keychainDeviceId];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode] intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if (errorCode == 0) {
            callback(true,response,NULL);
        } else {
            callback(false,@{},error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error);
        callback(false,@{},error.localizedDescription);
    }];
    
}

@end
