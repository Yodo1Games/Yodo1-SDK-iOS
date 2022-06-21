//
//  Yodo1Size.m
//  Yodo1sdk
//
//  Created by hyx on 2020/1/8.
//

#import "Yodo1Size.h"
#import "Yodo1Base.h"

@implementation Yodo1Size

+ (Yodo1Size *)valueWidth:(CGFloat)width height:(CGFloat)height {
    Yodo1Size *size = [Yodo1Base.shared cc_init:[Yodo1Size class]];
    size.width = width;
    size.height = height;
    size.size = CGSizeMake(width, height);
    return size;
}

@end
