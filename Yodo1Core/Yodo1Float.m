//
//  Yodo1Float.m
//  Joyhus
//
//  Created by hyx on 2019/8/23.
//  Copyright © 2019 hyx. All rights reserved.
//

#import "Yodo1Float.h"
#import "Yodo1Base.h"

@implementation Yodo1Float

+ (Yodo1Float *)value:(double)value {
    Yodo1Float *d = [Yodo1Base.shared cc_init:[Yodo1Float class]];
    d.value = value;
    return d;
}

@end
