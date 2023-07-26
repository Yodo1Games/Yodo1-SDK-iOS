//
//  Yodo1ShareBySinaWeibo.h
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yodo1ShareContent.h"

@interface Yodo1ShareBySinaWeibo : NSObject

+ (Yodo1ShareBySinaWeibo *)sharedInstance;

- (void)initSinaWeiboWithAppKey:(NSString *)appKey
                  universalLink:(NSString *)universalLink;

#pragma mark - sdk方式分享
- (void)shareWithContent:(ShareContent *)content
                   scene:(Yodo1ShareType)shareType
         completionBlock:(ShareCompletionBlock)aCompletionBlock;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options;
@end
