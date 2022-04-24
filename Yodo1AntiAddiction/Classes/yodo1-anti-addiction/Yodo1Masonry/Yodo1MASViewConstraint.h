//
//  Yodo1MASViewConstraint.h
//  Yodo1Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "Yodo1MASViewAttribute.h"
#import "Yodo1MASConstraint.h"
#import "Yodo1MASLayoutConstraint.h"
#import "Yodo1MASUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface Yodo1MASViewConstraint : Yodo1MASConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *secondViewAttribute;

/**
 *	initialises the Yodo1MASViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.mas_left, view.mas_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(Yodo1MASViewAttribute *)firstViewAttribute;

/**
 *  Returns all Yodo1MASViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of Yodo1MASViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(MAS_VIEW *)view;

@end
