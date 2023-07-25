//
//  Yodo1ShareByQQ.h
//  foundation
//
//  Created by Nyxon on 14-8-4.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yodo1ShareContent.h"

@interface Yodo1ShareByQQ : NSObject

+ (Yodo1ShareByQQ *)sharedInstance;

- (void)initQQWithAppId:(NSString *)appId
          universalLink:(NSString *)universalLink;

#pragma mark - sdk方式分享
- (void)shareWithContent:(ShareContent *)content
                   scene:(Yodo1ShareType)shareType
         completionBlock:(ShareCompletionBlock)aCompletionBlock;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options;

@end
