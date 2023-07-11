//
//  Yodo1Int.h
//  Joyhus
//
//  Created by hyx on 2019/8/23.
//  Copyright © 2019 hyx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yodo1Object.h"

NS_ASSUME_NONNULL_BEGIN

#define Int(v) [Yodo1Int value:v]

@interface Yodo1Int : Yodo1Object

@property (nonatomic,assign) int value;

+ (Yodo1Int *)value:(double)value;

@end

NS_ASSUME_NONNULL_END
