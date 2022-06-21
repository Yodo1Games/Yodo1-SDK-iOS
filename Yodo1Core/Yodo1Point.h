//
//  Yodo1Point.h
//  Yodo1sdk
//
//  Created by hyx on 2020/1/8.
//

#import <UIKit/UIKit.h>
#import "Yodo1Object.h"

NS_ASSUME_NONNULL_BEGIN

#define Point(xValue,yValue) [Yodo1Point valueX:xValue y:yValue]

@interface Yodo1Point : Yodo1Object

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGPoint point;

+ (Yodo1Point *)valueX:(CGFloat)x y:(CGFloat)y;

@end

NS_ASSUME_NONNULL_END
