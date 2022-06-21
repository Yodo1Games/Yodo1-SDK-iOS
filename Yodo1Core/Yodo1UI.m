//
//  Yodo1ShareUI.m
//  Yodo1sdk
//
//  Created by hyx on 2019/11/28.
//

#import "Yodo1UI.h"

@implementation Yodo1UI

+ (instancetype)shared {
    return [Yodo1Base.shared cc_registerSharedInstance:self];
}

@end
