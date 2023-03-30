//
//  Yodo1ClassWrapper.m
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1ClassWrapper.h"

@interface Yodo1ClassWrapper ()
{
    Class _theYodo1Class;
    BOOL _theEnable;
    NSString* _type;
}

@end

@implementation Yodo1ClassWrapper

@synthesize theYodo1Class = _theYodo1Class;
@synthesize theEnable = _theEnable;
@synthesize theHide = _theHide;
@synthesize type = _type;

- (id)initWithClass:(Class)c classType:(NSString *)classType{
    self = [super init];
    if (self != nil) {
        _theYodo1Class = c;
        _theEnable = YES;
        _theHide = NO;
        _type = classType;
    }
    return self;
}

@end
