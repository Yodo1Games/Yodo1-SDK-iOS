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
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AFNetworking.h"
#import "ThinkingAnalyticsSDK.h"
#import "Yodo1Privacy.h"

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

NSString* const YODO1_APPSFLYER_DEV_KEY     = @"AppsFlyerDevKey";
NSString* const YODO1_APPSFLYER_APPLE_APPID = @"AppleAppId";
NSString* const YODO1_APPSFLYER_ONE_LINK_ID = @"AppsFlyerOneLinkId";

@interface AnalyticsAdapterAppsFlyer ()<AppsFlyerLibDelegate, AppsFlyerDeepLinkDelegate>

@end

@implementation AnalyticsAdapterAppsFlyer

+ (AnalyticsType)analyticsType {
    return AnalyticsTypeAppsFlyer;
}

+ (void)load {
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (id)initWithConfig:(AnalyticsInitConfig *)initConfig {
    self = [super init];
    if (self) {
        NSString* devkey = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_APPSFLYER_DEV_KEY];
        if(devkey == nil || devkey.length <= 0) {
            YD1LOG(@"Failed to initialize AppsFlyer SDK with invalid devkey. Please check your configuration.");
            return self;
        }
        
        NSString* appleAppId = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_APPSFLYER_APPLE_APPID];
        if(appleAppId == nil || appleAppId.length <= 0) {
            YD1LOG(@"Failed to initialize AppsFlyer SDK with invalid app id of the Apple. Please check your configuration.");
            return self;
        }
        
        AppsFlyerLib.shared.appsFlyerDevKey = devkey;
        AppsFlyerLib.shared.appleAppID = appleAppId;
        
        NSString* oneLinkId = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_APPSFLYER_ONE_LINK_ID];
        if (oneLinkId.length > 0) {
            AppsFlyerLib.shared.appInviteOneLinkID = oneLinkId;
        }
        
        AppsFlyerLib.shared.delegate = self;
        AppsFlyerLib.shared.deepLinkDelegate = self;
        
        if (initConfig.debugEnabled) {
            //Log TAG: [AppsFlyerSDK]
            AppsFlyerLib.shared.isDebug = YES;
        }
        
        if (initConfig.appsflyerCustomUserId && initConfig.appsflyerCustomUserId.length > 0) {
            AppsFlyerLib.shared.customerUserID = initConfig.appsflyerCustomUserId;
        }
        
        if (ThinkingAnalyticsSDK.sharedInstance.getDistinctId) {
            [AppsFlyerLib.shared setAdditionalData:@{@"ta_distinct_id":ThinkingAnalyticsSDK.sharedInstance.getDistinctId}];
        }
        
        if (@available(iOS 14, *)) {
            NSString* timeInterval = @"60";
            [AppsFlyerLib.shared waitForATTUserAuthorizationWithTimeoutInterval:timeInterval.floatValue];
        }
        
        if ([Yodo1Privacy shareInstance].isReportData) {
            [AppsFlyerLib.shared start];
        } else {
            AppsFlyerLib.shared.isStopped = YES;
        }
    }
    return self;
}

/// AppsFlyer  set  custom user id
/// - Parameter userId: The unique identifier of the user
- (void)login:(NSString *_Nonnull)userId {
    AppsFlyerLib.shared.customerUserID = userId;
}

#pragma mark - UA in-app events

- (void)trackUAEvent:(NSString *_Nonnull)eventName eventValues:(NSDictionary * _Nullable)eventValues {
    [AppsFlyerLib.shared logEventWithEventName:eventName
                                   eventValues:eventValues
                             completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
        if(dictionary != nil) {
            YD1LOG(@"Report the event(%@) to AppsFlyer success:", eventName);
            for(id key in dictionary){
                YD1LOG(@"AppsFlyer callback response:(%@, %@)", key, [dictionary objectForKey:key]);
            }
        }
        if(error != nil) {
            YD1LOG(@"Report the event(%@) to AppsFlyer failed with error(code: %@, message:%@)", eventName, @(error.code), error.localizedDescription);
        }
    }];
}

- (void)trackIAPRevenue:(Yodo1IAPRevenue*)iapRevenue {
    if (iapRevenue == nil) {
        return;
    }
    float revenueFloat = [iapRevenue.revenue floatValue];
    int quantityInt = 1;
    
    [[AppsFlyerLib shared] logEventWithEventName:AFEventPurchase
                                     eventValues:@{AFEventParamRevenue : [NSNumber numberWithFloat:revenueFloat],
                                                   AFEventParamCurrency : iapRevenue.currency,
                                                   AFEventParamQuantity : [NSNumber numberWithInt:quantityInt],
                                                   AFEventParamContentId: iapRevenue.productIdentifier,
                                                   AFEventParamReceiptId: iapRevenue.receiptId}
                               completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
        if(dictionary != nil) {
            YD1LOG(@"Report the event(%@) to AppsFlyer success:", AFEventPurchase);
            for(id key in dictionary){
                YD1LOG(@"AppsFlyer callback response:(%@, %@)", key, [dictionary objectForKey:key]);
            }
        }
        if(error != nil) {
            YD1LOG(@"Report the event(%@) to AppsFlyer failed with error(code: %@, message:%@)", AFEventPurchase, @(error.code), error.localizedDescription);
        }
    }];
}

/**
 *  AppsFlyer Apple 内付费使用自定义事件上报
 */
- (void)eventAndTrackInAppPurchase:(NSString*)revenue
                          currency:(NSString*)currency
                          quantity:(NSString*)quantity
                         contentId:(NSString*)contentId
                         receiptId:(NSString*)receiptId {
    
    Yodo1IAPRevenue* iapRevenue= [[Yodo1IAPRevenue alloc] init];
    iapRevenue.revenue = revenue;
    iapRevenue.currency = currency;
    iapRevenue.productIdentifier = contentId;
    iapRevenue.receiptId = receiptId;
    
    [self trackIAPRevenue:iapRevenue];
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

#pragma mark - Deep Link

- (void)handleOpenUrl:(NSURL * _Nonnull)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if (url != nil || ![[url absoluteString] containsString:@"onelink.me"]) {
        return;
    }
    
    [AppsFlyerLib.shared handleOpenUrl:url options:options];
}

- (void)continueUserActivity:(NSUserActivity * _Nonnull)userActivity {
    NSURL *incomingURL = [userActivity webpageURL];
    if (![[incomingURL absoluteString] containsString:@"onelink.me"]) {
        return;
    }
    
    [AppsFlyerLib.shared continueUserActivity:userActivity restorationHandler:nil];
}

#pragma mark - Invite user
- (void)generateInviteUrlWithLinkGenerator:(NSDictionary * _Nonnull)linkDic CallBack:(InviteUrlCallBack _Nonnull)callBack {
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

#pragma mark - AppsFlyerLibDelegate
// AppsFlyerTracker implementation
//Handle Conversion Data (Deferred Deep Link)
-(void)onConversionDataSuccess:(NSDictionary*) installData {
    if ([installData objectForKey:@"deep_link_value"]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *jsonString = [Yodo1Commons stringWithJSONObject:installData error:nil];
        
        [dict setObject:jsonString forKey:Y_AF_DEEPLINK];
        [dict setObject:AppsFlyerLib.shared.getAppsFlyerUID forKey:Y_AF_ID];
        
        [self.delegate yodo1DeeplinkResult:dict];
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

#pragma mark - AppsFlyerDeepLinkDelegate
- (void)didResolveDeepLink:(AppsFlyerDeepLinkResult *)result {
    switch (result.status) {
        case AFSDKDeepLinkResultStatusNotFound:
            YD1LOG(@"Deep link not found");
            break;
        case AFSDKDeepLinkResultStatusFound:
        {
            YD1LOG(@"DeepLink data is: %@", result.deepLink.toString);
            
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
            [resultDict setObject:result.deepLink.toString forKey:Y_AF_DEEPLINK];
            [resultDict setObject:AppsFlyerLib.shared.getAppsFlyerUID forKey:Y_AF_ID];
            
            [self.delegate yodo1DeeplinkResult:resultDict];
            
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

@end
