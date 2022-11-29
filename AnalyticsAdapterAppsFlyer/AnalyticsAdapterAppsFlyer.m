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

#define YODO1AF_TARGET_VIEW @"targetView"
#define YODO1AF_PROMO_CODE @"promoCode"
#define YODO1AF_REFERRER_ID @"referrerId"

#define YODO1AF_DEEP_LINK_VALUE @"deep_link_value"
#define YODO1AF_DEEP_LINK_SUB1 @"deep_link_sub1"
#define YODO1AF_DEEP_LINK_SUB2 @"deep_link_sub2"
#define YODO1AF_SUB1 @"af_sub1"
#define YODO1AF_CAMPAIN @"campaign"
#define YODO1AF_CHANNEL @"channel"
#define YODO1AF_URL @"url"

NSString* const OPENSUIT_ANALYTICS_APPSFLYER_DEV_KEY       = @"AppsFlyerDevKey";
NSString* const OPENSUIT_ANALYTICS_APPSFLYER_APPLE_APPID   = @"AppleAppId";
NSString* const OPENSUIT_ANALYTICS_APPSFLYER_ONE_LINK_ID   = @"AppsFlyerOneLinkId";

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
        
        NSString* devkey = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_APPSFLYER_DEV_KEY];
        NSString* appleAppId = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_APPSFLYER_APPLE_APPID];
        NSAssert(devkey != nil||appleAppId != nil, @"AppsFlyer devKey is not set.");
        
        AppsFlyerLib.shared.appsFlyerDevKey = devkey;
        AppsFlyerLib.shared.appleAppID = appleAppId;
        
        
        NSString* oneLinkId = [[Yodo1KeyInfo shareInstance] configInfoForKey:OPENSUIT_ANALYTICS_APPSFLYER_ONE_LINK_ID];
        if (oneLinkId.length > 0) {
            AppsFlyerLib.shared.appInviteOneLinkID = oneLinkId;
        }

        AppsFlyerLib.shared.delegate = self;
        AppsFlyerLib.shared.deepLinkDelegate = self;
        
        NSInteger debug = [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] integerValue];
        if (debug) {
            AppsFlyerLib.shared.isDebug = YES;
        }
        
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
            
            [AppsFlyerLib.shared start];
            [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(sendLaunch:)
                name:UIApplicationDidBecomeActiveNotification
                object:nil];
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
        YD1LOG(@"Purcahse succeeded And verified!!! response: %@",result[@"receipt"]);
    } failure:^(NSError *error, id response) {
        YD1LOG(@"response = %@", response);
    }];
}

// AppsFlyerTracker implementation
//Handle Conversion Data (Deferred Deep Link)
-(void)onConversionDataSuccess:(NSDictionary*) installData {
    
    if ([installData objectForKey:@"deep_link_value"]) {

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *jsonString = [Yodo1Commons stringWithJSONObject:installData error:nil];

        [dict setObject:jsonString forKey:Y_AF_DEEPLINK];
        [dict setObject:AppsFlyerLib.shared.getAppsFlyerUID forKey:Y_AF_ID];

        [self.delegate getDeeplinkResult:dict];
    }
    
    id status = [installData objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        YD1LOG(@"This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        YD1LOG(@"This is an organic install.");
    }
}
-(void)onConversionDataFail:(NSError *) error {
    YD1LOG(@"error = %@",error);
}

//Handle Direct Deep Link
- (void) onAppOpenAttribution:(NSDictionary*) attributionData {
    YD1LOG(@"attributionData = %@",attributionData);
}
- (void) onAppOpenAttributionFailure:(NSError *)error {
    YD1LOG(@"error = %@",error);
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

//Deeplink
- (void)setDeeplink {
    NSDictionary *openUrlDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_DEEPLINK_OPEN_URL]];
    if ([openUrlDic count] > 0) {
        [AppsFlyerLib.shared handleOpenUrl:openUrlDic[@"url"] options:openUrlDic[@"options"]];
        [Yd1OpsTools.cached removeObjectForKey:Y_DEEPLINK_OPEN_URL];
    }
    
    NSDictionary *userActivityDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_DEEPLINK_USER_ACTIVITY]];
    if ([userActivityDic count] > 0) {
        [AppsFlyerLib.shared continueUserActivity:userActivityDic[@"userActivity"] restorationHandler:nil];
        [Yd1OpsTools.cached removeObjectForKey:Y_DEEPLINK_USER_ACTIVITY];
    }
}

- (void)didResolveDeepLink:(AppsFlyerDeepLinkResult *)result {
    switch (result.status) {
        case AFSDKDeepLinkResultStatusNotFound:
            YD1LOG(@"Deep link not found");
            break;
        case AFSDKDeepLinkResultStatusFound:
        {
            YD1LOG(@"DeepLink data is: %@", result.deepLink.toString);
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:result.deepLink.toString forKey:Y_AF_DEEPLINK];
            [dict setObject:AppsFlyerLib.shared.getAppsFlyerUID forKey:Y_AF_ID];
            
            [self.delegate getDeeplinkResult:dict];
            
            if (result.deepLink.isDeferred) {
                YD1LOG(@"This is a deferred deep link");
            } else {
                YD1LOG(@"This is a direct deep link");
            }
        }
            break;
        case AFSDKDeepLinkResultStatusFailure:
            YD1LOG(@"error = %@", result.error);
            break;
        default:
            break;
    }
}

- (void)generateInviteUrlWithLinkGenerator:(NSDictionary *)linkDic CallBack:(InviteUrlCallBack)callBack {
    
    [AppsFlyerShareInviteHelper generateInviteUrlWithLinkGenerator:^AppsFlyerLinkGenerator * _Nonnull(AppsFlyerLinkGenerator * _Nonnull generator) {
        
        if([[linkDic allKeys] containsObject:YODO1AF_TARGET_VIEW]) {
            if ([linkDic[YODO1AF_TARGET_VIEW] length] > 0) {
                [generator addParameterValue:linkDic[YODO1AF_TARGET_VIEW] forKey:YODO1AF_DEEP_LINK_VALUE];
            }
        }
        if([[linkDic allKeys] containsObject:YODO1AF_PROMO_CODE]) {
            if ([linkDic[YODO1AF_PROMO_CODE] length] > 0) {
                [generator addParameterValue:linkDic[YODO1AF_PROMO_CODE] forKey:YODO1AF_DEEP_LINK_SUB1];
            }
        }
        if([[linkDic allKeys] containsObject:YODO1AF_REFERRER_ID]) {
            if ([linkDic[YODO1AF_REFERRER_ID] length] > 0) {
                [generator addParameterValue:linkDic[YODO1AF_REFERRER_ID] forKey:YODO1AF_DEEP_LINK_SUB2];
                [generator addParameterValue:linkDic[YODO1AF_REFERRER_ID] forKey:YODO1AF_SUB1];
            }
        }
        if([[linkDic allKeys] containsObject:YODO1AF_CAMPAIN]) {
            if ([linkDic[YODO1AF_CAMPAIN] length] > 0) {
                [generator setCampaign:linkDic[YODO1AF_CAMPAIN]];
            }
        }
        if([[linkDic allKeys] containsObject:YODO1AF_CHANNEL]) {
            if ([linkDic[YODO1AF_CHANNEL] length] > 0) {
                [generator setChannel:linkDic[YODO1AF_CHANNEL]];
            }
        }
        
        if([[linkDic allKeys] containsObject:YODO1AF_URL]) {
            generator.brandDomain = linkDic[YODO1AF_URL];
        }
        return generator;
    } completionHandler:^(NSURL * _Nullable url) {

        if (url != nil) {
            YD1LOG(@"AppsFlyer share-invite link:%@", url.absoluteString);
            callBack(url.absoluteString, 1, @"");
        } else {
            callBack(@"", 0, @"url is nil!");
        }
    }];
}

- (void)logInviteAppsFlyerWithEventData:(NSDictionary *)eventData {
    
    [AppsFlyerShareInviteHelper logInvite:AFEventInvite parameters:eventData];
}

/**
 *  AppsFlyer  set  custom user id
 */
- (void)login:(NSString *)userId {
    AppsFlyerLib.shared.customerUserID = userId;//123456
}

@end
