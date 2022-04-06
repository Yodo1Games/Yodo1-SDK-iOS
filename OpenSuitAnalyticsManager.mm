//
//  OpenSuitAnalyticsManager.m
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "OpenSuitAnalyticsManager.h"
#import "Yodo1Registry.h"
#import "OpenSuitAnalyticsAdapter.h"
#import "Yodo1Commons.h"
#import "Yodo1ClassWrapper.h"
#import "Yodo1UnityTool.h"
#import "Yd1OnlineParameter.h"

#define OpenSuitOpenUrl        @"Yodo1OpenUrl"
#define OpenSuitUserActivity   @"Yodo1UserActivity"

@implementation OpenSuitAnalyticsInitConfig


@end

@interface OpenSuitAnalyticsManager ()
{
    BOOL bUmengOpen;
    BOOL bTalkingDataOpen;
    BOOL bGameAnalyticsOpen;
    BOOL bAppsFlyerOpen;
    BOOL bSwrveOpen;
    BOOL bThinkingOpen;
    BOOL bFirebaseOpen;
}

@property (nonatomic, strong) NSMutableDictionary* analyticsDict;
@property (nonatomic, strong) NSMutableDictionary* trackPropertys;

- (NSString*)talkingDataDeviceId;

///获取一个随机整数范围在[from,to]
- (int)randomNumber:(int)from to:(int)to;

@end

@implementation OpenSuitAnalyticsManager

static BOOL _enable = NO;
static BOOL _bInit_ = NO;

+(BOOL)isEnable {
    return _enable;
}

+ (OpenSuitAnalyticsManager *)sharedInstance
{
    static OpenSuitAnalyticsManager* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[OpenSuitAnalyticsManager alloc]init];
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

- (BOOL)isAppsFlyerInstalled {
    return YES;
}

- (void)initializeAnalyticsWithConfig:(OpenSuitAnalyticsInitConfig*)initConfig  
{
    if (_bInit_) {
        return;
    }
    _bInit_ = YES;
    NSString* umengEvent = [Yd1OnlineParameter.shared stringConfigWithKey:@"Platform_Analytics_SwitchUmeng" defaultValue:@"on"];
    if ([umengEvent isEqualToString:@"off"]) {//默认是开着
        bUmengOpen = NO;
    }else{
        bUmengOpen = YES;
    }
    
    NSString* talkingDataEvent = [Yd1OnlineParameter.shared stringConfigWithKey:@"Platform_Analytics_SwitchTalkingData" defaultValue:@"on"];
    if ([talkingDataEvent isEqualToString:@"off"]) {//默认是开着
        bTalkingDataOpen = NO;
    }else{
        bTalkingDataOpen = YES;
    }
    
    NSString* gameAnalyticsEvent = [Yd1OnlineParameter.shared stringConfigWithKey:@"Platform_Analytics_SwitchGameAnalytics" defaultValue:@"on"];
    if ([gameAnalyticsEvent isEqualToString:@"off"]) {//默认是开着
        bGameAnalyticsOpen = NO;
    }else{
        bGameAnalyticsOpen = YES;
    }
    
    NSString* appsFlyerEvent = [Yd1OnlineParameter.shared stringConfigWithKey:@"Platform_Analytics_SwitchAppsFlyer" defaultValue:@"on"];
    if ([appsFlyerEvent isEqualToString:@"off"]) {//默认是开着
        bAppsFlyerOpen = NO;
    }else{
        bAppsFlyerOpen = YES;
    }
    
    NSString* switchEvent = [Yd1OnlineParameter.shared stringConfigWithKey:@"Platform_Analytics_SwitchSwrve" defaultValue:@"on"];
    if ([switchEvent isEqualToString:@"off"]) {//默认是开着
        bSwrveOpen = NO;
    }else{
        bSwrveOpen = YES;
    }
    
    NSString* thinkingEvent = [Yd1OnlineParameter.shared stringConfigWithKey:@"Platform_Analytics_SwitchThinking" defaultValue:@"on"];
    if ([thinkingEvent isEqualToString:@"off"]) {//默认是开着
        bThinkingOpen = NO;
    }else{
        bThinkingOpen = YES;
    }
    
    NSString* firebaseEvent = [Yd1OnlineParameter.shared stringConfigWithKey:@"Platform_Analytics_SwitchFirebase" defaultValue:@"on"];
    if ([firebaseEvent isEqualToString:@"off"]) {//默认是开着
        bFirebaseOpen= NO;
    }else{
        bFirebaseOpen = YES;
    }
    
    NSDictionary* dic = [[Yodo1Registry sharedRegistry] getClassesStatusType:@"analyticsType"
                                                              replacedString:@"analyticsAdapter"
                                                               replaceString:@"analyticsType"];
    if (dic) {
        NSArray* keyArr = [dic allKeys];
        //优先初始化Swrve
        BOOL isHaveSwrve = false;
        for (id key1 in keyArr) {
            if (bSwrveOpen && [key1 integerValue] == OpenSuitAnalyticsTypeSwrve) {
                Class adapter = [[[Yodo1Registry sharedRegistry] adapterClassFor:[key1 integerValue] classType:@"analyticsType"] theYodo1Class];
                OpenSuitAnalyticsAdapter* advideoAdapter = [[adapter alloc] initWithAnalytics:initConfig];
                NSNumber* adVideoOrder = [NSNumber numberWithInt:[key1 intValue]];
                [self.analyticsDict setObject:advideoAdapter forKey:adVideoOrder];
                isHaveSwrve = true;
            }
        }
        
        for (id key in keyArr) {
            if (!bTalkingDataOpen && [key integerValue] == OpenSuitAnalyticsTypeTalkingData) {
                continue;
            }
            if (!bGameAnalyticsOpen && [key integerValue] == OpenSuitAnalyticsTypeGameAnalytics) {
                continue;
            }
            if (!bUmengOpen && [key integerValue] == OpenSuitAnalyticsTypeUmeng) {
                continue;
            }
            if (!bAppsFlyerOpen && [key integerValue] == OpenSuitAnalyticsTypeAppsFlyer) {
                continue;
            }
            if (!bSwrveOpen && [key integerValue] == OpenSuitAnalyticsTypeSwrve) {
                continue;
            }
            if (!bThinkingOpen && [key integerValue] == OpenSuitAnalyticsTypeThinking) {
                continue;
            }
            if (!bFirebaseOpen && [key integerValue] == OpenSuitAnalyticsTypeFirebase) {
                continue;
            }
            //跳过Swrve
            if (isHaveSwrve && [key integerValue] == OpenSuitAnalyticsTypeSwrve) {
                continue;
            }
            
            Class adapter = [[[Yodo1Registry sharedRegistry] adapterClassFor:[key integerValue] classType:@"analyticsType"] theYodo1Class];
            OpenSuitAnalyticsAdapter* advideoAdapter = [[adapter alloc] initWithAnalytics:initConfig];
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
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter eventWithAnalyticsEventName:eventName eventData:eventData];
    }
}

- (void)eventAdAnalyticsWithName:(NSString *)eventName 
                       eventData:(NSDictionary *)eventData
{
    if (eventName == nil) {
        NSAssert(eventName != nil, @"eventName cannot nil!");
    }
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeAppsFlyer){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter eventAdAnalyticsWithName:eventName eventData:eventData];
            break;
        }
    }
}
- (void)beginEvent:(NSString *)eventId {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeAppsFlyer){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter beginEvent:eventId];
            break;
        }
    }
}

- (void)endEvent:(NSString *)eventId {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeAppsFlyer){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter endEvent:eventId];
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
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter startLevelAnalytics:level];
    }
}

- (void)finishLevelAnalytics:(NSString*)level
{
    if (!level) {
        return;
    }
    for (id key in [self.analyticsDict allKeys]) {
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter finishLevelAnalytics:level];
    }
}

- (void)failLevelAnalytics:(NSString*)level failedCause:(NSString*)cause
{
    if (!level) {
        return;
    }
    for (id key in [self.analyticsDict allKeys]) {
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter failLevelAnalytics:level failedCause:cause];
    }
}

- (void)userLevelIdAnalytics:(int)level
{
    for (id key in [self.analyticsDict allKeys]) {
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
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
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
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
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter chargeSuccessAnalytics:orderId source:source];
    }
}


- (void)rewardAnalytics:(double)virtualCurrencyAmount reason:(NSString *)reason source:(int)source;
{
    if (virtualCurrencyAmount < 0) {
        virtualCurrencyAmount = 0;
    }
    
    for (id key in [self.analyticsDict allKeys]) {
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
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
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
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
        OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
        [adapter useAnalytics:item amount:amount price:price];
    }
}

- (NSString*)talkingDataDeviceId
{
    NSString* deviceId = nil;
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeTalkingData){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            deviceId = [adapter talkingDataDeviceId];
            break;
        }
    }
    return deviceId;
}

- (void)track:(NSString *)eventName
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == OpenSuitAnalyticsTypeUmeng || _key == OpenSuitAnalyticsTypeThinking){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter track:eventName];
            break;
        }
    }
}

-(void)saveTrackWithEventName:(NSString *)eventName
                  propertyKey:(NSString *)propertyKey
                propertyValue:(NSString *)propertyValue
{
    if (eventName == nil || propertyKey == nil || propertyValue == nil) {
        return;
    }
    NSMutableDictionary * propertys = [NSMutableDictionary dictionaryWithCapacity:5];
    if ([[self.trackPropertys allKeys]containsObject:eventName]) {
        NSDictionary* property = [self.trackPropertys objectForKey:eventName];
        [propertys addEntriesFromDictionary:property];
        if (![[propertys allKeys]containsObject:propertyKey]) {
            [propertys setObject:propertyValue forKey:propertyKey];
        }
    }else{
        [propertys setObject:propertyValue forKey:propertyKey];
    }
    
    [self.trackPropertys setObject:propertys forKey:eventName];
}

- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
              propertyIntValue:(int)propertyValue
{
    if (eventName == nil || propertyKey == nil) {
        return;
    }
    NSMutableDictionary * propertys = [NSMutableDictionary dictionaryWithCapacity:5];
    if ([[self.trackPropertys allKeys]containsObject:eventName]) {
        NSDictionary* property = [self.trackPropertys objectForKey:eventName];
        [propertys addEntriesFromDictionary:property];
        if (![[propertys allKeys]containsObject:propertyKey]) {
            [propertys setObject:[NSNumber numberWithInt:propertyValue] forKey:propertyKey];
        }
    }else{
        [propertys setObject:[NSNumber numberWithInt:propertyValue] forKey:propertyKey];
    }
    
    [self.trackPropertys setObject:propertys forKey:eventName];
}

- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
            propertyFloatValue:(float)propertyValue
{
    if (eventName == nil || propertyKey == nil) {
        return;
    }
    NSMutableDictionary * propertys = [NSMutableDictionary dictionaryWithCapacity:5];
    if ([[self.trackPropertys allKeys]containsObject:eventName]) {
        NSDictionary* property = [self.trackPropertys objectForKey:eventName];
        [propertys addEntriesFromDictionary:property];
        if (![[propertys allKeys]containsObject:propertyKey]) {
            [propertys setObject:[NSNumber numberWithFloat:propertyValue] forKey:propertyKey];
        }
    }else{
        [propertys setObject:[NSNumber numberWithFloat:propertyValue] forKey:propertyKey];
    }
    
    [self.trackPropertys setObject:propertys forKey:eventName];
}


- (void)saveTrackWithEventName:(NSString *)eventName
                   propertyKey:(NSString *)propertyKey
           propertyDoubleValue:(double)propertyValue
{
    if (eventName == nil || propertyKey == nil) {
        return;
    }
    NSMutableDictionary * propertys = [NSMutableDictionary dictionaryWithCapacity:5];
    if ([[self.trackPropertys allKeys]containsObject:eventName]) {
        NSDictionary* property = [self.trackPropertys objectForKey:eventName];
        [propertys addEntriesFromDictionary:property];
        if (![[propertys allKeys]containsObject:propertyKey]) {
            [propertys setObject:[NSNumber numberWithDouble:propertyValue] forKey:propertyKey];
        }
    }else{
        [propertys setObject:[NSNumber numberWithDouble:propertyValue] forKey:propertyKey];
    }
    
    [self.trackPropertys setObject:propertys forKey:eventName];
}

-(void)submitTrackWithEventName:(NSString *)eventName
{
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeUmeng){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            if ([[self.trackPropertys allKeys]containsObject:eventName]) {
                NSDictionary* property = [self.trackPropertys objectForKey:eventName];
                [adapter track:eventName property:property];
                //remove submit property
                [self.trackPropertys removeObjectForKey:eventName];
            }
            break;
        }
    }
}

- (void)registerSuperProperty:(NSDictionary *)property
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == OpenSuitAnalyticsTypeUmeng || _key == OpenSuitAnalyticsTypeThinking){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter registerSuperProperty:property];
            break;
        }
    }
}

- (void)unregisterSuperProperty:(NSString *)propertyName
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == OpenSuitAnalyticsTypeUmeng || _key == OpenSuitAnalyticsTypeThinking){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter unregisterSuperProperty:propertyName];
            break;
        }
    }
}

- (NSString *)getSuperProperty:(NSString *)propertyName
{
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeUmeng){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            return [adapter getSuperProperty:propertyName];
        }
    }
    return nil;
}


- (NSDictionary *)getSuperProperties
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == OpenSuitAnalyticsTypeUmeng || _key == OpenSuitAnalyticsTypeThinking){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            return [adapter getSuperProperties];
        }
    }
    return nil;
}

- (void)clearSuperProperties
{
    for (id key in [self.analyticsDict allKeys]) {
        NSInteger _key = [key integerValue];
        if (_key == OpenSuitAnalyticsTypeUmeng || _key == OpenSuitAnalyticsTypeThinking){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter clearSuperProperties];
            break;
        }
    }
}

- (void)setGACustomDimension01:(NSString*)dimension01
{
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeGameAnalytics){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter setGACustomDimension01:dimension01];
            break;
        }
    }
}

- (void)setGACustomDimension02:(NSString*)dimension02
{
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeGameAnalytics){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter setGACustomDimension02:dimension02];
            break;
        }
    }
}

- (void)setGACustomDimension03:(NSString*)dimension03
{
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeGameAnalytics){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter setGACustomDimension03:dimension03];
            break;
        }
    }
}

- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeAppsFlyer){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter validateAndTrackInAppPurchase:productIdentifier
                                             price:price
                                          currency:currency
                                     transactionId:transactionId];
            break;
        }
    }
}

- (void)swrveEventAnalyticsWithName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeSwrve){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter swrveEventAnalyticsWithName:eventName eventData:eventData];
            break;
        }
    }
}

- (void)swrveUserUpdate:(NSDictionary *)eventData {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeSwrve){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter swrveUserUpdate:eventData];
            break;
        }
    }
}

- (void)swrveTransactionProcessed:(SKPaymentTransaction*) transaction
                    productBought:(SKProduct*) product {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==OpenSuitAnalyticsTypeSwrve){
            OpenSuitAnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter swrveTransactionProcessed:transaction productBought:product];
            break;
        }
    }
}

/**
 *  订阅openURL
 *
 *  @param application  生命周期中的application
 *  @param url                    生命周期中的openurl
 *  @param options           生命周期中的options
 */
- (void)SubApplication:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (application) {
        [dict setObject:application forKey:@"application"];
    } else {
        [dict setObject:[NSNumber numberWithBool:false] forKey:@"application"];
    }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:OpenSuitOpenUrl object:self userInfo:dict];
}

/**
 *  订阅continueUserActivity
 *
 *  @param application                      生命周期中的application
 *  @param userActivity                    生命周期中的userActivity
 *  @param restorationHandler       生命周期中的restorationHandler
 */

- (void)SubApplication:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    NSDictionary *dict = [NSDictionary dictionary];
    dict = @{@"userActivity":userActivity};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OpenSuitUserActivity object:self userInfo:dict];
}

- (void)dealloc
{
    self.analyticsDict = nil;
    self.trackPropertys = nil;
}



#ifdef __cplusplus

extern "C" {
    
    char* Unity_GetTalkingDataDeviceId()
    {
        const char* deviceId = [[OpenSuitAnalyticsManager sharedInstance]talkingDataDeviceId].UTF8String;
        return Yodo1MakeStringCopy(deviceId);
    }
    /** 自定义事件,数量统计.
     友盟：使用前，请先到友盟App管理后台的设置->编辑自定义事件
     中添加相应的事件ID，然后在工程中传入相应的事件ID
     TalkingData:
     同道：
     */
    void Unity_EventWithJson(const char* eventId, const char* jsonData)
    {
        NSString* eventData = Yodo1CreateNSString(jsonData);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[OpenSuitAnalyticsManager sharedInstance]eventAnalytics:Yodo1CreateNSString(eventId)
                                                    eventData:eventDataDic];
    }
    
    void Unity_StartLevelAnalytics(const char* level)
    {
        [[OpenSuitAnalyticsManager sharedInstance]startLevelAnalytics:Yodo1CreateNSString(level)];
    }
    
    void Unity_FinishLevelAnalytics(const char* level)
    {
        [[OpenSuitAnalyticsManager sharedInstance]finishLevelAnalytics:Yodo1CreateNSString(level)];
    }
    
    void Unity_FailLevelAnalytics(const char* level,const char* cause)
    {
        [[OpenSuitAnalyticsManager sharedInstance]failLevelAnalytics:Yodo1CreateNSString(level)
                                                      failedCause:Yodo1CreateNSString(cause)];
    }
    
    void Unity_UserLevelIdAnalytics(int level)
    {
        [[OpenSuitAnalyticsManager sharedInstance]userLevelIdAnalytics:level];
    }
    
    void Unity_ChargeRequstAnalytics(const char* orderId,
                                    const char* iapId,
                                    double currencyAmount,
                                    const char* currencyType,
                                    double virtualCurrencyAmount,
                                    const char* paymentType)
    {
        [[OpenSuitAnalyticsManager sharedInstance]chargeRequstAnalytics:Yodo1CreateNSString(orderId)
                                                               iapId:Yodo1CreateNSString(iapId)
                                                      currencyAmount:currencyAmount
                                                        currencyType:Yodo1CreateNSString(currencyType)
                                               virtualCurrencyAmount:virtualCurrencyAmount
                                                         paymentType:Yodo1CreateNSString(paymentType)];
    }
    
    void Unity_ChargeSuccessAnalytics(const char* orderId,int source)
    {
        [[OpenSuitAnalyticsManager sharedInstance]chargeSuccessAnalytics:Yodo1CreateNSString(orderId) source:source];
    }
    
    void Unity_RewardAnalytics(double virtualCurrencyAmount,const char* reason ,int source)
    {
        [[OpenSuitAnalyticsManager sharedInstance]rewardAnalytics:virtualCurrencyAmount
                                                        reason:Yodo1CreateNSString(reason)
                                                        source:source];
    }
    
    void Unity_PurchaseAnalytics(const char* item,int number,double price)
    {
        [[OpenSuitAnalyticsManager sharedInstance]purchaseAnalytics:Yodo1CreateNSString(item)
                                                      itemNumber:number
                                          priceInVirtualCurrency:price];
    }
    
    void Unity_UseAnalytics(const char* item,int amount,double price)
    {
        [[OpenSuitAnalyticsManager sharedInstance]useAnalytics:Yodo1CreateNSString(item)
                                                     amount:amount
                                                      price:price];
        
    }
    
#pragma mark - DplusMobClick
    void Unity_Track(const char* eventName)
    {
        [[OpenSuitAnalyticsManager sharedInstance]track:Yodo1CreateNSString(eventName)];
    }
    
    void Unity_SaveTrackWithEventName(const char* eventName,const char* propertyKey,const char* propertyValue)
    {
        if(eventName == NULL || propertyKey == NULL || propertyValue == NULL)return;
        [[OpenSuitAnalyticsManager sharedInstance]saveTrackWithEventName:Yodo1CreateNSString(eventName)
                                                          propertyKey:Yodo1CreateNSString(propertyKey)
                                                        propertyValue:Yodo1CreateNSString(propertyValue)];
    }
    
    void Unity_SaveTrackWithEventNameIntValue(const char* eventName,const char* propertyKey,const char* propertyValue)
    {
        if(eventName == NULL || propertyKey == NULL)return;
        [[OpenSuitAnalyticsManager sharedInstance]saveTrackWithEventName:Yodo1CreateNSString(eventName)
                                                          propertyKey:Yodo1CreateNSString(propertyKey)
                                                     propertyIntValue:[Yodo1CreateNSString(propertyValue) intValue]];
    }
    
    void Unity_SaveTrackWithEventNameFloatValue(const char* eventName,const char* propertyKey,const char* propertyValue)
    {
        if(eventName == NULL || propertyKey == NULL)return;
        [[OpenSuitAnalyticsManager sharedInstance]saveTrackWithEventName:Yodo1CreateNSString(eventName)
                                                          propertyKey:Yodo1CreateNSString(propertyKey)
                                                   propertyFloatValue:[Yodo1CreateNSString(propertyValue) floatValue]];
    }
    
    void Unity_SaveTrackWithEventNameDoubleValue(const char* eventName,const char* propertyKey,const char* propertyValue)
    {
        if(eventName == NULL || propertyKey == NULL)return;
        [[OpenSuitAnalyticsManager sharedInstance]saveTrackWithEventName:Yodo1CreateNSString(eventName)
                                                          propertyKey:Yodo1CreateNSString(propertyKey)
                                                  propertyDoubleValue:[Yodo1CreateNSString(propertyValue) doubleValue]];
    }
    
     #pragma mark - AppsFlyer
    // AppsFlyer
    void Unity_ValidateAndTrackInAppPurchase(const char*productIdentifier,
                                            const char*price,
                                            const char*currency,
                                            const char*transactionId){
        [[OpenSuitAnalyticsManager sharedInstance]validateAndTrackInAppPurchase:Yodo1CreateNSString(productIdentifier)
                                                                       price:Yodo1CreateNSString(price)
                                                                    currency:Yodo1CreateNSString(currency)
                                                               transactionId:Yodo1CreateNSString(transactionId)];
    }
    // AppsFlyer Event
    void Unity_EventAdAnalyticsWithName(const char*eventName, const char* jsonData) {
        NSString* m_EventName = Yodo1CreateNSString(eventName);
        NSString* eventData = Yodo1CreateNSString(jsonData);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[OpenSuitAnalyticsManager sharedInstance]eventAdAnalyticsWithName:m_EventName eventData:eventDataDic];
    }
    
    // save AppsFlyer deeplink
    void Unity_SaveToNativeRuntime(const char*key, const char*valuepairs) {
        
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
    char* Unity_GetNativeRuntime(const char*key) {
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
