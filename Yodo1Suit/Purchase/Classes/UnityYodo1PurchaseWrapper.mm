#import "Yodo1Tool+Commons.h"
#import "Yodo1UnityTool.h"
#import "Yodo1PurchaseManager.h"
#import "Yodo1PurchaseAPI.h"

typedef enum {
    Unity_Result_Type_Payment = 2001,
    Unity_Result_Type_Restore_Payment = 2002,
    Unity_Result_Type_Request_Products = 2003,
    Unity_Result_Type_VerifyProductsInfo = 2004,
    Unity_Result_Type_LossOrderIdQuery = 2005,
    Unity_Result_Type_QuerySubscriptions = 2006,
    Unity_Result_Type_FetchPromotionVisibility = 2007,
    Unity_Result_Type_FetchStorePromotionOrder = 2008,
    Unity_Result_Type_UpdateStorePromotionVisibility = 2009,
    Unity_Result_Type_UpdateStorePromotionOrder = 2010,
    Unity_Reslut_Type_GetPromotionProduct = 2011,
    Unity_Result_Type_SendGoodsOver = 2013,
    Unity_Result_Type_SendGoodsOverFault = 2014,
}UnityResultType_Purchase;

#ifdef __cplusplus
extern "C" {
#endif

/**
 *根据产品ID,获取产品信息
 */
void UnityProductInfoWithProductId(const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    NSString* _uniformProductId = ConvertCharToNSString(uniformProductId);
    [Yodo1PurchaseManager.shared productWithUniformProductId:_uniformProductId callback:^(NSArray<Yodo1Product *> * _Nonnull productInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName) {
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Request_Products] forKey:@"resulType"];
                if([productInfo count] > 0){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    NSMutableArray* productArray = [NSMutableArray array];
                    for (Yodo1Product* product in productInfo) {
                        [productArray addObject:[product dictionary]];
                    }
                    [dict setObject:productArray forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Request_Products] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
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
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    [Yodo1PurchaseManager.shared products:^(NSArray<Yodo1Product *> * _Nonnull productInfo) {
        if(ocGameObjName && ocMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Request_Products] forKey:@"resulType"];
            if([productInfo count] > 0){
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                NSMutableArray* productArray = [NSMutableArray array];
                for (Yodo1Product* product in productInfo) {
                    [productArray addObject:[product dictionary]];
                }
                [dict setObject:productArray forKey:@"data"];
            }else{
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            }
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Request_Products] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

#pragma mark - 购买商品

void UnityPayNetGame(const char* mUniformProductId,const char* extra, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    NSString* _uniformProductId = ConvertCharToNSString(mUniformProductId);
    NSString* _extra = ConvertCharToNSString(extra);
    
    [Yodo1PurchaseManager.shared paymentWithUniformProductId:_uniformProductId
                                                       extra:_extra
                                                    callback:^(PaymentObject * _Nonnull payemntObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ocGameObjName && ocMethodName) {
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Payment] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:(int)payemntObject.paymentState] forKey:@"code"];
                [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                [dict setObject:_extra? :@"" forKey:@"extra"];
                [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Payment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:(int)payemntObject.paymentState] forKey:@"code"];
                    [dict setObject:payemntObject.response? :@"" forKey:@"data"];
                    [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                    [dict setObject:_extra? :@"" forKey:@"extra"];
                    [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
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
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
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
            [dict setObject:[NSNumber numberWithInt:(int)product.productType] forKey:@"ProductType"];
        }
        [dict setObject:[NSNumber numberWithInt:Unity_Reslut_Type_GetPromotionProduct] forKey:@"resulType"];
        [dict setObject:[NSNumber numberWithInt:product==nil ? 0 : 1] forKey:@"code"];
        
        NSError* parseJSONError = nil;
        NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
        if(parseJSONError){
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Payment] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
            msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
        }
        Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                         [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                         [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

void UnityReadyToContinuePurchaseFromPromotion(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    
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
                Yodo1PurchaseAPI.shared.transaction.statusCode = [NSString stringWithFormat:@"%ld",(long)payemntObject.paymentState];
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
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Payment] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:(int)payemntObject.paymentState] forKey:@"code"];
                [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                [dict setObject:@"extra" forKey:@"extra"];
                [dict setObject:payemntObject.channelOrderid ? :@"" forKey:@"channelOrderid"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Payment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:(int)payemntObject.paymentState] forKey:@"code"];
                    [dict setObject:payemntObject.response? :@"" forKey:@"data"];
                    [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                    [dict setObject:@"extra" forKey:@"extra"];
                    [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

void UnityFetchStorePromotionVisibilityForProduct(const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    NSString* _uniformProductId = ConvertCharToNSString(uniformProductId);
    [Yodo1PurchaseManager.shared fetchStorePromotionVisibilityForProduct:_uniformProductId callback:^(PromotionVisibility storePromotionVisibility, BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_FetchPromotionVisibility] forKey:@"resulType"];
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
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void UnityFetchStorePromotionOrder(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    [Yodo1PurchaseManager.shared fetchStorePromotionOrder:^(NSArray<NSString *> * _Nonnull storePromotionOrder, BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_FetchStorePromotionOrder] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            [dict setObject:storePromotionOrder forKey:@"storePromotionOrder"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void UnityUpdateStorePromotionOrder(const char* productids, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    [Yodo1PurchaseManager.shared updateStorePromotionOrder:[[NSString stringWithUTF8String:productids] componentsSeparatedByString:@","] callback:^(BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_UpdateStorePromotionOrder] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void UnityUpdateStorePromotionVisibility(bool visible, const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    [Yodo1PurchaseManager.shared  updateStorePromotionVisibility:visible product:[NSString stringWithUTF8String:uniformProductId] callback:^(BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_UpdateStorePromotionVisibility] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

#pragma mark - 查询漏单商品

void UnityQueryLossOrder(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    
    [Yodo1PurchaseManager.shared queryLossOrder:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_LossOrderIdQuery] forKey:@"resulType"];
                if([productIds count] > 0 ){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    NSMutableArray* productArray = [NSMutableArray array];
                    for (Yodo1Product* product in productIds) {
                        [productArray addObject:[product dictionary]];
                    }
                    [dict setObject:productArray forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_LossOrderIdQuery] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
        });
    }];
    
}

#pragma mark - 查询订阅商品

void UnityQuerySubscriptions(BOOL excludeOldTransactions, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    
    [Yodo1PurchaseManager.shared querySubscriptions:excludeOldTransactions callback:^(NSArray * _Nonnull subscriptions, NSTimeInterval serverTime, BOOL success, NSString * _Nullable error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_QuerySubscriptions] forKey:@"resulType"];
            
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
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_QuerySubscriptions] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

#pragma mark - 恢复购买商品

void UnityRestorePayment(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    [Yodo1PurchaseManager.shared restorePayment:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Restore_Payment] forKey:@"resulType"];
                if([productIds count] > 0 ){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    NSMutableArray* productArray = [NSMutableArray array];
                    for (Yodo1Product* product in productIds) {
                        [productArray addObject:[product dictionary]];
                    }
                    [dict setObject:productArray forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Restore_Payment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
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
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    NSString* ocOrders = ConvertCharToNSString(orders);
    
    [[Yodo1PurchaseManager shared] sendGoodsSuccess:ocOrders callback:^(BOOL success, NSString * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_SendGoodsOver] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:success?1:0] forKey:@"code"];
                [dict setObject:(error == nil?@"":error) forKey:@"error"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_SendGoodsOver] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithBool:success] forKey:@"code"];
                    [dict setObject:(error == nil?@"":error) forKey:@"error"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
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
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    NSString* ocOrders = ConvertCharToNSString(orders);
    [Yodo1PurchaseManager.shared sendGoodsFail:ocOrders
                                      callback:^(BOOL success, NSString * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_SendGoodsOverFault] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:success?1:0] forKey:@"code"];
                [dict setObject:(error == nil?@"":error) forKey:@"error"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_SendGoodsOverFault] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithBool:success] forKey:@"code"];
                    [dict setObject:(error == nil?@"":error) forKey:@"error"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                }
                Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

#ifdef __cplusplus
}
#endif
