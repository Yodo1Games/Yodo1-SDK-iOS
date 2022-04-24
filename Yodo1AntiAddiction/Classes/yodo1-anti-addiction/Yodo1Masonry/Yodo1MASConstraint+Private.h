//
//  Yodo1MASConstraint+Private.h
//  Yodo1Masonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "Yodo1MASConstraint.h"

@protocol Yodo1MASConstraintDelegate;


@interface Yodo1MASConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually Yodo1MASConstraintMaker but could be a parent Yodo1MASConstraint
 */
@property (nonatomic, weak) id<Yodo1MASConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with MASEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface Yodo1MASConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    Yodo1MASViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (Yodo1MASConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (Yodo1MASConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol Yodo1MASConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A Yodo1MASViewConstraint may turn into a Yodo1MASCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(Yodo1MASConstraint *)constraint shouldBeReplacedWithConstraint:(Yodo1MASConstraint *)replacementConstraint;

- (Yodo1MASConstraint *)constraint:(Yodo1MASConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
