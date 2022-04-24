//
//  UIView+Yodo1MASShorthandAdditions.h
//  Yodo1Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+Yodo1MASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand view additions without the 'mas_' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface MAS_VIEW (Yodo1MASShorthandAdditions)

@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *left;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *top;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *right;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *bottom;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *leading;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *trailing;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *width;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *height;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *centerX;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *centerY;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *baseline;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *topMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

- (NSArray *)makeConstraints:(void(^)(Yodo1MASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(Yodo1MASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(Yodo1MASConstraintMaker *make))block;

@end

#define MAS_ATTR_FORWARD(attr)  \
- (Yodo1MASViewAttribute *)attr {    \
    return [self mas_##attr];   \
}

@implementation MAS_VIEW (Yodo1MASShorthandAdditions)

MAS_ATTR_FORWARD(top);
MAS_ATTR_FORWARD(left);
MAS_ATTR_FORWARD(bottom);
MAS_ATTR_FORWARD(right);
MAS_ATTR_FORWARD(leading);
MAS_ATTR_FORWARD(trailing);
MAS_ATTR_FORWARD(width);
MAS_ATTR_FORWARD(height);
MAS_ATTR_FORWARD(centerX);
MAS_ATTR_FORWARD(centerY);
MAS_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

MAS_ATTR_FORWARD(firstBaseline);
MAS_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

MAS_ATTR_FORWARD(leftMargin);
MAS_ATTR_FORWARD(rightMargin);
MAS_ATTR_FORWARD(topMargin);
MAS_ATTR_FORWARD(bottomMargin);
MAS_ATTR_FORWARD(leadingMargin);
MAS_ATTR_FORWARD(trailingMargin);
MAS_ATTR_FORWARD(centerXWithinMargins);
MAS_ATTR_FORWARD(centerYWithinMargins);

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

MAS_ATTR_FORWARD(safeAreaLayoutGuideTop);
MAS_ATTR_FORWARD(safeAreaLayoutGuideBottom);
MAS_ATTR_FORWARD(safeAreaLayoutGuideLeft);
MAS_ATTR_FORWARD(safeAreaLayoutGuideRight);

#endif

- (Yodo1MASViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self mas_attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(Yodo1MASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(Yodo1MASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(Yodo1MASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
