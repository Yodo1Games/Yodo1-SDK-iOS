//
// Created by hyx on 2019-08-15.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import "UIView+YD1Extend.h"
#import "YD1LayoutAppearance.h"

@interface YD1ViewLayoutInfonce ()

@end

@implementation YD1ViewLayoutInfonce

- (instancetype)initWithMakeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    self = [super init];
    if (self) {
        self.makeLayoutType = makeLayoutType;
        self.viewLayoutType = makeLayoutType;
        self.multiplied = 1.0f;
        self.equalType = YD1EqualNone;
        self.isNum = NO;
    }
    
    return self;
}

+ (instancetype)viewInfoWithMakeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    return [[self alloc] initWithMakeLayoutType:makeLayoutType];
}

- (void)changeAttribute:(id)attribute equalType:(YD1EqualType)equalType {
    self.equalType = equalType;
    
    if ([attribute isKindOfClass:UIView.class]) {
        self.relateView = (UIView *) attribute;
        self.isNum = NO;
        
        if (self.relateView.viewLayoutType != YD1MakeLayoutTypeNone) {
            self.viewLayoutType = self.relateView.viewLayoutType;
            self.relateView.viewLayoutType = YD1MakeLayoutTypeNone;
        }
    } else {
        [self setAttribute:attribute];
        self.isNum = YES;
    }
}

- (void)setAttribute:(NSValue *)value {
    CGFloat scale = [YD1LayoutAppearance globalScale];
    if ([value isKindOfClass:NSNumber.class]) {
        self.value = [(NSNumber *) value floatValue] * scale;
    } else if (strcmp(value.objCType, @encode(CGPoint)) == 0) {
        CGPoint point;
        [value getValue:&point];
        self.point = CGPointMake(point.x * scale, point.y * scale);
    } else if (strcmp(value.objCType, @encode(CGSize)) == 0) {
        CGSize size;
        [value getValue:&size];
        self.size = CGSizeMake(size.width * scale, size.height * scale);
    } else if (strcmp(value.objCType, @encode(YD1EdgeInsets)) == 0) {
        YD1EdgeInsets insets;
        [value getValue:&insets];
        self.insets = UIEdgeInsetsMake(insets.top * scale, insets.left * scale, insets.bottom * scale, insets.right * scale);
    } else {
        NSAssert(NO, @"attempting to set layout constant with unsupported value: %@", value);
    }
}

@end
