//
//  Yodo1UA.mm
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1UA.h"
#import "Yodo1Registry.h"
#import "Yodo1UAAdapterBase.h"
#import "Yodo1Commons.h"
#import "Yodo1ClassWrapper.h"
#import "Yodo1UnityTool.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Model.h"

#define Y_UA_VERSION                  @"1.0.0"

#define Y_UA_DEEPLINK_OBJECTNAME @"Y_UA_DEEPLINK_OBJECTNAME"
#define Y_UA_DEEPLINK_METHODNAME @"Y_UA_DEEPLINK_METHODNAME"

NSString* const Y_UA_APPSFLYER_DEV_KEY       = @"AppsFlyerDevKey";
NSString* const Y_UA_APPLE_APPID             = @"AppleAppId";

@implementation UAInitConfig

@end

@interface Yodo1UA ()<Yodo1UAAdapterBaseDelegate>

@property (nonatomic, strong) NSMutableDictionary* uaDict;

@end

@implementation Yodo1UA

+ (Yodo1UA *)sharedInstance
{
    static Yodo1UA* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1UA alloc]init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _uaDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 *  Get SDK version information
 *
 */
- (NSString *)getSdkVersion {
    return Y_UA_VERSION;
}

- (void)setAgeRestrictedUser:(BOOL)isChild {
    [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:isChild] forKey:Y_UA_AGE_RESTRICTED_USER];
}

- (void)setHasUserConsent:(BOOL)isConsent {
    isConsent = !isConsent;
    [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:isConsent] forKey:Y_UA_HAS_USER_CONSENT];
}

- (void)setDoNotSell:(BOOL)isNotSell {
    [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:isNotSell] forKey:Y_UA_DO_NOT_SELL];
}

- (void)initWithInfoPlist
{
    UAInitConfig *config = [[UAInitConfig alloc] init];
    config.appsflyerDevKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:Y_UA_APPSFLYER_DEV_KEY];
    config.appleId = [[Yodo1KeyInfo shareInstance] configInfoForKey:Y_UA_APPLE_APPID];
    [self initWithConfig:config];
}

- (void)initWithConfig:(UAInitConfig*)initConfig
{
    NSDictionary* dic = [[Yodo1Registry sharedRegistry] getClassesStatusType:UA_CLASS_TYPE replacedString:@"Yodo1UAAdapterBase" replaceString:@"UAType"];
    if (dic) {
        NSArray* keyArr = [dic allKeys];
        for (id key in keyArr) {
            Class adapter = [[[Yodo1Registry sharedRegistry] adapterClassFor:[key integerValue] classType:UA_CLASS_TYPE] theYodo1Class];
            Yodo1UAAdapterBase *uaAdapter = [[adapter alloc]initWithAnalytics:initConfig];
            NSNumber* analyticsBack = [NSNumber numberWithInt:[key intValue]];
            [self.uaDict setObject:uaAdapter forKey:analyticsBack];
        }
    }
    
    [self setDeeplink];
}

- (void)setAdditionalData:(nullable NSDictionary *)customData {
    for (id key in [self.uaDict allKeys]) {
        if ([key integerValue]==UATypeAppsFlyer){
            Yodo1UAAdapterBase* adapter = [self.uaDict objectForKey:key];
            [adapter setAdditionalData:customData];
            break;
        }
    }
}

/**
 *  AppsFlyer and ThinkingData set user id
 */
- (void)setCustomUserId:(NSString *)userId {
    for (id key in [self.uaDict allKeys]) {
        if ([key integerValue]==UATypeAppsFlyer){
            Yodo1UAAdapterBase* adapter = [self.uaDict objectForKey:key];
            [adapter setCustomUserId:userId];
        }
    }
}

- (void)trackEvent:(nonnull NSString *)eventName withValues:(nullable NSDictionary *)eventData
{
    if (eventName == nil) {
        NSAssert(eventName != nil, @"eventName cannot nil!");
    }
    for (id key in [self.uaDict allKeys]) {
        if ([key integerValue]==UATypeAppsFlyer){
            Yodo1UAAdapterBase* adapter = [self.uaDict objectForKey:key];
            [adapter trackEvent:eventName withValues:eventData];
            break;
        }
    }
}

- (void)validateAndTrackInAppPurchase:(nonnull NSString*)productIdentifier
                                price:(nonnull NSString*)price
                             currency:(nonnull NSString*)currency
                        transactionId:(nonnull NSString*)transactionId {
    for (id key in [self.uaDict allKeys]) {
        if ([key integerValue]==UATypeAppsFlyer){
            Yodo1UAAdapterBase* adapter = [self.uaDict objectForKey:key];
            [adapter validateAndTrackInAppPurchase:productIdentifier
                                             price:price
                                          currency:currency
                                     transactionId:transactionId];
            break;
        }
    }
}

- (void)useReceiptValidationSandbox:(BOOL)isConsent {
    for (id key in [self.uaDict allKeys]) {
        if ([key integerValue]==UATypeAppsFlyer){
            Yodo1UAAdapterBase* adapter = [self.uaDict objectForKey:key];
            [adapter useReceiptValidationSandbox:isConsent];
            break;
        }
    }
}

- (void)setDebugLog:(BOOL)debugLog {
    [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:debugLog] forKey:Y_UA_DEBUG_LOG];
}

- (void)setDeeplink {
    for (id key in [self.uaDict allKeys]) {
        if ([key integerValue]==UATypeAppsFlyer){
            Yodo1UAAdapterBase* adapter = [self.uaDict objectForKey:key];
            [adapter setDeeplink];
            adapter.delegate = self;
            break;
        }
    }
}

- (void)getDeeplinkResult:(NSDictionary *)result {
    
    NSString* m_gameObject = (NSString *)[Yd1OpsTools.cached objectForKey:Y_UA_DEEPLINK_OBJECTNAME];
    NSString* m_methodName = (NSString *)[Yd1OpsTools.cached objectForKey:Y_UA_DEEPLINK_METHODNAME];
    if (m_gameObject.length > 0 && m_methodName.length > 0) {
        NSString* msg = [Yodo1Commons stringWithJSONObject:result error:nil];
        UnitySendMessage([m_gameObject cStringUsingEncoding:NSUTF8StringEncoding],
                         [m_methodName cStringUsingEncoding:NSUTF8StringEncoding],
                         [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    [self.delegate getDeeplinkResult:result];
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
    
    [Yd1OpsTools.cached setObject:dict forKey:Y_UA_DEEPLINK_OPEN_URL];
}

/**
 *  订阅continueUserActivity
 *
 *  @param userActivity                    生命周期中的userActivity
 */
- (void)continueUserActivity:(nonnull NSUserActivity *)userActivity {
    
    NSDictionary *dict = [NSDictionary dictionary];
    dict = @{@"userActivity":userActivity};
    
    [Yd1OpsTools.cached setObject:dict forKey:Y_UA_DEEPLINK_USER_ACTIVITY];
}

- (void)dealloc
{
    self.uaDict = nil;
}

#ifdef __cplusplus

extern "C" {
    
    void UnityUAInitWithInfoPlist() {
        [Yodo1UA.sharedInstance initWithInfoPlist];
    }
    
    void UnityUAInitWithConfig(const char* sdkConfigJson, const char *SdkObjectName,const char* SdkMethodName) {
        
        NSString* m_gameObject = Yodo1CreateNSString(SdkObjectName);
        NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
        NSString* m_methodName = Yodo1CreateNSString(SdkMethodName);
        NSCAssert(m_methodName != nil, @"Unity3d methodName isn't set!");
        
        [Yd1OpsTools.cached setObject:m_gameObject forKey:Y_UA_DEEPLINK_OBJECTNAME];
        [Yd1OpsTools.cached setObject:m_methodName forKey:Y_UA_DEEPLINK_METHODNAME];
        
        NSString* _configJson = Yodo1CreateNSString(sdkConfigJson);
        UAInitConfig* config = [UAInitConfig yodo1_modelWithJSON:_configJson];
        [Yodo1UA.sharedInstance initWithConfig:config];
    }
    
    char* UnityUAGetSdkVersion() {
        const char* sdkVersion = Y_UA_VERSION.UTF8String;
        YD1LOG(@"sdkVersion = %@", Y_UA_VERSION);
        return Yodo1MakeStringCopy(sdkVersion);
    }
    
    void UnityUASetAgeRestrictedUser(bool isChild) {
        [Yodo1UA.sharedInstance setAgeRestrictedUser:isChild];
    }
    
    void UnityUASetHasUserConsent(bool isConsent) {
        [Yodo1UA.sharedInstance setHasUserConsent:isConsent];
    }
    
    void UnityUASetDoNotSell(bool isNotSell) {
        [Yodo1UA.sharedInstance setDoNotSell:isNotSell];
    }
    
    //统计login
    void UnityUASetCustomUserId(const char* jsonUser)
    {
        NSString* _jsonUser = Yodo1CreateNSString(jsonUser);
        NSDictionary* user = [Yodo1Commons JSONObjectWithString:_jsonUser error:nil];
        
        if (user) {
            
            NSString* playerId = [user objectForKey:@"playerId"];
            [[Yodo1UA sharedInstance]setCustomUserId:playerId];

            Yodo1UALOG(@"playerId:%@",playerId);
        } else {
            Yodo1UALOG(@"user is not playerId!");
        }
    }
    
    void UnityUASetAdditionalData(const char* jsonAdditionalData)
    {
        NSString* _jsonAdditionalData = Yodo1CreateNSString(jsonAdditionalData);
        NSDictionary* _dataDic = [Yodo1Commons JSONObjectWithString:_jsonAdditionalData error:nil];
        
        [[Yodo1UA sharedInstance]setAdditionalData:_dataDic];

        Yodo1UALOG(@"AdditionalData:%@", _dataDic);
    }
    
     #pragma mark - AppsFlyer
    // AppsFlyer
    void UnityUAValidateAndTrackInAppPurchase(const char*productIdentifier,
                                            const char*price,
                                            const char*currency,
                                            const char*transactionId){
        [[Yodo1UA sharedInstance]validateAndTrackInAppPurchase:Yodo1CreateNSString(productIdentifier)
                                                                       price:Yodo1CreateNSString(price)
                                                                    currency:Yodo1CreateNSString(currency)
                                                               transactionId:Yodo1CreateNSString(transactionId)];
    }
    
    void UnityUATrackEvent(const char*eventName, const char* jsonData) {
        NSString* m_EventName = Yodo1CreateNSString(eventName);
        NSString* eventData = Yodo1CreateNSString(jsonData);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[Yodo1UA sharedInstance] trackEvent:m_EventName withValues:eventDataDic];
    }
    
    void UnityUAUseReceiptValidationSandbox(bool isConsent) {
        [Yodo1UA.sharedInstance useReceiptValidationSandbox:isConsent];
    }
    
    void UnityUASetDebugLog(bool debugLog) {
        [Yodo1UA.sharedInstance setDebugLog:debugLog];
        
    }
}
#endif

@end
