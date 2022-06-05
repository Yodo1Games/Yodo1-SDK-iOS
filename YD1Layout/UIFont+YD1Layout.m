//
// Created by hyx on 2019-08-23.
// Copyright (c) 2019 hyx. All rights reserved.
//


#import "UIFont+YD1Layout.h"

#import <objc/message.h>

#import "YD1LayoutAppearance.h"

@implementation UIFont (YD1Layout)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(_systemFontOfSize_:) originalMethod:@selector(systemFontOfSize:)];
        [self swizzleMethod:@selector(_boldSystemFontOfSize_:) originalMethod:@selector(boldSystemFontOfSize:)];
        [self swizzleMethod:@selector(_italicSystemFontOfSize_:) originalMethod:@selector(italicSystemFontOfSize:)];
    });
}

+ (void)swizzleMethod:(SEL)swizzleMethod originalMethod:(SEL)originalMethod {
    Method newMethod = class_getClassMethod([self class], swizzleMethod);
    Method method = class_getClassMethod([self class], originalMethod);
    method_exchangeImplementations(newMethod, method);
}

+ (UIFont *)_systemFontOfSize_:(CGFloat)fontSize {
    if ([YD1LayoutAppearance hasGlobalFontScale]) {
        return [UIFont _systemFontOfSize_:fontSize * [YD1LayoutAppearance globalScale]];
    }
    
    return [UIFont _systemFontOfSize_:fontSize];
}

+ (UIFont *)_boldSystemFontOfSize_:(CGFloat)fontSize {
    if ([YD1LayoutAppearance hasGlobalFontScale]) {
        return [UIFont _boldSystemFontOfSize_:fontSize * [YD1LayoutAppearance globalScale]];
    }
    
    return [UIFont _boldSystemFontOfSize_:fontSize];
}

+ (UIFont *)_italicSystemFontOfSize_:(CGFloat)fontSize {
    if ([YD1LayoutAppearance hasGlobalFontScale]) {
        return [UIFont _italicSystemFontOfSize_:fontSize * [YD1LayoutAppearance globalScale]];
    }
    
    return [UIFont _italicSystemFontOfSize_:fontSize];
}

+ (UIFont *)yd1_systemFontOfSize:(CGFloat)fontSize {
    return [UIFont _systemFontOfSize_:fontSize * [YD1LayoutAppearance globalScale]];
}

+ (UIFont *)yd1_boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont _boldSystemFontOfSize_:fontSize * [YD1LayoutAppearance globalScale]];
}

+ (UIFont *)yd1_italicSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont _italicSystemFontOfSize_:fontSize * [YD1LayoutAppearance globalScale]];
}

@end
