//
//  OpenSuitAnalyticsAdapterAppsFlyer.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "OpenSuitAnalyticsAdapterAppsFlyer.h"
#import "Yodo1Registry.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import <AdSupport/AdSupport.h>
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AFNetworking.h"
#import "Yd1OnlineParameter.h"
#import "ThinkingAnalyticsSDK.h"

#define OpenSuitLoginYID @"YODO1LoginYID"
#define OpenSuitAppsFlyerDeeplink @"YODO1AppsFlyerDeeplink"

#define kYODO1UcapDomain @"https://uc-ap.yodo1api.com/uc_ap"
#define kYODO1DeviceLoginURL @"channel/device/login"

NSString* const OPENSUIT_ANALYTICS_APPSFLYER_DEV_KEY       = @"AppsFlyerDevKey";
NSString* const OPENSUIT_ANALYTICS_APPSFLYER_APPLE_APPID   = @"AppleAppId";

@interface OpenSuitAnalyticsAdapterAppsFlyer ()<AppsFlyerLibDelegate, AppsFlyerDeepLinkDelegate>

@end

@implementation OpenSuitAnalyticsAdapterAppsFlyer

+ (OpenSuitAnalyticsType)analyticsType {
    return OpenSuitAnalyticsTypeAppsFlyer;
}

+ (void)load
{
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}
- (void)deviceLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"YODO1LoginYID"]) {
        Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:kYODO1UcapDomain]];
        manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        NSString* deviceId = Yd1OpsTools.keychainDeviceId;
        NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"yodo1.com%@%@",deviceId,Yd1OParameter.appKey]];
        NSDictionary* data = @{
            Yd1OpsTools.gameAppKey:Yd1OParameter.appKey ,Yd1OpsTools.channelCode:Yd1OParameter.channelId,Yd1OpsTools.deviceId:deviceId,Yd1OpsTools.regionCode:@"" };
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:data forKey:Yd1OpsTools.data];
        [parameters setObject:sign forKey:Yd1OpsTools.sign];
        [manager POST:kYODO1DeviceLoginURL
           parameters:parameters
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
            int errorCode = -1;
            NSString* error = @"";
            if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
                errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
            }
            if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
                error = [response objectForKey:Yd1OpsTools.error];
            }
            if ([[response allKeys]containsObject:Yd1OpsTools.data]) {
                NSDictionary* m_data = (NSDictionary*)[response objectForKey:Yd1OpsTools.data];
                YD1LOG(@"m_data:%@", m_data);
                NSString *yid = m_data[@"yid"];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:yid forKey:@"YODO1LoginYID"];
                
                if (yid.length > 0) {
                    [AppsFlyerLib.shared setAdditionalData:@{@"ta_account_id":yid}];
                    [AppsFlyerLib.shared start];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            YD1LOG(@"%@",error.localizedDescription);
            return;
        }];
    } else {
        [AppsFlyerLib.shared setAdditionalData:@{@"ta_account_id":[[NSUserDefaults standardUserDefaults] objectForKey:OpenSuitLoginYID]}];
    }
}

- (id)initWithAnalytics:(OpenSuitAnalyticsInitConfig *)initConfig {
    self = [super init];
    if (self) {
        NSLog(@"idfa:%@",ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString);
        if([[OpenSuitAnalyticsManager sharedInstance]isAppsFlyerInstalled]){
            NSString* devkey = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_APPSFLYER_DEV_KEY];
            NSString* appleAppId = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_APPSFLYER_APPLE_APPID];
            NSAssert(devkey != nil||appleAppId != nil, @"AppsFlyer devKey 没有设置");
            
            AppsFlyerLib.shared.appsFlyerDevKey = devkey;
            AppsFlyerLib.shared.appleAppID = appleAppId;

            AppsFlyerLib.shared.delegate = self;
            AppsFlyerLib.shared.deepLinkDelegate = self;
#ifdef DEBUG
            AppsFlyerLib.shared.isDebug = YES;
#endif
            
            // ThinkingData初始化失败会导致getDistinctId获取不到值，导致AppsFlyer初始化崩溃
            if (!ThinkingAnalyticsSDK.sharedInstance.getDistinctId) {
                if (Yodo1Commons.idfaString) {
                    [AppsFlyerLib.shared setAdditionalData:@{@"ta_distinct_id":Yodo1Commons.idfaString}];
                } else {
                    [AppsFlyerLib.shared setAdditionalData:@{@"ta_distinct_id":@"00000000-0000-0000-0000-000000000000"}];
                }
                
            } else {
                [AppsFlyerLib.shared setAdditionalData:@{@"ta_distinct_id":ThinkingAnalyticsSDK.sharedInstance.getDistinctId}];
            }
            
            [self deviceLogin];
            
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
                
                dispatch_queue_t queue = dispatch_queue_create("serial",DISPATCH_QUEUE_SERIAL);
                dispatch_sync(queue, ^{
                    [AppsFlyerLib.shared start];
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:@{@"appsflyer_id": AppsFlyerLib.shared.getAppsFlyerUID, @"appsflyer_deeplink": @""} forKey:OpenSuitAppsFlyerDeeplink];
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
    }
    return self;
}

-(void)sendLaunch:(UIApplication *)application {
    [AppsFlyerLib.shared start];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:OpenSuitAppsFlyerDeeplink]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict = [[NSUserDefaults standardUserDefaults] objectForKey:OpenSuitAppsFlyerDeeplink];
        
        [[NSUserDefaults standardUserDefaults] setObject:@{@"appsflyer_id": AppsFlyerLib.shared.getAppsFlyerUID, @"appsflyer_deeplink": dict[@"appsflyer_deeplink"]} forKey:OpenSuitAppsFlyerDeeplink];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)eventWithAnalyticsEventName:(NSString *)eventName
                          eventData:(NSDictionary *)eventData
{
}

- (void)eventAdAnalyticsWithName:(NSString *)eventName eventData:(NSDictionary *)eventData
{
    if ([eventName isEqualToString:AFEventPurchase]) {
           
        float revenue = [eventData[AFEventParamRevenue] intValue];
        NSString *currency = eventData[AFEventParamCurrency];
        int quantity = [eventData[AFEventParamQuantity] intValue];
        NSString *contentId = eventData[AFEventParamContentId];
        NSString *receiptId = eventData[AFEventParamReceiptId];
                
        [[AppsFlyerLib shared] logEvent:AFEventPurchase
                withValues: @{AFEventParamRevenue  : [NSNumber numberWithFloat:revenue],
                              AFEventParamCurrency : currency,
                              AFEventParamQuantity : [NSNumber numberWithInt:quantity],
                              AFEventParamContentId: contentId,
                              AFEventParamReceiptId: receiptId}];
        return;
    }
    [AppsFlyerLib.shared logEvent:eventName withValues:eventData];
}

- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId {
    if([[OpenSuitAnalyticsManager sharedInstance]isAppsFlyerInstalled]){
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
    
    if (installData.count > 0) {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:OpenSuitAppsFlyerDeeplink]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict = [[NSUserDefaults standardUserDefaults] objectForKey:OpenSuitAppsFlyerDeeplink];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:installData options:NSJSONWritingPrettyPrinted error:nil];
            NSString * deeplinkString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [[NSUserDefaults standardUserDefaults] setObject:@{@"appsflyer_id": AppsFlyerLib.shared.getAppsFlyerUID, @"appsflyer_deeplink": deeplinkString} forKey:OpenSuitAppsFlyerDeeplink];
            
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
- (BOOL)sendApplicationOfContinueUserActivity:(NSNotification *)noti {
    NSDictionary *dict = noti.userInfo;
    if (dict[@"userActivity"]) {
        [AppsFlyerLib.shared continueUserActivity:dict[@"userActivity"] restorationHandler:nil];
    }
    
    return YES;
}

- (BOOL)sendApplicationOfOpenURL:(NSNotification *)noti {
    
    NSDictionary *dict = noti.userInfo;
    [AppsFlyerLib.shared handleOpenUrl:dict[@"url"] options:dict[@"options"]];
    return YES;
}

- (void)didResolveDeepLink:(AppsFlyerDeepLinkResult *)result {
    switch (result.status) {
        case AFSDKDeepLinkResultStatusNotFound:
            NSLog(@"Deep link not found");
            break;
        case AFSDKDeepLinkResultStatusFound:
        {
            NSLog(@"DeepLink data is: %@", result.deepLink.toString);
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:OpenSuitAppsFlyerDeeplink]) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                dict = [[NSUserDefaults standardUserDefaults] objectForKey:OpenSuitAppsFlyerDeeplink];
                
                [[NSUserDefaults standardUserDefaults] setObject:@{@"appsflyer_id": AppsFlyerLib.shared.getAppsFlyerUID, @"appsflyer_deeplink": result.deepLink.toString} forKey:OpenSuitAppsFlyerDeeplink];
                
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
