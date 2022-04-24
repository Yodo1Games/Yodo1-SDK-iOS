//
//  UIViewController+Yodo1MASAdditions.h
//  Yodo1Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "Yodo1MASUtilities.h"
#import "Yodo1MASConstraintMaker.h"
#import "Yodo1MASViewAttribute.h"

#ifdef MAS_VIEW_CONTROLLER

@interface MAS_VIEW_CONTROLLER (Yodo1MASAdditions)

/**
 *	following properties return a new Yodo1MASViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_topLayoutGuide;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_bottomLayoutGuide;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_topLayoutGuideTop;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) Yodo1MASViewAttribute *mas_bottomLayoutGuideBottom;


@end

#endif
