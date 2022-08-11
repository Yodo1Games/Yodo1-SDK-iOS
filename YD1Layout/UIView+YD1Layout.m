
#import "UIView+YD1Layout.h"

#import <objc/runtime.h>

@implementation UIView (YD1Layout)

#pragma mark - Make

- (void)makeLayout:(YD1ViewLayout)layout {
    if (!self.yd1_state || [self.yd1_state integerValue] != 0) {
        return;
    }
    
    self.yd1_state = @0;
    [self layout:layout state:self.yd1_state];
}

- (void)remakeLayout:(YD1ViewLayout)layout {
    self.yd1_state = @0;
    [self layout:layout state:self.yd1_state];
}

- (void)updateLayout:(YD1ViewLayout)layout {
    self.yd1_state = @([self.yd1_state integerValue] + 1);
    [self layout:layout state:self.yd1_state];
}

- (void)layout:(YD1ViewLayout)layout state:(NSNumber *)state {
    [YD1MakeLayout configView:self state:state layout:layout];
}

#pragma mark - Runtime

- (void)setYd1_state:(NSNumber *)yd1_state {
    objc_setAssociatedObject(self, @selector(yd1_state), yd1_state, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)yd1_state {
    NSNumber *yd1_state = objc_getAssociatedObject(self, @selector(yd1_state));
    return (yd1_state) ?: @0;
}

@end
