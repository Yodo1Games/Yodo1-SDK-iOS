//
//  Yodo1Manager.m
//  localization_sdk_sample
//
//  Created by shon wang on 13-8-13.
//  Copyright (c) 2013年 游道易. All rights reserved.
//

#import "Yodo1Manager.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1UnityTool.h"
#import "Yd1OnlineParameter.h"
#import "Yodo1Tool+Storage.h"
#import <Bugly/Bugly.h>

#import "Yodo1Ads.h"

#import "Yodo1AnalyticsManager.h"
#import "OpenSuitAnalyticsManager.h"

#import "OpenSuitSNSManager.h"

#ifdef YODO1_MORE_GAME
#import "MoreGameManager.h"
#endif

#ifdef YODO1_UCCENTER
#import "Yd1UCenterManager.h"
#endif

#ifdef YODO1_SOOMLA
#import "IronSourceAdQuality.h"
#endif

#ifdef ANTI_ADDICTION
#import "Yodo1RealNameManager.h"
#endif

#import "Yodo1Model.h"

#define DEBUG [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] integerValue]

NSString* const kFacebookAppId      = @"FacebookAppId";
NSString* const kYodo1ChannelId     = @"AppStore";

NSString* const kSoomlaAppKey       = @"SoomlaAppKey";

@implementation SDKConfig

@end

static SDKConfig* kYodo1Config = nil;
static BOOL isInitialized = false;
static NSString* __kAppKey = @"";

@interface Yodo1Manager ()

@end

@implementation Yodo1Manager

+ (void)initSDKWithConfig:(SDKConfig*)sdkConfig {
    
    NSAssert(sdkConfig.appKey != nil, @"appKey is not set!");
    if (isInitialized) {
        NSLog(@"[Yodo1 SDK] has already been initialized!");
        return;
    }
    __kAppKey = sdkConfig.appKey;
    isInitialized = true;
    
#ifdef YODO1_ADS
    [Yodo1Ads initWithAppKey:__kAppKey];
#endif
    
#ifndef YODO1_ADS
    [Yd1OnlineParameter.shared initWithAppKey:__kAppKey channelId:@"AppStore"];
#endif
    
#ifdef YODO1_SOOMLA
    NSString *adQualityAppKey = [[Yodo1KeyInfo shareInstance]configInfoForKey:kSoomlaAppKey];
    ISAdQualityConfig *adQualityConfig = [ISAdQualityConfig config];
    adQualityConfig.userId = Yodo1Tool.shared.keychainDeviceId;
#ifdef DEBUG
    adQualityConfig.logLevel = IS_AD_QUALITY_LOG_LEVEL_INFO;
#endif
    [[IronSourceAdQuality getInstance] initializeWithAppKey:adQualityAppKey
                                                  andConfig:adQualityConfig];
#endif
    
    kYodo1Config = sdkConfig;

    //初始化sns
    NSMutableDictionary* snsPlugn = [NSMutableDictionary dictionary];
    NSString* qqAppId = [[Yodo1KeyInfo shareInstance]configInfoForKey:kOpenSuitQQAppId];
    NSString* qqUniversalLink = [[Yodo1KeyInfo shareInstance]configInfoForKey:kOpenSuitQQUniversalLink];
    NSString* wechatAppId = [[Yodo1KeyInfo shareInstance]configInfoForKey:kOpenSuitWechatAppId];
    NSString* wechatUniversalLink = [[Yodo1KeyInfo shareInstance]configInfoForKey:kOpenSuitWechatUniversalLink];
    NSString* sinaAppKey = [[Yodo1KeyInfo shareInstance]configInfoForKey:kOpenSuitSinaWeiboAppKey];
    NSString* sinaUniversalLink = [[Yodo1KeyInfo shareInstance]configInfoForKey:kOpenSuitSinaWeiboUniversalLink];
    NSString* twitterConsumerKey = [[Yodo1KeyInfo shareInstance]configInfoForKey:kOpenSuitTwitterConsumerKey];
    NSString* twitterConsumerSecret = [[Yodo1KeyInfo shareInstance]configInfoForKey:kOpenSuitTwitterConsumerSecret];
    if (qqAppId) {
        [snsPlugn setObject:qqAppId forKey:kOpenSuitQQAppId];
    }
    if (qqUniversalLink) {
        [snsPlugn setObject:qqUniversalLink forKey:kOpenSuitQQUniversalLink];
    }
    if (wechatAppId) {
        [snsPlugn setObject:wechatAppId forKey:kOpenSuitWechatAppId];
    }
    if (wechatUniversalLink) {
        [snsPlugn setObject:wechatUniversalLink forKey:kOpenSuitWechatUniversalLink];
    }
    if (sinaAppKey) {
        [snsPlugn setObject:sinaAppKey forKey:kOpenSuitSinaWeiboAppKey];
    }
    if (sinaUniversalLink) {
        [snsPlugn setObject:sinaAppKey forKey:kOpenSuitSinaWeiboUniversalLink];
    }
    if (twitterConsumerKey && twitterConsumerSecret) {
        [snsPlugn setObject:twitterConsumerKey forKey:kOpenSuitTwitterConsumerKey];
        [snsPlugn setObject:twitterConsumerSecret forKey:kOpenSuitTwitterConsumerSecret];
    }
    [[OpenSuitSNSManager sharedInstance] initSNSPlugn:snsPlugn];
    
    [Yodo1Manager analyticInit];
}

+ (void)analyticInit
{
    OpenSuitAnalyticsInitConfig * config = [[OpenSuitAnalyticsInitConfig alloc]init];
    config.gaCustomDimensions01 = kYodo1Config.gaCustomDimensions01;
    config.gaCustomDimensions02 = kYodo1Config.gaCustomDimensions02;
    config.gaCustomDimensions03 = kYodo1Config.gaCustomDimensions03;
    config.gaResourceCurrencies = kYodo1Config.gaResourceCurrencies;
    config.gaResourceItemTypes = kYodo1Config.gaResourceItemTypes;
    config.appsflyerCustomUserId = kYodo1Config.appsflyerCustomUserId;
    [[OpenSuitAnalyticsManager sharedInstance]initializeAnalyticsWithConfig:config];
}


+ (NSDictionary*)config {
    NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle]
                                                       pathForResource:@"Yodo1Ads"
                                                       ofType:@"bundle"]];
    if (bundle) {
        NSString *configPath = [bundle pathForResource:@"config" ofType:@"plist"];
        if (configPath) {
            NSDictionary *config =[NSDictionary dictionaryWithContentsOfFile:configPath];
            return config;
        }
    }
    return nil;
}

+ (NSString*)publishType {
    NSDictionary* _config = [Yodo1Manager config];
    NSString* _publishType = @"";
    if (_config && [[_config allKeys]containsObject:@"PublishType"]) {
        _publishType = (NSString*)[_config objectForKey:@"PublishType"];
    }
    return _publishType;
}
    
+ (NSString*)publishVersion {
    NSDictionary* _config = [Yodo1Manager config];
    NSString* _publishVersion = @"";
    if (_config && [[_config allKeys]containsObject:@"PublishVersion"]) {
        _publishVersion = (NSString*)[_config objectForKey:@"PublishVersion"];
    }
    return _publishVersion;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:kYodo1OnlineConfigFinishedNotification
                                                 object:nil];
    kYodo1Config = nil;
}

+ (void)handleOpenURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication {
    if ([OpenSuitSNSManager sharedInstance].isYodo1Shared) {
        [[OpenSuitSNSManager sharedInstance] application:nil openURL:url options:nil];
    }

}


#ifdef __cplusplus

extern "C" {

    void UnityInitSDKWithConfig(const char* sdkConfigJson) {
        NSString* _sdkConfigJson = Yodo1CreateNSString(sdkConfigJson);
        SDKConfig* yySDKConfig = [SDKConfig yodo1_modelWithJSON:_sdkConfigJson];
        [Yodo1Manager initSDKWithConfig:yySDKConfig];
        
    }

    char* UnityStringParams(const char* key,const char* defaultValue) {
        NSString* _defaultValue = Yodo1CreateNSString(defaultValue);
         NSString* _key = Yodo1CreateNSString(key);
        NSString* param = [Yd1OnlineParameter.shared stringConfigWithKey:_key defaultValue:_defaultValue];
        return Yodo1MakeStringCopy([param cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    bool UnityBoolParams(const char* key,bool defaultValue) {
        bool param = [Yd1OnlineParameter.shared boolConfigWithKey:Yodo1CreateNSString(key) defaultValue:defaultValue];
        return param;
    }
    
    bool UnitySwitchMoreGame() {
    #ifdef YODO1_MORE_GAME
        return [[MoreGameManager sharedInstance]switchYodo1GMG];
    #else
        return NO;
    #endif
    }
    
    void UnityShowMoreGame() {
    #ifdef YODO1_MORE_GAME
        [[MoreGameManager sharedInstance] present];
    #endif
    }

    char* UnityGetDeviceId() {
        const char* deviceId = Yd1OpsTools.keychainDeviceId.UTF8String;
        return Yodo1MakeStringCopy(deviceId);
    }
    
    char* UnityGetSDKVersion() {
        const char* sdkVersion = K_YODO1_ADS_VERSION.UTF8String;
        return Yodo1MakeStringCopy(sdkVersion);
    }

    char* UnityUserId(){
        const char* userId = Yd1OpsTools.keychainUUID.UTF8String;
        return Yodo1MakeStringCopy(userId);
    }
    
    void UnityOpenWebPage(const char* url, const char* jsonparam) {
        
    }
    
    char* UnityGetConfigParameter(const char* key) {
        return NULL;
    }
    
    char* UnityGetCountryCode() {
        
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countrycode = [locale localeIdentifier];
             
        return Yodo1MakeStringCopy([countrycode cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

#endif

@end
