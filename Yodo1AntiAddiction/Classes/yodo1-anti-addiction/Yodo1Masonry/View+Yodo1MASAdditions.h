//
//  UIView+Yodo1MASAdditions.h
//  Yodo1Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "Yodo1MASUtilities.h"
#import "Yodo1MASConstraintMaker.h"
#import "Yodo1MASViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating Yodo1MASViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface MAS_VIEW (Yodo1MASAdditions)

/**
 *	following properties return a new Yodo1MASViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_left;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_top;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_right;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_bottom;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_leading;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_trailing;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_width;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_height;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_centerX;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_centerY;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_baseline;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *(^mas_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_firstBaseline;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_leftMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_rightMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_topMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_bottomMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_leadingMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_trailingMargin;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_centerXWithinMargins;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id mas_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)mas_closestCommonSuperview:(MAS_VIEW *)view;

/**
 *  Creates a Yodo1MASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created Yodo1MASConstraints
 */
- (NSArray *)mas_makeConstraints:(void(NS_NOESCAPE ^)(Yodo1MASConstraintMaker *make))block;

/**
 *  Creates a Yodo1MASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated Yodo1MASConstraints
 */
- (NSArray *)mas_updateConstraints:(void(NS_NOESCAPE ^)(Yodo1MASConstraintMaker *make))block;

/**
 *  Creates a Yodo1MASConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated Yodo1MASConstraints
 */
- (NSArray *)mas_remakeConstraints:(void(NS_NOESCAPE ^)(Yodo1MASConstraintMaker *make))block;

@end
