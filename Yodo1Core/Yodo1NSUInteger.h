//
//  Yodo1NSUInterge.h
//  Yodo1sdk
//
//  Created by hyx on 2020/1/7.
//

#import <Foundation/Foundation.h>
#import "Yodo1Object.h"

NS_ASSUME_NONNULL_BEGIN

#define NSUInteger(v) [Yodo1NSUInteger value:v]

@interface Yodo1NSUInteger : Yodo1Object

@property (nonatomic,assign) NSUInteger value;

+ (Yodo1NSUInteger *)value:(double)value;

@end

NS_ASSUME_NONNULL_END
