
#import <UIKit/UIKit.h>
#import "YD1MakeLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (YD1Layout)

/*
 Apply new configuration state without frame updating.
 */
@property(nonatomic) NSNumber *yd1_state;

- (void)makeLayout:(YD1ViewLayout)layout;

- (void)remakeLayout:(YD1ViewLayout)layout;

- (void)updateLayout:(YD1ViewLayout)layout;

- (void)layout:(YD1ViewLayout)layout state:(NSNumber *)state;

@end

NS_ASSUME_NONNULL_END
