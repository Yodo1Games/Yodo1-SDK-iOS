//
//  NSArray+Yodo1MASShorthandAdditions.h
//  Yodo1Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+Yodo1MASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand array additions without the 'mas_' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface NSArray (Yodo1MASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(Yodo1MASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(Yodo1MASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(Yodo1MASConstraintMaker *make))block;

@end

@implementation NSArray (Yodo1MASShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(Yodo1MASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(Yodo1MASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(Yodo1MASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
