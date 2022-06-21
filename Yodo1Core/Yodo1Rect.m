//
//  Yodo1Rect.m
//  Yodo1sdk
//
//  Created by hyx on 2020/1/8.
//

#import "Yodo1Rect.h"
#import "Yodo1Base.h"

@implementation Yodo1Rect

+ (Yodo1Rect *)valueX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height {
    Yodo1Rect *rect = [Yodo1Base.shared cc_init:[Yodo1Rect class]];
    rect.x = x;
    rect.y = y;
    rect.maxX = x + width;
    rect.maxY = y + height;
    rect.centerX = x + width/2;
    rect.centerY = y + height/2;
    rect.width = width;
    rect.height = height;
    rect.rect = CGRectMake(x, y, width, height);
    return rect;
}

@end
