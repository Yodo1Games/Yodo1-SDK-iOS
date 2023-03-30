#import "Yodo1PurchaseBridge.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1UnityTool.h"
#import "Yodo1PurchaseManager.h"
#import "Yodo1PurchaseAPI.h"

#ifdef __cplusplus
extern "C" {

#pragma mark - 请求商品信息

/**
 *根据产品ID,获取产品信息
 */
void UnityProductInfoWithProductId(const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* _uniformProductId = Yodo1CreateNSString(uniformProductId);
    [Yodo1PurchaseManager.shared productWithUniformProductId:_uniformProductId callback:^(NSArray<Yodo1Product *> * _Nonnull productInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName) {
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_RequestProductsInfo] forKey:@"resulType"];
                if([productInfo count] > 0){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    [dict setObject:productInfo forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_RequestProductsInfo] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

/**
 *根据,获取所有产品信息
 */
void UnityProductsInfo(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [Yodo1PurchaseManager.shared products:^(NSArray<Yodo1Product *> * _Nonnull productInfo) {
        if(ocGameObjName && ocMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_RequestProductsInfo] forKey:@"resulType"];
            if([productInfo count] > 0){
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                [dict setObject:productInfo forKey:@"data"];
            }else{
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            }
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_RequestProductsInfo] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

#pragma mark - 购买商品

void UnityPayNetGame(const char* mUniformProductId,const char* extra, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* _uniformProductId = Yodo1CreateNSString(mUniformProductId);
    NSString* _extra = Yodo1CreateNSString(extra);
    
    [Yodo1PurchaseManager.shared paymentWithUniformProductId:_uniformProductId
                                                       extra:_extra
                                                    callback:^(PaymentObject * _Nonnull payemntObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ocGameObjName && ocMethodName) {
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_Payment] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:(int)payemntObject.paymentState] forKey:@"code"];
                [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                [dict setObject:_extra? :@"" forKey:@"extra"];
                [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_Payment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:(int)payemntObject.paymentState] forKey:@"code"];
                    [dict setObject:payemntObject.response? :@"" forKey:@"data"];
                    [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                    [dict setObject:_extra? :@"" forKey:@"extra"];
                    [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

#pragma mark - 促销活动商品

void UnityCancelPromotion(const char* gameObjectName, const char* methodName)
{
    [Yodo1PurchaseManager.shared cancelPromotion];
}

void UnityGetPromotionProduct(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    Yodo1Product* product = [Yodo1PurchaseManager.shared promotionProduct];
    if(ocGameObjName && ocMethodName){
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        if(product){
            [dict setObject:product.uniformProductId forKey:@"productId"];
            [dict setObject:product.channelProductId forKey:@"marketId"];
            [dict setObject:product.productName forKey:@"productName"];
            [dict setObject:product.productPrice forKey:@"price"];
            [dict setObject:product.priceDisplay forKey:@"priceDisplay"];
            [dict setObject:product.productDescription forKey:@"description"];
            [dict setObject:product.currency forKey:@"currency"];
            [dict setObject:[NSNumber numberWithInt:product.productType] forKey:@"ProductType"];
        }
        [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_GetPromotionProduct] forKey:@"resulType"];
        [dict setObject:[NSNumber numberWithInt:product==nil ? 0 : 1] forKey:@"code"];
        
        NSError* parseJSONError = nil;
        NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
        if(parseJSONError){
            [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_Payment] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
            msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
        }
        UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                         [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                         [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

void UnityReadyToContinuePurchaseFromPromotion(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    
    [Yodo1PurchaseManager.shared readyToContinuePurchaseFromPromot:^(PaymentObject * _Nonnull payemntObject) {
        if (payemntObject.paymentState == PaymentSuccess) {
            Yodo1PurchaseAPI.shared.transaction.orderId = payemntObject.orderId;
            Yodo1PurchaseAPI.shared.transaction.extra = @"";
            [Yodo1PurchaseAPI.shared reportOrderSuccess:Yodo1PurchaseAPI.shared.transaction
                                               callback:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"上报成功");
                } else {
                    YD1LOG(@"上报失败");
                }
            }];
            
            
        } else {
            if ([payemntObject.orderId length] > 0) {
                Yodo1PurchaseAPI.shared.transaction.channelOrderid = payemntObject.channelOrderid? :@"";
                Yodo1PurchaseAPI.shared.transaction.orderId = payemntObject.orderId;
                Yodo1PurchaseAPI.shared.transaction.statusCode = [NSString stringWithFormat:@"%d",payemntObject.paymentState];
                Yodo1PurchaseAPI.shared.transaction.statusMsg = payemntObject.response? :@"";
                [Yodo1PurchaseAPI.shared reportOrderFail:Yodo1PurchaseAPI.shared.transaction
                                                callback:^(BOOL success, NSString * _Nonnull error) {
                    if (success) {
                        YD1LOG(@"上报失败，成功");
                    } else {
                        YD1LOG(@"上报失败");
                    }
                }];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:payemntObject.uniformProductId ? :@"" forKey:@"uniformProductId"];
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_Payment] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:(int)payemntObject.paymentState] forKey:@"code"];
                [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                [dict setObject:@"extra" forKey:@"extra"];
                [dict setObject:payemntObject.channelOrderid ? :@"" forKey:@"channelOrderid"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_Payment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:(int)payemntObject.paymentState] forKey:@"code"];
                    [dict setObject:payemntObject.response? :@"" forKey:@"data"];
                    [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                    [dict setObject:@"extra" forKey:@"extra"];
                    [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

void UnityFetchStorePromotionVisibilityForProduct(const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* _uniformProductId = Yodo1CreateNSString(uniformProductId);
    [Yodo1PurchaseManager.shared fetchStorePromotionVisibilityForProduct:_uniformProductId callback:^(PromotionVisibility storePromotionVisibility, BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_FetchPromotionVisibility] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            if(success > 0 ){
                switch(storePromotionVisibility){
                    case Hide:
                        [dict setObject:[NSString stringWithFormat:@"%d", Hide] forKey:@"visible"];
                        break;
                    case Visible:
                        [dict setObject:[NSString stringWithFormat:@"%d", Visible] forKey:@"visible"];
                        break;
                    case Default:
                        [dict setObject:[NSString stringWithFormat:@"%d", Default] forKey:@"visible"];
                        break;
                }
            }
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void UnityFetchStorePromotionOrder(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [Yodo1PurchaseManager.shared fetchStorePromotionOrder:^(NSArray<NSString *> * _Nonnull storePromotionOrder, BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_FetchStorePromotionOrder] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            [dict setObject:storePromotionOrder forKey:@"storePromotionOrder"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void UnityUpdateStorePromotionOrder(const char* productids, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [Yodo1PurchaseManager.shared updateStorePromotionOrder:[[NSString stringWithUTF8String:productids] componentsSeparatedByString:@","] callback:^(BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_UpdateStorePromotionOrder] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void UnityUpdateStorePromotionVisibility(bool visible, const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [Yodo1PurchaseManager.shared  updateStorePromotionVisibility:visible product:[NSString stringWithUTF8String:uniformProductId] callback:^(BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_UpdateStorePromotionVisibility] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

#pragma mark - 查询漏单商品

void UnityQueryLossOrder(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    
    [Yodo1PurchaseManager.shared queryLossOrder:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_LossOrderIdQuery] forKey:@"resulType"];
                if([productIds count] > 0 ){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    [dict setObject:productIds forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_LossOrderIdQuery] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
        });
    }];
    
}

#pragma mark - 查询订阅商品

void UnityQuerySubscriptions(BOOL excludeOldTransactions, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    
    [Yodo1PurchaseManager.shared querySubscriptions:excludeOldTransactions callback:^(NSArray * _Nonnull subscriptions, NSTimeInterval serverTime, BOOL success, NSString * _Nullable error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            
            [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_QuerySubscriptions] forKey:@"resulType"];
            
            if([subscriptions count] > 0 ){
                NSMutableArray* arrayProduct = [NSMutableArray arrayWithCapacity:1];
                for(int i = 0;i < [subscriptions count]; i++){
                    NSMutableDictionary* dicProduct = [NSMutableDictionary dictionary];
                    SubscriptionProductInfo* info = [subscriptions objectAtIndex:i];
                    [dicProduct setObject:info.uniformProductId forKey:@"uniformProductId"];
                    [dicProduct setObject:info.channelProductId forKey:@"channelProductId"];
                    [dicProduct setObject:[NSNumber numberWithDouble:info.expiresTime] forKey:@"expiresTime"];
                    [dicProduct setObject:[NSNumber numberWithDouble:info.purchase_date_ms] forKey:@"purchase_date_ms"];
                    
                    [arrayProduct addObject:dicProduct];
                }
                
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                [dict setObject:arrayProduct forKey:@"data"];
                [dict setObject:[NSNumber numberWithDouble:serverTime] forKey:@"serverTime"];
            }else{
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            }
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_QuerySubscriptions] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

#pragma mark - 恢复购买商品

void UnityRestorePayment(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [Yodo1PurchaseManager.shared restorePayment:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_RestorePayment] forKey:@"resulType"];
                if([productIds count] > 0 ){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    [dict setObject:productIds forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_RestorePayment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

#pragma mark - 商品发货

/**
 *  购买成功发货通知成功
 */
void UnitySendGoodsOver(const char* orders,const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* ocOrders = Yodo1CreateNSString(orders);
    
    [[Yodo1PurchaseManager shared] sendGoodsSuccess:ocOrders callback:^(BOOL success, NSString * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_SendGoodsOver] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:success?1:0] forKey:@"code"];
                [dict setObject:(error == nil?@"":error) forKey:@"error"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_SendGoodsOver] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithBool:success] forKey:@"code"];
                    [dict setObject:(error == nil?@"":error) forKey:@"error"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

/**
 *  购买成功发货通知失败
 */
void UnitySendGoodsOverFault(const char* orders,const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* ocOrders = Yodo1CreateNSString(orders);
    [Yodo1PurchaseManager.shared sendGoodsFail:ocOrders
                                      callback:^(BOOL success, NSString * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_SendGoodsOverFault] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:success?1:0] forKey:@"code"];
                [dict setObject:(error == nil?@"":error) forKey:@"error"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_SendGoodsOverFault] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithBool:success] forKey:@"code"];
                    [dict setObject:(error == nil?@"":error) forKey:@"error"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

#pragma mark - 兑换码功能

/**
 *  激活码/优惠券
 */
void UnityVerifyActivationcode(const char* activationCode,const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* code = Yodo1CreateNSString(activationCode);
    
    [Yodo1PurchaseManager.shared verifyWithActivationCode:code callback:^(BOOL success, NSDictionary * _Nullable response, NSDictionary * _Nullable error) {
        YD1LOG(@"response=%@ error=%@", response, error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName) {
                if (success) {
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                    
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_VerifyActivationcode] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"errorCode"];
                    [dict setObject:@"success" forKey:@"errorMsg"];
                    
                    if (response[@"reward"]) {
                        [dict setObject:response[@"reward"] forKey:@"reward"];
                    } else {
                        [dict setObject:@"" forKey:@"reward"];
                    }
                    
                    if ([response[@"comment"] length] > 0) {
                        [dict setObject:response[@"comment"] forKey:@"rewardDes"];
                    } else {
                        [dict setObject:@"" forKey:@"rewardDes"];
                    }
                    
                    NSError* parseJSONError = nil;
                    NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                    if(parseJSONError){
                        [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                        msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                    }
                    
                    UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                } else {
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                    
                    [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_VerifyActivationcode] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    int errorCode = [error[@"error_code"] intValue];
                    [dict setObject:[NSNumber numberWithInt:errorCode] forKey:@"errorCode"];
                    [dict setObject:error[@"error"] forKey:@"errorMsg"];
                    [dict setObject:@"" forKey:@"reward"];
                    [dict setObject:@"" forKey:@"rewardDes"];
                    
                    NSError* parseJSONError = nil;
                    NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                    if(parseJSONError){
                        [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                        msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                    }
                    
                    UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        });
    }];
}

}

#endif
