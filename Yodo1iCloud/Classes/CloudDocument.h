//
//  CloudDocument.h
//  iCloudDemo
//
//  Created by zhaojun on 16/7/4.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Document type
 */
@interface CloudDocument : UIDocument
{
    NSData* _data;
    NSString* _base64Str;
}

- (void)setData:(NSString* __nullable) base64Str;

- (NSString* __nullable) getData;

@end
