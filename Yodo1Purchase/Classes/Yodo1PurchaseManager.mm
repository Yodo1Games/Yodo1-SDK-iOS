//
//  Yodo1PurchaseManager.m
//  Yodo1PurchaseManager
//
//  Created by yixian huang on 2017/7/24.
//

#import "Yodo1PurchaseManager.h"
#import "RMStore.h"
#import "Yodo1Reachability.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "RMStoreUserDefaultsPersistence.h"
#import "RMStoreTransaction.h"
#import "Yodo1UnityTool.h"
#import "Yodo1AnalyticsManager.h"
#import "Yodo1AFNetworking.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+OpsParameters.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1PurchaseDataAnalytics.h"
#import "Yodo1PurchaseAPI.h"
#import "Yodo1Commons.h"

@implementation PaymentObject

@end

@interface Yodo1PurchaseManager ()<RMStoreObserver> {
    NSMutableDictionary* productInfos;
    NSMutableArray* channelProductIds;
    RMStoreUserDefaultsPersistence *persistence;
    __block BOOL isBuying;
    __block PaymentObject* paymentObject;
}

@property (nonatomic,strong) NSString* currentUniformProductId;
@property (nonatomic,retain) SKPayment* addedStorePayment;//promot Appstore Buy
@property (nonatomic,copy)PaymentCallback paymentCallback;

- (Yodo1Product *)productWithChannelProductId:(NSString *)channelProductId;
- (NSArray *)productInfoWithProducts:(NSArray *)products;
- (void)updateProductInfo:(NSArray *)products;
- (NSString *)diplayPrice:(SKProduct *)product;
- (NSString *)productPrice:(SKProduct *)product;
- (NSString *)periodUnitWithProduct:(SKProduct *)product;
- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString;
- (void)rechargedProuct;

@end

@implementation Yodo1PurchaseManager

+ (instancetype)shared
{
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

- (void)willInit {
    productInfos = [NSMutableDictionary dictionary];
    channelProductIds = [NSMutableArray array];
    NSString* pathName = @"Yodo1KeyConfig.bundle/Yodo1ProductInfo";
    NSString* path=[NSBundle.mainBundle pathForResource:pathName ofType:@"plist"];
    NSDictionary* productInfo =[NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (productInfo.count == 0) {
        YD1LOG(@"Not found the products information in Yodo1ProductInof.plist file, please check it.");
    } else {
        for (id key in productInfo){
            NSDictionary* item = [productInfo objectForKey:key];
            Yodo1Product* product = [[Yodo1Product alloc] initWithDict:item productId:key];
            [productInfos setObject:product forKey:key];
            [channelProductIds addObject:[item objectForKey:@"ChannelProductId"]];
        }
    }
    
    persistence = [[RMStoreUserDefaultsPersistence alloc] init];
    RMStore.defaultStore.transactionPersistor = persistence;
    [RMStore.defaultStore addStoreObserver:self];
    
    self.user = [Yodo1UCenter.shared getUserInfo];
    self.isLogined = self.user != nil ? YES : NO;
    
    isBuying = false;
    paymentObject = [PaymentObject new];
    
    [self requestProducts];
    
    /// 网络变化监测
    __weak typeof(self) weakSelf = self;
    [Yodo1Reachability.reachability setNotifyBlock:^(Yodo1Reachability * _Nonnull reachability) {
        if (reachability.reachable) {
            [weakSelf requestProducts];
        }
    }];
}

- (void)invokePaymentCallback:(PaymentObject*)paymentObject {
    if (paymentObject == nil) {
        return;
    }
    
    if (paymentObject.paymentState != PaymentSuccess) {
        NSNumber* errorCode = [NSNumber numberWithInteger:paymentObject.error.code];
        NSString* errorMsg = paymentObject.error.description;
        [[Yodo1PurchaseDataAnalytics shared] trackOrderError:errorCode errorMessage:errorMsg];
    }
    
    if (self.paymentCallback != nil) {
        self.paymentCallback(paymentObject);
    }
}

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
    
    __block Yodo1Product* product = [productInfos objectForKey:uniformProductId];
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
        [Yodo1UCenter.shared deviceLoginWithPlayerId:@"" callback:^(YD1User * _Nullable user, NSError * _Nullable error) {
            if (user) {
                weakSelf.user.yid = user.yid;
                weakSelf.user.uid = user.uid;
                weakSelf.user.ucuid = user.ucuid? : user.uid;
                weakSelf.user.token = user.token;
                weakSelf.user.isOLRealName = user.isOLRealName;
                weakSelf.user.isRealName = user.isRealName;
                weakSelf.user.isnewuser = user.isnewuser;
                weakSelf.user.isnewyaccount = user.isnewyaccount;
                weakSelf.user.extra = user.extra;
                [Yd1OpsTools.cached setObject:weakSelf.user forKey:@"yd1User"];
            }
            if (user && !error) {
                [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"sdk_login_usercenter"
                                                           eventData:@{@"usercenter_login_status":@"success", @"usercenter_error_code":@"0", @"usercenter_error_message":@""}];
                weakSelf.isLogined = YES;
                
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
                        self->paymentObject.paymentState = PaymentFail;
                        NSString* message = [NSString stringWithFormat:@"%ld-%@", error.code, error.description];
                        YD1LOG(@"Failed to create order with error: %@", message);
                        self->paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                                        code:PaymentErrorCodeCreateOrder
                                                                    userInfo:@{NSLocalizedDescriptionKey:message}];
                        [weakSelf invokePaymentCallback:self->paymentObject];
                        self->isBuying = NO;
                    }
                }];
            }else{
                [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"sdk_login_usercenter" eventData:@{@"usercenter_login_status":@"fail", @"usercenter_error_code":@"1", @"usercenter_error_message":error.localizedDescription}];
                weakSelf.isLogined = NO;
                
                NSString* message = [NSString stringWithFormat:@"The user is not logged in Yodo1 ucenter with %ld-%@", error.code, error.description];
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
                NSString* message = [NSString stringWithFormat:@"%ld-%@", error.code, error.description];
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
    Yodo1PurchaseAPI.shared.itemInfo.orderId = product.orderId;
    
    NSString* msg = [self localizedStringForKey:@"SubscriptionAlertMessage"
                                    withDefault:@"确认启用后，您的iTunes账户将支付 %@ %@ 。%@自动续订此服务时您的iTunes账户也会支付相同费用。系统在订阅有效期结束前24小时会自动为您续订并扣费，除非您在有效期结束前取消服务。若需取消订阅，可前往设备设置-iTunes与App Store-查看Apple ID-订阅，管理或取消已经启用的服务。"];
    NSString* message = [NSString stringWithFormat:msg,product.productPrice,product.currency,product.periodUnit];
    
    NSString* title = [self localizedStringForKey:@"SubscriptionAlertTitle" withDefault:@"确认启用订阅服务"];
    NSString* cancelTitle = [self localizedStringForKey:@"SubscriptionAlertCancel" withDefault:@"取消"];
    NSString* okTitle = [self localizedStringForKey:@"SubscriptionAlertOK" withDefault:@"启用"];
    NSString* privateTitle = [self localizedStringForKey:@"SubscriptionAlertPrivate" withDefault:@"隐私协议"];
    NSString* serviceTitle = [self localizedStringForKey:@"SubscriptionAlertService" withDefault:@"服务条款"];
    
    NSString* privacyPolicyUrl = [self localizedStringForKey:@"SubscriptionPrivacyPolicyURL"
                                                 withDefault:@"https://www.yodo1.com/cn/privacy_policy"];
    NSString* termsServiceUrl = [self localizedStringForKey:@"SubscriptionTermsServiceURL"
                                                withDefault:@"https://www.yodo1.com/cn/user_agreement"];
    
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

- (void)invokeSubscriptionActions:(Yodo1Product*)product paymentState:(PaymentState)paymentState paymentError:(PaymentErrorCode)paymentErrorCode {
    if (product == nil) {
        return;
    }
    [self updateOrderId:product.orderId withProductId:product.uniformProductId];
    self->paymentObject.paymentState = paymentState;
    self->paymentObject.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                    code:paymentErrorCode
                                                userInfo:@{NSLocalizedDescriptionKey:@""}];
    [self invokePaymentCallback:self->paymentObject];
    self->isBuying = NO;
    Yodo1PurchaseAPI.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",self->paymentObject.paymentState];
    [Yodo1PurchaseAPI.shared reportOrderFail:Yodo1PurchaseAPI.shared.itemInfo callback:^(BOOL success, NSString * _Nonnull error) {
        YD1LOG(@"report %@.", success ? @"success" : @"failed");
    }];
}

- (void)paymentProduct:(Yodo1Product*)product {
    [RMStore.defaultStore addPayment:product.channelProductId];
}

- (void)updateOrderId:(NSString *)orderId withProductId:(NSString *)productIdentifier {
    //保存orderId
    NSString* oldOrderIdStr = [Yd1OpsTools keychainWithService:productIdentifier];
    NSArray* oldOrderId = (NSArray *)[Yd1OpsTools JSONObjectWithString:oldOrderIdStr error:nil];
    NSMutableArray* newOrderId = [[NSMutableArray alloc]initWithArray:oldOrderId];
    for (NSString *checkOrderId in newOrderId) {
        if ([checkOrderId isEqualToString:orderId]) {
            [newOrderId removeObject:checkOrderId];
            break;;
        }
    }
    NSString* orderidJson = [Yd1OpsTools stringWithJSONObject:newOrderId error:nil];
    [Yd1OpsTools saveKeychainWithService:productIdentifier str:orderidJson];
}

- (void)createOrderIdWithUniformProductId:(NSString *)uniformProductId
                                    extra:(NSString*)extra
                                 callback:(void (^)(bool, NSString * _Nonnull, NSError * _Nonnull))callback {
    self.currentUniformProductId = uniformProductId;
    __block Yodo1Product* product = [productInfos objectForKey:uniformProductId];
    __weak typeof(self) weakSelf = self;
    [Yodo1PurchaseAPI.shared generateOrderId:^(NSString * _Nullable orderId, NSError * _Nullable error) {
        if ((orderId == nil || [orderId isEqualToString:@""])) {
            YD1LOG(@"Failed to generat order, error %ld-%@", error.code, error.description);
            [[Yodo1PurchaseDataAnalytics shared] trackOrderRequest:NO];
            [[Yodo1PurchaseDataAnalytics shared] trackOrderPending];
            callback(NO,orderId,error);
            return;
        }
        
        //保存orderId
        NSString* oldOrderIdStr = [Yd1OpsTools keychainWithService:product.channelProductId];
        NSArray* oldOrderId = (NSArray *)[Yd1OpsTools JSONObjectWithString:oldOrderIdStr error:nil];
        NSMutableArray* newOrderId = [NSMutableArray array];
        if (oldOrderId) {
            [newOrderId setArray:oldOrderId];
        }
        [newOrderId addObject:orderId];
        NSString* orderidJson = [Yd1OpsTools stringWithJSONObject:newOrderId error:nil];
        [Yd1OpsTools saveKeychainWithService:product.channelProductId str:orderidJson];
        
        Yodo1PurchaseAPI.shared.itemInfo.orderId = orderId;
        Yodo1PurchaseAPI.shared.itemInfo.product_type = (int)product.productType;
        Yodo1PurchaseAPI.shared.itemInfo.item_code = product.channelProductId;
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
                YD1LOG(@"Failed to create order, error %ld-%@", error.code, error.description);
                [[Yodo1PurchaseDataAnalytics shared] trackOrderPending];
            }
            callback(success,orderId,error);
        }];
    }];
}

- (void)restorePayment:(RestoreCallback)callback {
    __weak typeof(self) weakSelf = self;
    [RMStore.defaultStore restoreTransactionsOnSuccess:^(NSArray *transactions) {
        NSMutableArray* restore = [NSMutableArray array];
        for (SKPaymentTransaction *transaction in transactions) {
            Yodo1Product* product = [weakSelf productWithChannelProductId:transaction.payment.productIdentifier];
            if (product) {
                BOOL isHave = false;
                for (Yodo1Product* pro in restore) {
                    if ([pro.channelProductId isEqualToString:product.channelProductId]) {
                        isHave = true;
                        continue;
                    }
                }
                if (!isHave) {
                    [restore addObject:product];
                }
            }
        }
        NSArray* restoreProduct = [weakSelf productInfoWithProducts:restore];
        callback(restoreProduct,@"Restore purchased successfully");
    } failure:^(NSError *error) {
        callback(@[],error.description);
    }];
}

- (NSArray *)productInfoWithProducts:(NSArray *)products {
    NSMutableArray* dicProducts = [NSMutableArray array];
    for (Yodo1Product* product in products) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:product.uniformProductId == nil?@"":product.uniformProductId forKey:@"productId"];
        [dict setObject:product.channelProductId == nil?@"":product.channelProductId forKey:@"marketId"];
        [dict setObject:product.productName == nil?@"":product.productName forKey:@"productName"];
        [dict setObject:product.orderId == nil?@"":product.orderId forKey:@"orderId"];
        
        SKProduct* skp = [RMStore.defaultStore productForIdentifier:product.channelProductId];
        NSString* price = nil;
        if (skp) {
            price = [self productPrice:skp];
        }else{
            price = product.productPrice;
        }
        
        NSString* priceDisplay = [NSString stringWithFormat:@"%@ %@",price,product.currency];
        [dict setObject:priceDisplay == nil?@"":priceDisplay forKey:@"priceDisplay"];
        [dict setObject:price == nil?@"":price forKey:@"price"];
        [dict setObject:product.productDescription == nil?@"":product.productDescription forKey:@"description"];
        [dict setObject:[NSNumber numberWithInt:(int)product.productType] forKey:@"ProductType"];
        [dict setObject:product.currency == nil?@"":product.currency forKey:@"currency"];
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"coin"];
        [dict setObject:product.periodUnit == nil?@"":[self periodUnitWithProduct:skp] forKey:@"periodUnit"];
        
        [dicProducts addObject:dict];
    }
    return dicProducts;
}

- (void)queryLossOrder:(LossOrderCallback)callback {
    __weak typeof(self) weakSelf = self;
    weakSelf.user = [Yodo1UCenter.shared getUserInfo];
    if (weakSelf.user == nil || weakSelf.user.yid == nil || weakSelf.user.yid.length <= 0) {
        [Yodo1UCenter.shared deviceLoginWithPlayerId:@"" callback:^(YD1User * _Nullable user, NSError * _Nullable error) {
            if (user && !error) {
                weakSelf.user = user;
                [weakSelf queryLossOrderAfterLogin:callback];
            }
        }];
    } else {
        [weakSelf queryLossOrderAfterLogin:callback];
    }
}

- (void)queryLossOrderAfterLogin:(LossOrderCallback)callback {
    NSMutableArray* lostTransactions = [NSMutableArray array];
    NSSet* productIdentifiers = [persistence purchasedProductIdentifiers];
    YD1LOG(@"%@",productIdentifiers);
    for (NSString* productIdentifier in productIdentifiers.allObjects) {
        NSArray* transactions = [persistence transactionsForProductOfIdentifier:productIdentifier];
        for (RMStoreTransaction* transaction in transactions) {
            if (transaction.consumed) {
                continue;
            }
            [lostTransactions addObject:transaction];
        }
    }
    
    if ([lostTransactions count] < 1) {
        callback(@[],@"No lost orders");
        return;
    }
    /// 去掉订单一样的对象
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
    
    NSString* receipt = [[NSData dataWithContentsOfURL:RMStore.receiptURL] base64EncodedStringWithOptions:0];
    Yodo1PurchaseAPI.shared.itemInfo.trx_receipt = receipt;
    __block NSMutableDictionary* lossOrder = [NSMutableDictionary dictionary];
    __block NSMutableArray* lossOrderProduct = [NSMutableArray array];
    __block int lossOrderCount = 0;
    __block int lossOrderReceiveCount = 0;
    __weak typeof(self) weakSelf = self;
    for (RMStoreTransaction* transaction in rp) {
        lossOrderCount++;
        
        Yodo1Product* paymentProduct = [self productWithChannelProductId:transaction.productIdentifier];
        Yodo1PurchaseAPI.shared.itemInfo.product_type = (int)paymentProduct.productType;
        Yodo1PurchaseAPI.shared.itemInfo.channelOrderid = transaction.transactionIdentifier;
        Yodo1PurchaseAPI.shared.itemInfo.orderId = transaction.orderId;
        Yodo1PurchaseAPI.shared.itemInfo.item_code = transaction.productIdentifier;
        
        [Yodo1PurchaseAPI.shared verifyOrder:Yodo1PurchaseAPI.shared.itemInfo
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
                if (lossOrderReceiveCount == lossOrderCount) {
                    if (callback) {
                        [Yodo1PurchaseAPI.shared queryLossOrders:Yodo1PurchaseAPI.shared.itemInfo
                                                            user:self.user
                                                        callback:^(BOOL success, NSArray * _Nonnull missorders, NSString * _Nonnull error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
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
                                
                                for (NSString* orderId in lossOrder) {
                                    NSString* itemCode = [lossOrder objectForKey:orderId];
                                    Yodo1Product* product = [weakSelf productWithChannelProductId:itemCode];
                                    if (product) {
                                        Yodo1Product* product2 = [[Yodo1Product alloc] initWithProduct:product];
                                        product2.orderId = orderId;
                                        [lossOrderProduct addObject:product2];
                                        //同步信息
                                        [Yodo1PurchaseAPI.shared clientNotifyToServer:@[orderId]
                                                                             callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                                            if (success) {
                                                NSLog(@"The information is synchronized successfully.");
                                            } else {
                                                NSLog(@"The information is synchronized unsuccessfully:%@",error);
                                            }
                                        }];
                                    }
                                }
                                NSArray* dics = [weakSelf productInfoWithProducts:lossOrderProduct];
                                callback(dics,@"");
                            });
                        }];
                    }
                }
            });
        }];
    }
}

- (void)querySubscriptions:(BOOL)excludeOldTransactions
                  callback:(QuerySubscriptionCallback)callback {
    __weak typeof(self) weakSelf = self;
    NSMutableArray* result = [NSMutableArray array];
    Yodo1PurchaseAPI.shared.itemInfo.exclude_old_transactions = excludeOldTransactions?@"true":@"false";
    NSString* receipt = [[NSData dataWithContentsOfURL:RMStore.receiptURL] base64EncodedStringWithOptions:0];
    if (!receipt) {
        callback(result, -1, NO, @"App Store of receipt is nil");
        return;
    }
    Yodo1PurchaseAPI.shared.itemInfo.trx_receipt = receipt;
    [Yodo1PurchaseAPI.shared querySubscriptions:Yodo1PurchaseAPI.shared.itemInfo
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
                    NSString* uniformProductId = [[weakSelf productWithChannelProductId:channelProductId] uniformProductId];
                    SubscriptionProductInfo* info = [[SubscriptionProductInfo alloc] initWithUniformProductId:uniformProductId channelProductId:channelProductId expires:expires_date_ms purchaseDate:purchase_date_ms];
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

- (void)requestProducts {
    NSSet* productIds = [NSSet setWithArray:channelProductIds];
    [RMStore.defaultStore requestProducts:productIds];
}

- (void)productWithUniformProductId:(NSString *)uniformProductId callback:(ProductsInfoCallback)callback {
    NSMutableArray* products = [NSMutableArray array];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    Yodo1Product* product = [productInfos objectForKey:uniformProductId];
    [dict setObject:product.uniformProductId == nil?@"":product.uniformProductId forKey:@"productId"];
    [dict setObject:product.channelProductId == nil?@"":product.channelProductId forKey:@"marketId"];
    [dict setObject:product.productName == nil?@"":product.productName forKey:@"productName"];
    SKProduct* skp = [RMStore.defaultStore productForIdentifier:product.channelProductId];
    NSString* price = nil;
    if (skp) {
        price = [skp.price stringValue];
        product.currency = [Yd1OpsTools currencyCode:skp.priceLocale];
        product.priceDisplay = [self diplayPrice:skp];
        product.periodUnit = [self periodUnitWithProduct:skp];
    }else{
        price = product.productPrice;
    }
    [dict setObject:product.priceDisplay == nil?@"":product.priceDisplay forKey:@"priceDisplay"];
    [dict setObject:price == nil?@"":price forKey:@"price"];
    [dict setObject:product.productDescription == nil?@"":product.productDescription forKey:@"description"];
    [dict setObject:[NSNumber numberWithInt:(int)product.productType] forKey:@"ProductType"];
    [dict setObject:product.currency == nil?@"":product.currency forKey:@"currency"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"coin"];
    [products addObject:dict];
    if (callback) {
        callback(products);
    }else{
        NSAssert(callback != nil, @"ProductsInfoCallback of callback not set!");
    }
}

- (void)products:(ProductsInfoCallback)callback {
    NSMutableArray* products = [NSMutableArray array];
    NSArray* allProduct = [productInfos allValues];
    for (Yodo1Product *product in allProduct) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:product.uniformProductId == nil?@"":product.uniformProductId forKey:@"productId"];
        [dict setObject:product.channelProductId == nil?@"":product.channelProductId forKey:@"marketId"];
        [dict setObject:product.productName == nil?@"":product.productName forKey:@"productName"];
        
        SKProduct* skp = [RMStore.defaultStore productForIdentifier:product.channelProductId];
        NSString* price = nil;
        if (skp) {
            price = [skp.price stringValue];
            product.currency = [Yd1OpsTools currencyCode:skp.priceLocale];
            product.priceDisplay = [self diplayPrice:skp];
            product.periodUnit = [self periodUnitWithProduct:skp];
        }else{
            price = product.productPrice;
        }
        
        [dict setObject:product.priceDisplay == nil?@"":product.priceDisplay forKey:@"priceDisplay"];
        [dict setObject:price == nil?@"":price forKey:@"price"];
        [dict setObject:product.productDescription == nil?@"":product.productDescription forKey:@"description"];
        [dict setObject:[NSNumber numberWithInt:(int)product.productType] forKey:@"ProductType"];
        [dict setObject:product.currency == nil?@"":product.currency forKey:@"currency"];
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"coin"];
        
        [products addObject:dict];
    }
    if (callback) {
        callback(products);
    }else{
        NSAssert(callback != nil, @"ProductsInfoCallback of callback not set!");
    }
}

#pragma mark- 促销活动

- (void)fetchStorePromotionOrder:(FetchStorePromotionOrderCallback)callback {
#ifdef __IPHONE_11_0
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 11.0, *)) {
        [[SKProductStorePromotionController defaultController] fetchStorePromotionOrderWithCompletionHandler:^(NSArray<SKProduct *> * _Nonnull storePromotionOrder, NSError * _Nullable error) {
            if(callback){
                NSMutableArray<NSString*>* uniformProductIDs = [[NSMutableArray alloc] init];
                for (int i = 0; i < [storePromotionOrder count]; i++) {
                    NSString* productID = [[storePromotionOrder objectAtIndex:i] productIdentifier];
                    NSString* uniformProductID = [[weakSelf productWithChannelProductId:productID] uniformProductId];
                    [uniformProductIDs addObject:uniformProductID];
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
        NSString* channelProductId = [[productInfos objectForKey:uniformProductId] channelProductId];
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
            NSString* channelProductId = [[productInfos objectForKey:uniformProductId] channelProductId];
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
        NSString* channelProductId = [[productInfos objectForKey:uniformProductId] channelProductId];
        SKProduct* product = [RMStore.defaultStore productForIdentifier:channelProductId];
        [[SKProductStorePromotionController defaultController] updateStorePromotionVisibility:visibility ? SKProductStorePromotionVisibilityShow : SKProductStorePromotionVisibilityHide forProduct:product completionHandler:^(NSError * _Nullable error) {
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
            NSString* uniformP = [self uniformProductIdWithChannelProductId:self.addedStorePayment.productIdentifier];
            [self paymentWithUniformProductId:uniformP extra:@"" callback:callback];
        } else {
            paymentObject.uniformProductId = self.currentUniformProductId;
            paymentObject.channelOrderid = @"";
            paymentObject.orderId = Yodo1PurchaseAPI.shared.itemInfo.orderId;
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
        NSString* uniformProductId = [[self productWithChannelProductId:self.addedStorePayment.productIdentifier] uniformProductId];
        Yodo1Product* product = [productInfos objectForKey:uniformProductId];
        return product;
    }
    return nil;
}

- (NSString *)uniformProductIdWithChannelProductId:(NSString *)channelProductId {
    return [self productWithChannelProductId:channelProductId].uniformProductId? :@"";
}

- (Yodo1Product*)productWithChannelProductId:(NSString*)channelProductId {
    NSArray* allProduct = [productInfos allValues];
    for (Yodo1Product *productInfo in allProduct) {
        if ([productInfo.channelProductId isEqualToString:channelProductId]) {
            return productInfo;
        }
    }
    return nil;
}

- (void)updateProductInfo:(NSArray *)products {
    for (NSString* uniformProductId in [productInfos allKeys]) {
        Yodo1Product* product = [productInfos objectForKey:uniformProductId];
        for (SKProduct* sk in products) {
            if ([sk.productIdentifier isEqualToString:product.channelProductId]) {
                product.productName = sk.localizedTitle;
                product.channelProductId = sk.productIdentifier;
                product.productPrice = [sk.price stringValue];
                product.productDescription = sk.localizedDescription;
                product.currency = [Yd1OpsTools currencyCode:sk.priceLocale];
                product.priceDisplay = [self diplayPrice:sk];
                product.periodUnit = [self periodUnitWithProduct:sk];
            }
        }
    }
}

- (NSString *)diplayPrice:(SKProduct *)product {
    return [NSString stringWithFormat:@"%@ %@",[self productPrice:product],[Yd1OpsTools currencyCode:product.priceLocale]];
}

- (NSString *)productPrice:(SKProduct *)product {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    [numberFormatter setCurrencySymbol:@""];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    return formattedPrice;
}

- (NSString*)periodUnitWithProduct:(SKProduct*)product {
    if (@available(iOS 11.2, *)) {
        NSString* unit = @"";
        int numberOfUnits = (int)product.subscriptionPeriod.numberOfUnits;
        switch (product.subscriptionPeriod.unit)
        {
            case SKProductPeriodUnitDay:
            {
                if (numberOfUnits == 7) {
                    unit = [self localizedStringForKey:@"SubscriptionWeek" withDefault:@"每周"];
                }else if (numberOfUnits == 30){
                    unit = [self localizedStringForKey:@"SubscriptionMonth" withDefault:@"每月"];
                } else {
                    unit = [NSString stringWithFormat:[self localizedStringForKey:@"SubscriptionDay" withDefault:@"每%d天"],numberOfUnits];
                }
            }
                break;
            case SKProductPeriodUnitWeek:
            {
                if (numberOfUnits == 1) {
                    unit = [self localizedStringForKey:@"SubscriptionWeek" withDefault:@"每周"];
                } else {
                    unit = [NSString stringWithFormat:[self localizedStringForKey:@"SubscriptionWeeks" withDefault:@"每%d周"],numberOfUnits];
                }
            }
                break;
            case SKProductPeriodUnitMonth:
            {
                if (numberOfUnits == 1) {
                    unit = [self localizedStringForKey:@"SubscriptionMonth" withDefault:@"每月"];
                } else {
                    unit = [NSString stringWithFormat:[self localizedStringForKey:@"SubscriptionMonths" withDefault:@"每%d个月"],numberOfUnits];
                }
            }
                break;
            case SKProductPeriodUnitYear:
            {
                if (numberOfUnits == 1) {
                    unit = [self localizedStringForKey:@"SubscriptionYear" withDefault:@"每年"];
                } else {
                    unit = [NSString stringWithFormat:[self localizedStringForKey:@"SubscriptionYears" withDefault:@"每%d年"],numberOfUnits];
                }
            }
                break;
        }
        return unit;
    } else {
        return @"";
    }
    return @"";
}

- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString {
    return [Yd1OpsTools localizedString:@"Yodo1SDKStrings"
                                    key:key
                          defaultString:defaultString];
}

- (void)rechargedProuct {
    Yodo1Product* product = [productInfos objectForKey:self.currentUniformProductId];
    if (self->persistence) {
        [self->persistence rechargedProuctOfIdentifier:product.channelProductId];
    }
}

#pragma mark- RMStoreObserver
- (void)storePaymentTransactionDeferred:(NSNotification*)notification {
    YD1LOG(@"");
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification {
    NSString* productIdentifier = notification.rm_productIdentifier;
    if (!productIdentifier) {
        Yodo1Product* pr = [productInfos objectForKey:self.currentUniformProductId];
        if (pr.channelProductId) {
            productIdentifier = pr.channelProductId;
        }
    }
    if (productIdentifier) {
        NSString* oldOrderIdStr = [Yd1OpsTools keychainWithService:productIdentifier];
        NSArray* oldOrderId = (NSArray *)[Yd1OpsTools JSONObjectWithString:oldOrderIdStr error:nil];
        NSMutableArray* newOrderId = [NSMutableArray array];
        if (oldOrderId) {
            [newOrderId setArray:oldOrderId];
        }
        for (NSString* oderid in oldOrderId) {
            if ([oderid isEqualToString:Yodo1PurchaseAPI.shared.itemInfo.orderId]) {
                [newOrderId removeObject:oderid];
                break;
            }
        }
        NSString* orderidJson = [Yd1OpsTools stringWithJSONObject:newOrderId error:nil];
        [Yd1OpsTools saveKeychainWithService:productIdentifier str:orderidJson];
    }
    
    NSString* channelOrderid = notification.rm_transaction.transactionIdentifier;
    if (!channelOrderid) {
        channelOrderid = @"";
    }
    
    NSString* message = @"";
    if (notification.rm_storeError != nil) {
        message = [NSString stringWithFormat:@"%ld-%@", notification.rm_storeError.code, notification.rm_storeError.description];
    }
    YD1LOG(@"%@", message);
    
    paymentObject.uniformProductId = self.currentUniformProductId;
    paymentObject.channelOrderid = channelOrderid;
    paymentObject.orderId = Yodo1PurchaseAPI.shared.itemInfo.orderId;
    paymentObject.response = @"";
    bool isCanncelled = NO;
    if (@available(iOS 12.2, *)) {
        if (notification.rm_storeError.code == SKErrorPaymentCancelled || notification.rm_storeError.code == SKErrorOverlayCancelled) {
            isCanncelled = YES;
        }
    } else {
        // Fallback on earlier versions
        if (notification.rm_storeError.code == SKErrorPaymentCancelled) {
            isCanncelled = YES;
        }
    }
    if (isCanncelled) {
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
    
    Yodo1PurchaseAPI.shared.itemInfo.channelOrderid = paymentObject.channelOrderid;
    Yodo1PurchaseAPI.shared.itemInfo.orderId = paymentObject.orderId;
    Yodo1PurchaseAPI.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d", paymentObject.paymentState];
    Yodo1PurchaseAPI.shared.itemInfo.statusMsg = message;
    [Yodo1PurchaseAPI.shared reportOrderFail:Yodo1PurchaseAPI.shared.itemInfo
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
    NSString* channelOrderid = notification.rm_transaction.transactionIdentifier;
    if (!channelOrderid) {
        channelOrderid = @"";
    }
    Yodo1Product* product = [productInfos objectForKey:self.currentUniformProductId];
    NSString* productIdentifier = notification.rm_productIdentifier;
    if (!productIdentifier) {
        productIdentifier = product.channelProductId;
    }
    NSString* receipt = [[NSData dataWithContentsOfURL:RMStore.receiptURL] base64EncodedStringWithOptions:0];
    YD1LOG(@"%@", receipt);
    
    //AppsFlyer 数据统计
    [Yodo1AnalyticsManager.sharedInstance validateAndTrackInAppPurchase:productIdentifier
                                                                  price:product.productPrice
                                                               currency:product.currency
                                                          transactionId:channelOrderid];
    
    Yodo1PurchaseAPI.shared.itemInfo.channelOrderid = channelOrderid;
    Yodo1PurchaseAPI.shared.itemInfo.trx_receipt = receipt;
    Yodo1PurchaseAPI.shared.itemInfo.productId = productIdentifier;
    if (Yodo1PurchaseManager.shared.validatePaymentBlock) {
        NSDictionary* extra = @{@"productIdentifier":productIdentifier,
                                @"transactionIdentifier":channelOrderid,
                                @"transactionReceipt":receipt};
        NSString* extraSt = [Yd1OpsTools stringWithJSONObject:extra error:nil];
        Yodo1PurchaseManager.shared.validatePaymentBlock(product.uniformProductId,extraSt);
    }
    
    __weak typeof(self) weakSelf = self;
    [Yodo1PurchaseAPI.shared verifyOrder:Yodo1PurchaseAPI.shared.itemInfo
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
            self->paymentObject.channelOrderid = Yodo1PurchaseAPI.shared.itemInfo.channelOrderid;
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
                message = [NSString stringWithFormat:@"%ld-%@", error.code, error.description];
            }
            YD1LOG(@"%@", message);
            
            Yodo1PurchaseAPI.shared.itemInfo.channelOrderid = Yodo1PurchaseAPI.shared.itemInfo.channelOrderid;
            Yodo1PurchaseAPI.shared.itemInfo.orderId = orderId;
            Yodo1PurchaseAPI.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",PaymentFail];
            Yodo1PurchaseAPI.shared.itemInfo.statusMsg = message;
            [Yodo1PurchaseAPI.shared reportOrderFail:Yodo1PurchaseAPI.shared.itemInfo
                                              callback:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"report success.");
                } else {
                    YD1LOG(@"report failed.");
                }
            }];
            
            self->paymentObject.uniformProductId = weakSelf.currentUniformProductId;
            self->paymentObject.channelOrderid = Yodo1PurchaseAPI.shared.itemInfo.channelOrderid;
            self->paymentObject.orderId = orderId;
            self->paymentObject.response = response;
            self->paymentObject.paymentState = PaymentFail;
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
    NSArray *products = notification.rm_products;
    [self updateProductInfo:products];
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

/**
 * 激活码/优惠券
 */
- (void)verifyWithActivationCode:(NSString *)activationCode
                        callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSDictionary* _Nullable error))callback {
    
    if (!activationCode || activationCode.length < 1) {
        callback(false,@{}, @{@"error":@"code is empty!"});
        return;
    }
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]init];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString *appKey = @"";
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://activationcode.yodo1api.com/activationcode/activateWithReward?game_appkey=%@&channel_code=%@&activation_code=%@&dev_id=%@", appKey, Yodo1Tool.shared.paymentChannelCodeValue, activationCode, Yd1OpsTools.keychainDeviceId];
    
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
            callback(false,@{},response);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(false,@{},@{@"error": error.localizedDescription});
    }];
    
}

@end

#pragma mark -   Unity3d 接口

#ifdef __cplusplus

extern "C" {

#pragma mark- 购买
/**
 *查询漏单
 */
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
            Yodo1PurchaseAPI.shared.itemInfo.orderId = payemntObject.orderId;
            Yodo1PurchaseAPI.shared.itemInfo.extra = @"";
            [Yodo1PurchaseAPI.shared reportOrderSuccess:Yodo1PurchaseAPI.shared.itemInfo
                                               callback:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"上报成功");
                } else {
                    YD1LOG(@"上报失败");
                }
            }];
            
            
        } else {
            if ([payemntObject.orderId length] > 0) {
                Yodo1PurchaseAPI.shared.itemInfo.channelOrderid = payemntObject.channelOrderid? :@"";
                Yodo1PurchaseAPI.shared.itemInfo.orderId = payemntObject.orderId;
                Yodo1PurchaseAPI.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",payemntObject.paymentState];
                Yodo1PurchaseAPI.shared.itemInfo.statusMsg = payemntObject.response? :@"";
                [Yodo1PurchaseAPI.shared reportOrderFail:Yodo1PurchaseAPI.shared.itemInfo
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

/**
 *查询订阅
 */
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
/**
 *appstore渠道，恢复购买
 */
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

/**
 *支付
 */
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
            if (success) {
                [Yodo1PurchaseManager.shared rechargedProuct];
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
