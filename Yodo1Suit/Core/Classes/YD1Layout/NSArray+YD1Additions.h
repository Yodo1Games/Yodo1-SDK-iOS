//
// Created by hyx on 2019-08-22.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YD1Layout.h"

typedef NS_ENUM(NSUInteger, YD1AxisType) {
    YD1AxisTypeHorizontal,
    YD1AxisTypeVertical
};

@interface NSArray (YD1Additions)

- (NSArray *)makeLayouts:(YD1ViewLayout)layout;

- (NSArray *)remakeLayouts:(YD1ViewLayout)layout;

- (NSArray *)updateLayouts:(YD1ViewLayout)layout;

- (NSArray *)layouts:(YD1ViewLayout)layout state:(NSNumber *)state;


/**
 *  distribute with fixed spacing
 *
 *  @param axisType     横排还是竖排
 *  @param fixedSpacing 两个控件间隔
 *  @param leadSpacing  第一个控件与边缘的间隔
 *  @param tailSpacing  最后一个控件与边缘的间隔
 */
- (void)distributeViewsAlongAxis:(YD1AxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing;

/**
 *  distribute with fixed item size
 *
 *  @param axisType        横排还是竖排
 *  @param fixedItemLength 控件的宽或高
 *  @param leadSpacing     第一个控件与边缘的间隔
 *  @param tailSpacing     最后一个控件与边缘的间隔
 */
- (void)distributeViewsAlongAxis:(YD1AxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing;

@end
