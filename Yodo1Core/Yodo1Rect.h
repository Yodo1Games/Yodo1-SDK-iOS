//
//  Yodo1Rect.h
//  Yodo1sdk
//
//  Created by hyx on 2020/1/8.
//

#import <UIKit/UIKit.h>
#import "Yodo1Object.h"
#import "Yodo1Point.h"
#import "Yodo1Size.h"

NS_ASSUME_NONNULL_BEGIN

#define Rect(xValue,yValue,widthValue,heightValue) [Yodo1Rect valueX:xValue y:yValue width:widthValue height:heightValue]

@interface Yodo1Rect : Yodo1Object

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat maxX;
@property (nonatomic, assign) CGFloat maxY;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGRect rect;

+ (Yodo1Rect *)valueX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
