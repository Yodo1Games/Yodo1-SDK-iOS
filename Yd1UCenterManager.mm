//
//  Yd1UCenterManager.m
//  Yd1UCenterManager
//
//  Created by yixian huang on 2017/7/24.
//

#import "Yd1UCenterManager.h"
#import "RMStore.h"
#import "Yodo1Reachability.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "RMStoreUserDefaultsPersistence.h"
#import "Yd1UCenter.h"
#import "RMStoreTransaction.h"
#import "Yodo1UnityTool.h"
#import "Yodo1AnalyticsManager.h"
#import "ThinkingAnalyticsSDK.h"
#import "Yd1OnlineParameter.h"

/// 超级属性
static NSString* const __gameName               = @"gameName";
static NSString* const __gameVersion            = @"gameVersion";
static NSString* const __gameBundleId           = @"gameBundleId";
static NSString* const __sdkType                = @"sdkType";
static NSString* const __sdkVersion             = @"sdkVersion";
static NSString* const __publishChannelCode     = @"publishChannelCode";
static NSString* const __masSdkVersion          = @"masSdkVersion";
/// 付费方式属性
static NSString* const __paymentChannelCode     = @"paymentChannelCode";
static NSString* const __paymentChannelVersion  = @"paymentChannelVersion";
/// IAP的公共属性
static NSString* const __itemCode               = @"itemCode";
static NSString* const __itemName               = @"itemName";
static NSString* const __itemType               = @"itemType";
static NSString* const __itemCurrency           = @"itemCurrency";
static NSString* const __itemPrice              = @"itemPrice";
static NSString* const __channelItemCode        = @"channelItemCode";
/// 属性值
static NSString* const __result                 = @"result";
static NSString* const __success                = @"success";
static NSString* const __fail                   = @"fail";
static NSString* const __serverVersion          = @"serverVersion";
static NSString* const __yodo1ErrorCode         = @"yodo1ErrorCode";
static NSString* const __channelErrorCode       = @"channelErrorCode";
static NSString* const __status                 = @"status";

@implementation Product

- (instancetype)initWithDict:(NSDictionary*)dictProduct
                   productId:(NSString*)uniformProductId_ {
    self = [super init];
    if (self) {
        self.uniformProductId = uniformProductId_;
        self.channelProductId = [dictProduct objectForKey:@"ChannelProductId"];
        self.productName = [dictProduct objectForKey:@"ProductName"];
        self.productPrice = [dictProduct objectForKey:@"ProductPrice"];
        self.priceDisplay = [dictProduct objectForKey:@"PriceDisplay"];
        self.currency = [dictProduct objectForKey:@"Currency"];
        self.productDescription = [dictProduct objectForKey:@"ProductDescription"];
        self.productType = (ProductType)[[dictProduct objectForKey:@"ProductType"] intValue];
        self.periodUnit = [dictProduct objectForKey:@"PeriodUnit"];
        self.orderId = [dictProduct objectForKey:@"OrderId"];
    }
    return self;
}

- (instancetype)initWithProduct:(Product*)product {
    self = [super init];
    if (self) {
        self.uniformProductId = product.uniformProductId;
        self.channelProductId = product.channelProductId;
        self.productName = product.productName;
        self.productPrice = product.productPrice;
        self.priceDisplay = product.priceDisplay;
        self.currency = product.currency;
        self.productDescription = product.productDescription;
        self.productType = product.productType;
        self.periodUnit = product.periodUnit;
        self.orderId = product.orderId;
    }
    return self;
}

@end

@implementation PaymentObject

@end

@interface Yd1UCenterManager ()<RMStoreObserver> {
    NSMutableDictionary* productInfos;
    NSMutableArray* channelProductIds;
    RMStoreUserDefaultsPersistence *persistence;
    __block BOOL isBuying;
    __block PaymentObject* po;
}

@property (nonatomic,strong) NSString* currentUniformProductId;
@property (nonatomic,retain) SKPayment* addedStorePayment;//promot Appstore Buy
@property (nonatomic,copy)PaymentCallback paymentCallback;

- (Product *)productWithChannelProductId:(NSString *)channelProductId;
- (NSArray *)productInfoWithProducts:(NSArray *)products;
- (void)updateProductInfo:(NSArray *)products;
- (NSString *)diplayPrice:(SKProduct *)product;
- (NSString *)productPrice:(SKProduct *)product;
- (NSString *)periodUnitWithProduct:(SKProduct *)product;
- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString;
- (void)rechargedProuct;

@end

@implementation Yd1UCenterManager

+ (instancetype)shared {
    return [Yodo1Base.shared cc_registerSharedInstance:self block:^{
        [Yd1UCenterManager.shared willInit];
    }];
}

- (void)dealloc {
    [RMStore.defaultStore removeStoreObserver:self];
}

- (void)willInit {
    _superProperty = [NSMutableDictionary dictionary];
    _itemProperty = [NSMutableDictionary dictionary];
    //公共属性
    [_superProperty setObject:Yd1OpsTools.appName forKey:__gameName];
    [_superProperty setObject:Yd1OpsTools.appVersion forKey:__gameVersion];
    [_superProperty setObject:Yd1OpsTools.appBid forKey:__gameBundleId];
    [_superProperty setObject:Yd1OParameter.publishType forKey:__sdkType];
    [_superProperty setObject:Yd1OParameter.publishVersion forKey:__sdkVersion];
    [_superProperty setObject:Yd1OParameter.channelId forKey:__publishChannelCode];
    [_superProperty setObject:Yd1OParameter.publishVersion forKey:__masSdkVersion];
    // 付费方式属性
    [_superProperty setObject:Yd1OParameter.channelId forKey:__paymentChannelCode];
    [_superProperty setObject:Yd1OParameter.publishVersion forKey:__paymentChannelVersion];
    
    po = [PaymentObject new];
    
    YD1User* user = (YD1User*)[Yd1OpsTools.cached objectForKey:@"yd1User"];
    if (user) {
        self.user = user;
        Yd1UCenter.shared.itemInfo.uid = user.uid;
        Yd1UCenter.shared.itemInfo.ucuid = user.ucuid? : user.uid;
        Yd1UCenter.shared.itemInfo.yid = user.yid;
        Yd1UCenter.shared.itemInfo.playerid = user.playerid;
    } else {
        _user = [[YD1User alloc]init];
    }
    
    isBuying = false;
    //设备登录
    __weak typeof(self) weakSelf = self;
    [Yd1UCenter.shared deviceLoginWithPlayerId:@""
                                      callback:^(YD1User * _Nullable user, NSError * _Nullable error) {
        if (user) {
            weakSelf.user.yid = user.yid;
            weakSelf.user.ucuid = user.ucuid? : user.uid;
            weakSelf.user.uid = user.uid;
            weakSelf.user.token = user.token;
            weakSelf.user.isOLRealName = user.isOLRealName;
            weakSelf.user.isRealName = user.isRealName;
            weakSelf.user.isnewuser = user.isnewuser;
            weakSelf.user.isnewyaccount = user.isnewyaccount;
            weakSelf.user.extra = user.extra;
            [Yd1OpsTools.cached setObject:weakSelf.user forKey:@"yd1User"];
        }
        if (user && !error) {
            weakSelf.isLogined = YES;
            Yd1UCenter.shared.itemInfo.uid = self.user.uid;
            Yd1UCenter.shared.itemInfo.yid = self.user.yid;
        }else{
            weakSelf.isLogined = NO;
            YD1LOG(@"%@",error.localizedDescription);
        }
    }];
    productInfos = [NSMutableDictionary dictionary];
    channelProductIds = [NSMutableArray array];
    NSString* pathName = @"Yodo1KeyConfig.bundle/Yodo1ProductInfo";
    NSString* path=[NSBundle.mainBundle pathForResource:pathName
                                                 ofType:@"plist"];
    NSDictionary* productInfo =[NSMutableDictionary dictionaryWithContentsOfFile:path];
   // NSAssert([productInfo count] > 0, @"Yodo1ProductInfo.plist 没有配置产品ID!");
    for (id key in productInfo){
        NSDictionary* item = [productInfo objectForKey:key];
        Product* product = [[Product alloc] initWithDict:item productId:key];
        [productInfos setObject:product forKey:key];
        [channelProductIds addObject:[item objectForKey:@"ChannelProductId"]];
    }
    
    persistence = [[RMStoreUserDefaultsPersistence alloc] init];
    RMStore.defaultStore.transactionPersistor = persistence;
    [RMStore.defaultStore addStoreObserver:self];
    
    [self requestProducts];
    
    /// 网络变化监测
    [Yodo1Reachability.reachability setNotifyBlock:^(Yodo1Reachability * _Nonnull reachability) {
        if (reachability.reachable) {
            [weakSelf requestProducts];
        }
    }];
}

- (void)requestProducts {
    /// 请求产品信息
    NSSet* productIds = [NSSet setWithArray:channelProductIds];
    [RMStore.defaultStore requestProducts:productIds];
}

- (void)paymentWithUniformProductId:(NSString *)uniformProductId
                           extra:(NSString*)extra
                           callback:(nonnull PaymentCallback)callback {
    
    if (isBuying) {
        YD1LOG(@"product is buying ...");
        return;
    }
    isBuying = true;
    self.paymentCallback = callback;
    
    if([self.itemProperty count] >0){
        [self.itemProperty removeAllObjects];
    }
    __block Product* product = [productInfos objectForKey:uniformProductId];
    [self.itemProperty setObject:product.channelProductId ? :@"" forKey:__itemCode];
    [self.itemProperty setObject:product.productName ? :@"" forKey:__itemName];
    [self.itemProperty setObject:[NSString stringWithFormat:@"%d",product.productType]  forKey:__itemType];
    [self.itemProperty setObject:product.productPrice ? :@"" forKey:__itemPrice];
    [self.itemProperty setObject:product.currency ? :@"" forKey:__itemCurrency];
    [self.itemProperty setObject:@"" forKey:__channelItemCode];
    
    if (!uniformProductId) {
        po.uniformProductId = uniformProductId;
        po.channelOrderid = @"";
        po.orderId = @"";
        po.response = @"";
        po.paymentState = PaymentFail;
        po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                       code:2001
                                   userInfo:@{NSLocalizedDescriptionKey:@"uniformProductId is nil!"}];
        self.paymentCallback(po);
         isBuying = false;
        return;
    }
    
    if (!RMStore.canMakePayments) {
        YD1LOG(@"This device is not able or allowed to make payments!");
        
        po.uniformProductId = uniformProductId;
        po.channelOrderid = @"";
        po.orderId = @"";
        po.response = @"";
        po.paymentState = PaymentFail;
        po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                       code:2002
                                   userInfo:@{NSLocalizedDescriptionKey:@"This device is not able or allowed to make payments!"}];
        self.paymentCallback(po);
        isBuying = false;
        return;
    }
    
    if ([[Yd1OpsTools networkType]isEqualToString:@"NONE"]) {
        po.uniformProductId = uniformProductId;
        po.channelOrderid = @"";
        po.orderId = @"";
        po.response = @"";
        po.paymentState = PaymentFail;
        po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                       code:2003
                                   userInfo:@{NSLocalizedDescriptionKey:@"The Network is noReachable!"}];
        self.paymentCallback(po);
        isBuying = false;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (!self.isLogined) {
        if (self.paymentCallback) {
            po.uniformProductId = uniformProductId;
            po.channelOrderid = @"";
            po.orderId = @"";
            po.response = @"";
            po.paymentState = PaymentFail;
            po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                           code:2001
                                       userInfo:@{NSLocalizedDescriptionKey:@"The device is not login!"}];
            self.paymentCallback(po);
            isBuying = false;
        }
        [Yd1UCenter.shared deviceLoginWithPlayerId:@""
                                          callback:^(YD1User * _Nullable user, NSError * _Nullable error) {
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
                weakSelf.isLogined = YES;
                Yd1UCenter.shared.itemInfo.uid = self.user.uid;
                Yd1UCenter.shared.itemInfo.yid = self.user.yid;
                Yd1UCenter.shared.itemInfo.ucuid = self.user.ucuid? :self.user.uid;
            }else{
                weakSelf.isLogined = NO;
                YD1LOG(@"%@",error.localizedDescription);
            }
        }];
        return;
    }
    [self createOrderIdWithUniformProductId:uniformProductId
                                      extra:extra
                                   callback:^(bool success, NSString * _Nonnull orderid, NSString * _Nonnull error) {
        if (success) {
            if (product.productType == Auto_Subscription) {
                NSString* msg = [weakSelf localizedStringForKey:@"SubscriptionAlertMessage"
                                                withDefault:@"确认启用后，您的iTunes账户将支付 %@ %@ 。%@自动续订此服务时您的iTunes账户也会支付相同费用。系统在订阅有效期结束前24小时会自动为您续订并扣费，除非您在有效期结束前取消服务。若需取消订阅，可前往设备设置-iTunes与App Store-查看Apple ID-订阅，管理或取消已经启用的服务。"];
                NSString* message = [NSString stringWithFormat:msg,product.productPrice,product.currency,product.periodUnit];
                
                NSString* title = [weakSelf localizedStringForKey:@"SubscriptionAlertTitle" withDefault:@"确认启用订阅服务"];
                NSString* cancelTitle = [weakSelf localizedStringForKey:@"SubscriptionAlertCancel" withDefault:@"取消"];
                NSString* okTitle = [weakSelf localizedStringForKey:@"SubscriptionAlertOK" withDefault:@"启用"];
                NSString* privateTitle = [weakSelf localizedStringForKey:@"SubscriptionAlertPrivate" withDefault:@"隐私协议"];
                NSString* serviceTitle = [weakSelf localizedStringForKey:@"SubscriptionAlertService" withDefault:@"服务条款"];
                UIAlertControllerStyle uiStyle = UIAlertControllerStyleActionSheet;
                if([Yd1OpsTools isIPad]){
                    uiStyle = UIAlertControllerStyleAlert;
                }
                
                UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:uiStyle];
                
                NSString* privacyPolicyUrl = [weakSelf localizedStringForKey:@"SubscriptionPrivacyPolicyURL"
                                                             withDefault:@"https://www.yodo1.com/cn/privacy_policy"];
                NSString* termsServiceUrl = [weakSelf localizedStringForKey:@"SubscriptionTermsServiceURL"
                                                            withDefault:@"https://www.yodo1.com/cn/user_agreement"];
                
                UIAlertAction *privateAction = [UIAlertAction actionWithTitle:privateTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:privacyPolicyUrl]];
                    self->po.uniformProductId = uniformProductId;
                    self->po.channelOrderid = @"";
                    self->po.orderId = @"";
                    self->po.response = @"";
                    self->po.paymentState = PaymentCannel;
                    self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                         code:2001
                                                     userInfo:@{NSLocalizedDescriptionKey:error? :@""}];
                    weakSelf.paymentCallback(self->po);
                    self->isBuying = false;
                }];
                UIAlertAction *serviceAction = [UIAlertAction actionWithTitle:serviceTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:termsServiceUrl]];
                    self->po.uniformProductId = uniformProductId;
                    self->po.channelOrderid = @"";
                    self->po.orderId = @"";
                    self->po.response = @"";
                    self->po.paymentState = PaymentCannel;
                    self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                         code:2001
                                                     userInfo:@{NSLocalizedDescriptionKey:error? :@""}];
                    weakSelf.paymentCallback(self->po);
                    self->isBuying = false;
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    self->po.uniformProductId = uniformProductId;
                    self->po.channelOrderid = @"";
                    self->po.orderId = @"";
                    self->po.response = @"";
                    self->po.paymentState = PaymentCannel;
                    self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                         code:2001
                                                     userInfo:@{NSLocalizedDescriptionKey:error? :@""}];
                    weakSelf.paymentCallback(self->po);
                    self->isBuying = false;
                }];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf paymentProduct:product];
                }];
                [alertController addAction:okAction];
                [alertController addAction:serviceAction];
                [alertController addAction:privateAction];
                [alertController addAction:cancelAction];
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
            } else {
                [weakSelf paymentProduct:product];
            }
        } else {
            self->po.uniformProductId = uniformProductId;
            self->po.channelOrderid = @"";
            self->po.orderId = @"";
            self->po.response = @"";
            self->po.paymentState = PaymentFail;
            self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                           code:2001
                                       userInfo:@{NSLocalizedDescriptionKey:error? :@""}];
            weakSelf.paymentCallback(self->po);
            self->isBuying = false;
        }
    }];
}

- (void)createOrderIdWithUniformProductId:(NSString *)uniformProductId
                                    extra:(NSString*)extra
                                 callback:(void (^)(bool, NSString * _Nonnull,NSString * _Nonnull))callback {
    self.currentUniformProductId = uniformProductId;
    __weak typeof(self) weakSelf = self;
    __block Product* product = [productInfos objectForKey:uniformProductId];
    SKProduct* skp = [RMStore.defaultStore productForIdentifier:product.channelProductId];
    if (!skp) {
         callback(false,@"",@"products request failed with error Error");
        return;
    }
    //创建订单号
    [Yd1UCenter.shared generateOrderId:^(NSString * _Nullable orderId, NSError * _Nullable error) {
        if ((!orderId || [orderId isEqualToString:@""])) {
            YD1LOG(@"%@",error.localizedDescription);
            callback(false,orderId,error.localizedDescription);
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties addEntriesFromDictionary:weakSelf.superProperty];
            [properties addEntriesFromDictionary:weakSelf.itemProperty];
            [ThinkingAnalyticsSDK.sharedInstance track:@"order_Pending" properties:properties];
            
            return;
        }
        Yd1UCenter.shared.itemInfo.orderId = orderId;
        
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
        
        Yd1UCenter.shared.itemInfo.product_type = (int)product.productType;
        Yd1UCenter.shared.itemInfo.item_code = product.channelProductId;
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
            [parameters setObject:uid? :@""
                           forKey:@"uid"];
        }
        
        [parameters setObject:weakSelf.user.yid? :@"" forKey:@"yid"];
        [parameters setObject:weakSelf.user.uid? :@"" forKey:@"ucuid"];
        
        Yd1UCenter.shared.itemInfo.ucuid = weakSelf.user.ucuid? :weakSelf.user.uid;
        
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
        
        [Yd1UCenter.shared createOrder:parameters
                              callback:^(int error_code, NSString * _Nonnull error) {
            if (error_code == 0) {
                YD1LOG(@"%@:下单成功",orderId);
                callback(true,orderId,error);
            } else {
                YD1LOG(@"%@",error);
                callback(false,orderId,error);
                NSMutableDictionary* properties = [NSMutableDictionary dictionary];
                [properties addEntriesFromDictionary:weakSelf.superProperty];
                [properties addEntriesFromDictionary:weakSelf.itemProperty];
                [ThinkingAnalyticsSDK.sharedInstance track:@"order_Pending" properties:properties];
            }
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:error_code==0?__success:__fail forKey:__result];
            [properties addEntriesFromDictionary:weakSelf.superProperty];
            [properties addEntriesFromDictionary:weakSelf.itemProperty];
            YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:properties error:nil]);
            [ThinkingAnalyticsSDK.sharedInstance track:@"order_Request" properties:properties];
        }];
    }];
}

- (void)paymentProduct:(Product*)product {
    [RMStore.defaultStore addPayment:product.channelProductId];
}

- (void)restorePayment:(RestoreCallback)callback {
    __weak typeof(self) weakSelf = self;
    [RMStore.defaultStore restoreTransactionsOnSuccess:^(NSArray *transactions) {
        NSMutableArray* restore = [NSMutableArray array];
        for (SKPaymentTransaction *transaction in transactions) {
            Product* product = [weakSelf productWithChannelProductId:transaction.payment.productIdentifier];
            if (product) {
                BOOL isHave = false;
                for (Product* pro in restore) {
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
        callback(restoreProduct,@"恢复购买成功");
    } failure:^(NSError *error) {
        callback(@[],error.localizedDescription);
    }];
}

- (NSArray *)productInfoWithProducts:(NSArray *)products {
    NSMutableArray* dicProducts = [NSMutableArray array];
    for (Product* product in products) {
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
    NSMutableArray* restoreProduct = [NSMutableArray array];
    NSSet* productIdentifiers = [persistence purchasedProductIdentifiers];
    YD1LOG(@"%@",productIdentifiers);
    for (NSString* productIdentifier in productIdentifiers.allObjects) {
        NSArray* transactions = [persistence transactionsForProductOfIdentifier:productIdentifier];
        for (RMStoreTransaction* transaction in transactions) {
            if (transaction.consumed) {
                continue;
            }
            [restoreProduct addObject:transaction];
        }
    }
    
    if ([restoreProduct count] < 1) {
        callback(@[],@"no have loss order");
        return;
    }
    /// 去掉订单一样的对象
    NSMutableArray *rp = [NSMutableArray array];
    for (RMStoreTransaction *model in restoreProduct) {
        __block BOOL isExist = NO;
        [rp enumerateObjectsUsingBlock:^(RMStoreTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.orderId isEqual:model.orderId]) {//数组中已经存在该对象
                *stop = YES;
                isExist = YES;
            }
        }];
        if (!isExist && model.orderId) {//如果不存在就添加进去
            [rp addObject:model];
        }
    }
   
    NSString* receipt = [[NSData dataWithContentsOfURL:RMStore.receiptURL] base64EncodedStringWithOptions:0];
    Yd1UCenter.shared.itemInfo.trx_receipt = receipt;
    __block NSMutableDictionary* lossOrder = [NSMutableDictionary dictionary];
    __block NSMutableArray* lossOrderProduct = [NSMutableArray array];
    __block int lossOrderCount = 0;
    __block int lossOrderReceiveCount = 0;
    __weak typeof(self) weakSelf = self;
    for (RMStoreTransaction* transaction in rp) {
        lossOrderCount++;
        Product* paymentProduct = [self productWithChannelProductId:transaction.productIdentifier];
        Yd1UCenter.shared.itemInfo.channelOrderid = transaction.transactionIdentifier;
        Yd1UCenter.shared.itemInfo.orderId = transaction.orderId;
        Yd1UCenter.shared.itemInfo.item_code = transaction.productIdentifier;
        Yd1UCenter.shared.itemInfo.product_type = (int)paymentProduct.productType;
        
        [Yd1UCenter.shared verifyAppStoreIAPOrder:Yd1UCenter.shared.itemInfo
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
#pragma mark- 单机查询服务器漏单
                        [Yd1UCenter.shared offlineMissorders:Yd1UCenter.shared.itemInfo
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
                                    Product* product = [weakSelf productWithChannelProductId:itemCode];
                                    if (product) {
                                        Product* product2 = [[Product alloc] initWithProduct:product];
                                        product2.orderId = orderId;
                                        [lossOrderProduct addObject:product2];
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
    Yd1UCenter.shared.itemInfo.exclude_old_transactions = excludeOldTransactions?@"true":@"false";
    NSString* receipt = [[NSData dataWithContentsOfURL:RMStore.receiptURL] base64EncodedStringWithOptions:0];
    if (!receipt) {
         callback(result, -1, NO, @"App Store of receipt is nil");
        return;
    }
    Yd1UCenter.shared.itemInfo.trx_receipt = receipt;
    [Yd1UCenter.shared querySubscriptions:Yd1UCenter.shared.itemInfo
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
                    SubscriptionInfo* info = [[SubscriptionInfo alloc] initWithUniformProductId:uniformProductId channelProductId:channelProductId expires:expires_date_ms purchaseDate:purchase_date_ms];
                    [result addObject:info];
                }
                //去重
                NSMutableArray *rp = [NSMutableArray array];
                for (SubscriptionInfo *model in result) {
                    __block BOOL isExist = NO;
                    [rp enumerateObjectsUsingBlock:^(SubscriptionInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)productWithUniformProductId:(NSString *)uniformProductId callback:(ProductsInfoCallback)callback {
    NSMutableArray* products = [NSMutableArray array];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    Product* product = [productInfos objectForKey:uniformProductId];
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
    for (Product *product in allProduct) {
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
            po.uniformProductId = self.currentUniformProductId;
            po.channelOrderid = @"";
            po.orderId = Yd1UCenter.shared.itemInfo.orderId;
            po.response = @"";
            po.paymentState = PaymentCannel;
            po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                 code:2004
                                             userInfo:@{NSLocalizedDescriptionKey:@"promot is nil!"}];
            callback(po);
        }
    }
#endif
}

- (void)cancelPromotion {
    self.addedStorePayment = nil;
}

- (Product*)promotionProduct {
    if (self.addedStorePayment) {
        NSString* uniformProductId = [[self productWithChannelProductId:self.addedStorePayment.productIdentifier] uniformProductId];
        Product* product = [productInfos objectForKey:uniformProductId];
        return product;
    }
    return nil;
}

- (NSString *)uniformProductIdWithChannelProductId:(NSString *)channelProductId {
    return [self productWithChannelProductId:channelProductId].uniformProductId? :@"";
}

- (Product*)productWithChannelProductId:(NSString*)channelProductId {
    NSArray* allProduct = [productInfos allValues];
    for (Product *productInfo in allProduct) {
        if ([productInfo.channelProductId isEqualToString:channelProductId]) {
            return productInfo;
        }
    }
    return nil;
}

- (void)updateProductInfo:(NSArray *)products {
    for (NSString* uniformProductId in [productInfos allKeys]) {
        Product* product = [productInfos objectForKey:uniformProductId];
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
    Product* product = [productInfos objectForKey:self.currentUniformProductId];
    if (self->persistence) {
        [self->persistence rechargedProuctOfIdentifier:product.channelProductId];
    }
}

#pragma mark- RMStoreObserver
- (void)storePaymentTransactionDeferred:(NSNotification*)notification {
    YD1LOG(@"");
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification {
    YD1LOG(@"");
    NSString* productIdentifier = notification.rm_productIdentifier;
    if (!productIdentifier) {
        Product* pr = [productInfos objectForKey:self.currentUniformProductId];
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
            if ([oderid isEqualToString:Yd1UCenter.shared.itemInfo.orderId]) {
                [newOrderId removeObject:oderid];
                break;
            }
        }
        NSString* orderidJson = [Yd1OpsTools stringWithJSONObject:newOrderId error:nil];
        [Yd1OpsTools saveKeychainWithService:productIdentifier str:orderidJson];
    }
    
    if (self.paymentCallback) {
        NSString* channelOrderid = notification.rm_transaction.transactionIdentifier;
        if (!channelOrderid) {
            channelOrderid = @"";
        }
        po.uniformProductId = self.currentUniformProductId;
        po.channelOrderid = channelOrderid;
        po.orderId = Yd1UCenter.shared.itemInfo.orderId;
        po.response = @"";
        po.paymentState = PaymentFail;
        po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                       code:2001
                                   userInfo:@{NSLocalizedDescriptionKey:notification.rm_storeError.localizedDescription? :@""}];
        self.paymentCallback(po);
        isBuying = false;
    }
}

- (void)storePaymentTransactionFinished:(NSNotification*)notification {
    if (!self.paymentCallback) {
        return;
    }
    NSString* channelOrderid = notification.rm_transaction.transactionIdentifier;
    if (!channelOrderid) {
        channelOrderid = @"";
    }
    Product* product = [productInfos objectForKey:self.currentUniformProductId];
    NSString* productIdentifier = notification.rm_productIdentifier;
    if (!productIdentifier) {
        productIdentifier = product.channelProductId;
    }
    NSString* receipt = [[NSData dataWithContentsOfURL:RMStore.receiptURL] base64EncodedStringWithOptions:0];
    Yd1UCenter.shared.itemInfo.channelOrderid = channelOrderid;
    Yd1UCenter.shared.itemInfo.trx_receipt = receipt;
    Yd1UCenter.shared.itemInfo.productId = productIdentifier;
    if (Yd1UCenterManager.shared.validatePaymentBlock) {
        NSDictionary* extra = @{@"productIdentifier":productIdentifier,
                                @"transactionIdentifier":channelOrderid,
                                @"transactionReceipt":receipt};
        NSString* extraSt = [Yd1OpsTools stringWithJSONObject:extra error:nil];
        Yd1UCenterManager.shared.validatePaymentBlock(product.uniformProductId,extraSt);
    }
    
    //AppsFlyer 数据统计
    [Yodo1AnalyticsManager.sharedInstance validateAndTrackInAppPurchase:productIdentifier
                                                                  price:product.productPrice
                                                               currency:product.currency
                                                          transactionId:channelOrderid];
    //Swrve 统计
    SKProduct* skp = [RMStore.defaultStore productForIdentifier:productIdentifier];
    [Yodo1AnalyticsManager.sharedInstance swrveTransactionProcessed:notification.rm_transaction
                                                      productBought:skp];
    __weak typeof(self) weakSelf = self;
    [Yd1UCenter.shared verifyAppStoreIAPOrder:Yd1UCenter.shared.itemInfo
                                     callback:^(BOOL verifySuccess, NSString * _Nonnull response, NSError * _Nonnull error) {
        NSDictionary* respo = [Yd1OpsTools JSONObjectWithString:response error:nil];
        NSString* orderId = @"";
        NSString* itemCode = @"";
        int error_code = -1;
        if (respo) {
            orderId = [respo objectForKey:@"orderid"];
            error_code = [[respo objectForKey:@"error_code"]intValue];
            itemCode = [respo objectForKey:@"item_code"];
        }
        YD1LOG(@"error_code:%d",error_code);
        if (verifySuccess) {
            if (weakSelf.paymentCallback) {
                self->po.uniformProductId = weakSelf.currentUniformProductId;
                self->po.channelOrderid = Yd1UCenter.shared.itemInfo.channelOrderid;
                self->po.orderId = orderId;
                self->po.response = response;
                self->po.paymentState = PaymentSuccess;
                weakSelf.paymentCallback(self->po);
            }
            [self->persistence consumeProductOfIdentifier:itemCode];
        } else {
            if (error_code == 20) {
                [self->persistence consumeProductOfIdentifier:itemCode];
            }
            if (weakSelf.paymentCallback) {
                self->po.uniformProductId = weakSelf.currentUniformProductId;
                self->po.channelOrderid = Yd1UCenter.shared.itemInfo.channelOrderid;
                self->po.orderId = orderId;
                self->po.response = response;
                self->po.paymentState = PaymentFail;
                self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                     code:2
                                                 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
                weakSelf.paymentCallback(self->po);
            }
        }
        self->isBuying = false;
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

@end

#pragma mark -   Unity3d 接口

#ifdef __cplusplus

extern "C" {
    
    void UnitySubmitUser(const char* jsonUser)
    {
        NSString* _jsonUser = Yodo1CreateNSString(jsonUser);
        NSDictionary* user = [Yd1OpsTools JSONObjectWithString:_jsonUser error:nil];
        if (user) {
            NSString* playerId = [user objectForKey:@"playerId"];
            NSString* nickName = [user objectForKey:@"nickName"];
            Yd1UCenterManager.shared.user.playerid = playerId;
            Yd1UCenterManager.shared.user.nickname = nickName;
            [Yd1OpsTools.cached setObject:Yd1UCenterManager.shared.user
                                   forKey:@"yd1User"];
            YD1LOG(@"playerId:%@",playerId);
            YD1LOG(@"nickName:%@",nickName);
        } else {
            YD1LOG(@"user is not submit!");
        }
    }

    /**
     *设置ops 环境
     */
    void UnityAPIEnvironment(int env)
    {
    }

    /**
     *设置是否显示log
     */
    void UnityLogEnabled(BOOL enable)
    {
        
    }

    void UnityGameUserId(const char* gameUserId)
    {
        
    }

    void UnityGameNickname(const char* gameNickname)
    {
        
    }

    /*
     获取在线分区列表
     */
    void UnityRegionList(const char* channelCode, const char* gameAppkey, const char* regionGroupCode, int env, const char* gameObjectName, const char* methodName)
    {

    }

    /**
     *获取版本更新信息
     */
    void UnityGetUpdateInfoWithAppKey(const char*gameAppkey,const char* channelCode,const char* gameObjectName, const char* methodName)
    {

    }

    /**
     *注册
     */
    void UnityRegistUsername(const char* username, const char* pwd, const char* gameObjectName, const char* methodName)
    {
  
    }

    /**
     *登录
     */
    void UnityLogin(int usertype, const char* username, const char* pwd, const char* gameObjectName, const char* methodName)
    {

    }

    /**
     *注销
     */
    void UnityLoginOut(const char* gameObjectName, const char* methodName)
    {
       
    }

    /**
     *设备账号转换
     */
    void UnityConverDeviceToNormal(const char* username, const char* pwd, const char* gameObjectName, const char* methodName)
    {

    }

    void UnityReplaceContentOfUserId(const char* replacedUserId, const char* deviceId, const char* gameObjectName, const char* methodName)
    {
        
    }

    /**
     *将device_id代表用户的存档的主帐号变更为user_id代表的帐号，user_id本身的数据被删除，替换的数据包括user_id本身
     *用户再次登录时取到的user_id是操作前device_id对应的user_id，原user_id已经删除了
     *device_id再次登录是取到的user_id是全新的
     *appkey 游戏 game_appkey
     *transferedUserId 用户id
     *device_id  设备id
     */
    void UnityTransferWithDeviceUserId(const char* transferedUserId, const char* deviceId, const char* gameObjectName, const char* methodName)
    {

    }

#pragma mark- 购买
    /**
     *查询漏单
     */
    void UnityQueryLossOrder(const char* gameObjectName, const char* methodName)
    {
        NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
        NSString* ocMethodName = Yodo1CreateNSString(methodName);
        
        [Yd1UCenterManager.shared queryLossOrder:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
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
        [Yd1UCenterManager.shared cancelPromotion];
    }

    void UnityGetPromotionProduct(const char* gameObjectName, const char* methodName)
    {
        NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
        NSString* ocMethodName = Yodo1CreateNSString(methodName);
        Product* product = [Yd1UCenterManager.shared promotionProduct];
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
        
        [Yd1UCenterManager.shared readyToContinuePurchaseFromPromot:^(PaymentObject * _Nonnull payemntObject) {
            if (payemntObject.paymentState == PaymentSuccess) {
                Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
                Yd1UCenter.shared.itemInfo.extra = @"";
                [Yd1UCenter.shared clientCallback:Yd1UCenter.shared.itemInfo
                                         callbakc:^(BOOL success, NSString * _Nonnull error) {
                    if (success) {
                        YD1LOG(@"上报成功");
                    } else {
                        YD1LOG(@"上报失败");
                    }
                }];
                ///同步信息
                [Yd1UCenter.shared clientNotifyForSyncUnityStatus:@[payemntObject.orderId]
                                                         callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                    if (success) {
                        YD1LOG(@"同步信息成功");
                    } else {
                        YD1LOG(@"同步信息失败:%@",error);
                    }
                    YD1LOG(@"notExistOrders:%@,notPayOrders:%@",
                           notExistOrders,notPayOrders)
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
            } else {
                if ([payemntObject.orderId length] > 0) {
                    Yd1UCenter.shared.itemInfo.channelCode = @"AppStore";
                    Yd1UCenter.shared.itemInfo.channelOrderid = payemntObject.channelOrderid? :@"";
                    Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
                    Yd1UCenter.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",payemntObject.paymentState];
                    Yd1UCenter.shared.itemInfo.statusMsg = payemntObject.response? :@"";
                    [Yd1UCenter.shared reportOrderStatus:Yd1UCenter.shared.itemInfo
                                                callbakc:^(BOOL success, NSString * _Nonnull error) {
                        if (success) {
                            YD1LOG(@"上报失败，成功");
                        } else {
                            YD1LOG(@"上报失败");
                        }
                    }];
                }
                //失败神策埋点
                NSMutableDictionary* properties = [NSMutableDictionary dictionary];
                [properties setObject:@-1 forKey:@"channelErrorCode"];
                [properties addEntriesFromDictionary:Yd1UCenterManager.shared .superProperty];
                [properties addEntriesFromDictionary:Yd1UCenterManager.shared.itemProperty];
                
                NSNumber* errorCode = [NSNumber numberWithInt:2004];//默认是未知失败
                if (payemntObject.error) {
                    errorCode  = [NSNumber numberWithInteger:payemntObject.error.code];
                }
                [properties setObject:errorCode forKey:@"yodo1ErrorCode"];
                YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:properties error:nil]);
                [ThinkingAnalyticsSDK.sharedInstance track:@"order_Error_FromSDK" properties:properties];
            
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
        }
        
        }];
    }

    void UnityFetchStorePromotionVisibilityForProduct(const char* uniformProductId, const char* gameObjectName, const char* methodName)
    {
        NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
        NSString* ocMethodName = Yodo1CreateNSString(methodName);
        NSString* _uniformProductId = Yodo1CreateNSString(uniformProductId);
        [Yd1UCenterManager.shared fetchStorePromotionVisibilityForProduct:_uniformProductId callback:^(PromotionVisibility storePromotionVisibility, BOOL success, NSString * _Nonnull error) {
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
        [Yd1UCenterManager.shared fetchStorePromotionOrder:^(NSArray<NSString *> * _Nonnull storePromotionOrder, BOOL success, NSString * _Nonnull error) {
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
        [Yd1UCenterManager.shared updateStorePromotionOrder:[[NSString stringWithUTF8String:productids] componentsSeparatedByString:@","] callback:^(BOOL success, NSString * _Nonnull error) {
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
        [Yd1UCenterManager.shared  updateStorePromotionVisibility:visible product:[NSString stringWithUTF8String:uniformProductId] callback:^(BOOL success, NSString * _Nonnull error) {
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
        
        [Yd1UCenterManager.shared querySubscriptions:excludeOldTransactions callback:^(NSArray * _Nonnull subscriptions, NSTimeInterval serverTime, BOOL success, NSString * _Nullable error) {
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                
                [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_QuerySubscriptions] forKey:@"resulType"];
                
                if([subscriptions count] > 0 ){
                    NSMutableArray* arrayProduct = [NSMutableArray arrayWithCapacity:1];
                    for(int i = 0;i < [subscriptions count]; i++){
                        NSMutableDictionary* dicProduct = [NSMutableDictionary dictionary];
                        SubscriptionInfo* info = [subscriptions objectAtIndex:i];
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
        [Yd1UCenterManager.shared restorePayment:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
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
        [Yd1UCenterManager.shared productWithUniformProductId:_uniformProductId callback:^(NSArray<Product *> * _Nonnull productInfo) {
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
        [Yd1UCenterManager.shared products:^(NSArray<Product *> * _Nonnull productInfo) {
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
        
        [Yd1UCenterManager.shared paymentWithUniformProductId:_uniformProductId
                                                        extra:_extra
                                                     callback:^(PaymentObject * _Nonnull payemntObject) {
            if (payemntObject.paymentState == PaymentSuccess) {
                Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
                Yd1UCenter.shared.itemInfo.extra = _extra? :@"";
                [Yd1UCenter.shared clientCallback:Yd1UCenter.shared.itemInfo
                                         callbakc:^(BOOL success, NSString * _Nonnull error) {
                    if (success) {
                        YD1LOG(@"上报成功");
                    } else {
                        YD1LOG(@"上报失败:%@",error);
                    }
                }];
                ///同步信息
                [Yd1UCenter.shared clientNotifyForSyncUnityStatus:@[payemntObject.orderId]
                                                         callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                    if (success) {
                        YD1LOG(@"同步信息成功");
                    } else {
                        YD1LOG(@"同步信息失败:%@",error);
                    }
                    YD1LOG(@"notExistOrders:%@,notPayOrders:%@",
                           notExistOrders,notPayOrders)
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(ocGameObjName && ocMethodName){
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
            } else {
                if ([payemntObject.orderId length] > 0) {
                    Yd1UCenter.shared.itemInfo.channelCode = @"AppStore";
                    Yd1UCenter.shared.itemInfo.channelOrderid = payemntObject.channelOrderid? :@"";
                    Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
                    Yd1UCenter.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",payemntObject.paymentState];
                    Yd1UCenter.shared.itemInfo.statusMsg = payemntObject.response? :@"";
                    [Yd1UCenter.shared reportOrderStatus:Yd1UCenter.shared.itemInfo
                                                callbakc:^(BOOL success, NSString * _Nonnull error) {
                        if (success) {
                            YD1LOG(@"上报失败，成功");
                        } else {
                            YD1LOG(@"上报失败");
                        }
                    }];
                }
                //失败神策埋点
                NSMutableDictionary* properties = [NSMutableDictionary dictionary];
                [properties setObject:@-1 forKey:@"channelErrorCode"];
                [properties addEntriesFromDictionary:Yd1UCenterManager.shared .superProperty];
                [properties addEntriesFromDictionary:Yd1UCenterManager.shared.itemProperty];
                
                NSNumber* errorCode = [NSNumber numberWithInt:2004];//默认是未知失败
                if (payemntObject.error) {
                    errorCode  = [NSNumber numberWithInteger:payemntObject.error.code];
                }
                [properties setObject:errorCode forKey:@"yodo1ErrorCode"];
                YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:properties error:nil]);
                [ThinkingAnalyticsSDK.sharedInstance track:@"order_Error_FromSDK" properties:properties];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ocGameObjName && ocMethodName){
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
        }
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
        [Yd1UCenter.shared sendGoodsOver:ocOrders callback:^(BOOL success, NSString * _Nonnull error) {
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
                    [Yd1UCenterManager.shared rechargedProuct];
                }
                NSMutableDictionary* properties = [NSMutableDictionary dictionary];
                [properties setObject:success?@"成功":@"失败" forKey:__status];
                [properties addEntriesFromDictionary:Yd1UCenterManager.shared .superProperty];
                [properties addEntriesFromDictionary:Yd1UCenterManager.shared.itemProperty];
                YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:properties error:nil]);
                [ThinkingAnalyticsSDK.sharedInstance track:@"order_Item_Delivered" properties:properties];
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
        [Yd1UCenter.shared sendGoodsOverForFault:ocOrders
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
        
        [Yd1UCenter.shared verifyActivationcode:code callback:^(BOOL success, NSDictionary * _Nullable response, NSString * _Nullable error) {
            NSLog(@"response=%@ error=%@", response, error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ocGameObjName && ocMethodName) {
                    if (success) {
                        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                        
                        [dict setObject:[NSNumber numberWithInt:Yodo1U3dSDK_ResulType_VerifyActivationcode] forKey:@"resulType"];
                        [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                        [dict setObject:[NSNumber numberWithInt:0] forKey:@"error"];
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
                        [dict setObject:[NSNumber numberWithInt:1] forKey:@"error"];
                        [dict setObject:error forKey:@"errorMsg"];
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
