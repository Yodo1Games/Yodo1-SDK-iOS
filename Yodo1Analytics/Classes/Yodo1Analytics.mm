//
//  Yodo1Analytics.m
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1Analytics.h"
#import "Yodo1Commons.h"
#import "Yodo1UnityTool.h"
#import "ThinkingAnalyticsSDK.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Model.h"

#define Yodo1CALOG(fmt, ...) NSLog((@"[Yodo1 Analytics] %s [Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define Y_ANALYTICS_DEBUG_LOG          @"Y_ANALYTICS_DEBUG_LOG"
#define Y_ANALYTICS_IDENTIFY           @"y_analytice_identify"

#define Y_ANALYTICS_VERSION            @"1.0.0"
#define Y_ANALYTICS_TD_SERVER_URL      @"https://c1.yodo1.com/"

NSString* const Y_ANALYTICS_TD_APPID       = @"ThinkingAppId";
NSString* const Y_ANALYTICS_GAME_KEY       = @"GameKey";

@implementation AnalyticsInitConfig

@end

@interface Yodo1Analytics ()
{
    BOOL _isDebugLog;
}

@end

@implementation Yodo1Analytics

+ (nonnull Yodo1Analytics*)sharedInstance
{
    static Yodo1Analytics* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1Analytics alloc]init];
    });
    return _instance;
}

- (void)initWithConfig:(AnalyticsInitConfig *)config
{
    AnalyticsInitConfig *_config = [[AnalyticsInitConfig alloc]init];
    
    if (config.tdAppId.length <= 0) {
        _config.tdAppId = [[Yodo1KeyInfo shareInstance] configInfoForKey:Y_ANALYTICS_TD_APPID];
    } else {
        _config.tdAppId = config.tdAppId;
    }
    NSAssert(_config.tdAppId != nil, @"Thinking AppId is not set.");
    
    if (config.gameKey.length <= 0) {
        _config.gameKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:Y_ANALYTICS_GAME_KEY];
    } else {
        _config.gameKey = config.gameKey;
    }
    NSAssert(_config.gameKey != nil, @"GameKey is not set.");
    
    TDConfig *tdConfig = [TDConfig new];
    tdConfig.appid = _config.tdAppId;
    tdConfig.configureURL = Y_ANALYTICS_TD_SERVER_URL;
    
    [ThinkingAnalyticsSDK startWithConfig:tdConfig];
    
    //设置访客ID
    NSString *identify = (NSString *)[Yd1OpsTools.cached objectForKey:Y_ANALYTICS_IDENTIFY];
    if (identify.length > 0) {
        [ThinkingAnalyticsSDK.sharedInstance identify:identify];
    }
    
    [ThinkingAnalyticsSDK.sharedInstance setSuperProperties:@{@"gameKey":_config.gameKey, @"device_id":Yodo1Tool.shared.keychainDeviceId, @"publishChannelCode":@"appstore", @"sdkVersion":Y_ANALYTICS_VERSION, @"channel_code":@"appstore"}];
    
    // 自动埋点 关闭
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:
    ThinkingAnalyticsEventTypeAppStart |
    ThinkingAnalyticsEventTypeAppEnd |
    ThinkingAnalyticsEventTypeAppViewScreen |
    ThinkingAnalyticsEventTypeAppClick |
    ThinkingAnalyticsEventTypeAppInstall |
    ThinkingAnalyticsEventTypeAppViewCrash
    ];
    
    _isDebugLog = (BOOL)[Yd1OpsTools.cached objectForKey:Y_ANALYTICS_DEBUG_LOG];
    if (_isDebugLog) {
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    }
}

- (void)trackEvent:(nonnull NSString *)eventName withValues:(nullable NSDictionary *)eventData {
    [ThinkingAnalyticsSDK.sharedInstance track:eventName properties:eventData];
}

/**
 *  ThinkingData  set  identify id
 */
- (void)identify:(nonnull NSString *)identify {
    [Yd1OpsTools.cached setObject:identify forKey:Y_ANALYTICS_IDENTIFY];
}

/**
 *  get  ThinkingData distinctId
 */
- (nonnull NSString *)getDistinctId {
    return [[ThinkingAnalyticsSDK sharedInstance] getDistinctId];
}


/**
 *  get  ThinkingData DeviceId
 */
- (nonnull NSString *)getDeviceId {
    return [[ThinkingAnalyticsSDK sharedInstance] getDeviceId];
}

/**
 *  ThinkingData  set  account id
 */
- (void)login:(nonnull NSString *)accountId {
    [ThinkingAnalyticsSDK.sharedInstance login:accountId];
}

/**
 *  ThinkingData logout
 */
- (void)logout {
    [ThinkingAnalyticsSDK.sharedInstance logout];
}

- (nonnull NSString *)getSdkVersion {
    return Y_ANALYTICS_VERSION;
}

- (void)setDebugLog:(BOOL)debugLog {
    [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:debugLog] forKey:Y_ANALYTICS_DEBUG_LOG];
}

#ifdef __cplusplus

extern "C" {
    
    void UnityAnalyticsInitialize(const char* config) {
        
        NSString* _config = Yodo1CreateNSString(config);
        AnalyticsInitConfig* sdkConfig = [AnalyticsInitConfig yodo1_modelWithJSON:_config];
        [Yodo1Analytics.sharedInstance initWithConfig:sdkConfig];
    }
    
    /*
    void UnityAnalyticsIdentify(const char* identify)
    {
        NSString *_identify = Yodo1CreateNSString(identify);
        
        if (_identify.length > 0) {
            [Yodo1Analytics.sharedInstance identify:_identify];

            Yodo1CALOG(@"identify:%@", _identify);
        } else {
            Yodo1CALOG(@"identify is not set!");
        }
    }
     */
    
    char* UnityAnalyticsGetDistinctId() {
        const char* deviceId = [Yodo1Analytics.sharedInstance getDistinctId].UTF8String;
        return Yodo1MakeStringCopy(deviceId);
    }
    
    char* UnityAnalyticsGetDeviceId() {
        const char* deviceId = [Yodo1Analytics.sharedInstance getDeviceId].UTF8String;
        return Yodo1MakeStringCopy(deviceId);
    }
    
    //统计login
    void UnityAnalyticsLogin(const char* accountId)
    {
        NSString *_accountId = Yodo1CreateNSString(accountId);
        
        if (_accountId.length > 0) {
            [Yodo1Analytics.sharedInstance login:_accountId];

            Yodo1CALOG(@"accountId:%@", _accountId);
        } else {
            Yodo1CALOG(@"accountId is not set!");
        }
    }
    
    void UnityAnalyticsLogout()
    {
        [Yodo1Analytics.sharedInstance logout];
    }
    
    // 自定义事件
    void UnityAnalyticsTrackEvent(const char*eventName, const char* jsonData) {
        NSString* m_EventName = Yodo1CreateNSString(eventName);
        NSString* eventData = Yodo1CreateNSString(jsonData);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [Yodo1Analytics.sharedInstance trackEvent:m_EventName withValues:eventDataDic];
    }
    
    char* UnityAnalyticsGetSdkVersion() {
        const char* sdkVersion = Y_ANALYTICS_VERSION.UTF8String;
        Yodo1CALOG(@"sdkVersion = %@", Y_ANALYTICS_VERSION);
        return Yodo1MakeStringCopy(sdkVersion);
    }
    
    void UnityAnalyticsSetDebugLog(bool debugLog) {
        [Yodo1Analytics.sharedInstance setDebugLog:debugLog];
    }
}
#endif

@end
