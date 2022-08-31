//
//  AnalyticsAdapterAppsFlyer.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1UAAppsFlyerAdapter.h"
#import "Yodo1Registry.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <AdSupport/AdSupport.h>
#import "Yodo1Tool+Storage.h"
#import "Yodo1Commons.h"

#define Y_UA_APPSFLYER_DEV_KEY_DEFAULT @"xFXairyqEQ3kBBZZ7Wythi"

@interface Yodo1UAAppsFlyerAdapter ()<AppsFlyerLibDelegate, AppsFlyerDeepLinkDelegate>

@end

@implementation Yodo1UAAppsFlyerAdapter

+ (UAType)UA_Type {
    return UATypeAppsFlyer;
}

+ (void)load
{
    // "registerClass" is the registration method, and "UA_CLASS_TYPE" maps to "UA_Type".
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:UA_CLASS_TYPE];
}

- (id)initWithAnalytics:(UAInitConfig *)initConfig {
    self = [super init];
    if (self) {
        
        NSString* devkey = initConfig.appsflyerDevKey;
        if (devkey.length <= 0) {
            devkey = Y_UA_APPSFLYER_DEV_KEY_DEFAULT;
        }
        NSString* appleAppId = initConfig.appleId;
        NSAssert(appleAppId != nil, @"appleAppId devKey is not set.");
        
        AppsFlyerLib.shared.appsFlyerDevKey = devkey;
        AppsFlyerLib.shared.appleAppID = appleAppId;

        AppsFlyerLib.shared.delegate = self;
        AppsFlyerLib.shared.deepLinkDelegate = self;
        
        if (@available(iOS 14, *)) {
            NSString* timeInterval = @"60";
            [AppsFlyerLib.shared waitForATTUserAuthorizationWithTimeoutInterval:timeInterval.floatValue];
        }
        
        BOOL isChild = (BOOL)[Yd1OpsTools.cached objectForKey:Y_UA_AGE_RESTRICTED_USER];
        BOOL isUserPrivacy = (BOOL)[Yd1OpsTools.cached objectForKey:Y_UA_HAS_USER_CONSENT];
        BOOL isDoNotSell = (BOOL)[Yd1OpsTools.cached objectForKey:Y_UA_DO_NOT_SELL];
        if (isChild || isUserPrivacy || isDoNotSell) {
            AppsFlyerLib.shared.isStopped = true;
            [Yd1OpsTools.cached removeObjectForKey:Y_UA_AGE_RESTRICTED_USER];
            [Yd1OpsTools.cached removeObjectForKey:Y_UA_HAS_USER_CONSENT];
            [Yd1OpsTools.cached removeObjectForKey:Y_UA_DO_NOT_SELL];
        } else {
            
            [AppsFlyerLib.shared start];
            [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(sendLaunch:)
                name:UIApplicationDidBecomeActiveNotification
                object:nil];
        }
    }
    return self;
}

- (void)setAdditionalData:(nullable NSDictionary *)customData {
    if ([customData count] <= 0) {
        Yodo1UALOG(@"Additional data is null.");
        return;
    }
    [AppsFlyerLib.shared setAdditionalData:customData];
}

- (void)trackEvent:(NSString *)eventName withValues:(NSDictionary *)eventData
{
    if ([eventName isEqualToString:Y_UA_INAPP_EVENT_PURCHASE]) {
        eventName = AFEventPurchase;
        
        NSMutableDictionary *newEventData = [NSMutableDictionary dictionary];
        
        for (NSString *key in [eventData allKeys]) {
            NSString *newKey = [key stringByReplacingOccurrencesOfString:@"y_ua" withString:@"af"];
            
            if ([key isEqualToString:Y_UA_INAPP_EVENT_QUANTITY]) {
                int _quantity = [eventData[key] intValue];
                [newEventData setObject:[NSNumber numberWithInteger:_quantity] forKey:newKey];
            } else if ([key isEqualToString:Y_UA_INAPP_EVENT_REVENUE]) {
                float _revenue = [eventData[key] floatValue];
                [newEventData setObject:[NSNumber numberWithFloat:_revenue] forKey:newKey];
            } else {
                [newEventData setObject:eventData[key] forKey:newKey];
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:eventName eventValues:newEventData completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
                Yodo1UALOG(@"dictionary = %@, error = %@", dictionary, error);
        }];
        return;
    }
    
    [AppsFlyerLib.shared logEventWithEventName:eventName eventValues:eventData completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            Yodo1UALOG(@"dictionary = %@, error = %@", dictionary, error);
    }];
}

- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId {
    [AppsFlyerLib.shared validateAndLogInAppPurchase:productIdentifier
                                               price:price
                                            currency:currency
                                       transactionId:transactionId
                                additionalParameters:@{}
                                             success:^(NSDictionary *result){
        Yodo1UALOG(@"Purcahse succeeded And verified!!! response: %@",result[@"receipt"]);
    } failure:^(NSError *error, id response) {
        Yodo1UALOG(@"response = %@", response);
    }];
}

// AppsFlyerTracker implementation
//Handle Conversion Data (Deferred Deep Link)
-(void)onConversionDataSuccess:(NSDictionary*) installData {
    
    if (installData.count > 0) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *jsonString = [Yodo1Commons stringWithJSONObject:installData error:nil];
        
        [dict setObject:jsonString forKey:UA_DEEPLINK];
        [dict setObject:[NSNumber numberWithInteger:UATypeAppsFlyer] forKey:@"ua_type"];
        
        [self.delegate getDeeplinkResult:dict];
    }
    
    id status = [installData objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        Yodo1UALOG(@"This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        Yodo1UALOG(@"This is an organic install.");
    }
}
-(void)onConversionDataFail:(NSError *) error {
    Yodo1UALOG(@"%@",error);
}

-(void)sendLaunch:(UIApplication *)application {
    [AppsFlyerLib.shared start];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

/**
 *  AppsFlyer  set  custom user id
 */
- (void)setCustomUserId:(NSString *)userId {
    if ([userId length] <= 0) {
        Yodo1UALOG(@"Custom userId is null.");
        return;
    }
    AppsFlyerLib.shared.customerUserID = userId;
}

- (void)useReceiptValidationSandbox:(BOOL)isConsent {
    AppsFlyerLib.shared.useReceiptValidationSandbox = isConsent;
}

- (void)logLevel:(int)level {
    
    if (level != 0) {
        AppsFlyerLib.shared.isDebug = YES;
    }
}

//Deeplink
- (void)setDeeplink {
    NSDictionary *openUrlDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_UA_DEEPLINK_OPEN_URL]];
    if ([openUrlDic count] > 0) {
        [AppsFlyerLib.shared handleOpenUrl:openUrlDic[@"url"] options:openUrlDic[@"options"]];
        [Yd1OpsTools.cached removeObjectForKey:Y_UA_DEEPLINK_OPEN_URL];
    }
    
    NSDictionary *userActivityDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_UA_DEEPLINK_USER_ACTIVITY]];
    if ([userActivityDic count] > 0) {
        [AppsFlyerLib.shared continueUserActivity:userActivityDic[@"userActivity"] restorationHandler:nil];
        [Yd1OpsTools.cached removeObjectForKey:Y_UA_DEEPLINK_USER_ACTIVITY];
    }
}

//Handle Direct Deep Link
- (void)onAppOpenAttribution:(NSDictionary*)attributionData {
    Yodo1UALOG(@"%@",attributionData);
}
- (void)onAppOpenAttributionFailure:(NSError *)error {
    Yodo1UALOG(@"%@",error);
}

- (void)didResolveDeepLink:(AppsFlyerDeepLinkResult *)result {
    switch (result.status) {
        case AFSDKDeepLinkResultStatusNotFound:
            Yodo1UALOG(@"Deep link not found.");
            break;
        case AFSDKDeepLinkResultStatusFound:
        {
            Yodo1UALOG(@"DeepLink data is: %@", result.deepLink.toString);
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:result.deepLink.toString forKey:UA_DEEPLINK];
            [dict setObject:[NSNumber numberWithInteger:UATypeAppsFlyer] forKey:@"ua_type"];
            
            [self.delegate getDeeplinkResult:dict];
            
            if (result.deepLink.isDeferred) {
                Yodo1UALOG(@"This is a deferred deep link");
            } else {
                Yodo1UALOG(@"This is a direct deep link");
            }
        }
            break;
        case AFSDKDeepLinkResultStatusFailure:
            Yodo1UALOG(@"Error %@", result.error);
            break;
        default:
            break;
    }
}


@end
