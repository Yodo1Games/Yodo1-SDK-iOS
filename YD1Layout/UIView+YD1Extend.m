//
// Created by hyx on 2019-08-16.
// Copyright (c) 2019 hyx. All rights reserved.
//


#import "UIView+YD1Extend.h"

#import <objc/runtime.h>

@implementation UIView (YD1Extend)

- (UIView *)yd1_width {
    self.viewLayoutType = YD1MakeLayoutTypeWidth;
    return self;
}

- (UIView *)yd1_height {
    self.viewLayoutType = YD1MakeLayoutTypeHeight;
    return self;
}

- (UIView *)yd1_left {
    self.viewLayoutType = YD1MakeLayoutTypeLeft;
    return self;
}

- (UIView *)yd1_right {
    self.viewLayoutType = YD1MakeLayoutTypeRight;
    return self;
}

- (UIView *)yd1_top {
    self.viewLayoutType = YD1MakeLayoutTypeTop;
    return self;
}

- (UIView *)yd1_bottom {
    self.viewLayoutType = YD1MakeLayoutTypeBottom;
    return self;
}

- (UIView *)yd1_centerX {
    self.viewLayoutType = YD1MakeLayoutTypeCenterX;
    return self;
}

- (UIView *)yd1_centerY {
    self.viewLayoutType = YD1MakeLayoutTypeCenterY;
    return self;
}

- (UIView *)yd1_center {
    self.viewLayoutType = YD1MakeLayoutTypeCenter;
    return self;
}

#pragma mark - Runtime

- (void)setViewLayoutType:(YD1MakeLayoutType)viewLayoutType {
    objc_setAssociatedObject(self, @selector(viewLayoutType), @(viewLayoutType), OBJC_ASSOCIATION_ASSIGN);
}

- (YD1MakeLayoutType)viewLayoutType {
    return (YD1MakeLayoutType) [objc_getAssociatedObject(self, @selector(viewLayoutType)) integerValue];
}

@end
