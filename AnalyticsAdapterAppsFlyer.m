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

#import "Yd1OnlineParameter.h"
#import "ThinkingAnalyticsSDK.h"

#define YODO1LoginYID @"YODO1LoginYID"

NSString* const YODO1_ANALYTICS_APPSFLYER_DEV_KEY       = @"AppsFlyerDevKey";
NSString* const YODO1_ANALYTICS_APPSFLYER_APPLE_APPID   = @"AppleAppId";

@interface AnalyticsAdapterAppsFlyer ()<AppsFlyerLibDelegate>

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
        if([[Yodo1AnalyticsManager sharedInstance]isAppsFlyerInstalled]){
            NSString* devkey = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_ANALYTICS_APPSFLYER_DEV_KEY];
            NSString* appleAppId = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_ANALYTICS_APPSFLYER_APPLE_APPID];
            NSAssert(devkey != nil||appleAppId != nil, @"AppsFlyer devKey 没有设置");
            
            AppsFlyerLib.shared.appsFlyerDevKey = devkey;
            AppsFlyerLib.shared.appleAppID = appleAppId;
            AppsFlyerLib.shared.delegate = self;
#ifdef DEBUG
            AppsFlyerLib.shared.isDebug = YES;
#endif
            
            [AppsFlyerLib.shared setAdditionalData:@{@"ta_distinct_id":ThinkingAnalyticsSDK.sharedInstance.getDistinctId}];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:YODO1LoginYID] length] > 0) {
                [AppsFlyerLib.shared setAdditionalData:@{@"ta_account_id":[[NSUserDefaults standardUserDefaults] objectForKey:YODO1LoginYID]}];
            }
            
            if (@available(iOS 14, *)) {
                NSString* timeInterval = [Yd1OnlineParameter.shared stringConfigWithKey:@"AF_waitForATT_TimeoutInterval" defaultValue:@"60"];
                if ([timeInterval isEqualToString:@""]||!timeInterval) {
                    timeInterval = @"60";
                }
                [AppsFlyerLib.shared waitForATTUserAuthorizationWithTimeoutInterval:timeInterval.floatValue];
            }
            NSString* useId = [[NSUserDefaults standardUserDefaults]objectForKey:@"YODO1_SWRVE_USEID"];
            if (useId) {
               AppsFlyerLib.shared.customerUserID = useId;
            }else{
                if (initConfig.appsflyerCustomUserId && initConfig.appsflyerCustomUserId.length > 0) {
                    AppsFlyerLib.shared.customerUserID = initConfig.appsflyerCustomUserId;
                }
            }
            BOOL isGDPR = [[NSUserDefaults standardUserDefaults]boolForKey:@"gdpr_data_consent"];
            if (isGDPR) {
                AppsFlyerLib.shared.isStopped = true;
            } else {
                [AppsFlyerLib.shared start];
                [[NSNotificationCenter defaultCenter] addObserver:self
                    selector:@selector(sendLaunch:)
                    name:UIApplicationDidBecomeActiveNotification
                    object:nil];
            }
        }
    }
    return self;
}

-(void)sendLaunch:(UIApplication *)application {
    [AppsFlyerLib.shared start];
}

- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{
}

- (void)eventAdAnalyticsWithName:(NSString *)eventName eventData:(NSDictionary *)eventData
{
    [AppsFlyerLib.shared logEvent:eventName withValues:@{}];
}

- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId {
    if([[Yodo1AnalyticsManager sharedInstance]isAppsFlyerInstalled]){
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
}

// AppsFlyerTracker implementation
//Handle Conversion Data (Deferred Deep Link)
-(void)onConversionDataSuccess:(NSDictionary*) installData {
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
}

@end
