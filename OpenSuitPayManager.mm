//
//  OpenSuitPayManager.m
//  OpenSuitPayManager
//
//  Created by yixian huang on 2017/7/24.
//

#import "OpenSuitPayManager.h"
#import "OpenSuitPayStore.h"
#import "OpenSuitReachability.h"
#import "OpenSuitCommons+PayParameters.h"
#import "OpenSuitCommons+Cache.h"
#import "OpenSuitPayStoreUserDefaultsPersistence.h"
#import "OpenSuitPayment.h"
#import "OpenSuitPayStoreTransaction.h"

#import "Yodo1UnityTool.h"

@interface OpenSuitAnalyticsManager : NSObject
@property(nonatomic,class,assign,readonly,getter=isEnable) BOOL enable;

+ (OpenSuitAnalyticsManager*)sharedInstance;

/*
 * appsFlyer安装判断
 */
- (BOOL)isAppsFlyerInstalled;

/**
 *  使用之前，先初始化initWithAnalytics
 *
 *  @param eventName  事件id(必须)
 *  @param eventData  事件数据(必须)
 */
- (void)eventAnalytics:(NSString*)eventName
             eventData:(NSDictionary*)eventData;

/**
 *  使用appsflyer 自定义事件
 *  @param eventName  事件id(必须)
 *  @param eventData  事件数据(必须)
 */
- (void)eventAdAnalyticsWithName:(NSString *)eventName
                       eventData:(NSDictionary *)eventData;
/**
 *  进入关卡/任务
 *
 *  @param level 关卡/任务
 */
- (void)startLevelAnalytics:(NSString*)level;

/**
 *  完成关卡/任务
 *
 *  @param level 关卡/任务
 */
- (void)finishLevelAnalytics:(NSString*)level;

/**
 *  未通过关卡
 *
 *  @param level 关卡/任务
 *  @param cause 未通过原因
 */
- (void)failLevelAnalytics:(NSString*)level failedCause:(NSString*)cause;

/**
 *  设置玩家等级
 *
 *  @param level 等级
 */
- (void)userLevelIdAnalytics:(int)level;

/**
 *  花费人民币去购买虚拟货币请求
 *
 *  @param orderId               订单id    类型:NSString
 *  @param iapId                 充值包id   类型:NSString
 *  @param currencyAmount        现金金额    类型:double
 *  @param currencyType          币种      类型:NSString 比如：参考 例：人民币CNY；美元USD；欧元EUR等
 *  @param virtualCurrencyAmount 虚拟币金额   类型:double
 *  @param paymentType           支付类型    类型:NSString 比如：“支付宝”“苹果官方”“XX支付SDK”
 */
- (void)chargeRequstAnalytics:(NSString*)orderId
                        iapId:(NSString*)iapId
               currencyAmount:(double)currencyAmount
                 currencyType:(NSString *)currencyType
        virtualCurrencyAmount:(double)virtualCurrencyAmount
                  paymentType:(NSString *)paymentType;

/**
 *  花费人民币去购买虚拟货币成功
 *
 *  @param orderId 订单id     类型:NSString
 *  @param source  支付渠道   1 ~ 99的整数, 其中1..20 是预定义含义,其余21-99需要在网站设置
 数值    含义
 1    App Store
 2    支付宝
 3    网银
 4    财付通
 5    移动通信
 6    联通通信
 7    电信通信
 8    paypal
 */
- (void)chargeSuccessAnalytics:(NSString *)orderId source:(int)source;

/**
 *  游戏中获得虚拟币
 *
 *  @param virtualCurrencyAmount 虚拟币金额         类型:double
 *  @param reason                赠送虚拟币的原因    类型:NSString
 *  @param source                奖励渠道    取值在 1~10 之间。“1”已经被预先定义为“系统奖励”，2~10 需要在网站设置含义          类型：int
 */
- (void)rewardAnalytics:(double)virtualCurrencyAmount reason:(NSString *)reason source:(int)source;

/**
 *  虚拟物品购买/使用虚拟币购买道具
 *
 *  @param item   道具           类型:NSString
 *  @param number 道具个数        类型:int
 *  @param price  道具单价        类型:double
 */
- (void)purchaseAnalytics:(NSString *)item itemNumber:(int)number priceInVirtualCurrency:(double)price;

/**
 *   虚拟物品消耗/玩家使用虚拟币购买道具
 *
 *  @param item   道具名称
 *  @param amount 道具数量
 *  @param price  道具单价
 */
- (void)useAnalytics:(NSString *)item amount:(int)amount price:(double)price;

#pragma mark- 友盟计时事件

- (void)beginEvent:(NSString *)eventId;

- (void)endEvent:(NSString *)eventId;

#pragma mark- DplusMobClick接口

/** Dplus增加事件
 @param eventName 事件名
 */
- (void)track:(NSString *)eventName;

/** Dplus增加事件
 @param eventName 事件名
 @param propertyKey 自定义属性key
 @param propertyValue 自定义属性Value
 */
- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
                 propertyValue:(NSString *)propertyValue;

/** Dplus增加事件 重载
 @param eventName 事件名
 @param propertyKey 自定义属性key
 @param propertyValue 自定义属性Value
 */
- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
              propertyIntValue:(int)propertyValue;

/** Dplus增加事件 重载
 @param eventName 事件名
 @param propertyKey 自定义属性key
 @param propertyValue 自定义属性Value
 */
- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
            propertyFloatValue:(float)propertyValue;

/** Dplus增加事件 重载
 @param eventName 事件名
 @param propertyKey 自定义属性key
 @param propertyValue 自定义属性Value
 */
- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
           propertyDoubleValue:(double)propertyValue;

/** Dplus增加事件:提交之前保存增加事件属性(一次性提交)
 @param eventName 事件名
 */
- (void)submitTrackWithEventName:(NSString *)eventName;

/**
 * 设置属性 键值对 会覆盖同名的key
 * 将该函数指定的key-value写入dplus专用文件；APP启动时会自动读取该文件的所有key-value，并将key-value自动作为后续所有track事件的属性。
 */
- (void)registerSuperProperty:(NSDictionary *)property;

/**
 *
 * 从dplus专用文件中删除指定key-value
 @param propertyName 属性名
 */
- (void)unregisterSuperProperty:(NSString *)propertyName;

/**
 *
 * 返回dplus专用文件中key对应的value；如果不存在，则返回空。
 @param propertyName 属性名
 @return NSString
 */
- (NSString *)getSuperProperty:(NSString *)propertyName;

/**
 * 返回Dplus专用文件中的所有key-value；如果不存在，则返回空。
 */
- (NSDictionary *)getSuperProperties;

/**
 *清空Dplus专用文件中的所有key-value。
 */
- (void)clearSuperProperties;

#pragma mark- GameAnalytics接口
/**
 *  GameAnalytics 设置维度01类型
 **/
- (void)setGACustomDimension01:(NSString*)dimension01;
/**
 *  GameAnalytics 设置维度02类型
 **/
- (void)setGACustomDimension02:(NSString*)dimension02;

/**
 *  GameAnalytics 设置维度03类型
 **/
- (void)setGACustomDimension03:(NSString*)dimension03;

/**
 *  AppsFlyer Apple 内付费验证和事件统计
 */
- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId;

/**
 *  Swrve 事件统计
 */
- (void)swrveEventAnalyticsWithName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData;

/**
 *  Swrve 更新用户数据事件
 */
- (void)swrveUserUpdate:(NSDictionary *)eventData;

/**
 *  Swrve 内付费验证和事件统计
 */
- (void)swrveTransactionProcessed:(SKPaymentTransaction*) transaction
                    productBought:(SKProduct*) product;
@end


/// 超级属性
static NSString* const __kGameName               = @"gameName";
static NSString* const __kGameVersion            = @"gameVersion";
static NSString* const __kGameBundleId           = @"gameBundleId";
static NSString* const __KSdkType                = @"sdkType";
static NSString* const __kSdkVersion             = @"sdkVersion";
static NSString* const __kPublishChannelCode     = @"publishChannelCode";
static NSString* const __kMasSdkVersion          = @"masSdkVersion";
/// 付费方式属性
static NSString* const __kPaymentChannelCode     = @"paymentChannelCode";
static NSString* const __kPaymentChannelVersion  = @"paymentChannelVersion";
/// IAP的公共属性
static NSString* const __kItemCode               = @"itemCode";
static NSString* const __kItemName               = @"itemName";
static NSString* const __kItemType               = @"itemType";
static NSString* const __kitemCurrency           = @"itemCurrency";
static NSString* const __kItemPrice              = @"itemPrice";
static NSString* const __kChannelItemCode        = @"channelItemCode";
/// 属性值
static NSString* const __kResult                 = @"result";
static NSString* const __kSuccess                = @"success";
static NSString* const __kFail                   = @"fail";
static NSString* const __kServerVersion          = @"serverVersion";
static NSString* const __kYodo1ErrorCode         = @"yodo1ErrorCode";
static NSString* const __kChannelErrorCode       = @"channelErrorCode";
static NSString* const __kStatus                 = @"status";

@implementation OpenSuitProduct

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
        self.openSuitProductType = (OpenSuitProductType)[[dictProduct objectForKey:@"OpenSuitProductType"] intValue];
        self.periodUnit = [dictProduct objectForKey:@"PeriodUnit"];
        self.orderId = [dictProduct objectForKey:@"OrderId"];
    }
    return self;
}

- (instancetype)initWithProduct:(OpenSuitProduct*)product {
    self = [super init];
    if (self) {
        self.uniformProductId = product.uniformProductId;
        self.channelProductId = product.channelProductId;
        self.productName = product.productName;
        self.productPrice = product.productPrice;
        self.priceDisplay = product.priceDisplay;
        self.currency = product.currency;
        self.productDescription = product.productDescription;
        self.openSuitProductType = product.openSuitProductType;
        self.periodUnit = product.periodUnit;
        self.orderId = product.orderId;
    }
    return self;
}

@end

@implementation OpenSuitPayObject

@end

@interface OpenSuitPayManager ()<OpenSuitPayStoreObserver> {
    NSMutableDictionary* productInfos;
    NSMutableArray* channelProductIds;
    OpenSuitPayStoreUserDefaultsPersistence *persistence;
    __block BOOL isBuying;
    __block OpenSuitPayObject* po;
}

@property (nonatomic,strong) NSString* currentUniformProductId;
@property (nonatomic,retain) SKPayment* addedStorePayment;//promot Appstore Buy
@property (nonatomic,copy)OpenSuitPayCallback OpenSuitPayCallback;

- (OpenSuitProduct *)productWithChannelProductId:(NSString *)channelProductId;
- (NSArray *)productInfoWithProducts:(NSArray *)products;
- (void)updateProductInfo:(NSArray *)products;
- (NSString *)diplayPrice:(SKProduct *)product;
- (NSString *)productPrice:(SKProduct *)product;
- (NSString *)periodUnitWithProduct:(SKProduct *)product;
- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString;
- (void)rechargedProuct;

@end

@implementation OpenSuitPayManager

+ (instancetype)shared {
    static OpenSuitPayManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OpenSuitPayManager alloc] init];
    });
    return _sharedInstance;
}

- (void)startOpenSuitPayWithAppKey:(NSString *)appKey
                         channelId:(NSString *)channelId {
    _payAppKey = appKey;
    _payChannelId = channelId?:@"";
    _superProperty = [NSMutableDictionary dictionary];
    _itemProperty = [NSMutableDictionary dictionary];
    //公共属性
    [_superProperty setObject:OpenSuitCommons.appName forKey:__kGameName];
    [_superProperty setObject:OpenSuitCommons.appVersion forKey:__kGameVersion];
    [_superProperty setObject:OpenSuitCommons.appBid forKey:__kGameBundleId];
    [_superProperty setObject:[OpenSuitPayment.shared publishType] forKey:__KSdkType];
    [_superProperty setObject:[OpenSuitPayment.shared publishVersion] forKey:__kSdkVersion];
    [_superProperty setObject:OpenSuitPayManager.shared.payChannelId forKey:__kPublishChannelCode];
    [_superProperty setObject:[OpenSuitPayment.shared publishVersion] forKey:__kMasSdkVersion];
    // 付费方式属性
    [_superProperty setObject:OpenSuitPayManager.shared.payChannelId forKey:__kPaymentChannelCode];
    [_superProperty setObject:[OpenSuitPayment.shared publishVersion] forKey:__kPaymentChannelVersion];
    
    po = [OpenSuitPayObject new];
    
    PayUser* user = (PayUser*)[OpenSuitCommons.cached objectForKey:@"yd1User"];
    if (user) {
        self.user = user;
        OpenSuitPayment.shared.itemInfo.uid = user.uid;
        OpenSuitPayment.shared.itemInfo.ucuid = user.ucuid? : user.uid;
        OpenSuitPayment.shared.itemInfo.yid = user.yid;
        OpenSuitPayment.shared.itemInfo.playerid = user.playerid;
    } else {
        _user = [[PayUser alloc]init];
    }
    
    isBuying = false;
    //设备登录
    __weak typeof(self) weakSelf = self;
    [OpenSuitPayment.shared deviceLoginWithPlayerId:@""
                                           callback:^(PayUser * _Nullable user, NSError * _Nullable error) {
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
            [OpenSuitCommons.cached setObject:weakSelf.user forKey:@"yd1User"];
        }
        if (user && !error) {
            weakSelf.isLogined = YES;
            OpenSuitPayment.shared.itemInfo.uid = self.user.uid;
            OpenSuitPayment.shared.itemInfo.yid = self.user.yid;
        }else{
            weakSelf.isLogined = NO;
            OpenSuitLog(@"%@",error.localizedDescription);
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
        OpenSuitProduct* product = [[OpenSuitProduct alloc] initWithDict:item productId:key];
        [productInfos setObject:product forKey:key];
        [channelProductIds addObject:[item objectForKey:@"ChannelProductId"]];
    }
    
    persistence = [[OpenSuitPayStoreUserDefaultsPersistence alloc] init];
    OpenSuitPayStore.defaultStore.transactionPersistor = persistence;
    [OpenSuitPayStore.defaultStore addStoreObserver:self];
    
    [self requestProducts];
    
    /// 网络变化监测
    [OpenSuitReachability.reachability setNotifyBlock:^(OpenSuitReachability * _Nonnull reachability) {
        if (reachability.reachable) {
            [weakSelf requestProducts];
        }
    }];
}

- (void)dealloc {
    [OpenSuitPayStore.defaultStore removeStoreObserver:self];
}

- (void)requestProducts {
    /// 请求产品信息
    NSSet* productIds = [NSSet setWithArray:channelProductIds];
    [OpenSuitPayStore.defaultStore requestProducts:productIds];
}

- (void)paymentWithUniformProductId:(NSString *)uniformProductId
                              extra:(NSString*)extra
                           callback:(nonnull OpenSuitPayCallback)callback {
    
    if (isBuying) {
        OpenSuitLog(@"product is buying ...");
        return;
    }
    isBuying = true;
    self.OpenSuitPayCallback = callback;
    
    if([self.itemProperty count] >0){
        [self.itemProperty removeAllObjects];
    }
    __block OpenSuitProduct* product = [productInfos objectForKey:uniformProductId];
    [self.itemProperty setObject:product.channelProductId ? :@"" forKey:__kItemCode];
    [self.itemProperty setObject:product.productName ? :@"" forKey:__kItemName];
    [self.itemProperty setObject:[NSString stringWithFormat:@"%d",product.openSuitProductType]  forKey:__kItemType];
    [self.itemProperty setObject:product.productPrice ? :@"" forKey:__kItemPrice];
    [self.itemProperty setObject:product.currency ? :@"" forKey:__kitemCurrency];
    [self.itemProperty setObject:@"" forKey:__kChannelItemCode];
    
    if (!uniformProductId) {
        po.uniformProductId = uniformProductId;
        po.channelOrderid = @"";
        po.orderId = @"";
        po.response = @"";
        po.PayState = PaytFail;
        po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                       code:2001
                                   userInfo:@{NSLocalizedDescriptionKey:@"uniformProductId is nil!"}];
        self.OpenSuitPayCallback(po);
        isBuying = false;
        return;
    }
    
    if (!OpenSuitPayStore.canMakePayments) {
        OpenSuitLog(@"This device is not able or allowed to make payments!");
        
        po.uniformProductId = uniformProductId;
        po.channelOrderid = @"";
        po.orderId = @"";
        po.response = @"";
        po.PayState = PaytFail;
        po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                       code:2002
                                   userInfo:@{NSLocalizedDescriptionKey:@"This device is not able or allowed to make payments!"}];
        self.OpenSuitPayCallback(po);
        isBuying = false;
        return;
    }
    
    if ([[OpenSuitCommons networkType]isEqualToString:@"NONE"]) {
        po.uniformProductId = uniformProductId;
        po.channelOrderid = @"";
        po.orderId = @"";
        po.response = @"";
        po.PayState = PaytFail;
        po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                       code:2003
                                   userInfo:@{NSLocalizedDescriptionKey:@"The Network is noReachable!"}];
        self.OpenSuitPayCallback(po);
        isBuying = false;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (!self.isLogined) {
        if (self.OpenSuitPayCallback) {
            po.uniformProductId = uniformProductId;
            po.channelOrderid = @"";
            po.orderId = @"";
            po.response = @"";
            po.PayState = PaytFail;
            po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                           code:2001
                                       userInfo:@{NSLocalizedDescriptionKey:@"The device is not login!"}];
            self.OpenSuitPayCallback(po);
            isBuying = false;
        }
        [OpenSuitPayment.shared deviceLoginWithPlayerId:@""
                                               callback:^(PayUser * _Nullable user, NSError * _Nullable error) {
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
                [OpenSuitCommons.cached setObject:weakSelf.user forKey:@"yd1User"];
            }
            if (user && !error) {
                weakSelf.isLogined = YES;
                OpenSuitPayment.shared.itemInfo.uid = self.user.uid;
                OpenSuitPayment.shared.itemInfo.yid = self.user.yid;
                OpenSuitPayment.shared.itemInfo.ucuid = self.user.ucuid? :self.user.uid;
            }else{
                weakSelf.isLogined = NO;
                OpenSuitLog(@"%@",error.localizedDescription);
            }
        }];
        return;
    }
    [self createOrderIdWithUniformProductId:uniformProductId
                                      extra:extra
                                   callback:^(bool success, NSString * _Nonnull orderid, NSString * _Nonnull error) {
        if (success) {
            if (product.openSuitProductType == Auto_Subscription) {
                NSString* msg = [weakSelf localizedStringForKey:@"SubscriptionAlertMessage"
                                                    withDefault:@"确认启用后，您的iTunes账户将支付 %@ %@ 。%@自动续订此服务时您的iTunes账户也会支付相同费用。系统在订阅有效期结束前24小时会自动为您续订并扣费，除非您在有效期结束前取消服务。若需取消订阅，可前往设备设置-iTunes与App Store-查看Apple ID-订阅，管理或取消已经启用的服务。"];
                NSString* message = [NSString stringWithFormat:msg,product.productPrice,product.currency,product.periodUnit];
                
                NSString* title = [weakSelf localizedStringForKey:@"SubscriptionAlertTitle" withDefault:@"确认启用订阅服务"];
                NSString* cancelTitle = [weakSelf localizedStringForKey:@"SubscriptionAlertCancel" withDefault:@"取消"];
                NSString* okTitle = [weakSelf localizedStringForKey:@"SubscriptionAlertOK" withDefault:@"启用"];
                NSString* privateTitle = [weakSelf localizedStringForKey:@"SubscriptionAlertPrivate" withDefault:@"隐私协议"];
                NSString* serviceTitle = [weakSelf localizedStringForKey:@"SubscriptionAlertService" withDefault:@"服务条款"];
                UIAlertControllerStyle uiStyle = UIAlertControllerStyleActionSheet;
                if([OpenSuitCommons isIPad]){
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
                    self->po.PayState = PayCannel;
                    self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                         code:2001
                                                     userInfo:@{NSLocalizedDescriptionKey:error? :@""}];
                    weakSelf.OpenSuitPayCallback(self->po);
                    self->isBuying = false;
                }];
                UIAlertAction *serviceAction = [UIAlertAction actionWithTitle:serviceTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:termsServiceUrl]];
                    self->po.uniformProductId = uniformProductId;
                    self->po.channelOrderid = @"";
                    self->po.orderId = @"";
                    self->po.response = @"";
                    self->po.PayState = PayCannel;
                    self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                         code:2001
                                                     userInfo:@{NSLocalizedDescriptionKey:error? :@""}];
                    weakSelf.OpenSuitPayCallback(self->po);
                    self->isBuying = false;
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    self->po.uniformProductId = uniformProductId;
                    self->po.channelOrderid = @"";
                    self->po.orderId = @"";
                    self->po.response = @"";
                    self->po.PayState = PayCannel;
                    self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                         code:2001
                                                     userInfo:@{NSLocalizedDescriptionKey:error? :@""}];
                    weakSelf.OpenSuitPayCallback(self->po);
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
            self->po.PayState = PaytFail;
            self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                 code:2001
                                             userInfo:@{NSLocalizedDescriptionKey:error? :@""}];
            weakSelf.OpenSuitPayCallback(self->po);
            self->isBuying = false;
        }
    }];
}

- (void)createOrderIdWithUniformProductId:(NSString *)uniformProductId
                                    extra:(NSString*)extra
                                 callback:(void (^)(bool, NSString * _Nonnull,NSString * _Nonnull))callback {
    self.currentUniformProductId = uniformProductId;
    __weak typeof(self) weakSelf = self;
    __block OpenSuitProduct* product = [productInfos objectForKey:uniformProductId];
    SKProduct* skp = [OpenSuitPayStore.defaultStore productForIdentifier:product.channelProductId];
    if (!skp) {
        callback(false,@"",@"products request failed with error Error");
        return;
    }
    //创建订单号
    [OpenSuitPayment.shared generateOrderId:^(NSString * _Nullable orderId, NSError * _Nullable error) {
        if ((!orderId || [orderId isEqualToString:@""])) {
            OpenSuitLog(@"%@",error.localizedDescription);
            callback(false,orderId,error.localizedDescription);
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties addEntriesFromDictionary:weakSelf.superProperty];
            [properties addEntriesFromDictionary:weakSelf.itemProperty];
            Class thinkingClass = NSClassFromString(@"OpenSuitAnalyticsManager");
            if (thinkingClass && [thinkingClass respondsToSelector:@selector(sharedInstance)]) {
                OpenSuitAnalyticsManager *sdk = [thinkingClass sharedInstance];
                if (sdk && [sdk respondsToSelector:@selector(eventAnalytics:eventData:)]) {
                    [sdk eventAnalytics:@"order_Pending" eventData:properties];
                }
            }
            return;
        }
        OpenSuitPayment.shared.itemInfo.orderId = orderId;
        
        //保存orderId
        NSString* oldOrderIdStr = [OpenSuitCommons keychainWithService:product.channelProductId];
        NSArray* oldOrderId = (NSArray *)[OpenSuitCommons JSONObjectWithString:oldOrderIdStr error:nil];
        NSMutableArray* newOrderId = [NSMutableArray array];
        if (oldOrderId) {
            [newOrderId setArray:oldOrderId];
        }
        [newOrderId addObject:orderId];
        NSString* orderidJson = [OpenSuitCommons stringWithJSONObject:newOrderId error:nil];
        [OpenSuitCommons saveKeychainWithService:product.channelProductId str:orderidJson];
        
        OpenSuitPayment.shared.itemInfo.product_type = (int)product.openSuitProductType;
        OpenSuitPayment.shared.itemInfo.item_code = product.channelProductId;
        // 下单
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        [parameters setObject:orderId forKey:@"orderId"];
        
        NSDictionary* productInfo = @{
            @"productId":product.channelProductId? :@"",
            @"productName":product.productName? :@"",
            @"productCount":@"1",
            @"productDescription":product.productDescription? :@"",
            @"currency":product.currency? :@"",
            @"productType":[NSNumber numberWithInt:(int)product.openSuitProductType],
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
        
        OpenSuitPayment.shared.itemInfo.ucuid = weakSelf.user.ucuid? :weakSelf.user.uid;
        
        if (weakSelf.user.playerid) {
            [parameters setObject:weakSelf.user.playerid forKey:@"playerId"];
        }else{
            NSString* playerid = weakSelf.user.ucuid? :weakSelf.user.uid;
            [parameters setObject:playerid? :@"" forKey:@"playerId"];
        }
        
        [parameters setObject:OpenSuitCommons.appName? :@"" forKey:@"gameName"];
        [parameters setObject:@"offline" forKey:@"gameType"];
        [parameters setObject:OpenSuitCommons.appVersion? :@"" forKey:@"gameVersion"];
        [parameters setObject:@"" forKey:@"gameExtra"];
        [parameters setObject:extra? :@"" forKey:@"extra"];
        [parameters setObject:OpenSuitCommons.appVersion? :@"" forKey:@"channelVersion"];
        
        [OpenSuitPayment.shared createOrder:parameters
                                   callback:^(int error_code, NSString * _Nonnull error) {
            if (error_code == 0) {
                OpenSuitLog(@"%@:下单成功",orderId);
                callback(true,orderId,error);
            } else {
                OpenSuitLog(@"%@",error);
                callback(false,orderId,error);
                NSMutableDictionary* properties = [NSMutableDictionary dictionary];
                [properties addEntriesFromDictionary:weakSelf.superProperty];
                [properties addEntriesFromDictionary:weakSelf.itemProperty];
                Class thinkingClass = NSClassFromString(@"OpenSuitAnalyticsManager");
                if (thinkingClass && [thinkingClass respondsToSelector:@selector(sharedInstance)]) {
                    OpenSuitAnalyticsManager *sdk = [thinkingClass sharedInstance];
                    if (sdk && [sdk respondsToSelector:@selector(eventAnalytics:eventData:)]) {
                        [sdk eventAnalytics:@"order_Pending" eventData:properties];
                    }
                }
            }
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:error_code==0?__kSuccess:__kFail forKey:__kResult];
            [properties addEntriesFromDictionary:weakSelf.superProperty];
            [properties addEntriesFromDictionary:weakSelf.itemProperty];
            OpenSuitLog(@"%@",[OpenSuitCommons stringWithJSONObject:properties error:nil]);
            
            Class thinkingClass = NSClassFromString(@"OpenSuitAnalyticsManager");
            if (thinkingClass && [thinkingClass respondsToSelector:@selector(sharedInstance)]) {
                OpenSuitAnalyticsManager *sdk = [thinkingClass sharedInstance];
                if (sdk && [sdk respondsToSelector:@selector(eventAnalytics:eventData:)]) {
                    [sdk eventAnalytics:@"order_Request" eventData:properties];
                }
            }
        }];
    }];
}

- (void)paymentProduct:(OpenSuitProduct*)product {
    [OpenSuitPayStore.defaultStore addPayment:product.channelProductId];
}

- (void)restorePayment:(OpenSuitRestoreCallback)callback {
    __weak typeof(self) weakSelf = self;
    [OpenSuitPayStore.defaultStore restoreTransactionsOnSuccess:^(NSArray *transactions) {
        NSMutableArray* restore = [NSMutableArray array];
        for (SKPaymentTransaction *transaction in transactions) {
            OpenSuitProduct* product = [weakSelf productWithChannelProductId:transaction.payment.productIdentifier];
            if (product) {
                BOOL isHave = false;
                for (OpenSuitProduct* pro in restore) {
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
    for (OpenSuitProduct* product in products) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:product.uniformProductId == nil?@"":product.uniformProductId forKey:@"productId"];
        [dict setObject:product.channelProductId == nil?@"":product.channelProductId forKey:@"marketId"];
        [dict setObject:product.productName == nil?@"":product.productName forKey:@"productName"];
        [dict setObject:product.orderId == nil?@"":product.orderId forKey:@"orderId"];
        
        SKProduct* skp = [OpenSuitPayStore.defaultStore productForIdentifier:product.channelProductId];
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
        [dict setObject:[NSNumber numberWithInt:(int)product.openSuitProductType] forKey:@"OpenSuitProductType"];
        [dict setObject:product.currency == nil?@"":product.currency forKey:@"currency"];
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"coin"];
        [dict setObject:product.periodUnit == nil?@"":[self periodUnitWithProduct:skp] forKey:@"periodUnit"];
        
        [dicProducts addObject:dict];
    }
    return dicProducts;
}

- (void)queryLossOrder:(OpenSuitLossOrderCallback)callback {
    NSMutableArray* restoreProduct = [NSMutableArray array];
    NSSet* productIdentifiers = [persistence purchasedProductIdentifiers];
    OpenSuitLog(@"%@",productIdentifiers);
    for (NSString* productIdentifier in productIdentifiers.allObjects) {
        NSArray* transactions = [persistence transactionsForProductOfIdentifier:productIdentifier];
        for (OpenSuitPayStoreTransaction* transaction in transactions) {
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
    for (OpenSuitPayStoreTransaction *model in restoreProduct) {
        __block BOOL isExist = NO;
        [rp enumerateObjectsUsingBlock:^(OpenSuitPayStoreTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.orderId isEqual:model.orderId]) {//数组中已经存在该对象
                *stop = YES;
                isExist = YES;
            }
        }];
        if (!isExist && model.orderId) {//如果不存在就添加进去
            [rp addObject:model];
        }
    }
    
    NSString* receipt = [[NSData dataWithContentsOfURL:OpenSuitPayStore.receiptURL] base64EncodedStringWithOptions:0];
    OpenSuitPayment.shared.itemInfo.trx_receipt = receipt;
    __block NSMutableDictionary* lossOrder = [NSMutableDictionary dictionary];
    __block NSMutableArray* lossOrderProduct = [NSMutableArray array];
    __block int lossOrderCount = 0;
    __block int lossOrderReceiveCount = 0;
    __weak typeof(self) weakSelf = self;
    for (OpenSuitPayStoreTransaction* transaction in rp) {
        lossOrderCount++;
        OpenSuitProduct* paymentProduct = [self productWithChannelProductId:transaction.productIdentifier];
        OpenSuitPayment.shared.itemInfo.channelOrderid = transaction.transactionIdentifier;
        OpenSuitPayment.shared.itemInfo.orderId = transaction.orderId;
        OpenSuitPayment.shared.itemInfo.item_code = transaction.productIdentifier;
        OpenSuitPayment.shared.itemInfo.product_type = (int)paymentProduct.openSuitProductType;
        
        [OpenSuitPayment.shared verifyAppStoreIAPOrder:OpenSuitPayment.shared.itemInfo
                                              callback:^(BOOL verifySuccess, NSString * _Nonnull response, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response && response.length > 0) {
                    NSDictionary* dic = [OpenSuitCommons JSONObjectWithString:response error:nil];
                    NSString* orderId = [dic objectForKey:@"orderid"];
                    NSString* itemCode = [dic objectForKey:@"item_code"];
                    int errorcode = [[dic objectForKey:@"error_code"]intValue];
                    if (verifySuccess) {
                        if (orderId && itemCode) {
                            [lossOrder setObject:itemCode forKey:orderId];
                            [self->persistence consumeProductOfIdentifier:itemCode];
                            [self->persistence rechargedProuctOfIdentifier:itemCode];
                        }
                        OpenSuitLog(@"验证成功orderid:%@",orderId);
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
                        [OpenSuitPayment.shared offlineMissorders:OpenSuitPayment.shared.itemInfo
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
                                    OpenSuitProduct* product = [weakSelf productWithChannelProductId:itemCode];
                                    if (product) {
                                        OpenSuitProduct* product2 = [[OpenSuitProduct alloc] initWithProduct:product];
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
                  callback:(OpenSuitQuerySubscriptionCallback)callback {
    __weak typeof(self) weakSelf = self;
    NSMutableArray* result = [NSMutableArray array];
    OpenSuitPayment.shared.itemInfo.exclude_old_transactions = excludeOldTransactions?@"true":@"false";
    NSString* receipt = [[NSData dataWithContentsOfURL:OpenSuitPayStore.receiptURL] base64EncodedStringWithOptions:0];
    if (!receipt) {
        callback(result, -1, NO, @"App Store of receipt is nil");
        return;
    }
    OpenSuitPayment.shared.itemInfo.trx_receipt = receipt;
    [OpenSuitPayment.shared querySubscriptions:OpenSuitPayment.shared.itemInfo
                                      callback:^(BOOL success, NSString * _Nullable response, NSError * _Nullable error) {
        if (success) {
            NSDictionary *responseDic = [OpenSuitCommons JSONObjectWithString:response error:nil];
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
                    PaySubscriptionInfo* info = [[PaySubscriptionInfo alloc] initWithUniformProductId:uniformProductId channelProductId:channelProductId expires:expires_date_ms purchaseDate:purchase_date_ms];
                    [result addObject:info];
                }
                //去重
                NSMutableArray *rp = [NSMutableArray array];
                for (PaySubscriptionInfo *model in result) {
                    __block BOOL isExist = NO;
                    [rp enumerateObjectsUsingBlock:^(PaySubscriptionInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)productWithUniformProductId:(NSString *)uniformProductId callback:(OpenSuitProductsInfoCallback)callback {
    NSMutableArray* products = [NSMutableArray array];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    OpenSuitProduct* product = [productInfos objectForKey:uniformProductId];
    [dict setObject:product.uniformProductId == nil?@"":product.uniformProductId forKey:@"productId"];
    [dict setObject:product.channelProductId == nil?@"":product.channelProductId forKey:@"marketId"];
    [dict setObject:product.productName == nil?@"":product.productName forKey:@"productName"];
    SKProduct* skp = [OpenSuitPayStore.defaultStore productForIdentifier:product.channelProductId];
    NSString* price = nil;
    if (skp) {
        price = [skp.price stringValue];
        product.currency = [OpenSuitCommons currencyCode:skp.priceLocale];
        product.priceDisplay = [self diplayPrice:skp];
        product.periodUnit = [self periodUnitWithProduct:skp];
    }else{
        price = product.productPrice;
    }
    [dict setObject:product.priceDisplay == nil?@"":product.priceDisplay forKey:@"priceDisplay"];
    [dict setObject:price == nil?@"":price forKey:@"price"];
    [dict setObject:product.productDescription == nil?@"":product.productDescription forKey:@"description"];
    [dict setObject:[NSNumber numberWithInt:(int)product.openSuitProductType] forKey:@"OpenSuitProductType"];
    [dict setObject:product.currency == nil?@"":product.currency forKey:@"currency"];
    [dict setObject:product.periodUnit == nil?@"":product.periodUnit forKey:@"periodUnit"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"coin"];
    [products addObject:dict];
    if (callback) {
        callback(products);
    }else{
        NSAssert(callback != nil, @"OpenSuitProductsInfoCallback of callback not set!");
    }
}

- (void)products:(OpenSuitProductsInfoCallback)callback {
    NSMutableArray* products = [NSMutableArray array];
    NSArray* allProduct = [productInfos allValues];
    for (OpenSuitProduct *product in allProduct) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:product.uniformProductId == nil?@"":product.uniformProductId forKey:@"productId"];
        [dict setObject:product.channelProductId == nil?@"":product.channelProductId forKey:@"marketId"];
        [dict setObject:product.productName == nil?@"":product.productName forKey:@"productName"];
        
        SKProduct* skp = [OpenSuitPayStore.defaultStore productForIdentifier:product.channelProductId];
        NSString* price = nil;
        if (skp) {
            price = [skp.price stringValue];
            product.currency = [OpenSuitCommons currencyCode:skp.priceLocale];
            product.priceDisplay = [self diplayPrice:skp];
            product.periodUnit = [self periodUnitWithProduct:skp];
        }else{
            price = product.productPrice;
        }
        
        [dict setObject:product.priceDisplay == nil?@"":product.priceDisplay forKey:@"priceDisplay"];
        [dict setObject:price == nil?@"":price forKey:@"price"];
        [dict setObject:product.productDescription == nil?@"":product.productDescription forKey:@"description"];
        [dict setObject:[NSNumber numberWithInt:(int)product.openSuitProductType] forKey:@"OpenSuitProductType"];
        [dict setObject:product.currency == nil?@"":product.currency forKey:@"currency"];
        [dict setObject:[NSNumber numberWithInt:0] forKey:@"coin"];
        
        [products addObject:dict];
    }
    if (callback) {
        callback(products);
    }else{
        NSAssert(callback != nil, @"OpenSuitProductsInfoCallback of callback not set!");
    }
}

#pragma mark- 促销活动

- (void)fetchStorePromotionOrder:(OpenSuitFetchStorePromotionOrderCallback)callback {
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

- (void)fetchStorePayPromotionVisibilityForProduct:(NSString *)uniformProductId callback:(OpenSuitFetchStorePayPromotionVisibilityCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        NSString* channelProductId = [[productInfos objectForKey:uniformProductId] channelProductId];
        [[SKProductStorePromotionController defaultController] fetchStorePromotionVisibilityForProduct:[OpenSuitPayStore.defaultStore productForIdentifier:channelProductId] completionHandler:^(SKProductStorePromotionVisibility storePromotionVisibility, NSError * _Nullable error) {
            if(callback){
                PayPromotionVisibility result = Default;
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
                         callback:(nonnull OpenSuitUpdateStorePromotionOrderCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        NSMutableArray<SKProduct *> *productsArray = [[NSMutableArray alloc] init];
        for (NSString* uniformProductId in uniformProductIdArray) {
            NSString* channelProductId = [[productInfos objectForKey:uniformProductId] channelProductId];
            [productsArray addObject:[OpenSuitPayStore.defaultStore productForIdentifier:channelProductId]];
        }
        [[SKProductStorePromotionController defaultController] updateStorePromotionOrder:productsArray completionHandler:^(NSError * _Nullable error) {
            callback(error == nil, [error description]);
        }];
    } else {
        
    }
#endif
}

- (void)updateStorePayPromotionVisibility:(BOOL)visibility
                                  product:(NSString *)uniformProductId
                                 callback:(OpenSuitUpdateStorePayPromotionVisibilityCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        NSString* channelProductId = [[productInfos objectForKey:uniformProductId] channelProductId];
        SKProduct* product = [OpenSuitPayStore.defaultStore productForIdentifier:channelProductId];
        [[SKProductStorePromotionController defaultController] updateStorePromotionVisibility:visibility ? SKProductStorePromotionVisibilityShow : SKProductStorePromotionVisibilityHide forProduct:product completionHandler:^(NSError * _Nullable error) {
            callback(error == nil, [error description]);
        }];
    } else {
    }
#endif
}

- (void)readyToContinuePurchaseFromPromot:(OpenSuitPayCallback)callback {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        if(self.addedStorePayment){
            NSString* uniformP = [self uniformProductIdWithChannelProductId:self.addedStorePayment.productIdentifier];
            [self paymentWithUniformProductId:uniformP extra:@"" callback:callback];
        } else {
            po.uniformProductId = self.currentUniformProductId;
            po.channelOrderid = @"";
            po.orderId = OpenSuitPayment.shared.itemInfo.orderId;
            po.response = @"";
            po.PayState = PayCannel;
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

- (OpenSuitProduct*)promotionProduct {
    if (self.addedStorePayment) {
        NSString* uniformProductId = [[self productWithChannelProductId:self.addedStorePayment.productIdentifier] uniformProductId];
        OpenSuitProduct* product = [productInfos objectForKey:uniformProductId];
        return product;
    }
    return nil;
}

- (NSString *)uniformProductIdWithChannelProductId:(NSString *)channelProductId {
    return [self productWithChannelProductId:channelProductId].uniformProductId? :@"";
}

- (OpenSuitProduct*)productWithChannelProductId:(NSString*)channelProductId {
    NSArray* allProduct = [productInfos allValues];
    for (OpenSuitProduct *productInfo in allProduct) {
        if ([productInfo.channelProductId isEqualToString:channelProductId]) {
            return productInfo;
        }
    }
    return nil;
}

- (void)updateProductInfo:(NSArray *)products {
    for (NSString* uniformProductId in [productInfos allKeys]) {
        OpenSuitProduct* product = [productInfos objectForKey:uniformProductId];
        for (SKProduct* sk in products) {
            if ([sk.productIdentifier isEqualToString:product.channelProductId]) {
                product.productName = sk.localizedTitle;
                product.channelProductId = sk.productIdentifier;
                product.productPrice = [sk.price stringValue];
                product.productDescription = sk.localizedDescription;
                product.currency = [OpenSuitCommons currencyCode:sk.priceLocale];
                product.priceDisplay = [self diplayPrice:sk];
                product.periodUnit = [self periodUnitWithProduct:sk];
            }
        }
    }
}

- (NSString *)diplayPrice:(SKProduct *)product {
    return [NSString stringWithFormat:@"%@ %@",[self productPrice:product],[OpenSuitCommons currencyCode:product.priceLocale]];
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
    return [OpenSuitCommons localizedString:@"OpenSuitPayment"
                                        key:key
                              defaultString:defaultString];
}

- (void)rechargedProuct {
    OpenSuitProduct* product = [productInfos objectForKey:self.currentUniformProductId];
    if (self->persistence) {
        [self->persistence rechargedProuctOfIdentifier:product.channelProductId];
    }
}

#pragma mark- OpenSuitPayStoreObserver
- (void)storePaymentTransactionDeferred:(NSNotification*)notification {
    OpenSuitLog(@"");
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification {
    OpenSuitLog(@"");
    NSString* productIdentifier = notification.rm_productIdentifier;
    if (!productIdentifier) {
        OpenSuitProduct* pr = [productInfos objectForKey:self.currentUniformProductId];
        if (pr.channelProductId) {
            productIdentifier = pr.channelProductId;
        }
    }
    if (productIdentifier) {
        NSString* oldOrderIdStr = [OpenSuitCommons keychainWithService:productIdentifier];
        NSArray* oldOrderId = (NSArray *)[OpenSuitCommons JSONObjectWithString:oldOrderIdStr error:nil];
        NSMutableArray* newOrderId = [NSMutableArray array];
        if (oldOrderId) {
            [newOrderId setArray:oldOrderId];
        }
        for (NSString* oderid in oldOrderId) {
            if ([oderid isEqualToString:OpenSuitPayment.shared.itemInfo.orderId]) {
                [newOrderId removeObject:oderid];
                break;
            }
        }
        NSString* orderidJson = [OpenSuitCommons stringWithJSONObject:newOrderId error:nil];
        [OpenSuitCommons saveKeychainWithService:productIdentifier str:orderidJson];
    }
    
    if (self.OpenSuitPayCallback) {
        NSString* channelOrderid = notification.rm_transaction.transactionIdentifier;
        if (!channelOrderid) {
            channelOrderid = @"";
        }
        po.uniformProductId = self.currentUniformProductId;
        po.channelOrderid = channelOrderid;
        po.orderId = OpenSuitPayment.shared.itemInfo.orderId;
        po.response = @"";
        po.PayState = PaytFail;
        po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                       code:2001
                                   userInfo:@{NSLocalizedDescriptionKey:notification.rm_storeError.localizedDescription? :@""}];
        self.OpenSuitPayCallback(po);
        isBuying = false;
    }
}

- (void)storePaymentTransactionFinished:(NSNotification*)notification {
    if (!self.OpenSuitPayCallback) {
        return;
    }
    NSString* channelOrderid = notification.rm_transaction.transactionIdentifier;
    if (!channelOrderid) {
        channelOrderid = @"";
    }
    OpenSuitProduct* product = [productInfos objectForKey:self.currentUniformProductId];
    NSString* productIdentifier = notification.rm_productIdentifier;
    if (!productIdentifier) {
        productIdentifier = product.channelProductId;
    }
    NSString* receipt = [[NSData dataWithContentsOfURL:OpenSuitPayStore.receiptURL] base64EncodedStringWithOptions:0];
    OpenSuitPayment.shared.itemInfo.channelOrderid = channelOrderid;
    OpenSuitPayment.shared.itemInfo.trx_receipt = receipt;
    OpenSuitPayment.shared.itemInfo.productId = productIdentifier;
    if (OpenSuitPayManager.shared.OpenSuitValidatePaymentBlock) {
        NSDictionary* extra = @{@"productIdentifier":productIdentifier,
                                @"transactionIdentifier":channelOrderid,
                                @"transactionReceipt":receipt};
        NSString* extraSt = [OpenSuitCommons stringWithJSONObject:extra error:nil];
        OpenSuitPayManager.shared.OpenSuitValidatePaymentBlock(product.uniformProductId,extraSt);
    }
    
    Class thinkingClass = NSClassFromString(@"OpenSuitAnalyticsManager");
    if (thinkingClass && [thinkingClass respondsToSelector:@selector(sharedInstance)]) {
        OpenSuitAnalyticsManager *sdk = [thinkingClass sharedInstance];
        if (sdk && [sdk respondsToSelector:@selector(validateAndTrackInAppPurchase:price:currency:transactionId:)]) {
            [sdk validateAndTrackInAppPurchase:productIdentifier
                                         price:product.productPrice
                                      currency:product.currency
                                 transactionId:channelOrderid];
        }
    }
    
    //Swrve 统计
    SKProduct* skp = [OpenSuitPayStore.defaultStore productForIdentifier:productIdentifier];
    
    if (thinkingClass && [thinkingClass respondsToSelector:@selector(sharedInstance)]) {
        OpenSuitAnalyticsManager *sdk = [thinkingClass sharedInstance];
        if (sdk && [sdk respondsToSelector:@selector(swrveTransactionProcessed:productBought:)]) {
            [sdk swrveTransactionProcessed:notification.rm_transaction
                             productBought:skp];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [OpenSuitPayment.shared verifyAppStoreIAPOrder:OpenSuitPayment.shared.itemInfo
                                          callback:^(BOOL verifySuccess, NSString * _Nonnull response, NSError * _Nonnull error) {
        NSDictionary* respo = [OpenSuitCommons JSONObjectWithString:response error:nil];
        NSString* orderId = @"";
        NSString* itemCode = @"";
        int error_code = -1;
        if (respo) {
            orderId = [respo objectForKey:@"orderid"];
            error_code = [[respo objectForKey:@"error_code"]intValue];
            itemCode = [respo objectForKey:@"item_code"];
        }
        OpenSuitLog(@"error_code:%d",error_code);
        if (verifySuccess) {
            if (weakSelf.OpenSuitPayCallback) {
                self->po.uniformProductId = weakSelf.currentUniformProductId;
                self->po.channelOrderid = OpenSuitPayment.shared.itemInfo.channelOrderid;
                self->po.orderId = orderId;
                self->po.response = response;
                self->po.PayState = PaySuccess;
                weakSelf.OpenSuitPayCallback(self->po);
            }
            [self->persistence consumeProductOfIdentifier:itemCode];
        } else {
            if (error_code == 20) {
                [self->persistence consumeProductOfIdentifier:itemCode];
            }
            if (weakSelf.OpenSuitPayCallback) {
                self->po.uniformProductId = weakSelf.currentUniformProductId;
                self->po.channelOrderid = OpenSuitPayment.shared.itemInfo.channelOrderid;
                self->po.orderId = orderId;
                self->po.response = response;
                self->po.PayState = PaytFail;
                self->po.error = [NSError errorWithDomain:@"com.yodo1.payment"
                                                     code:2
                                                 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
                weakSelf.OpenSuitPayCallback(self->po);
            }
        }
        self->isBuying = false;
    }];
}

- (void)storeProductsRequestFailed:(NSNotification*)notification {
    OpenSuitLog(@"%@",notification.rm_storeError);
}

- (void)storeProductsRequestFinished:(NSNotification*)notification {
    OpenSuitLog(@"");
    NSArray *products = notification.rm_products;
    [self updateProductInfo:products];
}

- (void)storeRefreshReceiptFailed:(NSNotification*)notification {
    OpenSuitLog(@"");
}

- (void)storeRefreshReceiptFinished:(NSNotification*)notification {
    OpenSuitLog(@"");
}

- (void)storeRestoreTransactionsFailed:(NSNotification*)notification {
    OpenSuitLog(@"");
}

- (void)storeRestoreTransactionsFinished:(NSNotification*)notification {
    OpenSuitLog(@"");
}

- (void)storePromotionPaymentFinished:(NSNotification *)notification {
    OpenSuitLog(@"");
    self.addedStorePayment = notification.rm_payment;
}

@end

#pragma mark -   Unity3d 接口

#ifdef __cplusplus

extern "C" {

void unity_StartOpenSuitPayWithAppKey(const char* appKey,const char* channelId)
{
    NSString* _appKey = Yodo1CreateNSString(appKey);
    NSString* _channelId = Yodo1CreateNSString(channelId);
    [OpenSuitPayManager.shared startOpenSuitPayWithAppKey:_appKey
                                                channelId:_channelId];
}

void unity_SubmitUser(const char* jsonUser)
{
    NSString* _jsonUser = Yodo1CreateNSString(jsonUser);
    NSDictionary* user = [OpenSuitCommons JSONObjectWithString:_jsonUser error:nil];
    if (user) {
        NSString* playerId = [user objectForKey:@"playerId"];
        NSString* nickName = [user objectForKey:@"nickName"];
        OpenSuitPayManager.shared.user.playerid = playerId;
        OpenSuitPayManager.shared.user.nickname = nickName;
        [OpenSuitCommons.cached setObject:OpenSuitPayManager.shared.user
                                   forKey:@"yd1User"];
        OpenSuitLog(@"playerId:%@",playerId);
        OpenSuitLog(@"nickName:%@",nickName);
    } else {
        OpenSuitLog(@"user is not submit!");
    }
}

/**
 *设置ops 环境
 */
void unity_APIEnvironment(int env)
{
}

/**
 *设置是否显示log
 */
void unity_LogEnabled(BOOL enable)
{
    
}

void unity_GameUserId(const char* gameUserId)
{
    
}

void unity_GameNickname(const char* gameNickname)
{
    
}

/**
 *获取版本更新信息
 */
void unity_GetUpdateInfoWithAppKey(const char*gameAppkey,const char* channelCode,const char* gameObjectName, const char* methodName)
{

}

#pragma mark- 购买
/**
 *查询漏单
 */
void unity_QueryLossOrder(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    
    [OpenSuitPayManager.shared queryLossOrder:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_LossOrderIdQuery] forKey:@"resulType"];
                if([productIds count] > 0 ){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    [dict setObject:productIds forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_LossOrderIdQuery] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
        });
    }];
}

void unity_CancelPromotion(const char* gameObjectName, const char* methodName)
{
    [OpenSuitPayManager.shared cancelPromotion];
}

void unity_GetPromotionProduct(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    OpenSuitProduct* product = [OpenSuitPayManager.shared promotionProduct];
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
            [dict setObject:[NSNumber numberWithInt:product.openSuitProductType] forKey:@"OpenSuitProductType"];
        }
        [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_GetPromotionProduct] forKey:@"resulType"];
        [dict setObject:[NSNumber numberWithInt:product==nil ? 0 : 1] forKey:@"code"];
        
        NSError* parseJSONError = nil;
        NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
        if(parseJSONError){
            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
            msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
        }
        UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                         [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                         [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

void unity_ReadyToContinuePurchaseFromPromotion(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    
    [OpenSuitPayManager.shared readyToContinuePurchaseFromPromot:^(OpenSuitPayObject * _Nonnull payemntObject) {
        if (payemntObject.PayState == PaySuccess) {
            OpenSuitPayment.shared.itemInfo.orderId = payemntObject.orderId;
            OpenSuitPayment.shared.itemInfo.extra = @"";
            [OpenSuitPayment.shared clientCallback:OpenSuitPayment.shared.itemInfo
                                          callbakc:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    OpenSuitLog(@"上报成功");
                } else {
                    OpenSuitLog(@"上报失败");
                }
            }];
            ///同步信息
            [OpenSuitPayment.shared clientNotifyForSyncUnityStatus:@[payemntObject.orderId]
                                                          callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                if (success) {
                    OpenSuitLog(@"同步信息成功");
                } else {
                    OpenSuitLog(@"同步信息失败:%@",error);
                }
                OpenSuitLog(@"notExistOrders:%@,notPayOrders:%@",
                            notExistOrders,notPayOrders);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(ocGameObjName && ocMethodName){
                        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                        [dict setObject:payemntObject.uniformProductId ? :@"" forKey:@"uniformProductId"];
                        [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
                        [dict setObject:[NSNumber numberWithInt:(int)payemntObject.PayState] forKey:@"code"];
                        [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                        [dict setObject:@"extra" forKey:@"extra"];
                        [dict setObject:payemntObject.channelOrderid ? :@"" forKey:@"channelOrderid"];
                        
                        NSError* parseJSONError = nil;
                        NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                        if(parseJSONError){
                            [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
                            [dict setObject:[NSNumber numberWithInt:(int)payemntObject.PayState] forKey:@"code"];
                            [dict setObject:payemntObject.response? :@"" forKey:@"data"];
                            [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                            [dict setObject:@"extra" forKey:@"extra"];
                            [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                            [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                            msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                        }
                        UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                         [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                         [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                    }
                });
            }];
        } else {
            if ([payemntObject.orderId length] > 0) {
                OpenSuitPayment.shared.itemInfo.channelCode = @"AppStore";
                OpenSuitPayment.shared.itemInfo.channelOrderid = payemntObject.channelOrderid? :@"";
                OpenSuitPayment.shared.itemInfo.orderId = payemntObject.orderId;
                OpenSuitPayment.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",payemntObject.PayState];
                OpenSuitPayment.shared.itemInfo.statusMsg = payemntObject.response? :@"";
                [OpenSuitPayment.shared reportOrderStatus:OpenSuitPayment.shared.itemInfo
                                                 callbakc:^(BOOL success, NSString * _Nonnull error) {
                    if (success) {
                        OpenSuitLog(@"上报失败，成功");
                    } else {
                        OpenSuitLog(@"上报失败");
                    }
                }];
            }
            //失败神策埋点
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:@-1 forKey:@"channelErrorCode"];
            [properties addEntriesFromDictionary:OpenSuitPayManager.shared .superProperty];
            [properties addEntriesFromDictionary:OpenSuitPayManager.shared.itemProperty];
            
            NSNumber* errorCode = [NSNumber numberWithInt:2004];//默认是未知失败
            if (payemntObject.error) {
                errorCode  = [NSNumber numberWithInteger:payemntObject.error.code];
            }
            [properties setObject:errorCode forKey:@"yodo1ErrorCode"];
            OpenSuitLog(@"%@",[OpenSuitCommons stringWithJSONObject:properties error:nil]);
            
            Class thinkingClass = NSClassFromString(@"OpenSuitAnalyticsManager");
            if (thinkingClass && [thinkingClass respondsToSelector:@selector(sharedInstance)]) {
                OpenSuitAnalyticsManager *sdk = [thinkingClass sharedInstance];
                if (sdk && [sdk respondsToSelector:@selector(eventAnalytics:eventData:)]) {
                    [sdk eventAnalytics:@"order_Error_FromSDK" eventData:properties];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ocGameObjName && ocMethodName){
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                    [dict setObject:payemntObject.uniformProductId ? :@"" forKey:@"uniformProductId"];
                    [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:(int)payemntObject.PayState] forKey:@"code"];
                    [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                    [dict setObject:@"extra" forKey:@"extra"];
                    [dict setObject:payemntObject.channelOrderid ? :@"" forKey:@"channelOrderid"];
                    
                    NSError* parseJSONError = nil;
                    NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                    if(parseJSONError){
                        [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                        [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
                        [dict setObject:[NSNumber numberWithInt:(int)payemntObject.PayState] forKey:@"code"];
                        [dict setObject:payemntObject.response? :@"" forKey:@"data"];
                        [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                        [dict setObject:@"extra" forKey:@"extra"];
                        [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                        [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                        msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                    }
                    UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            });
        }
        
    }];
}

void unity_FetchStorePromotionVisibilityForProduct(const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* _uniformProductId = Yodo1CreateNSString(uniformProductId);
    [OpenSuitPayManager.shared fetchStorePayPromotionVisibilityForProduct:_uniformProductId callback:^(PayPromotionVisibility storePayPromotionVisibility, BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_FetchPayPromotionVisibility] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            if(success > 0 ){
                switch(storePayPromotionVisibility){
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
            NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void unity_FetchStorePromotionOrder(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [OpenSuitPayManager.shared fetchStorePromotionOrder:^(NSArray<NSString *> * _Nonnull storePromotionOrder, BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_FetchStorePromotionOrder] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            [dict setObject:storePromotionOrder forKey:@"storePromotionOrder"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void unity_UpdateStorePromotionOrder(const char* productids, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [OpenSuitPayManager.shared updateStorePromotionOrder:[[NSString stringWithUTF8String:productids] componentsSeparatedByString:@","] callback:^(BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_UpdateStorePromotionOrder] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }];
}

void unity_UpdateStorePromotionVisibility(bool visible, const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [OpenSuitPayManager.shared  updateStorePayPromotionVisibility:visible product:[NSString stringWithUTF8String:uniformProductId] callback:^(BOOL success, NSString * _Nonnull error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_UpdateStorePayPromotionVisibility] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:success ? 1 : 0] forKey:@"code"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
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
void unity_QuerySubscriptions(BOOL excludeOldTransactions, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    
    [OpenSuitPayManager.shared querySubscriptions:excludeOldTransactions callback:^(NSArray * _Nonnull subscriptions, NSTimeInterval serverTime, BOOL success, NSString * _Nullable error) {
        if(ocGameObjName && ocMethodName){
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            
            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_QuerySubscriptions] forKey:@"resulType"];
            
            if([subscriptions count] > 0 ){
                NSMutableArray* arrayProduct = [NSMutableArray arrayWithCapacity:1];
                for(int i = 0;i < [subscriptions count]; i++){
                    NSMutableDictionary* dicProduct = [NSMutableDictionary dictionary];
                    PaySubscriptionInfo* info = [subscriptions objectAtIndex:i];
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
            NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_QuerySubscriptions] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
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
void Unity_RestorePayment(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [OpenSuitPayManager.shared restorePayment:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_RestorePayment] forKey:@"resulType"];
                if([productIds count] > 0 ){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    [dict setObject:productIds forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_RestorePayment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
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
void unity_ProductInfoWithProductId(const char* uniformProductId, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* _uniformProductId = Yodo1CreateNSString(uniformProductId);
    [OpenSuitPayManager.shared productWithUniformProductId:_uniformProductId callback:^(NSArray<OpenSuitProduct *> * _Nonnull productInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName) {
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_RequestProductsInfo] forKey:@"resulType"];
                if([productInfo count] > 0){
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    [dict setObject:productInfo forKey:@"data"];
                }else{
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                }
                NSError* parseJSONError = nil;
                NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_RequestProductsInfo] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
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
void unity_ProductsInfo(const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    [OpenSuitPayManager.shared products:^(NSArray<OpenSuitProduct *> * _Nonnull productInfo) {
        if(ocGameObjName && ocMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_RequestProductsInfo] forKey:@"resulType"];
            if([productInfo count] > 0){
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                [dict setObject:productInfo forKey:@"data"];
            }else{
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            }
            NSError* parseJSONError = nil;
            NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_RequestProductsInfo] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
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
void unity_PayNetGame(const char* mUniformProductId,const char* extra, const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* _uniformProductId = Yodo1CreateNSString(mUniformProductId);
    NSString* _extra = Yodo1CreateNSString(extra);
    
    [OpenSuitPayManager.shared paymentWithUniformProductId:_uniformProductId
                                                     extra:_extra
                                                  callback:^(OpenSuitPayObject * _Nonnull payemntObject) {
        if (payemntObject.PayState == PaySuccess) {
            OpenSuitPayment.shared.itemInfo.orderId = payemntObject.orderId;
            OpenSuitPayment.shared.itemInfo.extra = _extra? :@"";
            [OpenSuitPayment.shared clientCallback:OpenSuitPayment.shared.itemInfo
                                          callbakc:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    OpenSuitLog(@"上报成功");
                } else {
                    OpenSuitLog(@"上报失败:%@",error);
                }
            }];
            ///同步信息
            [OpenSuitPayment.shared clientNotifyForSyncUnityStatus:@[payemntObject.orderId]
                                                          callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                if (success) {
                    OpenSuitLog(@"同步信息成功");
                } else {
                    OpenSuitLog(@"同步信息失败:%@",error);
                }
                OpenSuitLog(@"notExistOrders:%@,notPayOrders:%@",
                            notExistOrders,notPayOrders);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(ocGameObjName && ocMethodName){
                        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                        [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                        [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
                        [dict setObject:[NSNumber numberWithInt:(int)payemntObject.PayState] forKey:@"code"];
                        [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                        [dict setObject:_extra? :@"" forKey:@"extra"];
                        [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                        
                        NSError* parseJSONError = nil;
                        NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                        if(parseJSONError){
                            [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                            [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
                            [dict setObject:[NSNumber numberWithInt:(int)payemntObject.PayState] forKey:@"code"];
                            [dict setObject:payemntObject.response? :@"" forKey:@"data"];
                            [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                            [dict setObject:_extra? :@"" forKey:@"extra"];
                            [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                            [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                            msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                        }
                        UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                         [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                         [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                    }
                });
            }];
        } else {
            if ([payemntObject.orderId length] > 0) {
                OpenSuitPayment.shared.itemInfo.channelCode = @"AppStore";
                OpenSuitPayment.shared.itemInfo.channelOrderid = payemntObject.channelOrderid? :@"";
                OpenSuitPayment.shared.itemInfo.orderId = payemntObject.orderId;
                OpenSuitPayment.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",payemntObject.PayState];
                OpenSuitPayment.shared.itemInfo.statusMsg = payemntObject.response? :@"";
                [OpenSuitPayment.shared reportOrderStatus:OpenSuitPayment.shared.itemInfo
                                                 callbakc:^(BOOL success, NSString * _Nonnull error) {
                    if (success) {
                        OpenSuitLog(@"上报失败，成功");
                    } else {
                        OpenSuitLog(@"上报失败");
                    }
                }];
            }
            //失败神策埋点
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:@-1 forKey:@"channelErrorCode"];
            [properties addEntriesFromDictionary:OpenSuitPayManager.shared .superProperty];
            [properties addEntriesFromDictionary:OpenSuitPayManager.shared.itemProperty];
            
            NSNumber* errorCode = [NSNumber numberWithInt:2004];//默认是未知失败
            if (payemntObject.error) {
                errorCode  = [NSNumber numberWithInteger:payemntObject.error.code];
            }
            [properties setObject:errorCode forKey:@"yodo1ErrorCode"];
            OpenSuitLog(@"%@",[OpenSuitCommons stringWithJSONObject:properties error:nil]);
            Class thinkingClass = NSClassFromString(@"OpenSuitAnalyticsManager");
            if (thinkingClass && [thinkingClass respondsToSelector:@selector(sharedInstance)]) {
                OpenSuitAnalyticsManager *sdk = [thinkingClass sharedInstance];
                if (sdk && [sdk respondsToSelector:@selector(eventAnalytics:eventData:)]) {
                    [sdk eventAnalytics:@"order_Error_FromSDK" eventData:properties];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ocGameObjName && ocMethodName){
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                    [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                    [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:(int)payemntObject.PayState] forKey:@"code"];
                    [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                    [dict setObject:_extra? :@"" forKey:@"extra"];
                    [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                    
                    NSError* parseJSONError = nil;
                    NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                    if(parseJSONError){
                        [dict setObject:payemntObject.uniformProductId? :@"" forKey:@"uniformProductId"];
                        [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_Payment] forKey:@"resulType"];
                        [dict setObject:[NSNumber numberWithInt:(int)payemntObject.PayState] forKey:@"code"];
                        [dict setObject:payemntObject.response? :@"" forKey:@"data"];
                        [dict setObject:payemntObject.orderId? :@"" forKey:@"orderId"];
                        [dict setObject:_extra? :@"" forKey:@"extra"];
                        [dict setObject:payemntObject.channelOrderid? :@"" forKey:@"channelOrderid"];
                        [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                        msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                    }
                    UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            });
        }
    }];
    [OpenSuitPayManager.shared setOpenSuitValidatePaymentBlock:^(NSString * _Nonnull uniformProductId, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:(_uniformProductId? :@"") forKey:@"uniformProductId"];
                [dict setObject:(response? :@"") forKey:@"response"];
                [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_ValidatePayment] forKey:@"resulType"];
                NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:nil];
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
void unity_SendGoodsOver(const char* orders,const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* ocOrders = Yodo1CreateNSString(orders);
    [OpenSuitPayment.shared sendGoodsOver:ocOrders callback:^(BOOL success, NSString * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                
                [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_SendGoodsOver] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:success?1:0] forKey:@"code"];
                [dict setObject:(error == nil?@"":error) forKey:@"error"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_SendGoodsOver] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithBool:success] forKey:@"code"];
                    [dict setObject:(error == nil?@"":error) forKey:@"error"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            if (success) {
                [OpenSuitPayManager.shared rechargedProuct];
            }
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:success?@"成功":@"失败" forKey:__kStatus];
            [properties addEntriesFromDictionary:OpenSuitPayManager.shared .superProperty];
            [properties addEntriesFromDictionary:OpenSuitPayManager.shared.itemProperty];
            OpenSuitLog(@"%@",[OpenSuitCommons stringWithJSONObject:properties error:nil]);
            
            Class thinkingClass = NSClassFromString(@"OpenSuitAnalyticsManager");
            if (thinkingClass && [thinkingClass respondsToSelector:@selector(sharedInstance)]) {
                OpenSuitAnalyticsManager *sdk = [thinkingClass sharedInstance];
                if (sdk && [sdk respondsToSelector:@selector(eventAnalytics:eventData:)]) {
                    [sdk eventAnalytics:@"order_Item_Delivered" eventData:properties];
                }
            }
            
        });
    }];
}

/**
 *  购买成功发货通知失败
 */
void unity_SendGoodsOverFault(const char* orders,const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* ocOrders = Yodo1CreateNSString(orders);
    [OpenSuitPayment.shared sendGoodsOverForFault:ocOrders
                                         callback:^(BOOL success, NSString * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                
                [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_SendGoodsOverFault] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:success?1:0] forKey:@"code"];
                [dict setObject:(error == nil?@"":error) forKey:@"error"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:OpenSuitPayResulType_SendGoodsOverFault] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithBool:success] forKey:@"code"];
                    [dict setObject:(error == nil?@"":error) forKey:@"error"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [OpenSuitCommons stringWithJSONObject:dict error:&parseJSONError];
                }
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        });
    }];
}

}

#endif
