//
//  Yodo1Double.h
//  Joyhus
//
//  Created by hyx on 2019/8/23.
//  Copyright © 2019 hyx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yodo1Object.h"

NS_ASSUME_NONNULL_BEGIN

#define Double(v) [Yodo1Double value:v]

@interface Yodo1Double : Yodo1Object

@property (nonatomic,assign) double value;

+ (Yodo1Double *)value:(double)value;

@end

NS_ASSUME_NONNULL_END
