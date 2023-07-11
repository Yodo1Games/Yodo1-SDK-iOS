//
// Created by hyx on 2019-08-15.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YD1LayoutUtils.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YD1MakeLayoutType) {
    YD1MakeLayoutTypeNone,
    YD1MakeLayoutTypeLeft,
    YD1MakeLayoutTypeRight,
    YD1MakeLayoutTypeTop,
    YD1MakeLayoutTypeBottom,
    YD1MakeLayoutTypeCenterX,
    YD1MakeLayoutTypeCenterY,
    YD1MakeLayoutTypeCenter,
    YD1MakeLayoutTypeHeight,
    YD1MakeLayoutTypeWidth,
    YD1MakeLayoutTypeSize,
    YD1MakeLayoutTypeEdges,
};

typedef NS_ENUM(NSUInteger, YD1EqualType) {
    YD1EqualNone,
    YD1EqualTo,
    YD1GreaterThanOrEqualTo,
    YD1LessThanOrEqualTo,
};

@interface YD1ViewLayoutInfonce : NSObject

@property(nonatomic, assign) YD1MakeLayoutType makeLayoutType;
@property(nonatomic, assign) YD1MakeLayoutType viewLayoutType;
@property(nonatomic, assign) YD1EqualType equalType;
@property(nonatomic, assign) BOOL isNum;
@property(nonatomic, assign) CGFloat multiplied;
@property(nonatomic, assign) NSInteger priority;

@property(nonatomic, weak) UIView *relateView;
@property(nonatomic, assign) CGFloat value;
@property(nonatomic, assign) CGPoint point;
@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) YD1EdgeInsets insets;

- (instancetype)initWithMakeLayoutType:(YD1MakeLayoutType)makeLayoutType;

+ (instancetype)viewInfoWithMakeLayoutType:(YD1MakeLayoutType)makeLayoutType;

- (void)changeAttribute:(id)attribute equalType:(YD1EqualType)equalType;

- (void)setAttribute:(NSValue *)value;

@end

NS_ASSUME_NONNULL_END
