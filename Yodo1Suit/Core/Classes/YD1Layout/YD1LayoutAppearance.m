//
// Created by hyx on 2019-08-23.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import "YD1LayoutAppearance.h"

static CGFloat yd1_global_scale;
static BOOL yd1_open_view_scale;
static BOOL yd1_font_scale;

@implementation YD1LayoutAppearance

+ (CGFloat)width {
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (CGFloat)height {
    return [[UIScreen mainScreen] bounds].size.height;
}

+ (CGFloat)xMinWidth {
    return MIN([YD1LayoutAppearance height], [YD1LayoutAppearance width]);
}

+ (CGFloat)xMaxHeight {
    return MAX([YD1LayoutAppearance height], [YD1LayoutAppearance width]);
}

+ (BOOL)hasGlobalFontScale {
    return yd1_font_scale;
}

+ (void)setGlobalScaleFont:(BOOL)scaleFont {
    yd1_font_scale = scaleFont;
}

+ (BOOL)hasGlobalViewScale {
    return yd1_open_view_scale;
}

+ (void)setGlobalViewScale:(BOOL)open {
    yd1_open_view_scale = open;
}

+ (CGFloat)globalScale {
    if (!yd1_open_view_scale) {
        return 1.0f;
    }
    
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        yd1_global_scale = [YD1LayoutAppearance xMinWidth] / 375.0f;
    });
    
    return yd1_global_scale;
}

+ (void)setGlobalScale:(CGFloat)value {
    yd1_global_scale = value;
}

@end
