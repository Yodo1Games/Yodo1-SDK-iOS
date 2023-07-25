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
#import "Yodo1Privacy.h"

#import <SafariServices/SafariServices.h>


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


#pragma mark- OC Manily Methods

@interface Yodo1Suit()

@end

@implementation Yodo1Suit

+ (void)setLogEnable:(BOOL)enable {
    //    [[Yodo1Analytics instance]setDebugMode:enable];
}

#pragma mark - Init

+ (void)initWithAppKey:(NSString *)appKey {
    SDKConfig* config = [[SDKConfig alloc] init];
    config.appKey = appKey;
    [[Yodo1Manager shared] initWithConfig:config];
}

+ (void)initWithConfig:(SDKConfig*)config {
    [[Yodo1Manager shared] initWithConfig:config];
}

+ (void)initWithPlist {
    SDKConfig* config = [[SDKConfig alloc] init];
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        config.appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    } else {
        config.appKey = @"";
    }
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"RegionCode"]) {
        config.regionCode = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"RegionCode"];
    } else {
        config.regionCode = @"";
    }
    [[Yodo1Manager shared] initWithConfig:config];
}

#pragma mark - Privacy

+ (void)setUserConsent:(BOOL)consent {
    [Yodo1Privacy shareInstance].userConsent = consent;
}

+ (BOOL)isUserConsent {
    return [Yodo1Privacy shareInstance].userConsent;
}

+ (void)setTagForUnderAgeOfConsent:(BOOL)isBelowConsentAge {
    [Yodo1Privacy shareInstance].ageRestrictedUser = isBelowConsentAge;
}

+ (BOOL)isTagForUnderAgeOfConsent {
    return [Yodo1Privacy shareInstance].ageRestrictedUser;
}

+ (void)setDoNotSell:(BOOL)doNotSell {
    [Yodo1Privacy shareInstance].doNotSell = doNotSell;
}

+ (BOOL)isDoNotSell {
    return [Yodo1Privacy shareInstance].doNotSell;
}

#pragma mark - Online Config

+ (NSString *)stringParamsConfigWithKey:(NSString *)key defaultValue:(NSString *)value {
    return [Yd1OnlineParameter.shared stringConfigWithKey:key defaultValue:value];
}

+ (BOOL)boolParamsConfigWithKey:(NSString *)key defaultValue:(bool)value {
    return [Yd1OnlineParameter.shared boolConfigWithKey:key defaultValue:value];
}

#pragma mark - 兑换码功能

+ (void)verifyWithActivationCode:(NSString *)activationCode
                        callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSDictionary* _Nullable error))callback {
    [[Yodo1Manager shared] verifyWithActivationCode:activationCode callback:callback];
}

#pragma mark - Other

+ (NSString *)sdkVersion {
    return Yodo1Tool.shared.sdkVersionValue;
}

+ (NSString *)getDeviceId {
    return Yd1OpsTools.keychainDeviceId;
}

+ (NSString *)getCountryCode {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale localeIdentifier];
    return countryCode;
}

+ (void)openWebPage:(NSString *)url paramter:(NSString *)param {
    YD1LOG(@"url = %@, param = %@", url, param);
    
    if ([param isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } else if ([param isEqualToString:@"0"]) {
        SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url] entersReaderIfAvailable:YES];
        UIViewController *rootViewController = [UIViewController new];
        rootViewController = [Yodo1Commons getRootViewController];
        [rootViewController presentViewController:viewController animated:YES completion:nil];
    }
}


@end
