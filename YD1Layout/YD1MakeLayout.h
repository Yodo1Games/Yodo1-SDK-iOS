//
// Created by hyx on 2019-08-15.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YD1LayoutUtils.h"

#define yd1_equalTo(...)                 equalTo(YD1BoxValue((__VA_ARGS__)))
#define yd1_offset(...)                  valueOffset(YD1BoxValue((__VA_ARGS__)))

@class YD1MakeLayout;

typedef void (^YD1ViewLayout)(YD1MakeLayout *make);

@interface YD1MakeLayout : NSObject

+ (void)configView:(UIView *)view layout:(YD1ViewLayout)layout;

+ (void)configView:(UIView *)view state:(NSNumber *)state layout:(YD1ViewLayout)layout;

- (YD1MakeLayout *)and;

- (YD1MakeLayout *)with;

- (YD1MakeLayout *)left;

- (YD1MakeLayout *)right;

- (YD1MakeLayout *)top;

- (YD1MakeLayout *)bottom;

- (YD1MakeLayout *)centerX;

- (YD1MakeLayout *)centerY;

- (YD1MakeLayout *)center;

- (YD1MakeLayout *)width;

- (YD1MakeLayout *)height;

- (YD1MakeLayout *)edges;

- (YD1MakeLayout *)size;

- (YD1MakeLayout *(^)(CGFloat))offset;

- (YD1MakeLayout *(^)(CGSize))sizeOffset;

- (YD1MakeLayout *(^)(CGPoint))centerOffset;

- (YD1MakeLayout *(^)(YD1EdgeInsets))insets;

- (YD1MakeLayout *(^)(NSValue *))valueOffset;

- (YD1MakeLayout *(^)(id))equalTo;

- (YD1MakeLayout *(^)(CGFloat))multipliedBy;

- (YD1MakeLayout *(^)(NSInteger))priority;

- (YD1MakeLayout *)container;

- (YD1MakeLayout *)sizeToFit;

- (YD1MakeLayout *)widthToFit;

- (YD1MakeLayout *)heightToFit;

- (YD1MakeLayout *(^)(CGSize size))sizeThatFits;

- (YD1MakeLayout *(^)(CGFloat))heightThatFits;

- (YD1MakeLayout *(^)(CGFloat))widthThatFits;

@end

@interface YD1MakeLayout (AutoboxingSupport)

- (YD1MakeLayout *(^)(id))yd1_equalTo;

@end
