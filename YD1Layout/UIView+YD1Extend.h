//
// Created by hyx on 2019-08-16.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YD1ViewLayoutInfonce.h"

@interface UIView (YD1Extend)

@property(nonatomic, assign) YD1MakeLayoutType viewLayoutType;

@property(nonatomic, readonly) UIView *yd1_width;
@property(nonatomic, readonly) UIView *yd1_height;
@property(nonatomic, readonly) UIView *yd1_left;
@property(nonatomic, readonly) UIView *yd1_right;
@property(nonatomic, readonly) UIView *yd1_top;
@property(nonatomic, readonly) UIView *yd1_bottom;
@property(nonatomic, readonly) UIView *yd1_centerX;
@property(nonatomic, readonly) UIView *yd1_centerY;
@property(nonatomic, readonly) UIView *yd1_center;

@end
