//
//  Yodo1Point.m
//  Yodo1sdk
//
//  Created by hyx on 2020/1/8.
//

#import "Yodo1Point.h"
#import "Yodo1Base.h"

@implementation Yodo1Point

+ (Yodo1Point *)valueX:(CGFloat)x y:(CGFloat)y {
    Yodo1Point *point = [Yodo1Base.shared cc_init:[Yodo1Point class]];
    point.x = x;
    point.y = y;
    point.point = CGPointMake(x, y);
    return point;
}

@end
