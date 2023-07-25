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
#import "Yodo1Base.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1KeyInfo.h"

@implementation AnalyticsInitConfig

@end

@interface Yodo1AnalyticsManager()<Yodo1UAAdapterDelegate>

@property (nonatomic, strong) NSMutableDictionary* analyticsDict;
@property (nonatomic,assign) BOOL isInitialized;

@end

@implementation Yodo1AnalyticsManager

+ (Yodo1AnalyticsManager *)sharedInstance {
    static Yodo1AnalyticsManager* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1AnalyticsManager alloc] init];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _analyticsDict = [[NSMutableDictionary alloc] init];
        _isInitialized = NO;
    }
    return self;
}

- (void)dealloc {
    self.analyticsDict = nil;
}

- (void)initializeWithPlist {
    AnalyticsInitConfig* config = [[AnalyticsInitConfig alloc] init];
    config.gameKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    config.debugEnabled = [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] boolValue];
    
    [self initializeWithConfig:config];
}

- (void)initializeWithConfig:(AnalyticsInitConfig*)initConfig {
    [self initAdapters:initConfig];
    
    NSDictionary *openUrlDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_DEEPLINK_OPEN_URL]];
    if ([openUrlDic count] > 0) {
        [self handleOpenUrl:openUrlDic[@"url"] options:openUrlDic[@"options"]];
    }

    NSDictionary *userActivityDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_DEEPLINK_USER_ACTIVITY]];
    if ([userActivityDic count] > 0) {
        [self continueUserActivity:userActivityDic[@"userActivity"]];
    }
}

- (void)initializeAnalyticsWithConfig:(AnalyticsInitConfig*)initConfig {
    [self initializeWithConfig:initConfig];
}

- (void)initAdapters:(AnalyticsInitConfig*)initConfig {
    NSDictionary* dic = [[Yodo1Registry sharedRegistry] getClassesStatusType:@"analyticsType"
                                                              replacedString:@"AnalyticsAdapter"
                                                               replaceString:@"AnalyticsType"];
    if (dic) {
        NSArray* keyArr = [dic allKeys];
        for (id key in keyArr) {
            Class adapterClass = [[[Yodo1Registry sharedRegistry] adapterClassFor:[key integerValue] classType:@"analyticsType"] theYodo1Class];
            AnalyticsAdapter* adapter = [[adapterClass alloc] initWithConfig:initConfig];
            adapter.delegate = self;
            NSNumber* analyticsBack = [NSNumber numberWithInt:[key intValue]];
            [self.analyticsDict setObject:adapter forKey:analyticsBack];
        }
    }
    
    self.isInitialized = YES;
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

- (void)eventAnalytics:(NSString *)eventName eventData:(NSDictionary *)eventData {
    [self trackEvent:eventName eventValues:eventData];
}

- (void)trackEvent:(NSString *)eventName eventValues:(NSDictionary *)eventValues {
    if (eventName == nil) {
        NSAssert(eventName != nil, @"eventName cannot nil!");
    }
    
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue] == AnalyticsTypeThinking){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter trackEvent:eventName eventValues:eventValues];
        }
    }
}


#pragma mark - UA

- (void)eventAppsFlyerAnalyticsWithName:(NSString *)eventName eventData:(NSDictionary *)eventValues {
    [self trackUAEvent:eventName eventValues:eventValues];
}

- (void)trackUAEvent:(NSString *)eventName eventValues:(NSDictionary *)eventValues {
    if (eventName == nil) {
        NSAssert(eventName != nil, @"eventName cannot nil!");
    }
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue] == AnalyticsTypeAppsFlyer || [key integerValue] == AnalyticsTypeAdjust){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter trackUAEvent:eventName eventValues:eventValues];
        }
    }
}

- (void)trackAdRevenue:(Yodo1AdRevenue *)adRevenue {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue] == AnalyticsTypeAdjust){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter trackAdRevenue:adRevenue];
        }
    }
}

- (void)trackIAPRevenue:(Yodo1IAPRevenue *)iapRevenue {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue] == AnalyticsTypeAppsFlyer || [key integerValue] == AnalyticsTypeAdjust){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter trackIAPRevenue:iapRevenue];
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

#pragma mark - User Invite
/**
 *  AppsFlyer User invite attribution
 */
- (void)generateInviteUrlWithLinkGenerator:(NSDictionary *)linkDic CallBack:(Yodo1InviteUrlCallBack)callBack {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==AnalyticsTypeAppsFlyer){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter generateInviteUrlWithLinkGenerator:linkDic CallBack:^(NSString *url, int code, NSString *errorMsg) {
                callBack(url, code, errorMsg);
            }];
        }
    }
}

/**
 *  AppsFlyer logInvite AFEventInvite
 */
- (void)logInviteAppsFlyerWithEventData:(NSDictionary *)eventData {
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue]==AnalyticsTypeAppsFlyer){
            AnalyticsAdapter* adapter = [self.analyticsDict objectForKey:key];
            [adapter logInviteAppsFlyerWithEventData:eventData];
        }
    }
}

#pragma mark - Deep Link Yodo1AdapterBaseDelegate
- (void)yodo1DeeplinkResult:(NSDictionary *)result {
    if (self.delegate != nil) {
        [self.delegate yodo1DeeplinkResult:result];
    }
    [Yd1OpsTools.cached setObject:result forKey:Y_DEEPLINK_RESULT];
}

#pragma mark - Deep Link Lifecycle Methods
/// 订阅openURL
/// @param url 生命周期中的openurl
/// @param options 生命周期中的options
- (void)handleOpenUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if (!self.isInitialized) {
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
        
        [Yd1OpsTools.cached setObject:dict forKey:Y_DEEPLINK_OPEN_URL];
        return;
    } else {
        [Yd1OpsTools.cached removeObjectForKey:Y_DEEPLINK_OPEN_URL];
    }

    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue] == AnalyticsTypeAppsFlyer || [key integerValue] == AnalyticsTypeAdjust){
            AnalyticsAdapter* adapter = [self.self.analyticsDict objectForKey:key];
            [adapter handleOpenUrl:url options:options];
            adapter.delegate = self;
        }
    }
}

/// 订阅continueUserActivity
/// @param userActivity 生命周期中的userActivity
- (void)continueUserActivity:(nonnull NSUserActivity *)userActivity {
    if (!self.isInitialized) {
        NSDictionary *dict = [NSDictionary dictionary];
        dict = @{@"userActivity":userActivity};
        
        [Yd1OpsTools.cached setObject:dict forKey:Y_DEEPLINK_USER_ACTIVITY];
        return;
    } else {
        [Yd1OpsTools.cached removeObjectForKey:Y_DEEPLINK_USER_ACTIVITY];
    }
    
    for (id key in [self.analyticsDict allKeys]) {
        if ([key integerValue] == AnalyticsTypeAppsFlyer || [key integerValue] == AnalyticsTypeAdjust){
            AnalyticsAdapter* adapter = [self.self.analyticsDict objectForKey:key];
            [adapter continueUserActivity:userActivity];
            adapter.delegate = self;
        }
    }
}

@end
