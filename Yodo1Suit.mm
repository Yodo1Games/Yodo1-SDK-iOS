//
//  Yodo1Suit.m
//
//  Created by hyx on 17/7/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Yodo1Suit.h"
#import "Yodo1UnityTool.h"

#import "Yd1OnlineParameter.h"
#import "YD1AgePrivacyManager.h"
#import "Yodo1Commons.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AFNetworking.h"

#import "Yodo1KeyInfo.h"

#import "Yodo1Manager.h"

//Unity3d
const char* UNITY3D_YODO1SUIT_METHOD     = "Yodo1U3dSDKCallBackResult";
static NSString* kYodo1SuitGameObject    = @"Yodo1Suit";//默认

@interface Yodo1SuitDelegate : NSObject

+ (instancetype)instance;

+ (UIViewController*)getRootViewController;

+ (UIViewController*)topMostViewController:(UIViewController*)controller;

+ (NSString *)stringWithJSONObject:(id)obj error:(NSError**)error;

+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error;

@end

@implementation Yodo1SuitDelegate

+ (instancetype)instance {
    static Yodo1SuitDelegate *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1SuitDelegate alloc] init];
    });
    
    return sharedInstance;
}

+ (UIViewController*)getRootViewController {
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray* windows = [[UIApplication sharedApplication] windows];
        for (UIWindow* _window in windows) {
            if (_window.windowLevel == UIWindowLevelNormal) {
                window = _window;
                break;
            }
        }
    }
    UIViewController* viewController = nil;
    for (UIView* subView in [window subviews]) {
        UIResponder* responder = [subView nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            viewController = [self topMostViewController:(UIViewController*)responder];
        }
    }
    if (!viewController) {
        viewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    return viewController;
}

+ (UIViewController*)topMostViewController:(UIViewController*)controller {
    BOOL isPresenting = NO;
    do {
        // this path is called only on iOS 6+, so -presentedViewController is fine here.
        UIViewController* presented = [controller presentedViewController];
        isPresenting = presented != nil;
        if (presented != nil) {
            controller = presented;
        }
        
    } while (isPresenting);
    
    return controller;
}

+ (NSString*)stringWithJSONObject:(id)obj error:(NSError**)error {
    if (obj) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSData* data = nil;
            @try {
                data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:error];
            }
            @catch (NSException* exception)
            {
                *error = [NSError errorWithDomain:[exception description] code:0 userInfo:nil];
                return nil;
            }
            @finally
            {
            }
            
            if (data) {
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
    }
    return nil;
}

+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error {
    if (str) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            return [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingAllowFragments
                                                     error:error];
        }
    }
    return nil;
}

@end


#pragma mark- ///OC实现

@interface Yodo1Suit ()

@end

@implementation Yodo1Suit

+ (void)initWithAppKey:(NSString *)appKey {
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    }
    
    SDKConfig* config = [[SDKConfig alloc] init];
    config.appKey = appKey;
    [Yodo1Manager initSDKWithConfig:config];
}

+ (NSString *)sdkVersion {
    return Yodo1Tool.shared.sdkVersionValue;
}

+ (NSString *)getDeviceId {
    return Yd1OpsTools.keychainDeviceId;
}

+ (NSString *)GetCountryCode {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale localeIdentifier];
    return countryCode;
}

// 在线参数功能
+ (NSString *)stringParamsConfigWithKey:(NSString *)key defaultValue:(NSString *)value {
    return [Yd1OnlineParameter.shared stringConfigWithKey:key defaultValue:value];
}
+ (BOOL)boolParamsConfigWithKey:(NSString *)key defaultValue:(bool)value {
    return [Yd1OnlineParameter.shared boolConfigWithKey:key defaultValue:value];
}

+ (void)setLogEnable:(BOOL)enable {
//    [[Yodo1Analytics instance]setDebugMode:enable];
}

+ (void)setUserConsent:(BOOL)consent {

}

+ (BOOL)isUserConsent {
    return YES;
}

+ (void)setTagForUnderAgeOfConsent:(BOOL)isBelowConsentAge {

}

+ (BOOL)isTagForUnderAgeOfConsent {
    return NO;
}

+ (void)setDoNotSell:(BOOL)doNotSell {

}

+ (BOOL)isDoNotSell {
    return NO;
}

@end


#pragma mark- ///Unity3d

extern "C" {

void Unity3dInitWithAppKey(const char *appKey,const char* gameObject)
{
    NSString* m_appKey = Yodo1CreateNSString(appKey);
    NSCAssert(m_appKey != nil, @"AppKey 没有设置!");
    
    NSString* m_gameObject = Yodo1CreateNSString(gameObject);
    if (m_gameObject) {
        kYodo1SuitGameObject = m_gameObject;
    }
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    
    [Yodo1Suit initWithAppKey:m_appKey];
}

void Unity3dSetLogEnable(BOOL enable)
{
    [Yodo1Suit setLogEnable:enable];
}

#pragma mark - Privacy

void UnitySetUserConsent(BOOL consent)
{
    [Yodo1Suit setUserConsent:consent];
}

bool UnityGetUserConsent()
{
    return [Yodo1Suit isUserConsent];
}

void UnitySetTagForUnderAgeOfConsent(BOOL underAgeOfConsent)
{
    [Yodo1Suit setTagForUnderAgeOfConsent:underAgeOfConsent];
}

bool UnityGetTagForUnderAgeOfConsent()
{
    return [Yodo1Suit isTagForUnderAgeOfConsent];
}

void UnitySetDoNotSell(BOOL doNotSell)
{
    [Yodo1Suit setDoNotSell:doNotSell];
}

bool UnityGetDoNotSell()
{
    return [Yodo1Suit isDoNotSell];
}

void UnityShowUserConsent(const char *SdkObjectName,const char* SdkMethodName)
{
    NSString* m_appKey = nil;
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        m_appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    }
    NSCAssert(m_appKey != nil, @"AppKey 没有设置!");
    NSString* m_gameObject = Yodo1CreateNSString(SdkObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    NSString* m_methodName = Yodo1CreateNSString(SdkMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d methodName isn't set!");
    UIViewController* rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    if (rootViewController == nil) {
        rootViewController = [Yodo1Commons getRootViewController];
    }
    [YD1AgePrivacyManager dialogShowUserConsentWithGameAppKey:m_appKey
                                                  channelCode:Yodo1Tool.shared.paymentChannelCodeValue
                                               viewController:rootViewController
                                                        block:^(BOOL accept, BOOL child, int age) {
        if (m_gameObject && m_methodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:8001] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:age] forKey:@"age"];
            [dict setObject:[NSNumber numberWithBool:child] forKey:@"isChild"];
            [dict setObject:[NSNumber numberWithBool:accept] forKey:@"accept"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            NSString* jsonError = @"";
            if(parseJSONError){
                jsonError = @"Convert result to json failed!";
                [dict setObject:jsonError forKey:@"error"];
                msg =  [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            }
            
            UnitySendMessage([kYodo1SuitGameObject cStringUsingEncoding:NSUTF8StringEncoding],UNITY3D_YODO1SUIT_METHOD,
                             [msg cStringUsingEncoding:NSUTF8StringEncoding] );
        }
    }];
}
}
