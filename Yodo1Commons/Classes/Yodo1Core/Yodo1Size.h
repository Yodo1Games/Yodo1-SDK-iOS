//
//  Yodo1Size.h
//  Yodo1sdk
//
//  Created by hyx on 2020/1/8.
//

#import <UIKit/UIKit.h>
#import "Yodo1Object.h"

NS_ASSUME_NONNULL_BEGIN

#define Size(widthValue,heightValue) [Yodo1Size valueWidth:widthValue height:heightValue]

@interface Yodo1Size : Yodo1Object

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

+ (Yodo1Size *)valueWidth:(CGFloat)width height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
