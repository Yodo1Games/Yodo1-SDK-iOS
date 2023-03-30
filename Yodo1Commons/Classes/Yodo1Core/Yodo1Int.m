//
//  Yodo1Int.m
//  Joyhus
//
//  Created by hyx on 2019/8/23.
//  Copyright © 2019 hyx. All rights reserved.
//

#import "Yodo1Int.h"
#import "Yodo1Base.h"

@implementation Yodo1Int

+ (Yodo1Int *)value:(double)value {
    Yodo1Int *d = [Yodo1Base.shared cc_init:[Yodo1Int class]];
    d.value = value;
    return d;
}

@end
