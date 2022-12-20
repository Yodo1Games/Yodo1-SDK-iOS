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
#import <SafariServices/SafariServices.h>

#import "Yodo1Suit.h"

#import "Yodo1AnalyticsManager.h"

#ifdef YODO1_UCCENTER
#import "Yodo1PurchaseManager.h"
#endif

#ifdef ANTI_ADDICTION
#import "Yodo1RealNameManager.h"
#endif

#import "Yodo1Model.h"

#define Yodo1Debug [[[Yodo1KeyInfo shareInstance] configInfoForKey:@"debugEnabled"] integerValue]

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
        YD1LOG(@"[Yodo1 SDK] has already been initialized! && Appkey = %@", sdkConfig.appKey);
        return;
    }
    __kAppKey = sdkConfig.appKey;
    isInitialized = true;
    
    [Yodo1Suit initWithAppKey:__kAppKey];
    
    kYodo1Config = sdkConfig;
    
    [Yodo1Manager analyticInit];
    
#ifdef YODO1_UCCENTER
    [Yodo1PurchaseManager willInit];
#endif
}

+ (void)analyticInit
{
    AnalyticsInitConfig * config = [[AnalyticsInitConfig alloc]init];
    config.appsflyerCustomUserId = kYodo1Config.appsflyerCustomUserId;
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
        YD1LOG(@"defaultValue = %@, key = %@, param = %@", _defaultValue, _key, param);
        return Yodo1MakeStringCopy([param cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    bool UnityBoolParams(const char* key,bool defaultValue) {
        bool param = [Yd1OnlineParameter.shared boolConfigWithKey:Yodo1CreateNSString(key) defaultValue:defaultValue];
        YD1LOG(@"defaultValue = %d, key = %@, param = %d", defaultValue, Yodo1CreateNSString(key), param);
        return param;
    }

    char* UnityGetDeviceId() {
        const char* deviceId = Yd1OpsTools.keychainDeviceId.UTF8String;
        YD1LOG(@"deviceId = %@", Yd1OpsTools.keychainDeviceId);
        return Yodo1MakeStringCopy(deviceId);
    }
    
    char* UnityGetSDKVersion() {
        const char* sdkVersion = K_YODO1_SUIT_VERSION.UTF8String;
        YD1LOG(@"sdkVersion = %@", K_YODO1_SUIT_VERSION);
        return Yodo1MakeStringCopy(sdkVersion);
    }

    char* UnityUserId(){
        const char* userId = Yd1OpsTools.keychainUUID.UTF8String;
        YD1LOG(@"userId = %@", Yd1OpsTools.keychainUUID);
        return Yodo1MakeStringCopy(userId);
    }
    
    void UnityOpenWebPage(const char* url, const char* jsonparam) {
        NSString *_url = Yodo1CreateNSString(url);
        NSString *_jsonparam = Yodo1CreateNSString(jsonparam);
        
        YD1LOG(@"url = %@, jsonparam = %@", _url, _jsonparam);
        
        if ([_jsonparam isEqualToString:@"1"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
        } else if ([_jsonparam isEqualToString:@"0"]) {
            SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:_url] entersReaderIfAvailable:YES];
            UIViewController *rootViewController = [UIViewController new];
            rootViewController = [Yodo1Commons getRootViewController];
            [rootViewController presentViewController:viewController animated:YES completion:nil];
        }
        
        
    }
    
    char* UnityGetConfigParameter(const char* key) {
        return NULL;
    }
    
    char* UnityGetCountryCode() {
        
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countrycode = [locale localeIdentifier];
        
        YD1LOG(@"countryCode = %@", countrycode);
             
        return Yodo1MakeStringCopy([countrycode cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    void UnitySubmitUser(const char* jsonUser)
    {
        NSString* _jsonUser = Yodo1CreateNSString(jsonUser);
        NSDictionary* user = [Yodo1Commons JSONObjectWithString:_jsonUser error:nil];
        if (user) {
            
#ifdef YODO1_UCCENTER
            NSString* playerId = [user objectForKey:@"playerId"];
            NSString* nickName = [user objectForKey:@"nickName"];

            Yodo1PurchaseManager.shared.user.playerid = playerId;
            Yodo1PurchaseManager.shared.user.nickname = nickName;
            [Yd1OpsTools.cached setObject:Yodo1PurchaseManager.shared.user
                                   forKey:@"yd1User"];
            YD1LOG(@"playerId:%@",playerId);
            YD1LOG(@"nickName:%@",nickName);
#endif
        } else {
            YD1LOG(@"user is not submit!");
        }
    }
}

#endif

@end
