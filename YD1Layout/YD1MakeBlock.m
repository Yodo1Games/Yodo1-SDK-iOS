

#import "YD1MakeBlock.h"

@implementation YD1MakeBlock

+ (instancetype)makeBlockT:(dispatch_block_t)block_t priority:(YD1MakeBlockPriority)priority {
    YD1MakeBlock *blockT = [[YD1MakeBlock alloc] init];
    blockT.make_block_t = block_t;
    blockT.priority = priority;
    return blockT;
}

@end
