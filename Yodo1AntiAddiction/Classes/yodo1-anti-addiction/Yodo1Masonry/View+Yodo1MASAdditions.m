//
//  UIView+Yodo1MASAdditions.m
//  Yodo1Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+Yodo1MASAdditions.h"
#import <objc/runtime.h>

@implementation MAS_VIEW (Yodo1MASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(Yodo1MASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    Yodo1MASConstraintMaker *constraintMaker = [[Yodo1MASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_updateConstraints:(void(^)(Yodo1MASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    Yodo1MASConstraintMaker *constraintMaker = [[Yodo1MASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_remakeConstraints:(void(^)(Yodo1MASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    Yodo1MASConstraintMaker *constraintMaker = [[Yodo1MASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (Yodo1MASViewAttribute *)mas_left {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (Yodo1MASViewAttribute *)mas_top {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (Yodo1MASViewAttribute *)mas_right {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (Yodo1MASViewAttribute *)mas_bottom {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (Yodo1MASViewAttribute *)mas_leading {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (Yodo1MASViewAttribute *)mas_trailing {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (Yodo1MASViewAttribute *)mas_width {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (Yodo1MASViewAttribute *)mas_height {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (Yodo1MASViewAttribute *)mas_centerX {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (Yodo1MASViewAttribute *)mas_centerY {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (Yodo1MASViewAttribute *)mas_baseline {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (Yodo1MASViewAttribute *(^)(NSLayoutAttribute))mas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (Yodo1MASViewAttribute *)mas_firstBaseline {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (Yodo1MASViewAttribute *)mas_lastBaseline {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (Yodo1MASViewAttribute *)mas_leftMargin {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (Yodo1MASViewAttribute *)mas_rightMargin {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (Yodo1MASViewAttribute *)mas_topMargin {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (Yodo1MASViewAttribute *)mas_bottomMargin {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (Yodo1MASViewAttribute *)mas_leadingMargin {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (Yodo1MASViewAttribute *)mas_trailingMargin {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (Yodo1MASViewAttribute *)mas_centerXWithinMargins {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (Yodo1MASViewAttribute *)mas_centerYWithinMargins {
    return [[Yodo1MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

- (Yodo1MASViewAttribute *)mas_safeAreaLayoutGuide {
    return [[Yodo1MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (Yodo1MASViewAttribute *)mas_safeAreaLayoutGuideTop {
    return [[Yodo1MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (Yodo1MASViewAttribute *)mas_safeAreaLayoutGuideBottom {
    return [[Yodo1MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (Yodo1MASViewAttribute *)mas_safeAreaLayoutGuideLeft {
    return [[Yodo1MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}
- (Yodo1MASViewAttribute *)mas_safeAreaLayoutGuideRight {
    return [[Yodo1MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

#endif

#pragma mark - associated properties

- (id)mas_key {
    return objc_getAssociatedObject(self, @selector(mas_key));
}

- (void)setMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(mas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas_closestCommonSuperview:(MAS_VIEW *)view {
    MAS_VIEW *closestCommonSuperview = nil;

    MAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        MAS_VIEW *firstViewSuperview = self;
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
