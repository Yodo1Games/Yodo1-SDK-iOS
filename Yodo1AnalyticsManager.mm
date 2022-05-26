//
//  Yodo1AnalyticsManager.m
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1AnalyticsManager.h"
#import "Yodo1Registry.h"
#import "AnalyticsAdapter.h"
#import "Yodo1Commons.h"
#import "Yodo1ClassWrapper.h"
#import "Yodo1UnityTool.h"

#define Yodo1OpenUrl        @"Yodo1OpenUrl"
#define Yodo1UserActivity   @"Yodo1UserActivity"

@implementation AnalyticsInitConfig


@end

@interface Yodo1AnalyticsManager ()
{
    BOOL bAppsFlyerOpen;
    BOOL bThinkingOpen;
}

@property (nonatomic, strong) NSMutableDictionary* analyticsDict;
@property (nonatomic, strong) NSMutableDictionary* trackPropertys;

///获取一个随机整数范围在[from,to]
- (int)randomNumber:(int)from to:(int)to;

@end

@implementation Yodo1AnalyticsManager

static BOOL _enable = NO;
static BOOL _bInit_ = NO;

+(BOOL)isEnable {
    return _enable;
}

+ (Yodo1AnalyticsManager *)sharedInstance
{
    static Yodo1AnalyticsManager* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1AnalyticsManager alloc]init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _analyticsDict = [[NSMutableDictionary alloc] init];
        _trackPropertys = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (int)randomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

- (void)initializeAnalyticsWithConfig:(AnalyticsInitConfig*)initConfig
{
    if (_bInit_) {
        return;
    }
    _bInit_ = YES;
     
    bAppsFlyerOpen = YES;
    bThinkingOpen = YES;
    
    NSDictionary* dic = [[Yodo1Registry sharedRegistry] getClassesStatusType:@"analyticsType"
                                                              replacedString:@"AnalyticsAdapter"
                                                               replaceString:@"AnalyticsType"];
    if (dic) {
        NSArray* keyArr = [dic allKeys];
        
        for (id key in keyArr) {
            
            if (!bAppsFlyerOpen && [key integerValue] == AnalyticsTypeAppsFlyer) {
                continue;
            }
            
            if (!bThinkingOpen && [key integerValue] == AnalyticsTypeThinking) {
                continue;
            }
            
            Class adapter = [[[Yodo1Registry sharedRegistry] adapterClassFor:[key integerValue] classType:@"analyticsType"] theYodo1Class];
            AnalyticsAdapter* advideoAdapter = [[adapter alloc] initWithAnalytics:initConfig];
            NSNumber* adVideoOrder = [NSNumber numberWithInt:[key intValue]];
            [self.analyticsDict setObject:advideoAdapter forKey:adVideoOrder];
        }
    }
    _enable = self.analyticsDict.count;
}

- (void)eventAnalytics:(NSString *)eventName
             eventData:(NSDictionary *)eventData

{
    if (eventName == nil) {
        NSAssert(eventName != nil, @"eventName cannot nil!");
    }
    
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter eventWithAnalyticsEventName:eventName eventData:eventData];
    }
}

- (void)eventAppsFlyerAnalyticsWithName:(NSString *)eventName
                       eventData:(NSDictionary *)eventData
{
    if (eventName == nil) {
        NSAssert(eventName != nil, @"eventName cannot nil!");
    }
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==AnalyticsTypeAppsFlyer){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter eventAppsFlyerAnalyticsWithName:eventName eventData:eventData];
            break;
        }
    }
}

- (void)startLevelAnalytics:(NSString*)level
{
    if (!level) {
        return;
    }
    
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter startLevelAnalytics:level];
    }
}

- (void)finishLevelAnalytics:(NSString*)level
{
    if (!level) {
        return;
    }
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter finishLevelAnalytics:level];
    }
}

- (void)failLevelAnalytics:(NSString*)level failedCause:(NSString*)cause
{
    if (!level) {
        return;
    }
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter failLevelAnalytics:level failedCause:cause];
    }
}

- (void)userLevelIdAnalytics:(int)level
{
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter userLevelIdAnalytics:level];
    }
}

- (void)chargeRequstAnalytics:(NSString*)orderId
                        iapId:(NSString*)iapId
               currencyAmount:(double)currencyAmount
                 currencyType:(NSString *)currencyType
        virtualCurrencyAmount:(double)virtualCurrencyAmount
                  paymentType:(NSString *)paymentType
{
    if (currencyAmount < 0 ) {
        currencyAmount = 0;
    }
    
    if (virtualCurrencyAmount < 0) {
        virtualCurrencyAmount = 0;
    }
    
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter chargeRequstAnalytics:orderId
                                 iapId:iapId
                        currencyAmount:currencyAmount
                          currencyType:currencyType
                 virtualCurrencyAmount:virtualCurrencyAmount
                           paymentType:paymentType
         ];
    }
}

- (void)chargeSuccessAnalytics:(NSString *)orderId source:(int)source;
{
    
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter chargeSuccessAnalytics:orderId source:source];
    }
}


- (void)rewardAnalytics:(double)virtualCurrencyAmount reason:(NSString *)reason source:(int)source;
{
    if (virtualCurrencyAmount < 0) {
        virtualCurrencyAmount = 0;
    }
    
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter rewardAnalytics:virtualCurrencyAmount reason:reason source:source];
    }
}

- (void)purchaseAnalytics:(NSString *)item itemNumber:(int)number priceInVirtualCurrency:(double)price
{
    if (number < 0) {
        number = 0;
    }
    if (price < 0) {
        price = 0;
    }
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter purchaseAnalytics:item itemNumber:number priceInVirtualCurrency:price];
    }
}


- (void)useAnalytics:(NSString *)item amount:(int)amount price:(double)price;
{
    if (amount < 0) {
        amount = 0;
    }
    if (price < 0) {
        price = 0;
    }
    for (id key in [self.analyticsDict allKeys]) {
        AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter useAnalytics:item amount:amount price:price];
    }
}

- (void)registerSuperProperty:(NSDictionary *)property
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == AnalyticsTypeThinking){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter registerSuperProperty:property];
            break;
        }
    }
}

- (void)unregisterSuperProperty:(NSString *)propertyName
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == AnalyticsTypeThinking){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter unregisterSuperProperty:propertyName];
            break;
        }
    }
}

- (NSDictionary *)getSuperProperties
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == AnalyticsTypeThinking){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            return [adapter getSuperProperties];
        }
    }
    return nil;
}

- (void)clearSuperProperties
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == AnalyticsTypeThinking){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter clearSuperProperties];
            break;
        }
    }
}

- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==AnalyticsTypeAppsFlyer){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter validateAndTrackInAppPurchase:productIdentifier
                                             price:price
                                          currency:currency
                                     transactionId:transactionId];
            break;
        }
    }
}

/**
 *  AppsFlyer Apple 内付费使用自定义事件上报
 */
- (void)eventAndTrackInAppPurchase:(NSString*)revenue
                          currency:(NSString*)currency
                          quantity:(NSString*)quantity
                         contentId:(NSString*)contentId
                         receiptId:(NSString*)receiptId {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==AnalyticsTypeAppsFlyer){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter eventAndTrackInAppPurchase:revenue
                                       currency:currency
                                       quantity:quantity
                                      contentId:contentId
                                      receiptId:receiptId];
            break;
        }
    }
}

/**
 *  订阅openURL
 *
 *  @param url                    生命周期中的openurl
 *  @param options           生命周期中的options
 */
- (void)handleOpenUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (url) {
        [dict setObject:url forKey:@"url"];
    } else {
        [dict setObject:[NSNumber numberWithBool:false] forKey:@"url"];
    }
    if (options) {
        [dict setObject:options forKey:@"options"];
    } else {
        [dict setObject:[NSNumber numberWithBool:false] forKey:@"options"];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:Yodo1OpenUrl object:self userInfo:dict];
    });
    
    
}

/**
 *  订阅continueUserActivity
 *
 *  @param userActivity                    生命周期中的userActivity
 */
- (void)continueUserActivity:(nonnull NSUserActivity *)userActivity {
    
    NSDictionary *dict = [NSDictionary dictionary];
    dict = @{@"userActivity":userActivity};
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:Yodo1UserActivity object:self userInfo:dict];
    });
}

- (void)dealloc
{
    self.analyticsDict = nil;
    self.trackPropertys = nil;
}



#ifdef __cplusplus

extern "C" {
    
    /** 自定义事件,数量统计.
     友盟：使用前，请先到友盟App管理后台的设置->编辑自定义事件
     中添加相应的事件ID，然后在工程中传入相应的事件ID
     TalkingData:
     同道：
     */
    void UnityEventWithJson(const char* eventId, const char* jsonData)
    {
        NSString* eventData = Yodo1CreateNSString(jsonData);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[Yodo1AnalyticsManager sharedInstance]eventAnalytics:Yodo1CreateNSString(eventId)
                                                    eventData:eventDataDic];
    }
    
    void UnityStartLevelAnalytics(const char* level)
    {
        [[Yodo1AnalyticsManager sharedInstance]startLevelAnalytics:Yodo1CreateNSString(level)];
    }
    
    void UnityFinishLevelAnalytics(const char* level)
    {
        [[Yodo1AnalyticsManager sharedInstance]finishLevelAnalytics:Yodo1CreateNSString(level)];
    }
    
    void UnityFailLevelAnalytics(const char* level,const char* cause)
    {
        [[Yodo1AnalyticsManager sharedInstance]failLevelAnalytics:Yodo1CreateNSString(level)
                                                      failedCause:Yodo1CreateNSString(cause)];
    }
    
    void UnityUserLevelIdAnalytics(int level)
    {
        [[Yodo1AnalyticsManager sharedInstance]userLevelIdAnalytics:level];
    }
    
    void UnityChargeRequstAnalytics(const char* orderId,
                                    const char* iapId,
                                    double currencyAmount,
                                    const char* currencyType,
                                    double virtualCurrencyAmount,
                                    const char* paymentType)
    {
        [[Yodo1AnalyticsManager sharedInstance]chargeRequstAnalytics:Yodo1CreateNSString(orderId)
                                                               iapId:Yodo1CreateNSString(iapId)
                                                      currencyAmount:currencyAmount
                                                        currencyType:Yodo1CreateNSString(currencyType)
                                               virtualCurrencyAmount:virtualCurrencyAmount
                                                         paymentType:Yodo1CreateNSString(paymentType)];
    }
    
    void UnityChargeSuccessAnalytics(const char* orderId,int source)
    {
        [[Yodo1AnalyticsManager sharedInstance]chargeSuccessAnalytics:Yodo1CreateNSString(orderId) source:source];
    }
    
    void UnityRewardAnalytics(double virtualCurrencyAmount,const char* reason ,int source)
    {
        [[Yodo1AnalyticsManager sharedInstance]rewardAnalytics:virtualCurrencyAmount
                                                        reason:Yodo1CreateNSString(reason)
                                                        source:source];
    }
    
    void UnityPurchaseAnalytics(const char* item,int number,double price)
    {
        [[Yodo1AnalyticsManager sharedInstance]purchaseAnalytics:Yodo1CreateNSString(item)
                                                      itemNumber:number
                                          priceInVirtualCurrency:price];
    }
    
    void UnityUseAnalytics(const char* item,int amount,double price)
    {
        [[Yodo1AnalyticsManager sharedInstance]useAnalytics:Yodo1CreateNSString(item)
                                                     amount:amount
                                                      price:price];
        
    }
    
#pragma mark - DplusMobClick
    
     #pragma mark - AppsFlyer
    // AppsFlyer
    void UnityValidateAndTrackInAppPurchase(const char*productIdentifier,
                                            const char*price,
                                            const char*currency,
                                            const char*transactionId){
        [[Yodo1AnalyticsManager sharedInstance]validateAndTrackInAppPurchase:Yodo1CreateNSString(productIdentifier)
                                                                       price:Yodo1CreateNSString(price)
                                                                    currency:Yodo1CreateNSString(currency)
                                                               transactionId:Yodo1CreateNSString(transactionId)];
    }
    
    // AppsFlyer
    void UnityEventAndTrackInAppPurchase(const char*revenue,
                                            const char*currency,
                                            const char*quantity,
                                            const char*contentId,
                                            const char*receiptId){
        
        [[Yodo1AnalyticsManager sharedInstance] eventAndTrackInAppPurchase:Yodo1CreateNSString(revenue)
                                                                  currency:Yodo1CreateNSString(currency)
                                                                  quantity:Yodo1CreateNSString(quantity)
                                                                 contentId:Yodo1CreateNSString(contentId)
                                                                 receiptId:Yodo1CreateNSString(receiptId)];
    }
    
    // AppsFlyer Event
    void UnityeventAppsFlyerAnalyticsWithName(const char*eventName, const char* jsonData) {
        NSString* m_EventName = Yodo1CreateNSString(eventName);
        NSString* eventData = Yodo1CreateNSString(jsonData);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[Yodo1AnalyticsManager sharedInstance]eventAppsFlyerAnalyticsWithName:m_EventName eventData:eventDataDic];
    }
    
    // save AppsFlyer deeplink
    void UnitySaveToNativeRuntime(const char*key, const char*valuepairs) {
        
        NSString *keyString = Yodo1CreateNSString(key);
        NSString *valuepairsString = Yodo1CreateNSString(valuepairs);
        
        if ([keyString isEqualToString:@"appsflyer_id"] || [keyString isEqualToString:@"appsflyer_deeplink"]) {
            NSMutableDictionary *msg = [NSMutableDictionary dictionary];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if ([userDefaults objectForKey:@"YODO1AppsFlyerDeeplink"]) {
                msg = [userDefaults objectForKey:@"YODO1AppsFlyerDeeplink"];
                if ([keyString isEqualToString:@"appsflyer_id"]) {
                    [userDefaults setObject:@{keyString: valuepairsString, @"appsflyer_deeplink": msg[@"appsflyer_deeplink"]} forKey:@"YODO1AppsFlyerDeeplink"];
                }
                
                if ([keyString isEqualToString:@"appsflyer_deeplink"]) {
                    [userDefaults setObject:@{keyString: valuepairsString, @"appsflyer_id": msg[@"appsflyer_id"]} forKey:@"YODO1AppsFlyerDeeplink"];
                }
                
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            if (keyString.length > 0 && valuepairsString.length > 0) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:@{keyString: valuepairsString} forKey:[NSString stringWithFormat:@"Yodo1-%@", keyString]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        
    }
    // get AppsFlyer deeplink
    char* UnityGetNativeRuntime(const char*key) {
        NSString *keyString = Yodo1CreateNSString(key);
        if ([keyString isEqualToString:@"appsflyer_id"] || [keyString isEqualToString:@"appsflyer_deeplink"]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"YODO1AppsFlyerDeeplink"]) {
                NSMutableDictionary *deeplinkUrl = [NSMutableDictionary dictionary];
                deeplinkUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"YODO1AppsFlyerDeeplink"];
                NSString *msg = deeplinkUrl[keyString];
                return Yodo1MakeStringCopy(msg.UTF8String);
            } else {
                if (keyString.length > 0 && [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Yodo1-%@", keyString]]) {
                    NSMutableDictionary *deeplinkUrl = [NSMutableDictionary dictionary];
                    deeplinkUrl = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Yodo1-%@", keyString]];
                    NSString *msg = deeplinkUrl[keyString];
                    return Yodo1MakeStringCopy(msg.UTF8String);
                }
            }
        }
        
        return NULL;
    }
}
#endif

@end
