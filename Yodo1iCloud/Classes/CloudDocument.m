//
//  CloudDocument.m
//  iCloudDemo
//
//  Created by zhaojun on 16/7/4.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import "CloudDocument.h"

@interface CloudDocument()

@end

@implementation CloudDocument

- (BOOL)loadFromContents:(id)contents
                  ofType:(NSString *)typeName
                   error:(NSError **)outError
{
    _data = contents;
    return YES;
}

- (id)contentsForType:(NSString *)typeName
                error:(NSError **)outError
{
    return _data;
}

- (void) setData:(NSString *)base64Str
{
    _data = [base64Str dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*) getData
{
    return [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
}

@end
