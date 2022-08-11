//
// Created by hyx on 2019-08-22.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import "UIView+YD1Addition.h"

@implementation UIView (YD1Addition)

- (instancetype)vv_closestCommonSuperview:(UIView *)view {
    UIView *closestCommonSuperview = nil;
    
    UIView *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        UIView *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
