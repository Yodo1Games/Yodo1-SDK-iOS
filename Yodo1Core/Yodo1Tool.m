//
//  Yodo1Tool.m
//  Yodo1sdk
//
//  Created by hyx on 2020/2/3.
//

#import "Yodo1Tool.h"

@implementation Yodo1Tool

+ (instancetype)shared {
    return [Yodo1Base.shared cc_registerSharedInstance:self];
}

@end
