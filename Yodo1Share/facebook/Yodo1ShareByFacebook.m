//
//  Yodo1ShareByFacebook.m
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1ShareByFacebook.h"
#import "Yodo1SNSManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface Yodo1ShareByFacebook ()<FBSDKSharingDelegate>
{
    Yodo1SNSType _snsType;
    SNSShareCompletionBlock completionBlock;
    
}

@property(nonatomic,strong)FBSDKShareDialog* shareDialog;

- (UIViewController*)getRootViewController;
- (UIViewController*)topMostViewController:(UIViewController*)controller;

@end

@implementation Yodo1ShareByFacebook

+ (Yodo1ShareByFacebook *)sharedInstance
{
    static Yodo1ShareByFacebook *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1ShareByFacebook alloc] init];
    });
    return sharedInstance;
}

- (void)initFacebookWithAppId:(NSString *)appId {
    if (_shareDialog == nil) {
        _shareDialog = [[FBSDKShareDialog alloc] initWithViewController:[self getRootViewController] content:nil delegate:self];
    }
}

- (void)dealloc {
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                                   options:options];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


- (BOOL)isInstallFacebook {
    
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
     
    if (isInstalled) {
        return YES;
    } else {
        return NO;
    }
}

- (void)shareWithContent:(SMContent *)content
                   scene:(Yodo1SNSType)snsType
         completionBlock:(SNSShareCompletionBlock)aCompletionBlock
{
    completionBlock = [aCompletionBlock copy];
    _snsType = snsType;
    if (self.shareDialog == nil) {
        if(completionBlock){
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"没有初始化",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            completionBlock(snsType,Yodo1ShareContentStateUnInstalled,error);
        }
        completionBlock = nil;
        return;
    }
    
    
    if (![self isInstallFacebook]) {
        if(completionBlock){
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"客户端没有安装",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            completionBlock(snsType,Yodo1ShareContentStateUnInstalled,error);
        }
        completionBlock = nil;
        return;
    }
    
    NSString *status = content.desc;
    NSString *url = content.url;
    NSURL* contentUrl = [NSURL URLWithString:url];

    FBSDKShareLinkContent *shareLinkContent = [[FBSDKShareLinkContent alloc] init];
    shareLinkContent.contentURL = contentUrl;
    shareLinkContent.quote = status;
    
    [FBSDKShareDialog showFromViewController:[self getRootViewController]
                                 withContent:shareLinkContent
                                    delegate:self];
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    if(completionBlock){
        completionBlock(_snsType,Yodo1ShareContentStateSuccess,nil);
    }
    completionBlock = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    if(completionBlock){
        completionBlock(_snsType,Yodo1ShareContentStateFail,error);
    }
    completionBlock = nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"share cancelled",
                                NSLocalizedFailureReasonErrorKey : @"",
                                NSLocalizedRecoverySuggestionErrorKey : @""};
    
    NSError *error = [NSError errorWithDomain:@"SNSShare" code:-1 userInfo:errorDict];
    
    if(completionBlock){
        completionBlock(_snsType,Yodo1ShareContentStateCancel,error);
    }
    completionBlock = nil;
}

- (UIViewController*)getRootViewController {
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

- (UIViewController*)topMostViewController:(UIViewController*)controller {
    BOOL isPresenting = NO;
    do {
        UIViewController* presented = [controller presentedViewController];
        isPresenting = presented != nil;
        if (presented != nil) {
            controller = presented;
        }
        
    } while (isPresenting);
    
    return controller;
}

@end
