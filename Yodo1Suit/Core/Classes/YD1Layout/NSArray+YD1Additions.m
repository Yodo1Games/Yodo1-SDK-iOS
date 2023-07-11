//
// Created by hyx on 2019-08-22.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import "NSArray+YD1Additions.h"

#import "UIView+YD1Layout.h"
#import "UIView+YD1Addition.h"

@implementation NSArray (YD1Additions)

- (NSArray *)makeLayouts:(YD1ViewLayout)layout {
    NSMutableArray *constraints = [NSMutableArray array];
    for (UIView *view in self) {
        [view makeLayout:layout];
        [constraints addObject:view];
    }
    return constraints;
}

- (NSArray *)remakeLayouts:(YD1ViewLayout)layout {
    NSMutableArray *constraints = [NSMutableArray array];
    for (UIView *view in self) {
        [view remakeLayout:layout];
        [constraints addObject:view];
    }
    return constraints;
}

- (NSArray *)updateLayouts:(YD1ViewLayout)layout {
    NSMutableArray *constraints = [NSMutableArray array];
    for (UIView *view in self) {
        [view updateLayout:layout];
        [constraints addObject:view];
    }
    return constraints;
}

- (NSArray *)layouts:(YD1ViewLayout)layout state:(NSNumber *)state {
    NSMutableArray *constraints = [NSMutableArray array];
    for (UIView *view in self) {
        [view layout:layout state:state];
        [constraints addObject:view];
    }
    return constraints;
}

- (void)distributeViewsAlongAxis:(YD1AxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count > 1, @"views to distribute need to bigger than one");
        return;
    }
    
    UIView *tempSuperView = [self commonSuperviewOfViews];
    
    if (axisType == YD1AxisTypeHorizontal) {
        CGFloat width = CGRectGetWidth(tempSuperView.frame);
        width = (width - leadSpacing + tailSpacing - (self.count - 1) * fixedSpacing) / self.count;
        
        UIView *prev;
        for (int i = 0; i < self.count; i++) {
            UIView *v = self[i];
            [v makeLayout:^(YD1MakeLayout *make) {
                make.width.yd1_equalTo(width);
                if (prev) {
                    make.left.equalTo(prev.yd1_right).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(tailSpacing);
                    }
                } else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    } else {
        CGFloat height = CGRectGetHeight(tempSuperView.frame);
        height = (height - leadSpacing + tailSpacing - (self.count - 1) * fixedSpacing) / self.count;
        
        UIView *prev;
        for (int i = 0; i < self.count; i++) {
            UIView *v = self[i];
            [v makeLayout:^(YD1MakeLayout *make) {
                make.height.yd1_equalTo(height);
                if (prev) {
                    make.top.equalTo(prev.yd1_bottom).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(tailSpacing);
                    }
                } else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
}

- (void)distributeViewsAlongAxis:(YD1AxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count > 1, @"views to distribute need to bigger than one");
        return;
    }
    
    UIView *tempSuperView = [self commonSuperviewOfViews];
    
    if (axisType == YD1AxisTypeHorizontal) {
        CGFloat fixedSpacing = CGRectGetWidth(tempSuperView.frame);
        fixedSpacing = (fixedSpacing - fixedItemLength * self.count - leadSpacing + tailSpacing) / (self.count - 1);
        UIView *prev;
        for (int i = 0; i < self.count; i++) {
            UIView *v = self[i];
            [v makeLayout:^(YD1MakeLayout *make) {
                make.width.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(tailSpacing);
                    } else {
                        make.left.equalTo(prev.yd1_right).offset(fixedSpacing);
                    }
                } else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    } else {
        CGFloat fixedSpacing = CGRectGetHeight(tempSuperView.frame);
        fixedSpacing = (fixedSpacing - fixedItemLength * self.count - leadSpacing + tailSpacing) / (self.count - 1);
        
        UIView *prev;
        for (int i = 0; i < self.count; i++) {
            UIView *v = self[i];
            [v makeLayout:^(YD1MakeLayout *make) {
                make.height.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(tailSpacing);
                    } else {
                        make.top.equalTo(prev.yd1_bottom).offset(fixedSpacing);
                    }
                } else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
}

- (UIView *)commonSuperviewOfViews {
    UIView *commonSuperview = nil;
    UIView *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *) object;
            if (previousView) {
                commonSuperview = [view vv_closestCommonSuperview:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

@end
