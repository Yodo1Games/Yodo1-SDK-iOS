//
//  ImageCloudDocument.m
//  iCloudDemo
//
//  Created by zhaojun on 16/7/4.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import "ImageCloudDocument.h"

@implementation ImageCloudDocument

- (void) setData:(NSString*) base64Str
{
    _data = [[NSData alloc]initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString*) getData
{
    return _base64Str;
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    _base64Str = [contents base64EncodedStringWithOptions: NSDataBase64DecodingIgnoreUnknownCharacters];
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    return _data;
}
@end
