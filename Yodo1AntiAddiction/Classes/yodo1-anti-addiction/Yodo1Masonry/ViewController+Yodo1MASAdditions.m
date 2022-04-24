//
//  UIViewController+Yodo1MASAdditions.m
//  Yodo1Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+Yodo1MASAdditions.h"

#ifdef MAS_VIEW_CONTROLLER

@implementation MAS_VIEW_CONTROLLER (Yodo1MASAdditions)

- (Yodo1MASViewAttribute *)mas_topLayoutGuide {
    return [[Yodo1MASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (Yodo1MASViewAttribute *)mas_topLayoutGuideTop {
    return [[Yodo1MASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (Yodo1MASViewAttribute *)mas_topLayoutGuideBottom {
    return [[Yodo1MASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (Yodo1MASViewAttribute *)mas_bottomLayoutGuide {
    return [[Yodo1MASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (Yodo1MASViewAttribute *)mas_bottomLayoutGuideTop {
    return [[Yodo1MASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (Yodo1MASViewAttribute *)mas_bottomLayoutGuideBottom {
    return [[Yodo1MASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
