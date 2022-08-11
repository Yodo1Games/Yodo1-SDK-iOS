

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YD1MakeBlockPriority) {
    YD1MakeBlockPriorityLow,
    YD1MakeBlockPriorityMiddle,
    YD1MakeBlockPriorityHigh,
};

#define YD1Weakify(o)   __weak   typeof(self) vvwo = o;
#define YD1Strongify(o) __strong typeof(self) o = vvwo;

@interface YD1MakeBlock : NSObject

+ (instancetype)makeBlockT:(dispatch_block_t)block_t priority:(YD1MakeBlockPriority)priority;

@property(nonatomic) dispatch_block_t make_block_t;
@property(nonatomic) YD1MakeBlockPriority priority;

@end
