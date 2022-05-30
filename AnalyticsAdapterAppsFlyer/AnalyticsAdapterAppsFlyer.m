//
//  AnalyticsAdapterAppsFlyer.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "AnalyticsAdapterAppsFlyer.h"
#import "Yodo1Registry.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import <AdSupport/AdSupport.h>
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AFNetworking.h"
#import "ThinkingAnalyticsSDK.h"

#define Yodo1AppsFlyerDeeplink @"Yodo1AppsFlyerDeeplink"

NSString* const OPENSUIT_ANALYTICS_APPSFLYER_DEV_KEY       = @"AppsFlyerDevKey";
NSString* const OPENSUIT_ANALYTICS_APPSFLYER_APPLE_APPID   = @"AppleAppId";

@interface AnalyticsAdapterAppsFlyer ()<AppsFlyerLibDelegate, AppsFlyerDeepLinkDelegate>

@end

@implementation AnalyticsAdapterAppsFlyer

+ (AnalyticsType)analyticsType {
    return AnalyticsTypeAppsFlyer;
}

+ (void)load
{
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (id)initWithAnalytics:(AnalyticsInitConfig *)initConfig {
    self = [super init];
    if (self) {
        NSLog(@"idfa:%@",ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString);
        
        NSString* devkey = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_APPSFLYER_DEV_KEY];
        NSString* appleAppId = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_APPSFLYER_APPLE_APPID];
        NSAssert(devkey != nil||appleAppId != nil, @"AppsFlyer devKey 没有设置");
        
        AppsFlyerLib.shared.appsFlyerDevKey = devkey;
        AppsFlyerLib.shared.appleAppID = appleAppId;

        AppsFlyerLib.shared.delegate = self;
        AppsFlyerLib.shared.deepLinkDelegate = self;
        
        NSInteger debug = [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] integerValue];
        if (debug) {
            AppsFlyerLib.shared.isDebug = YES;
        }
        
        // ThinkingData初始化失败会导致getDistinctId获取不到值，导致AppsFlyer初始化崩溃
        if (ThinkingAnalyticsSDK.sharedInstance.getDistinctId) {
            [AppsFlyerLib.shared setAdditionalData:@{@"ta_distinct_id":ThinkingAnalyticsSDK.sharedInstance.getDistinctId}];
        }
        
        if (@available(iOS 14, *)) {
            NSString* timeInterval = @"60";
            [AppsFlyerLib.shared waitForATTUserAuthorizationWithTimeoutInterval:timeInterval.floatValue];
        }
        
        if (initConfig.appsflyerCustomUserId && initConfig.appsflyerCustomUserId.length > 0) {
            AppsFlyerLib.shared.customerUserID = initConfig.appsflyerCustomUserId;
        }
        
        BOOL isGDPR = [[NSUserDefaults standardUserDefaults]boolForKey:@"gdpr_data_consent"];
        if (isGDPR) {
            AppsFlyerLib.shared.isStopped = true;
        } else {
            
            dispatch_queue_t queue = dispatch_queue_create("serial",DISPATCH_QUEUE_SERIAL);
            dispatch_sync(queue, ^{
                [AppsFlyerLib.shared start];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:@{@"appsflyer_id": AppsFlyerLib.shared.getAppsFlyerUID, @"appsflyer_deeplink": @""} forKey:Yodo1AppsFlyerDeeplink];
                [[NSNotificationCenter defaultCenter] addObserver:self
                    selector:@selector(sendLaunch:)
                    name:UIApplicationDidBecomeActiveNotification
                    object:nil];
            });
            dispatch_sync(queue, ^{
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(sendApplicationOfOpenURL:)
                    name:@"Yodo1OpenUrl"
                    object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(sendApplicationOfContinueUserActivity:)
                    name:@"Yodo1UserActivity"
                    object:nil];
            });
        }
    }
    return self;
}

-(void)sendLaunch:(UIApplication *)application {
    [AppsFlyerLib.shared start];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:Yodo1AppsFlyerDeeplink]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict = [[NSUserDefaults standardUserDefaults] objectForKey:Yodo1AppsFlyerDeeplink];
        
        [[NSUserDefaults standardUserDefaults] setObject:@{@"appsflyer_id": AppsFlyerLib.shared.getAppsFlyerUID, @"appsflyer_deeplink": dict[@"appsflyer_deeplink"]} forKey:Yodo1AppsFlyerDeeplink];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{
}

- (void)eventAppsFlyerAnalyticsWithName:(NSString *)eventName eventData:(NSDictionary *)eventData
{
    [AppsFlyerLib.shared logEvent:eventName withValues:eventData];
}

/**
 *  AppsFlyer Apple 内付费使用自定义事件上报
 */
- (void)eventAndTrackInAppPurchase:(NSString*)revenue
                          currency:(NSString*)currency
                          quantity:(NSString*)quantity
                         contentId:(NSString*)contentId
                         receiptId:(NSString*)receiptId {

        float revenueFloat = [revenue floatValue];
        int quantityInt = [quantity intValue];
        
        [[AppsFlyerLib shared] logEvent:AFEventPurchase
                             withValues: @{AFEventParamRevenue : [NSNumber numberWithFloat:revenueFloat],
                                           AFEventParamCurrency : currency,
                                           AFEventParamQuantity : [NSNumber numberWithInt:quantityInt],
                                           AFEventParamContentId: contentId,
                                           AFEventParamReceiptId: receiptId}];
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
        NSLog(@"[ Yodo1 ] Purcahse succeeded And verified!!! response: %@",result[@"receipt"]);
    } failure:^(NSError *error, id response) {
        NSLog(@"[ Yodo1 ] response = %@", response);
    }];
}

- (void)setAppsFlyerCustomUserId:(NSString *)userId {
    if (userId.length > 0) {
        AppsFlyerLib.shared.customerUserID = userId;
    }
}

// AppsFlyerTracker implementation
//Handle Conversion Data (Deferred Deep Link)
-(void)onConversionDataSuccess:(NSDictionary*) installData {
    
    if (installData.count > 0) {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:Yodo1AppsFlyerDeeplink]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict = [[NSUserDefaults standardUserDefaults] objectForKey:Yodo1AppsFlyerDeeplink];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:installData options:NSJSONWritingPrettyPrinted error:nil];
            NSString * deeplinkString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [[NSUserDefaults standardUserDefaults] setObject:@{@"appsflyer_id": AppsFlyerLib.shared.getAppsFlyerUID, @"appsflyer_deeplink": deeplinkString} forKey:Yodo1AppsFlyerDeeplink];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    id status = [installData objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        NSLog(@"[ Yodo1 ] This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        NSLog(@"[ Yodo1 ] This is an organic install.");
    }
}
-(void)onConversionDataFail:(NSError *) error {
  NSLog(@"[ Yodo1 ] %@",error);
}

//Handle Direct Deep Link
- (void) onAppOpenAttribution:(NSDictionary*) attributionData {
  NSLog(@"[ Yodo1 ] %@",attributionData);
}
- (void) onAppOpenAttributionFailure:(NSError *)error {
  NSLog(@"[ Yodo1 ] %@",error);
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    //删除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Yodo1OpenUrl" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Yodo1UserActivity" object:nil];
}

// deeplink
- (void)sendApplicationOfContinueUserActivity:(NSNotification *)noti {
    NSDictionary *dict = noti.userInfo;
    if (dict[@"userActivity"]) {
        [AppsFlyerLib.shared continueUserActivity:dict[@"userActivity"] restorationHandler:nil];
    }
}

- (void)sendApplicationOfOpenURL:(NSNotification *)noti {
    
    NSDictionary *dict = noti.userInfo;
    [AppsFlyerLib.shared handleOpenUrl:dict[@"url"] options:dict[@"options"]];
}

- (void)didResolveDeepLink:(AppsFlyerDeepLinkResult *)result {
    switch (result.status) {
        case AFSDKDeepLinkResultStatusNotFound:
            NSLog(@"Deep link not found");
            break;
        case AFSDKDeepLinkResultStatusFound:
        {
            NSLog(@"DeepLink data is: %@", result.deepLink.toString);
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:Yodo1AppsFlyerDeeplink]) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                dict = [[NSUserDefaults standardUserDefaults] objectForKey:Yodo1AppsFlyerDeeplink];
                
                [[NSUserDefaults standardUserDefaults] setObject:@{@"appsflyer_id": AppsFlyerLib.shared.getAppsFlyerUID, @"appsflyer_deeplink": result.deepLink.toString} forKey:Yodo1AppsFlyerDeeplink];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (result.deepLink.isDeferred) {
                NSLog(@"This is a deferred deep link");
            } else {
                NSLog(@"This is a direct deep link");
            }
        }
            break;
        case AFSDKDeepLinkResultStatusFailure:
            NSLog(@"Error %@", result.error);
            break;
        default:
            break;
    }
}

@end
