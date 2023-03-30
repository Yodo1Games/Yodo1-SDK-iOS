//
//  Yodo1Double.m
//  Joyhus
//
//  Created by hyx on 2019/8/23.
//  Copyright © 2019 hyx. All rights reserved.
//

#import "Yodo1Double.h"
#import "Yodo1Base.h"

@implementation Yodo1Double

+ (Yodo1Double *)value:(double)value {
    Yodo1Double *d = [Yodo1Base.shared cc_init:[Yodo1Double class]];
    d.value = value;
    return d;
}

@end
