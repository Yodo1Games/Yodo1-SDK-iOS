//
// Created by hyx on 2019-08-15.
// Copyright (c) 2019 hyx. All rights reserved.
//

#import "YD1MakeLayout.h"

#import "YD1ViewLayoutInfonce.h"
#import "YD1MakeBlock.h"
#import "UIView+YD1Layout.h"
#import "UIView+YD1Extend.h"
#import "YD1LayoutAppearance.h"

#define YD1MAX_LAYOUT_VALUE 10000.f

#define EmptyMethodExcetion() \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
reason:[NSString stringWithFormat:@"This is a empty %@ method.", NSStringFromSelector(_cmd)] \
userInfo:nil]

#if DEBUG && OPENLOG
# define YD1_Log(fmt,...) NSLog((@"[file:%s]\n" "[method:%s]\n" "[line:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define YD1_Log(...);
#endif

@interface YD1MakeLayout ()

@property(nonatomic, strong) YD1ViewLayoutInfonce *viewLayoutInfo;

@property(nonatomic, getter=isTopMaked) BOOL topMaked;
@property(nonatomic, getter=isLeftMaked) BOOL leftMaked;
@property(nonatomic) CGRect newFrame;

@property(nonatomic, nonnull) NSMutableArray <YD1ViewLayoutInfonce *> *viewLayoutInfos;
@property(nonatomic, nonnull) NSMutableArray <YD1MakeBlock *> *makeBlcoks;
@property(nonatomic, weak, nullable) UIView *view;

@end

@implementation YD1MakeLayout


#pragma mark - Initialize

- (instancetype)init {
    self = [super init];
    if (self) {
        _viewLayoutInfos = [NSMutableArray new];
        _makeBlcoks = [NSMutableArray new];
        
#ifdef VVOBS
        [self addObserver:self forKeyPath:@"newFrame" options:NSKeyValueObservingOptionNew context:nil];
#endif
        
    }
    return self;
}

#ifdef VVOBS
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"newFrame"]) {
        YD1Layout *vvf = (YD1Layout *) object;
        YD1_Log(@"%@", NSStringFromCGRect(vvf.newFrame));
    }
}
#endif

#pragma mark - Configurate methods

+ (void)configView:(UIView *)view layout:(YD1ViewLayout)layout {
    [self configView:view state:@0 layout:layout];
}

+ (void)configView:(UIView *)view state:(NSNumber *)state layout:(YD1ViewLayout)layout {
    if (view.yd1_state.integerValue == state.integerValue) {
        YD1MakeLayout *makeLayout = [YD1MakeLayout new];
        makeLayout.view = view;
        
        [makeLayout startConfig];
        
        // 在Block中进行设置操作
        if (layout) {
            layout(makeLayout);
        }
        
        [makeLayout configFrames];
    }
}

// 将记录当前 View的frame的值
- (void)startConfig {
    YD1_Log(@"start %@ %@", self.view, NSStringFromCGRect(self.view.frame));
    self.newFrame = self.view.frame;
}

// 将新的frame赋值给当前 View
- (void)endConfig {
    YD1_Log(@"end %@ %@", self.view, NSStringFromCGRect(self.newFrame));
    self.view.frame = self.newFrame;
}

// 按照优先级进行排序
- (void)configOrderHandlers {
    for (YD1ViewLayoutInfonce *makeInfo in self.viewLayoutInfos) {
        switch (makeInfo.makeLayoutType) {
            case YD1MakeLayoutTypeTop: {
                [self topWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeBottom: {
                [self bottomWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeLeft: {
                [self leftWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeRight: {
                [self rightWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeCenterX: {
                [self centerXWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeCenterY: {
                [self centerYWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeCenter: {
                [self centerWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeWidth: {
                [self widthWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeHeight: {
                [self heightWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeSize: {
                [self sizeWithMakeInfo:makeInfo];
            }
                break;
            case YD1MakeLayoutTypeEdges: {
                [self edgesWithMakeInfo:makeInfo];
                break;
            }
            default:
                break;
        }
    }
    
    [self.makeBlcoks sortUsingComparator:^NSComparisonResult(YD1MakeBlock *_Nonnull block_t1, YD1MakeBlock *block_t2) {
        if (block_t1.priority > block_t2.priority) {
            return NSOrderedAscending;
        }
        
        return (block_t1.priority == block_t2.priority) ? NSOrderedSame : NSOrderedDescending;
    }];
}

- (void)configFrames {
    [self configOrderHandlers];
    
    [self.makeBlcoks enumerateObjectsUsingBlock:^(YD1MakeBlock *_Nonnull block_t, NSUInteger idx, BOOL *_Nonnull stop) {
        block_t.make_block_t();
    }];
    
    [self endConfig];
}

- (YD1MakeLayout *)and {
    return self;
}

- (YD1MakeLayout *)with {
    return self;
}

- (YD1MakeLayout *)left {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeLeft];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)right {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeRight];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)top {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeTop];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)bottom {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeBottom];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)centerX {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeCenterX];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)centerY {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeCenterY];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)center {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeCenter];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)width {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeWidth];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)height {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeHeight];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)size {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeSize];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *)edges {
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:YD1MakeLayoutTypeEdges];
    [self.viewLayoutInfos addObject:self.viewLayoutInfo];
    return self;
}

- (YD1MakeLayout *(^)(id))equalTo {
    return ^(id attribute) {
        [self.viewLayoutInfo changeAttribute:attribute equalType:YD1EqualTo];
        return self;
    };
}

- (YD1MakeLayout *(^)(id))greaterThanOrEqualTo {
    return ^(id attribute) {
        [self.viewLayoutInfo changeAttribute:attribute equalType:YD1GreaterThanOrEqualTo];
        return self;
    };
}

- (YD1MakeLayout *(^)(id))lessThanOrEqualTo {
    return ^(id attribute) {
        [self.viewLayoutInfo changeAttribute:attribute equalType:YD1LessThanOrEqualTo];
        return self;
    };
}

- (YD1MakeLayout *(^)(CGFloat))offset {
    return ^id(CGFloat value) {
        self.viewLayoutInfo.value = value * [YD1LayoutAppearance globalScale];
        return self;
    };
}

- (YD1MakeLayout *(^)(CGSize))sizeOffset {
    return ^id(CGSize size) {
        CGFloat scale = [YD1LayoutAppearance globalScale];
        self.viewLayoutInfo.size = CGSizeMake(size.width * scale, size.height * scale);
        return self;
    };
}

- (YD1MakeLayout *(^)(CGPoint))centerOffset {
    return ^id(CGPoint point) {
        CGFloat scale = [YD1LayoutAppearance globalScale];
        self.viewLayoutInfo.point = CGPointMake(point.x * scale, point.y * scale);
        return self;
    };
}

- (YD1MakeLayout *(^)(YD1EdgeInsets))insets {
    return ^id(YD1EdgeInsets insets) {
        CGFloat scale = [YD1LayoutAppearance globalScale];
        self.viewLayoutInfo.insets = UIEdgeInsetsMake(insets.top * scale, insets.left * scale, insets.bottom * scale, insets.right * scale);
        return self;
    };
}

- (YD1MakeLayout *(^)(NSValue *))valueOffset {
    return ^id(NSValue *value) {
        [self.viewLayoutInfo setAttribute:value];
        return self;
    };
}

- (YD1MakeLayout *(^)(CGFloat))multipliedBy {
    return ^id(CGFloat multiplied) {
        self.viewLayoutInfo.multiplied = multiplied;
        return self;
    };
}

- (YD1MakeLayout *(^)(NSInteger))priority {
    return ^id(NSInteger priority) {
        self.viewLayoutInfo.priority = priority;
        return self;
    };
}

#pragma mark - Helpers

- (YD1ViewLayoutInfonce *)viewInfoForType:(YD1MakeLayoutType)type {
    for (YD1ViewLayoutInfonce *mi in self.viewLayoutInfos) {
        if (mi.makeLayoutType == type && mi.isNum) {
            return mi;
        }
    }
    
    return nil;
}

// 得到当前 view 的对应位置的值
- (CGFloat)valueForMakeLayoutType:(YD1MakeLayoutType)type forView:(UIView *)view {
    view = view ?: self.view.superview;
    CGRect convertedRect = [self.view.superview convertRect:view.frame fromView:view.superview];
    switch (type) {
        case YD1MakeLayoutTypeTop:
            return CGRectGetMinY(convertedRect);
        case YD1MakeLayoutTypeBottom:
            return CGRectGetMaxY(convertedRect);
        case YD1MakeLayoutTypeCenterY:
            return CGRectGetMidY(convertedRect);
        case YD1MakeLayoutTypeCenterX:
            return CGRectGetMidX(convertedRect);
        case YD1MakeLayoutTypeRight:
            return CGRectGetMaxX(convertedRect);
        case YD1MakeLayoutTypeLeft:
            return CGRectGetMinX(convertedRect);
        default:
            return 0;
    }
}

#pragma mark Left relations

- (void)leftWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    YD1Weakify(self);
    YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        CGFloat x = [self leftXForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];
        CGRect frame = self.newFrame;
        frame.origin.x = x;
        self.newFrame = frame;
        self.leftMaked = YES;
    };
    
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityHigh]];
}

- (CGFloat)leftXForView:(UIView *)view withValue:(CGFloat)value makeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    CGFloat x = [self valueForMakeLayoutType:makeLayoutType forView:view];
    return x + value;
}


#pragma mark Top relations

- (void)topWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    YD1Weakify(self);
    YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        CGFloat y = [self topYForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];
        CGRect frame = self.newFrame;
        frame.origin.y = y;
        self.newFrame = frame;
        self.topMaked = YES;
    };
    
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityHigh]];
}

- (CGFloat)topYForView:(UIView *)view withValue:(CGFloat)value makeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    CGFloat y = [self valueForMakeLayoutType:makeLayoutType forView:view];
    return y + value;
}

#pragma mark Bottom relations

- (void)bottomWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    YD1Weakify(self);
    YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        CGRect frame = self.newFrame;
        if (!self.topMaked) {
            CGFloat y = [self bottomYForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];
            frame.origin.y = y;
        } else {
            frame.size.height = [self bottomHeightForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];;
        }
        self.newFrame = frame;
    };
    
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityMiddle]];
}

- (CGFloat)bottomYForView:(UIView *)view withValue:(CGFloat)value makeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    CGFloat y = [self valueForMakeLayoutType:makeLayoutType forView:view];
    return y + value - CGRectGetHeight(self.newFrame);
}

- (CGFloat)bottomHeightForView:(UIView *)view withValue:(CGFloat)value makeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    CGFloat height = fabs(CGRectGetMinY(self.newFrame) - [self valueForMakeLayoutType:makeLayoutType forView:view]);
    return height + value;
}

#pragma mark Right relations

- (void)rightWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    YD1Weakify(self);
    YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        CGRect frame = self.newFrame;
        if (!self.leftMaked) {
            CGFloat x = [self rightXForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];
            frame.origin.x = x;
        } else {
            frame.size.width = [self rightWidthForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];;
        }
        self.newFrame = frame;
    };
    
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityMiddle]];
}

- (CGFloat)rightXForView:(UIView *)view withValue:(CGFloat)value makeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    CGFloat x = [self valueForMakeLayoutType:makeLayoutType forView:view];
    return x + value - CGRectGetWidth(self.newFrame);
}

- (CGFloat)rightWidthForView:(UIView *)view withValue:(CGFloat)value makeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    CGFloat width = fabs(CGRectGetMinX(self.newFrame) - [self valueForMakeLayoutType:makeLayoutType forView:view]);
    return width + value;
}

#pragma mark - Low priority

#pragma mark Center X relations

- (void)centerWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    YD1Weakify(self);
    YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        CGRect frame = self.newFrame;
        if (makeLayoutType == YD1MakeLayoutTypeCenter) {
            frame.origin.x = [self centerXForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:YD1MakeLayoutTypeCenterX];
            frame.origin.y = [self centerYForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:YD1MakeLayoutTypeCenterY];
        } else {
            frame.origin.x = [self centerXForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];
            frame.origin.y = [self centerYForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];
        }
        
        self.newFrame = frame;
    };
    
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityLow]];
}

- (void)centerXWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    YD1Weakify(self);
    YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        CGRect frame = self.newFrame;
        frame.origin.x = [self centerXForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];
        self.newFrame = frame;
    };
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityLow]];
}

- (CGFloat)centerXForView:(UIView *)view withValue:(CGFloat)value makeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    CGFloat x = [self valueForMakeLayoutType:makeLayoutType forView:view];
    return x - CGRectGetWidth(self.newFrame) * 0.5f + value;
}

#pragma mark Center Y relations

- (void)centerYWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    YD1Weakify(self);
    YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        CGRect frame = self.newFrame;
        frame.origin.y = [self centerYForView:makeInfo.relateView withValue:makeInfo.value makeLayoutType:makeLayoutType];
        self.newFrame = frame;
    };
    
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityLow]];
}

- (CGFloat)centerYForView:(UIView *)view withValue:(CGFloat)value makeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    CGFloat y = [self valueForMakeLayoutType:makeLayoutType forView:view];
    return y - CGRectGetHeight(self.newFrame) * 0.5f + value;
}

#pragma mark - Top priority

#pragma mark Width / Height relations

- (void)widthWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    dispatch_block_t block_t;
    if (makeInfo.isNum) {
        YD1Weakify(self);
        block_t = ^{
            YD1Strongify(self);
            CGRect frame = self.newFrame;
            frame.size.width = makeInfo.value;
            self.newFrame = frame;
        };
    } else {
        YD1Weakify(self);
        YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
        block_t = ^{
            YD1Strongify(self);
            
            if (makeInfo.relateView && makeInfo.relateView != self.view) {
                CGFloat width = [self sizeForView:makeInfo.relateView withMakeLayoutType:makeLayoutType] * makeInfo.multiplied;
                [self setSizeValue:width type:YD1MakeLayoutTypeWidth];
            } else {
                YD1ViewLayoutInfonce *heightInfo = [self viewInfoForType:YD1MakeLayoutTypeHeight];
                if (heightInfo && heightInfo.isNum) {
                    CGFloat width = heightInfo.value;
                    [self setSizeValue:width * makeInfo.multiplied type:YD1MakeLayoutTypeWidth];
                    
                } else if (heightInfo && !heightInfo.isNum) {
                    UIView *tempView = heightInfo.relateView;
                    CGFloat tempMultiplier = heightInfo.multiplied;
                    YD1MakeLayoutType makeType = heightInfo.makeLayoutType;
                    
                    CGFloat width = [self sizeForView:tempView withMakeLayoutType:makeType] * (tempMultiplier * makeInfo.multiplied);
                    [self setSizeValue:width type:YD1MakeLayoutTypeWidth];
                    
                } else {
                    YD1ViewLayoutInfonce *topInfo = [self viewInfoForType:YD1MakeLayoutTypeTop];
                    YD1ViewLayoutInfonce *bottomInfo = [self viewInfoForType:YD1MakeLayoutTypeBottom];
                    
                    if (topInfo && bottomInfo) {
                        UIView *topView = topInfo.relateView;
                        CGFloat topInset = topInfo.value;
                        YD1MakeLayoutType topMakeLayoutType = topInfo.makeLayoutType;
                        
                        CGFloat topViewY = [self topYForView:topView withValue:topInset makeLayoutType:topMakeLayoutType];
                        
                        UIView *bottomView = bottomInfo.relateView;
                        CGFloat bottomInset = bottomInfo.value;
                        YD1MakeLayoutType bottomMakeLayoutType = bottomInfo.makeLayoutType;
                        
                        CGFloat bottomViewY = [self valueForMakeLayoutType:bottomMakeLayoutType forView:bottomView] - bottomInset;
                        
                        [self setSizeValue:(bottomViewY - topViewY) * makeInfo.multiplied type:YD1MakeLayoutTypeWidth];
                    }
                }
            }
        };
    }
    
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityHigh]];
}

- (void)heightWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    dispatch_block_t block_t;
    if (makeInfo.isNum) {
        YD1Weakify(self);
        block_t = ^{
            YD1Strongify(self);
            CGRect frame = self.newFrame;
            frame.size.height = makeInfo.value;
            self.newFrame = frame;
        };
    } else {
        YD1Weakify(self);
        YD1MakeLayoutType makeLayoutType = makeInfo.viewLayoutType;
        block_t = ^{
            YD1Strongify(self);
            if (makeInfo.relateView && makeInfo.relateView != self.view) {// 获取的View的值进行设值
                CGFloat height = [self sizeForView:makeInfo.relateView withMakeLayoutType:makeLayoutType] * makeInfo.multiplied;
                [self setSizeValue:height type:YD1MakeLayoutTypeHeight];
            } else {
                YD1ViewLayoutInfonce *widthInfo = [self viewInfoForType:YD1MakeLayoutTypeWidth];
                if (widthInfo && widthInfo.isNum) {// 获取输入的数字设值
                    CGFloat height = widthInfo.value;
                    [self setSizeValue:height * widthInfo.multiplied type:YD1MakeLayoutTypeHeight];
                    
                } else if (widthInfo && !widthInfo.isNum) {// 与自己的已经确定的宽进行设值
                    YD1ViewLayoutInfonce *widthToInfo = [self viewInfoForType:YD1MakeLayoutTypeWidth];
                    
                    UIView *tempView = widthToInfo.relateView;
                    CGFloat tempMultiplier = widthToInfo.multiplied;
                    YD1MakeLayoutType makeType = widthToInfo.makeLayoutType;
                    
                    CGFloat height = [self sizeForView:tempView withMakeLayoutType:makeType] * (tempMultiplier * makeInfo.multiplied);
                    [self setSizeValue:height type:YD1MakeLayoutTypeHeight];
                    
                } else {// 与自己的左右值计算得到的宽进行设值
                    YD1ViewLayoutInfonce *leftInfo = [self viewInfoForType:YD1MakeLayoutTypeLeft];
                    YD1ViewLayoutInfonce *rightInfo = [self viewInfoForType:YD1MakeLayoutTypeRight];
                    
                    if (leftInfo && rightInfo) {
                        UIView *leftView = leftInfo.relateView;
                        CGFloat leftInset = leftInfo.value;
                        YD1MakeLayoutType leftMakeLayoutType = leftInfo.makeLayoutType;
                        
                        CGFloat leftViewX = [self leftXForView:leftView withValue:leftInset makeLayoutType:leftMakeLayoutType];
                        
                        UIView *rightView = rightInfo.relateView;
                        CGFloat rightInset = rightInfo.value;
                        YD1MakeLayoutType rightMakeLayoutType = rightInfo.makeLayoutType;
                        
                        CGFloat rightViewX = [self valueForMakeLayoutType:rightMakeLayoutType forView:rightView] - rightInset;
                        
                        [self setSizeValue:(rightViewX - leftViewX) * makeInfo.multiplied type:YD1MakeLayoutTypeHeight];
                    }
                }
            }
        };
    }
    
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityHigh]];
}

// 得到当前view的宽或者高
- (CGFloat)sizeForView:(UIView *)view withMakeLayoutType:(YD1MakeLayoutType)makeLayoutType {
    if (makeLayoutType == YD1MakeLayoutTypeWidth) {
        return CGRectGetWidth(view.bounds);
    } else if (makeLayoutType == YD1MakeLayoutTypeHeight) {
        return CGRectGetHeight(view.bounds);
    }
    
    return 0.0f;
}

- (void)setHighPriorityValue:(CGFloat)value withType:(YD1MakeLayoutType)type {
    YD1Weakify(self);
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        [self setSizeValue:value type:type];
    };
    
    self.viewLayoutInfo = [YD1ViewLayoutInfonce viewInfoWithMakeLayoutType:type];
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityHigh]];
}

// 改变Frame的值
- (void)setSizeValue:(CGFloat)value type:(YD1MakeLayoutType)type {
    CGRect frame = self.newFrame;
    switch (type) {
        case YD1MakeLayoutTypeWidth:
            frame.size.width = value;
            break;
        case YD1MakeLayoutTypeHeight:
            frame.size.height = value;
            break;
        default:
            break;
    }
    self.newFrame = frame;
}

- (YD1MakeLayout *)sizeWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    CGSize size = makeInfo.size;
    YD1Weakify(self);
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        CGRect frame = self.newFrame;
        frame.size = size;
        self.newFrame = frame;
    };
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityHigh]];
    return self;
}

- (YD1MakeLayout *)edgesWithMakeInfo:(YD1ViewLayoutInfonce *)makeInfo {
    UIEdgeInsets insets = makeInfo.insets;
    YD1Weakify(self);
    dispatch_block_t block_t = ^{
        YD1Strongify(self);
        UIView *relateView = makeInfo.relateView;
        if (!relateView) {
            relateView = [self.view superview];
        }
        CGFloat width = CGRectGetWidth(relateView.bounds) - (insets.left + insets.right);
        CGFloat height = CGRectGetHeight(relateView.bounds) - (insets.top + insets.bottom);
        CGRect frame = CGRectMake(insets.left, insets.top, width, height);
        self.newFrame = frame;
    };
    [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityMiddle]];
    return self;
}

#pragma mark Container

- (YD1MakeLayout *)container {
    CGRect frame = CGRectZero;
    for (UIView *subview in [self.view subviews]) {
        frame = CGRectUnion(frame, subview.frame);
    }
    
    [self setHighPriorityValue:CGRectGetWidth(frame) withType:YD1MakeLayoutTypeWidth];
    [self setHighPriorityValue:CGRectGetHeight(frame) withType:YD1MakeLayoutTypeHeight];
    return self;
}

#pragma mark Fits

- (YD1MakeLayout *)sizeToFit {
    [self.view sizeToFit];
    [self setHighPriorityValue:CGRectGetWidth(self.view.frame) withType:YD1MakeLayoutTypeWidth];
    [self setHighPriorityValue:CGRectGetHeight(self.view.frame) withType:YD1MakeLayoutTypeHeight];
    return self;
}

- (YD1MakeLayout *)widthToFit {
    [self.view sizeToFit];
    [self setHighPriorityValue:CGRectGetWidth(self.view.frame) withType:YD1MakeLayoutTypeWidth];
    return self;
}

- (YD1MakeLayout *)heightToFit {
    [self.view sizeToFit];
    [self setHighPriorityValue:CGRectGetHeight(self.view.frame) withType:YD1MakeLayoutTypeHeight];
    return self;
}

- (YD1MakeLayout *(^)(CGSize size))sizeThatFits {
    return ^id(CGSize size) {
        CGFloat scale = [YD1LayoutAppearance globalScale];
        CGSize fitSize = [self.view sizeThatFits:size];
        CGFloat width = size.width > YD1MAX_LAYOUT_VALUE ? YD1MAX_LAYOUT_VALUE : size.width * scale;
        CGFloat height = size.height > YD1MAX_LAYOUT_VALUE ? YD1MAX_LAYOUT_VALUE : size.height * scale;
        width = MIN(width, fitSize.width);
        height = MIN(height, fitSize.height);
        [self setHighPriorityValue:width withType:YD1MakeLayoutTypeWidth];
        [self setHighPriorityValue:height withType:YD1MakeLayoutTypeHeight];
        return self;
    };
}

- (YD1MakeLayout *(^)(CGFloat))heightThatFits {
    return ^id(CGFloat maxHeight) {
        YD1Weakify(self);
        dispatch_block_t block_t = ^{
            YD1Strongify(self);
            CGFloat height = maxHeight > YD1MAX_LAYOUT_VALUE ? YD1MAX_LAYOUT_VALUE : maxHeight * [YD1LayoutAppearance globalScale];
            CGSize fitSize = [self.view sizeThatFits:CGSizeMake(CGRectGetWidth(self.newFrame), height)];
            CGRect frame = self.newFrame;
            frame.size.height = fitSize.height;
            self.newFrame = frame;
        };
        [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityLow]];
        return self;
    };
}

- (YD1MakeLayout *(^)(CGFloat))widthThatFits {
    return ^id(CGFloat maxWidth) {
        YD1Weakify(self);
        dispatch_block_t block_t = ^{
            YD1Strongify(self);
            CGFloat height = maxWidth > YD1MAX_LAYOUT_VALUE ? YD1MAX_LAYOUT_VALUE : maxWidth * [YD1LayoutAppearance globalScale];
            CGSize fitSize = [self.view sizeThatFits:CGSizeMake(height, CGRectGetHeight(self.newFrame))];
            CGRect frame = self.newFrame;
            frame.size.width = fitSize.width;
            self.newFrame = frame;
        };
        [self.makeBlcoks addObject:[YD1MakeBlock makeBlockT:block_t priority:YD1MakeBlockPriorityLow]];
        return self;
    };
}

@end

@implementation YD1MakeLayout (AutoboxingSupport)

- (YD1MakeLayout *(^)(id))yd1_equalTo {
    EmptyMethodExcetion();
}

@end
