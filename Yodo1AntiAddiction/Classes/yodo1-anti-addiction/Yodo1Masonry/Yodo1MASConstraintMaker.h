//
//  Yodo1MASConstraintMaker.h
//  Yodo1Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "Yodo1MASConstraint.h"
#import "Yodo1MASUtilities.h"

typedef NS_OPTIONS(NSInteger, MASAttribute) {
    MASAttributeLeft = 1 << NSLayoutAttributeLeft,
    MASAttributeRight = 1 << NSLayoutAttributeRight,
    MASAttributeTop = 1 << NSLayoutAttributeTop,
    MASAttributeBottom = 1 << NSLayoutAttributeBottom,
    MASAttributeLeading = 1 << NSLayoutAttributeLeading,
    MASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    MASAttributeWidth = 1 << NSLayoutAttributeWidth,
    MASAttributeHeight = 1 << NSLayoutAttributeHeight,
    MASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    MASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    MASAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    MASAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    MASAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    MASAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    MASAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    MASAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    MASAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    MASAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    MASAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    MASAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    MASAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating Yodo1MASConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface Yodo1MASConstraintMaker : NSObject

/**
 *	The following properties return a new Yodo1MASViewConstraint
 *  with the first item set to the makers associated view and the appropriate Yodo1MASViewAttribute
 */
@property (nonatomic, strong, readonly) Yodo1MASConstraint *left;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *top;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *right;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *bottom;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *leading;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *trailing;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *width;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *height;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *centerX;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *centerY;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) Yodo1MASConstraint *firstBaseline;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) Yodo1MASConstraint *leftMargin;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *rightMargin;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *topMargin;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *bottomMargin;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *leadingMargin;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *trailingMargin;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) Yodo1MASConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new Yodo1MASCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  MASAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) Yodo1MASConstraint *(^attributes)(MASAttribute attrs);

/**
 *	Creates a Yodo1MASCompositeConstraint with type Yodo1MASCompositeConstraintTypeEdges
 *  which generates the appropriate Yodo1MASViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) Yodo1MASConstraint *edges;

/**
 *	Creates a Yodo1MASCompositeConstraint with type Yodo1MASCompositeConstraintTypeSize
 *  which generates the appropriate Yodo1MASViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) Yodo1MASConstraint *size;

/**
 *	Creates a Yodo1MASCompositeConstraint with type Yodo1MASCompositeConstraintTypeCenter
 *  which generates the appropriate Yodo1MASViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) Yodo1MASConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any Yodo1MASConstraint are created with this view as the first item
 *
 *	@return	a new Yodo1MASConstraintMaker
 */
- (id)initWithView:(MAS_VIEW *)view;

/**
 *	Calls install method on any Yodo1MASConstraints which have been created by this maker
 *
 *	@return	an array of all the installed Yodo1MASConstraints
 */
- (NSArray *)install;

- (Yodo1MASConstraint * (^)(dispatch_block_t))group;

@end
