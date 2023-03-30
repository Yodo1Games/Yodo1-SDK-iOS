//
//  Yodo1NSUInterge.m
//  Yodo1sdk
//
//  Created by hyx on 2020/1/7.
//

#import "Yodo1NSUInteger.h"
#import "Yodo1Base.h"

@implementation Yodo1NSUInteger

+ (Yodo1NSUInteger *)value:(double)value {
    Yodo1NSUInteger *d = [Yodo1Base.shared cc_init:[Yodo1NSUInteger class]];
    d.value = value;
    return d;
}

@end
