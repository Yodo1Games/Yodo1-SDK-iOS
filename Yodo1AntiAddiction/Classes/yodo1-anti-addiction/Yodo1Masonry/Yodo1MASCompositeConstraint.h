//
//  Yodo1MASCompositeConstraint.h
//  Yodo1Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "Yodo1MASConstraint.h"
#import "Yodo1MASUtilities.h"

/**
 *	A group of Yodo1MASConstraint objects
 */
@interface Yodo1MASCompositeConstraint : Yodo1MASConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child Yodo1MASConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
