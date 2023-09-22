//
//  Yodo1PurchaseManager.m
//  Yodo1PurchaseManager
//
//  Created by yixian huang on 2017/7/24.
//

#import "Yodo1PurchaseManager.h"
#import "RMStore.h"
#import "RMStoreTransaction.h"
#import "RMStoreUserDefaultsPersistence.h"
#import "Yodo1Reachability.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AnalyticsManager.h"
#import "Yodo1AFNetworking.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1PurchaseDataAnalytics.h"
#import "Yodo1PurchaseAPI.h"
#import "Yodo1Commons.h"
#import "Yodo1Privacy.h"
#import "Yodo1Product.h"
#import "Yodo1PurchaseUtils.h"

@implementation PaymentObject

@end

@interface Yodo1PurchaseManager ()<RMStoreObserver> {
    RMStoreUserDefaultsPersistence *persistence;
    __block BOOL isBuying;
    __block PaymentObject* paymentObject;
}

@property (nonatomic,strong) NSString* currentUniformProductId;
@property (nonatomic,retain) SKPayment* addedStorePayment;//promot Appstore Buy
@property (nonatomic,copy)PaymentCallback paymentCallback;

- (void)rechargedProuct;

@end

@implementation Yodo1PurchaseManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[Yodo1PurchaseManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    [RMStore.defaultStore removeStoreObserver:self];
}

- (void)init:(NSString *)appKey regionCode:(NSString *)regionCode {
    if (self.isInitialized) {
        return;
    }
    self.isInitialized = YES;
    
    self->persistence = [[RMStoreUserDefaultsPersistence alloc] init];
    [RMStore.defaultStore setTransactionPersistor:persistence];
    [RMStore.defaultStore addStoreObserver:self];
    
    [[Yodo1PurchaseAPI shared] init:appKey regionCode:regionCode];
    [[Yodo1ProductManager shared] initProducts];
    
    self.user = [Yodo1UCenter.shared getUserInfo];
    
    isBuying = false;
    paymentObject = [PaymentObject new];
}

#pragma mark - 请求商品信息

- (void)productWithUniformProductId:(NSString *)uniformProductId callback:(ProductsInfoCallback)callback {
    NSSet* identifiers = [[NSSet alloc] initWithObjects:uniformProductId, nil];
    [Yodo1ProductManager.shared requestProducts:identifiers success:^(NSArray * _Nonnull products) {
        if (callback) {
            callback(products);
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)products:(ProductsInfoCallback)callback {
    [Yodo1ProductManager.shared requestProducts:^(NSArray * _Nonnull products) {
        if (callback) {
            callback(products);
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 购买

- (void)paymentWithUniformProductId:(NSString *)uniformProductId
                              extra:(NSString*)extra
                           callback:(nonnull PaymentCallback)callback {
    if (isBuying) {
        YD1LOG(@"product is buying ...");
        return;
    }
    isBuying = YES;
    self.paymentCallback = callback;
    
    paymentObject.uniformProductId = uniformProductId;
    paymentObject.channelOrderid = @"";
    paymentObject.orderId = @"";
    paymentObject.response = @"";
    paymentObject.paymentState = PaymentFail;
    paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                              code:PaymentErrorCodeUnKnow
                                          userInfo:@{NSLocalizedDescriptionKey:@""}];
    
    __block Yodo1Product* product = [Yodo1ProductManager.shared productForIdentifier:uniformProductId];
    if (product != nil) {
        [[Yodo1PurchaseDataAnalytics shared] updateItemProperties:product];
    }
    
    if (product == nil || uniformProductId == nil || uniformProductId.length == 0) {
        NSString* message = @"Invalid product identifier";
        YD1LOG(@"%@", message);
        paymentObject.paymentState = PaymentFail;
        paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                  code:PaymentErrorCodeInvalidProductId
                                              userInfo:@{NSLocalizedDescriptionKey:message}];
        [self invokePaymentCallback:paymentObject];
        isBuying = NO;
        return;
    }
    
    if (!RMStore.canMakePayments) {
        NSString* message = @"This device is not able or allowed to make payments";
        YD1LOG(@"%@", message);
        paymentObject.paymentState = PaymentFail;
        paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                  code:PaymentErrorCodeUserFail
                                              userInfo:@{NSLocalizedDescriptionKey:message}];
        [self invokePaymentCallback:paymentObject];
        isBuying = NO;
        return;
    }
    
    SKProduct* skp = [RMStore.defaultStore productForIdentifier:product.channelProductId];
    if (skp == nil) {
        NSString* message = @"It's not in RMStore products";
        YD1LOG(@"%@", message);
        paymentObject.paymentState = PaymentFail;
        paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                  code:PaymentErrorCodeInvalidProductId
                                              userInfo:@{NSLocalizedDescriptionKey:message}];
        [self invokePaymentCallback:paymentObject];
        isBuying = NO;
        return;
    }
    
    if ([[Yd1OpsTools networkType]isEqualToString:@"NONE"]) {
        NSString* message = @"The Network is not reachable";
        YD1LOG(@"%@", message);
        paymentObject.paymentState = PaymentFail;
        paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                  code:PaymentErrorCodeNotNetwork
                                              userInfo:@{NSLocalizedDescriptionKey:message}];
        [self invokePaymentCallback:paymentObject];
        isBuying = NO;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    weakSelf.user = [Yodo1UCenter.shared getUserInfo];
    if (weakSelf.user == nil || weakSelf.user.yid == nil || weakSelf.user.yid.length <= 0) {
        [Yodo1UCenter.shared loginWitheDeviceId:^(YD1User * _Nullable user, NSError * _Nullable error) {
            if (user) {
                weakSelf.user = user;
                weakSelf.user.ucuid = user.ucuid? : user.uid;
                [Yd1OpsTools.cached setObject:weakSelf.user forKey:@"yd1User"];
            }
            if (user && !error) {
                [self createOrderIdWithUniformProductId:uniformProductId
                                                  extra:extra
                                               callback:^(bool success, NSString * _Nonnull orderId, NSError * _Nonnull error) {
                    if (success) {
                        if (product.productType == Auto_Subscription) {
                            product.orderId = orderId;
                            [weakSelf paymentAutoSubscriptionProduct:product];
                        } else {
                            [weakSelf paymentProduct:product];
                        }
                    } else {
                        self->paymentObject.paymentState = PaymentFail;
                        NSString* message = [NSString stringWithFormat:@"%@ (error %ld)", error.localizedDescription, error.code];
                        YD1LOG(@"Failed to create order with error: %@", message);
                        self->paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                                        code:PaymentErrorCodeCreateOrder
                                                                    userInfo:@{NSLocalizedDescriptionKey:message}];
                        [weakSelf invokePaymentCallback:self->paymentObject];
                        self->isBuying = NO;
                    }
                }];
            }else{
                NSString* message = [NSString stringWithFormat:@"The user is not logged in Yodo1 ucenter. %@ (error %ld.)", error.localizedDescription, error.code];
                YD1LOG(@"%@", message);
                self->paymentObject.paymentState = PaymentFail;
                self->paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                                code:PaymentErrorCodeUserLoginFail
                                                            userInfo:@{NSLocalizedDescriptionKey:message}];
                [self invokePaymentCallback:self->paymentObject];
                self->isBuying = NO;
            }
        }];
    } else {
        [self createOrderIdWithUniformProductId:uniformProductId
                                          extra:extra
                                       callback:^(bool success, NSString * _Nonnull orderid, NSError * _Nonnull error) {
            if (success) {
                if (product.productType == Auto_Subscription) {
                    product.orderId = orderid;
                    [weakSelf paymentAutoSubscriptionProduct:product];
                } else {
                    [weakSelf paymentProduct:product];
                }
            } else {
                self->isBuying = NO;
                self->paymentObject.uniformProductId = uniformProductId;
                self->paymentObject.paymentState = PaymentFail;
                NSString* message = [NSString stringWithFormat:@"%@ (error %ld)", error.localizedDescription, error.code];
                YD1LOG(@"Failed to create order with error: %@", message);
                self->paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                                code:PaymentErrorCodeCreateOrder
                                                            userInfo:@{NSLocalizedDescriptionKey:message}];
                [weakSelf invokePaymentCallback:self->paymentObject];
            }
        }];
    }
}

- (void)paymentAutoSubscriptionProduct:(Yodo1Product *)product {
    self->paymentObject.uniformProductId = product.uniformProductId;
    self->paymentObject.orderId = product.orderId;
    Yodo1PurchaseAPI.shared.transaction.orderId = product.orderId;
    
    NSString* msg = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionAlertMessage"
                                    withDefault:@"确认启用后，您的iTunes账户将支付 %@ %@ 。%@自动续订此服务时您的iTunes账户也会支付相同费用。系统在订阅有效期结束前24小时会自动为您续订并扣费，除非您在有效期结束前取消服务。若需取消订阅，可前往设备设置-iTunes与App Store-查看Apple ID-订阅，管理或取消已经启用的服务。"];
    NSString* message = [NSString stringWithFormat:msg,product.productPrice,product.currency,product.periodUnit];
    
    NSString* title = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionAlertTitle" withDefault:@"确认启用订阅服务"];
    NSString* cancelTitle = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionAlertCancel" withDefault:@"取消"];
    NSString* okTitle = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionAlertOK" withDefault:@"启用"];
    NSString* privateTitle = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionAlertPrivate" withDefault:@"隐私协议"];
    NSString* serviceTitle = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionAlertService" withDefault:@"服务条款"];
    
    NSString* privacyPolicyUrl = [[Yodo1Privacy shareInstance] getPrivacyPolicyUrl];
    NSString* termsServiceUrl = [[Yodo1Privacy shareInstance] getTermsOfServiceUrl];
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    // Ok Action
    [alertController addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self paymentProduct:product];
    }]];
    // Service Action
    [alertController addAction:[UIAlertAction actionWithTitle:serviceTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:termsServiceUrl]];
        [self invokeSubscriptionActions:product paymentState:PaymentCancel paymentError:PaymentErrorCodeCannelForPrivacy];
    }]];
    // Privacy Action
    [alertController addAction:[UIAlertAction actionWithTitle:privateTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:privacyPolicyUrl]];
        [self invokeSubscriptionActions:product paymentState:PaymentCancel paymentError:PaymentErrorCodeCannelForPrivacy];
    }]];
    // Cancel Action
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self invokeSubscriptionActions:product paymentState:PaymentCancel paymentError:PaymentErrorCodeCancelled];
    }]];
    
    UIViewController* viewController = [Yodo1Commons getRootViewController];
    if([Yd1OpsTools isIPad]){
        [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self invokeSubscriptionActions:product paymentState:PaymentCancel paymentError:PaymentErrorCodeCancelled];
        }]];
        
        if (alertController.popoverPresentationController) {
            //            [alertController.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionUp];//去掉arrow箭头
            alertController.popoverPresentationController.sourceView = viewController.view;
            alertController.popoverPresentationController.sourceRect = CGRectMake(0, viewController.view.frame.size.height, viewController.view.frame.size.width, viewController.view.frame.size.height);
        }
    }
    [viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)paymentProduct:(Yodo1Product*)product {
    [RMStore.defaultStore addPayment:product.channelProductId];
}

- (void)invokePaymentCallback:(PaymentObject*)paymentObject {
    if (paymentObject == nil) {
        return;
    }
    
    if (paymentObject.paymentState != PaymentSuccess) {
        NSNumber* errorCode = [NSNumber numberWithInteger:paymentObject.error.code];
        NSString* errorMsg = paymentObject.error.localizedDescription;
        [[Yodo1PurchaseDataAnalytics shared] trackOrderError:errorCode errorMessage:errorMsg];
    }
    
    if (self.paymentCallback != nil) {
        self.paymentCallback(paymentObject);
    }
}

- (void)invokeSubscriptionActions:(Yodo1Product*)product paymentState:(PaymentState)paymentState paymentError:(PaymentErrorCode)paymentErrorCode {
    if (product == nil) {
        return;
    }
    
    [self removeOrder:product.orderId storeProductIdentifier:product.channelProductId];
    
    self->paymentObject.paymentState = paymentState;
    self->paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                    code:paymentErrorCode
                                                userInfo:@{NSLocalizedDescriptionKey:@"The user cancelled a payment request from Subscription action."}];
    [self invokePaymentCallback:self->paymentObject];
    self->isBuying = NO;
    Yodo1PurchaseAPI.shared.transaction.statusCode = [NSString stringWithFormat:@"%ld",(long)self->paymentObject.paymentState];
    [Yodo1PurchaseAPI.shared reportOrderFail:Yodo1PurchaseAPI.shared.transaction callback:^(BOOL success, NSString * _Nonnull error) {
        YD1LOG(@"report %@.", success ? @"success" : @"failed");
    }];
}

- (void)addOrder:(NSString *)orderId storeProductIdentifier:(NSString*)storeProductIdentifier {
    NSString* oldOrderIdStr = [Yd1OpsTools keychainWithService:storeProductIdentifier];
    NSArray* oldOrderId = (NSArray *)[Yd1OpsTools JSONObjectWithString:oldOrderIdStr error:nil];
    NSMutableArray* newOrderId = [NSMutableArray array];
    if (oldOrderId) {
        [newOrderId setArray:oldOrderId];
    }
    [newOrderId addObject:orderId];
    NSString* orderidJson = [Yd1OpsTools stringWithJSONObject:newOrderId error:nil];
    [Yd1OpsTools saveKeychainWithService:storeProductIdentifier str:orderidJson];
}

- (void)removeOrder:(NSString *)orderId storeProductIdentifier:(NSString*)storeProductIdentifier {
    NSString* oldOrderIdStr = [Yd1OpsTools keychainWithService:storeProductIdentifier];
    NSArray* oldOrderId = (NSArray *)[Yd1OpsTools JSONObjectWithString:oldOrderIdStr error:nil];
    NSMutableArray* newOrderId = [NSMutableArray array];
    if (oldOrderId) {
        [newOrderId setArray:oldOrderId];
    }
    for (NSString* checkOrderId in oldOrderId) {
        if ([checkOrderId isEqualToString:orderId]) {
            [newOrderId removeObject:checkOrderId];
            break;
        }
    }
    NSString* orderidJson = [Yd1OpsTools stringWithJSONObject:newOrderId error:nil];
    [Yd1OpsTools saveKeychainWithService:storeProductIdentifier str:orderidJson];
}

- (void)createOrderIdWithUniformProductId:(NSString *)uniformProductId
                                    extra:(NSString*)extra
                                 callback:(void (^)(bool, NSString * _Nonnull, NSError * _Nonnull))callback {
    self.currentUniformProductId = uniformProductId;
    __block Yodo1Product* product = [Yodo1ProductManager.shared productForIdentifier:uniformProductId];
    __weak typeof(self) weakSelf = self;
    [Yodo1PurchaseAPI.shared generateOrderId:^(NSString * _Nullable orderId, NSError * _Nullable error) {
        if ((orderId == nil || [orderId isEqualToString:@""])) {
            YD1LOG(@"Failed to generat order, %@", error.description);
            [[Yodo1PurchaseDataAnalytics shared] trackOrderRequest:NO];
            [[Yodo1PurchaseDataAnalytics shared] trackOrderPending];
            callback(NO,orderId,error);
            return;
        }
        
        [weakSelf addOrder:orderId storeProductIdentifier:product.channelProductId];
        
        Yodo1PurchaseAPI.shared.transaction.orderId = orderId;
        Yodo1PurchaseAPI.shared.transaction.product_type = (int)product.productType;
        Yodo1PurchaseAPI.shared.transaction.item_code = product.channelProductId;
        // 下单
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        [parameters setObject:orderId forKey:@"orderId"];
        
        NSDictionary* productInfo = @{
            @"productId":product.channelProductId? :@"",
            @"productName":product.productName? :@"",
            @"productCount":@"1",
            @"productDescription":product.productDescription? :@"",
            @"currency":product.currency? :@"",
            @"productType":[NSNumber numberWithInt:(int)product.productType],
            @"price":product.productPrice? :@"",
            @"channelItemCode":@"",
        };
        
        [parameters setObject:productInfo forKey:@"product"];
        [parameters setObject:product.channelProductId? :@"" forKey:@"itemCode"];
        [parameters setObject:product.productPrice? :@"" forKey:@"orderMoney"];
        
        if (weakSelf.user.uid) {
            [parameters setObject:weakSelf.user.uid forKey:@"uid"];
        }else{
            NSString* uid = weakSelf.user.playerid? :weakSelf.user.ucuid;
            [parameters setObject:uid? :@"" forKey:@"uid"];
        }
        [parameters setObject:weakSelf.user.yid? :@"" forKey:@"yid"];
        [parameters setObject:weakSelf.user.ucuid? :@"" forKey:@"ucuid"];
        if (weakSelf.user.playerid) {
            [parameters setObject:weakSelf.user.playerid forKey:@"playerId"];
        }else{
            NSString* playerid = weakSelf.user.ucuid? :weakSelf.user.uid;
            [parameters setObject:playerid? :@"" forKey:@"playerId"];
        }
        
        [parameters setObject:Yd1OpsTools.appName? :@"" forKey:@"gameName"];
        [parameters setObject:@"offline" forKey:@"gameType"];
        [parameters setObject:Yd1OpsTools.appVersion? :@"" forKey:@"gameVersion"];
        [parameters setObject:@"" forKey:@"gameExtra"];
        [parameters setObject:extra? :@"" forKey:@"extra"];
        [parameters setObject:Yd1OpsTools.appVersion? :@"" forKey:@"channelVersion"];
        
        [Yodo1PurchaseAPI.shared createOrder:parameters callback:^(BOOL success, NSError * _Nonnull error) {
            [[Yodo1PurchaseDataAnalytics shared] trackOrderRequest:success];
            if (success) {
                YD1LOG(@"Create order successfully, %@: ", orderId);
            } else {
                YD1LOG(@"Failed to create order, %@", error.description);
                [[Yodo1PurchaseDataAnalytics shared] trackOrderPending];
            }
            callback(success,orderId,error);
        }];
    }];
}

#pragma mark - 恢复购买

- (void)restorePayment:(RestoreCallback)callback {
    [RMStore.defaultStore restoreTransactionsOnSuccess:^(NSArray *transactions) {
        NSMutableArray* restoredProducts = [NSMutableArray array];
        for (SKPaymentTransaction *transaction in transactions) {
            YD1LOG(@"transaction.payment.productIdentifier -- %@", transaction.payment.productIdentifier);
            Yodo1Product* product = [Yodo1ProductManager.shared productForStoreIdentifier:transaction.payment.productIdentifier];
            if (product) {
                BOOL isHave = false;
                for (Yodo1Product* pro in restoredProducts) {
                    if ([pro.channelProductId isEqualToString:product.channelProductId]) {
                        isHave = true;
                        continue;
                    }
                }
                if (!isHave) {
                    [restoredProducts addObject:product];
                }
            }
        }
        callback(restoredProducts,@"Restore purchased successfully");
    } failure:^(NSError *error) {
        callback(@[],error.localizedDescription);
    }];
}

#pragma mark - 查询漏单商品

- (void)queryLossOrder:(LossOrderCallback)callback {
    __weak typeof(self) weakSelf = self;
    weakSelf.user = [Yodo1UCenter.shared getUserInfo];
    if (weakSelf.user == nil || weakSelf.user.yid == nil || weakSelf.user.yid.length <= 0) {
        [Yodo1UCenter.shared loginWitheDeviceId:^(YD1User * _Nullable user, NSError * _Nullable error) {
            if (user && !error) {
                weakSelf.user = user;
                [weakSelf queryLossOrderAfterLogin:callback];
            }
        }];
    } else {
        [weakSelf queryLossOrderAfterLogin:callback];
    }
}

- (void)queryLossOrderAfterLogin:(LossOrderCallback)lossOrderCallback {
    NSMutableArray* lostTransactions = [NSMutableArray array];
    NSSet* purchasedProductIdentifiers = [persistence purchasedProductIdentifiers];
    YD1LOG(@"purchasedProductIdentifiers: %@",purchasedProductIdentifiers);
    for (NSString* productIdentifier in purchasedProductIdentifiers.allObjects) {
        NSArray* transactions = [persistence transactionsForProductOfIdentifier:productIdentifier];
        for (RMStoreTransaction* transaction in transactions) {
            if (transaction.consumed) {
                continue;
            }
            [lostTransactions addObject:transaction];
        }
    }
    
    if ([lostTransactions count] < 1) {
        lossOrderCallback(@[],@"No lost orders");
        return;
    }
    
    // 去掉订单一样的对象
    NSMutableArray *rp = [NSMutableArray array];
    for (RMStoreTransaction *transaction in lostTransactions) {
        __block BOOL isExist = NO;
        [rp enumerateObjectsUsingBlock:^(RMStoreTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.orderId isEqual:transaction.orderId]) {//数组中已经存在该对象
                *stop = YES;
                isExist = YES;
            }
        }];
        if (!isExist && transaction.orderId) {//如果不存在就添加进去
            [rp addObject:transaction];
        }
    }
    
    __block NSMutableDictionary* lossOrder = [NSMutableDictionary dictionary];
    __block NSMutableArray* lossOrderProduct = [NSMutableArray array];
    __block int lossOrderCount = 0;
    __block int lossOrderReceiveCount = 0;
    for (RMStoreTransaction* transaction in rp) {
        lossOrderCount++;
        
        BOOL isSandbox = NO;
        NSString *encodedReceipt = @"";
        NSURL* receiptURL = RMStore.receiptURL;
        NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
        if (!receipt) {
            YD1LOG(@"no receipt");
            /* No local receipt -- handle the error. */
        } else {
            /* Get the receipt in encoded format. */
            encodedReceipt = [receipt base64EncodedStringWithOptions:0];
            isSandbox = [[receiptURL absoluteString] containsString:@"sandboxReceipt"];
        }
        
        Yodo1PurchaseAPI.shared.transaction.channelOrderid = transaction.transactionIdentifier;
        Yodo1PurchaseAPI.shared.transaction.orderId = transaction.orderId;
        Yodo1PurchaseAPI.shared.transaction.item_code = transaction.productIdentifier;
        Yodo1PurchaseAPI.shared.transaction.trx_receipt = encodedReceipt;
        Yodo1PurchaseAPI.shared.transaction.is_sandbox = isSandbox? @"true" : @"";
                
        Yodo1Product* paymentProduct = [Yodo1ProductManager.shared productForStoreIdentifier:transaction.productIdentifier];
        Yodo1PurchaseAPI.shared.transaction.product_type = (int)paymentProduct.productType;

        [Yodo1PurchaseAPI.shared verifyOrder:Yodo1PurchaseAPI.shared.transaction
                                        user: self.user
                                    callback:^(BOOL verifySuccess, NSString * _Nonnull response, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response && response.length > 0) {
                    NSDictionary* dic = [Yd1OpsTools JSONObjectWithString:response error:nil];
                    NSString* orderId = [dic objectForKey:@"orderid"];
                    NSString* itemCode = [dic objectForKey:@"item_code"];
                    int errorcode = [[dic objectForKey:@"error_code"]intValue];
                    if (verifySuccess) {
                        if (orderId && itemCode) {
                            [lossOrder setObject:itemCode forKey:orderId];
                            [self->persistence consumeProductOfIdentifier:itemCode];
                            [self->persistence rechargedProuctOfIdentifier:itemCode];
                        }
                        
                        [Yodo1PurchaseDataAnalytics.shared trackReplaceOrder];
                        
                        YD1LOG(@"验证成功orderid:%@",orderId);
                    } else {
                        if (errorcode == 20) {
                            [self->persistence consumeProductOfIdentifier:itemCode? :@""];
                        }
                    }
                }
                lossOrderReceiveCount++;
                if (lossOrderReceiveCount == lossOrderCount) { // we got the verify resluts of all orders from IAP payment system
                    [self queryLossOrdersFromServer:lossOrder lostProducts:lossOrderProduct callback:lossOrderCallback];
                }
            });
        }];
    }
}

- (void)queryLossOrdersFromServer:(NSMutableDictionary*)lossOrder lostProducts:(NSMutableArray*)lossOrderProducts callback:(LossOrderCallback)lossOrderCallback {
    [Yodo1PurchaseAPI.shared queryLossOrders:self.user
                                    callback:^(BOOL success, NSArray * _Nonnull missorders, NSString * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Get all missed orders inlucde local and server records
            if (success && [missorders count] > 0) {
                for (NSDictionary* item in missorders) {
                    NSString* productId2 = (NSString*)[item objectForKey:@"productId"];
                    NSString* orderId2 = (NSString*)[item objectForKey:@"orderId"];
                    
                    if ([[lossOrder allKeys]containsObject:orderId2]) {
                        continue;
                    }
                    if (productId2 && orderId2) {
                        [lossOrder setObject:productId2 forKey:orderId2];
                    }
                }
            }
            
            // Get all missed products and callback to the developer
            for (NSString* orderId in lossOrder) {
                NSString* itemCode = [lossOrder objectForKey:orderId];
                Yodo1Product* product = [Yodo1ProductManager.shared productForStoreIdentifier:itemCode];
                if (product) {
                    Yodo1Product* product2 = [[Yodo1Product alloc] initWithProduct:product];
                    product2.orderId = orderId;
                    [lossOrderProducts addObject:product2];
                    //同步信息
                    [Yodo1PurchaseAPI.shared clientNotifyToServer:@[orderId]
                                                         callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                        if (success) {
                            YD1LOG(@"The information is synchronized successfully.");
                        } else {
                            YD1LOG(@"The information is synchronized unsuccessfully:%@",error);
                        }
                    }];
                }
            }
            if (lossOrderCallback) {
                lossOrderCallback(lossOrderProducts,@"");
            }
        });
    }];
}

#pragma mark - 查询订阅商品

- (void)querySubscriptions:(BOOL)excludeOldTransactions
                  callback:(QuerySubscriptionCallback)callback {
    NSMutableArray* result = [NSMutableArray array];
    Yodo1PurchaseAPI.shared.transaction.exclude_old_transactions = excludeOldTransactions?@"true":@"false";
    NSString* receipt = [[NSData dataWithContentsOfURL:RMStore.receiptURL] base64EncodedStringWithOptions:0];
    if (!receipt) {
        callback(result, -1, NO, @"App Store of receipt is nil");
        return;
    }
    Yodo1PurchaseAPI.shared.transaction.trx_receipt = receipt;
    [Yodo1PurchaseAPI.shared querySubscriptions:Yodo1PurchaseAPI.shared.transaction
                                       callback:^(BOOL success, NSString * _Nullable response, NSError * _Nullable error) {
        if (success) {
            NSDictionary *responseDic = [Yd1OpsTools JSONObjectWithString:response error:nil];
            if(responseDic){
                NSDictionary* extra =[responseDic objectForKey:@"extra"];
                NSArray* latest_receipt_infos =[extra objectForKey:@"latest_receipt_info"];
                NSTimeInterval serverTime = [[responseDic objectForKey:@"timestamp"] doubleValue];
                
                for (int i = 0; i < [latest_receipt_infos count]; i++) {
                    NSDictionary* latest_receipt_info =[latest_receipt_infos objectAtIndex:i];
                    NSTimeInterval expires_date_ms = [[latest_receipt_info objectForKey:@"expires_date_ms"] doubleValue];
                    if(expires_date_ms == 0){
                        continue;
                    }
                    NSTimeInterval purchase_date_ms = [[latest_receipt_info objectForKey:@"purchase_date_ms"] doubleValue];
                    NSString* channelProductId = [latest_receipt_info objectForKey:@"product_id"];
                    Yodo1Product* product = [Yodo1ProductManager.shared productForStoreIdentifier:channelProductId];
                    if (product == nil) {
                        continue;
                    }
                    NSString* uniformProductId = product.uniformProductId;
                    SubscriptionProductInfo* info = [[SubscriptionProductInfo alloc] initWithUniformProductId:uniformProductId
                                                                                             channelProductId:channelProductId
                                                                                                      expires:expires_date_ms
                                                                                                 purchaseDate:purchase_date_ms];
                    [result addObject:info];
                }
                //去重
                NSMutableArray *rp = [NSMutableArray array];
                for (SubscriptionProductInfo *model in result) {
                    __block BOOL isExist = NO;
                    [rp enumerateObjectsUsingBlock:^(SubscriptionProductInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.channelProductId isEqual:model.channelProductId]) {
                            *stop = YES;
                            isExist = YES;
                        }
                    }];
                    if (!isExist && model.channelProductId) {
                        [rp addObject:model];
                    }
                }
                callback(rp, serverTime, YES, nil);
            }
        }else{
            callback(result, -1, NO, response);
        }
    }];
}

#pragma mark - 促销活动

- (void)fetchStorePromotionOrder:(FetchStorePromotionOrderCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        [[SKProductStorePromotionController defaultController] fetchStorePromotionOrderWithCompletionHandler:^(NSArray<SKProduct *> * _Nonnull storePromotionOrder, NSError * _Nullable error) {
            if(callback){
                NSMutableArray<NSString*>* uniformProductIDs = [[NSMutableArray alloc] init];
                for (int i = 0; i < [storePromotionOrder count]; i++) {
                    NSString* storeProductID = [[storePromotionOrder objectAtIndex:i] productIdentifier];
                    Yodo1Product* product = [Yodo1ProductManager.shared productForStoreIdentifier:storeProductID];
                    if (product == nil) {
                        continue;
                    }
                    [uniformProductIDs addObject:product.uniformProductId];
                }
                callback(uniformProductIDs, error == nil, [error description]);
            }
        }];
    } else {
        
    }
#endif
}

- (void)fetchStorePromotionVisibilityForProduct:(NSString *)uniformProductId callback:(FetchStorePromotionVisibilityCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        Yodo1Product* product = [Yodo1ProductManager.shared productForIdentifier:uniformProductId];
        NSString* channelProductId = product.channelProductId;
        [[SKProductStorePromotionController defaultController] fetchStorePromotionVisibilityForProduct:[RMStore.defaultStore productForIdentifier:channelProductId] completionHandler:^(SKProductStorePromotionVisibility storePromotionVisibility, NSError * _Nullable error) {
            if(callback){
                PromotionVisibility result = Default;
                switch (storePromotionVisibility) {
                    case SKProductStorePromotionVisibilityShow:
                        result = Visible;
                        break;
                    case SKProductStorePromotionVisibilityHide:
                        result = Hide;
                        break;
                    default:
                        break;
                }
                callback(result, error == nil, [error description]);
            }
        }];
    } else {
    }
#endif
}

- (void)updateStorePromotionOrder:(NSArray<NSString *> *)uniformProductIdArray
                         callback:(nonnull UpdateStorePromotionOrderCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        NSMutableArray<SKProduct *> *productsArray = [[NSMutableArray alloc] init];
        for (NSString* uniformProductId in uniformProductIdArray) {
            Yodo1Product* product = [Yodo1ProductManager.shared productForIdentifier:uniformProductId];
            NSString* channelProductId = product.channelProductId;
            [productsArray addObject:[RMStore.defaultStore productForIdentifier:channelProductId]];
        }
        [[SKProductStorePromotionController defaultController] updateStorePromotionOrder:productsArray completionHandler:^(NSError * _Nullable error) {
            callback(error == nil, [error description]);
        }];
    } else {
        
    }
#endif
}

- (void)updateStorePromotionVisibility:(BOOL)visibility
                               product:(NSString *)uniformProductId
                              callback:(UpdateStorePromotionVisibilityCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        Yodo1Product* product = [Yodo1ProductManager.shared productForIdentifier:uniformProductId];
        NSString* channelProductId = product.channelProductId;
        SKProduct* skProduct = [RMStore.defaultStore productForIdentifier:channelProductId];
        [[SKProductStorePromotionController defaultController] updateStorePromotionVisibility:visibility ? SKProductStorePromotionVisibilityShow : SKProductStorePromotionVisibilityHide forProduct:skProduct completionHandler:^(NSError * _Nullable error) {
            callback(error == nil, [error description]);
        }];
    } else {
    }
#endif
}

- (void)readyToContinuePurchaseFromPromot:(PaymentCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        if(self.addedStorePayment){
            Yodo1Product* product = [Yodo1ProductManager.shared productForStoreIdentifier:self.addedStorePayment.productIdentifier];
            NSString* uniformP = @"";
            if (product != nil) {
                uniformP = product.uniformProductId? :@"";
            }
            [self paymentWithUniformProductId:uniformP extra:@"" callback:callback];
        } else {
            paymentObject.uniformProductId = self.currentUniformProductId;
            paymentObject.channelOrderid = @"";
            paymentObject.orderId = Yodo1PurchaseAPI.shared.transaction.orderId;
            paymentObject.response = @"";
            paymentObject.paymentState = PaymentCancel;
            paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                      code:PaymentErrorCodeCancelled
                                                  userInfo:@{NSLocalizedDescriptionKey:@"promot is nil!"}];
            callback(paymentObject);
        }
    }
#endif
}

- (void)cancelPromotion {
    self.addedStorePayment = nil;
}

- (Yodo1Product*)promotionProduct {
    if (self.addedStorePayment) {
        Yodo1Product* product = [Yodo1ProductManager.shared productForStoreIdentifier:self.addedStorePayment.productIdentifier];
        return product;
    }
    return nil;
}

- (void)rechargedProuct {
    Yodo1Product* product = [Yodo1ProductManager.shared productForIdentifier:self.currentUniformProductId];
    if (self->persistence) {
        [self->persistence rechargedProuctOfIdentifier:product.channelProductId];
    }
}

#pragma mark - RMStoreObserver
- (void)storePaymentTransactionDeferred:(NSNotification*)notification {
    YD1LOG(@"");
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification {
    NSString* storeProductIdentifier = notification.rm_productIdentifier;
    if (!storeProductIdentifier) {
        Yodo1Product* product = [Yodo1ProductManager.shared productForIdentifier:self.currentUniformProductId];
        if (product.channelProductId) {
            storeProductIdentifier = product.channelProductId;
        }
    }
    if (storeProductIdentifier) {
        [self removeOrder:Yodo1PurchaseAPI.shared.transaction.orderId storeProductIdentifier:storeProductIdentifier];
    }
    
    NSString* channelOrderid = notification.rm_transaction.transactionIdentifier;
    if (!channelOrderid) {
        channelOrderid = @"";
    }
    
    NSString* message = @"";
    if (notification.rm_storeError != nil) {
        message = [NSString stringWithFormat:@"%@", notification.rm_storeError.localizedDescription];
    }
    YD1LOG(@"%@", message);
    
    paymentObject.uniformProductId = self.currentUniformProductId;
    paymentObject.channelOrderid = channelOrderid;
    paymentObject.orderId = Yodo1PurchaseAPI.shared.transaction.orderId;
    paymentObject.response = @"";
    bool isCancelled = NO;
    if (@available(iOS 12.2, *)) {
        if (notification.rm_storeError.code == SKErrorPaymentCancelled || notification.rm_storeError.code == SKErrorOverlayCancelled) {
            isCancelled = YES;
        }
    } else {
        // Fallback on earlier versions
        if (notification.rm_storeError.code == SKErrorPaymentCancelled) {
            isCancelled = YES;
        }
    }
    if (isCancelled) {
        paymentObject.paymentState = PaymentCancel;
        paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                  code:PaymentErrorCodeCancelled
                                              userInfo:@{NSLocalizedDescriptionKey:message}];
    } else {
        paymentObject.paymentState = PaymentFail;
        paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                  code:PaymentErrorCodeAppleFail
                                              userInfo:@{NSLocalizedDescriptionKey:message}];
    }
    
    Yodo1PurchaseAPI.shared.transaction.channelOrderid = paymentObject.channelOrderid;
    Yodo1PurchaseAPI.shared.transaction.orderId = paymentObject.orderId;
    Yodo1PurchaseAPI.shared.transaction.statusCode = [NSString stringWithFormat:@"%ld", (long)paymentObject.paymentState];
    Yodo1PurchaseAPI.shared.transaction.statusMsg = message;
    [Yodo1PurchaseAPI.shared reportOrderFail:Yodo1PurchaseAPI.shared.transaction
                                    callback:^(BOOL success, NSString * _Nonnull error) {
        if (success) {
            YD1LOG(@"report success.");
        } else {
            YD1LOG(@"report failed.");
        }
    }];
    
    [self invokePaymentCallback:self->paymentObject];
    self->isBuying = NO;
}

- (void)storePaymentTransactionFinished:(NSNotification*)notification {
    SKPaymentTransaction* paymentTransaction = notification.rm_transaction;
    
    NSString* channelOrderId = paymentTransaction.transactionIdentifier;
    if (channelOrderId == nil) {
        channelOrderId = @"";
    }
        
    Yodo1Product* product = [Yodo1ProductManager.shared productForIdentifier:self.currentUniformProductId];
    NSString* storeProductIdentifier = notification.rm_productIdentifier;
    if (!storeProductIdentifier) {
        storeProductIdentifier = product.channelProductId;
    }
    
    BOOL isSandbox = NO;
    NSString *encodedReceipt = @"";
    NSURL* receiptURL = RMStore.receiptURL;
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    if (!receipt) {
        YD1LOG(@"no receipt");
        /* No local receipt -- handle the error. */
    } else {
        /* Get the receipt in encoded format. */
        encodedReceipt = [receipt base64EncodedStringWithOptions:0];
        isSandbox = [[receiptURL absoluteString] containsString:@"sandboxReceipt"];
    }
    
    Yodo1PurchaseAPI.shared.transaction.channelOrderid = channelOrderId;
    Yodo1PurchaseAPI.shared.transaction.productId = storeProductIdentifier;
    Yodo1PurchaseAPI.shared.transaction.trx_receipt = encodedReceipt;
    Yodo1PurchaseAPI.shared.transaction.is_sandbox = isSandbox? @"true" : @"";

    __weak typeof(self) weakSelf = self;
    [Yodo1PurchaseAPI.shared verifyOrder:Yodo1PurchaseAPI.shared.transaction
                                    user: self.user
                                callback:^(BOOL verifySuccess, NSString * _Nonnull response, NSError * _Nonnull error) {
        NSDictionary* respo = [Yd1OpsTools JSONObjectWithString:response error:nil];
        NSString* orderId = @"";
        NSString* itemCode = @"";
        int errorCode = -1;
        if (respo) {
            orderId = [respo objectForKey:@"orderid"];
            errorCode = [[respo objectForKey:@"error_code"]intValue];
            itemCode = [respo objectForKey:@"item_code"];
        }
        YD1LOG(@"error_code:%d",errorCode);
        if (verifySuccess) {
            Yodo1IAPRevenue* iapRevenue = [[Yodo1IAPRevenue alloc] init];
            iapRevenue.productIdentifier = storeProductIdentifier;
            iapRevenue.revenue = product.productPrice;
            iapRevenue.currency = product.currency;
            iapRevenue.transactionId = channelOrderId;
            iapRevenue.receiptId = encodedReceipt;
            [Yodo1AnalyticsManager.sharedInstance trackIAPRevenue:iapRevenue];
            
            [Yodo1PurchaseAPI.shared clientNotifyToServer:@[orderId]
                                                 callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"The information is synchronized successfully.");
                } else {
                    YD1LOG(@"The information is synchronized unsuccessfully:%@",error);
                }
                YD1LOG(@"notExistOrders:%@,notPayOrders:%@", notExistOrders,notPayOrders)
            }];
            
            self->paymentObject.uniformProductId = weakSelf.currentUniformProductId;
            self->paymentObject.channelOrderid = Yodo1PurchaseAPI.shared.transaction.channelOrderid;
            self->paymentObject.orderId = orderId;
            self->paymentObject.response = response;
            self->paymentObject.paymentState = PaymentSuccess;
            [weakSelf invokePaymentCallback:self->paymentObject];
            
            [self->persistence consumeProductOfIdentifier:itemCode];
        } else {
            if (errorCode == 20) {
                [self->persistence consumeProductOfIdentifier:itemCode];
            }
            
            NSString* message = @"";
            if (error != nil) {
                message = [NSString stringWithFormat:@"%@ (error %ld)", error.localizedDescription, error.code];
            }
            YD1LOG(@"%@", message);
            
            Yodo1PurchaseAPI.shared.transaction.channelOrderid = Yodo1PurchaseAPI.shared.transaction.channelOrderid;
            Yodo1PurchaseAPI.shared.transaction.orderId = orderId;
            Yodo1PurchaseAPI.shared.transaction.statusCode = [NSString stringWithFormat:@"%ld",(long)PaymentFail];
            Yodo1PurchaseAPI.shared.transaction.statusMsg = message;
            [Yodo1PurchaseAPI.shared reportOrderFail:Yodo1PurchaseAPI.shared.transaction
                                            callback:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"report success.");
                } else {
                    YD1LOG(@"report failed.");
                }
            }];
            
            self->paymentObject.uniformProductId = weakSelf.currentUniformProductId;
            self->paymentObject.channelOrderid = Yodo1PurchaseAPI.shared.transaction.channelOrderid;
            self->paymentObject.orderId = orderId;
            self->paymentObject.response = response;
            self->paymentObject.paymentState = PaymentVerifyOrderFail;
            self->paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                            code:PaymentErrorCodeVerifyOrderFail
                                                        userInfo:@{NSLocalizedDescriptionKey:message}];
            [weakSelf invokePaymentCallback:self->paymentObject];
        }
        self->isBuying = NO;
    }];
}

- (void)storeProductsRequestFailed:(NSNotification*)notification {
    YD1LOG(@"%@",notification.rm_storeError);
}

- (void)storeProductsRequestFinished:(NSNotification*)notification {
    YD1LOG(@"");
    //    NSArray *products = notification.rm_products;
    //    [self updateProductInfo:products];
}

- (void)storeRefreshReceiptFailed:(NSNotification*)notification {
    YD1LOG(@"");
}

- (void)storeRefreshReceiptFinished:(NSNotification*)notification {
    YD1LOG(@"");
}

- (void)storeRestoreTransactionsFailed:(NSNotification*)notification {
    YD1LOG(@"");
}

- (void)storeRestoreTransactionsFinished:(NSNotification*)notification {
    YD1LOG(@"");
}

- (void)storePromotionPaymentFinished:(NSNotification *)notification {
    YD1LOG(@"");
    self.addedStorePayment = notification.rm_payment;
}

/**
 * 通知已发货成功
 */
- (void)sendGoodsSuccess:(NSString *)orderIds
                callback:(void (^)(BOOL success,NSString* error))callback {
    if (!orderIds || orderIds.length < 1) {
        callback(false,@"order Ids is empty!");
        return;
    }
    [Yodo1PurchaseAPI.shared sendGoodsSuccess:orderIds callback:^(BOOL success, NSString * _Nonnull error) {
        if (callback != nil) {
            callback(success, error);
        }
        [[Yodo1PurchaseDataAnalytics shared] trackOrderItemReceived:success];
        if (success) {
            [Yodo1PurchaseManager.shared rechargedProuct];
        }
    }];
}


/**
 * 通知已发货失败
 */
- (void)sendGoodsFail:(NSString *)orderIds
             callback:(void (^)(BOOL success,NSString* error))callback {
    if (!orderIds || orderIds.length < 1) {
        callback(false,@"order Ids is empty!");
        return;
    }
    [Yodo1PurchaseAPI.shared sendGoodsFail:orderIds callback:^(BOOL success, NSString * _Nonnull error) {
        if (callback != nil) {
            callback(success, error);
        }
    }];
}


@end
