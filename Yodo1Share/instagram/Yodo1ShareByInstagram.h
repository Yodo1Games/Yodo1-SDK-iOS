//
//  Yodo1ShareByInstagram.h
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yodo1ShareConstant.h"

@interface Yodo1ShareByInstagram : NSObject

+ (Yodo1ShareByInstagram *)sharedInstance;

#pragma mark - sdk方式分享
- (void)shareWithContent:(ShareContent *)content
                   scene:(Yodo1ShareType)shareType
         completionBlock:(ShareCompletionBlock)aCompletionBlock;

- (BOOL)isInstalledIntagram;

@end
