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

@property (nonatomic, strong) NSMutableDictionary* analyticsDict;

@end

@implementation Yodo1AnalyticsManager

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
    }
    return self;
}

- (void)initializeAnalyticsWithConfig:(AnalyticsInitConfig*)initConfig
{
    
    NSDictionary* dic = [[Yodo1Registry sharedRegistry] getClassesStatusType:@"analyticsType"
                                                              replacedString:@"AnalyticsAdapter"
                                                               replaceString:@"AnalyticsType"];
    if (dic) {
        NSArray* keyArr = [dic allKeys];
        
        Class adapter = [[[Yodo1Registry sharedRegistry] adapterClassFor:AnalyticsTypeThinking classType:@"analyticsType"] theYodo1Class];
        AnalyticsAdapter* advideoAdapter = [[adapter alloc] initWithAnalytics:initConfig];
        NSNumber* tdBack = [NSNumber numberWithInt:AnalyticsTypeThinking];
        [self.analyticsDict setObject:advideoAdapter forKey:tdBack];
        
        for (id key in keyArr) {
            
            // 忽略ThinkingData
            if ([key integerValue] == AnalyticsTypeThinking) {
                continue;
            }
            Class adapter = [[[Yodo1Registry sharedRegistry] adapterClassFor:[key integerValue] classType:@"analyticsType"] theYodo1Class];
            AnalyticsAdapter* advideoAdapter = [[adapter alloc] initWithAnalytics:initConfig];
            NSNumber* analyticsBack = [NSNumber numberWithInt:[key intValue]];
            [self.analyticsDict setObject:advideoAdapter forKey:analyticsBack];
            
        }
    }
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
 *  AppsFlyer and ThinkingData set user id
 */
- (void)login:(NSString *)userId {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==AnalyticsTypeAppsFlyer || [key integerValue]==AnalyticsTypeThinking){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter login:userId];
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
}



#ifdef __cplusplus

extern "C" {
    
    //统计login
    void UnityLogin(const char* jsonUser)
    {
        NSString* _jsonUser = Yodo1CreateNSString(jsonUser);
        NSDictionary* user = [Yodo1Commons JSONObjectWithString:_jsonUser error:nil];
        if (user) {
            
            NSString* playerId = [user objectForKey:@"playerId"];
            [[Yodo1AnalyticsManager sharedInstance]login:playerId];

            NSLog(@"playerId:%@",playerId);
        } else {
            NSLog(@"user is not playerId!");
        }
    }
    
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
    void UnityEventAppsFlyerAnalyticsWithName(const char*eventName, const char* jsonData) {
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
