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

#import "Yodo1Suit.h"

#import "Yodo1AnalyticsManager.h"

#import "Yodo1SNSManager.h"

#ifdef YODO1_UCCENTER
#import "Yd1UCenterManager.h"
#endif

#ifdef ANTI_ADDICTION
#import "Yodo1RealNameManager.h"
#endif

#import "Yodo1Model.h"

#define DEBUG [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] integerValue]

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
    
    [Yodo1Suit initWithAppKey:__kAppKey];
    
    kYodo1Config = sdkConfig;

    //初始化sns
    NSMutableDictionary* snsPlugn = [NSMutableDictionary dictionary];
    NSString* qqAppId = [[Yodo1KeyInfo shareInstance]configInfoForKey:kYodo1QQAppId];
    NSString* qqUniversalLink = [[Yodo1KeyInfo shareInstance]configInfoForKey:kYodo1QQUniversalLink];
    NSString* wechatAppId = [[Yodo1KeyInfo shareInstance]configInfoForKey:kYodo1WechatAppId];
    NSString* wechatUniversalLink = [[Yodo1KeyInfo shareInstance]configInfoForKey:kYodo1WechatUniversalLink];
    NSString* sinaAppKey = [[Yodo1KeyInfo shareInstance]configInfoForKey:kYodo1SinaWeiboAppKey];
    NSString* sinaUniversalLink = [[Yodo1KeyInfo shareInstance]configInfoForKey:kYodo1SinaWeiboUniversalLink];
    NSString* twitterConsumerKey = [[Yodo1KeyInfo shareInstance]configInfoForKey:kYodo1TwitterConsumerKey];
    NSString* twitterConsumerSecret = [[Yodo1KeyInfo shareInstance]configInfoForKey:kYodo1TwitterConsumerSecret];
    if (qqAppId) {
        [snsPlugn setObject:qqAppId forKey:kYodo1QQAppId];
    }
    if (qqUniversalLink) {
        [snsPlugn setObject:qqUniversalLink forKey:kYodo1QQUniversalLink];
    }
    if (wechatAppId) {
        [snsPlugn setObject:wechatAppId forKey:kYodo1WechatAppId];
    }
    if (wechatUniversalLink) {
        [snsPlugn setObject:wechatUniversalLink forKey:kYodo1WechatUniversalLink];
    }
    if (sinaAppKey) {
        [snsPlugn setObject:sinaAppKey forKey:kYodo1SinaWeiboAppKey];
    }
    if (sinaUniversalLink) {
        [snsPlugn setObject:sinaAppKey forKey:kYodo1SinaWeiboUniversalLink];
    }
    if (twitterConsumerKey && twitterConsumerSecret) {
        [snsPlugn setObject:twitterConsumerKey forKey:kYodo1TwitterConsumerKey];
        [snsPlugn setObject:twitterConsumerSecret forKey:kYodo1TwitterConsumerSecret];
    }
    [[Yodo1SNSManager sharedInstance] initSNSPlugn:snsPlugn];
    
    [Yodo1Manager analyticInit];
}

+ (void)analyticInit
{
    AnalyticsInitConfig * config = [[AnalyticsInitConfig alloc]init];
    config.appsflyerCustomUserId = kYodo1Config.appsflyerCustomUserId;
    config.thinkingDataAccountId = kYodo1Config.thinkingDataAccountId;
    [[Yodo1AnalyticsManager sharedInstance]initializeAnalyticsWithConfig:config];
}


+ (NSDictionary*)config {
    NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle]
                                                       pathForResource:@"Yodo1Suit"
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

    char* UnityGetDeviceId() {
        const char* deviceId = Yd1OpsTools.keychainDeviceId.UTF8String;
        return Yodo1MakeStringCopy(deviceId);
    }
    
    char* UnityGetSDKVersion() {
        const char* sdkVersion = K_YODO1_SUIT_VERSION.UTF8String;
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
