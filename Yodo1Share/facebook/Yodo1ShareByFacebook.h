//
//  Yodo1ShareByFacebook.h
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yodo1ShareConstant.h"

@interface Yodo1ShareByFacebook : NSObject

+ (Yodo1ShareByFacebook *)sharedInstance;

- (void)initFacebookWithAppId:(NSString *)appId;

#pragma mark - sdk方式分享
- (void)shareWithContent:(ShareContent *)content
                   scene:(Yodo1ShareType)shareType
         completionBlock:(ShareCompletionBlock)aCompletionBlock;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options;

// Still need this for iOS8
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation;

- (BOOL)isInstallFacebook;

@end
