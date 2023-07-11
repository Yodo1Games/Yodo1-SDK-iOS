//
//  Yodo1Float.h
//  Joyhus
//
//  Created by hyx on 2019/8/23.
//  Copyright © 2019 hyx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yodo1Object.h"

NS_ASSUME_NONNULL_BEGIN

#define Float(v) [Yodo1Float value:v]

@interface Yodo1Float : Yodo1Object

@property (nonatomic,assign) float value;

+ (Yodo1Float *)value:(double)value;

@end

NS_ASSUME_NONNULL_END
