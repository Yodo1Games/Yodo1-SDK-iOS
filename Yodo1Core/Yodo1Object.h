//
//  Yodo1Object.h
//  Yodo1sdk
//
//  Created by hyx on 2020/3/23.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define YD1LOG(fmt, ...) NSLog((@"[ YD1 ] %s [Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define YD1LOG(...)
#endif

#ifdef DEBUG
#   define YD1LOGAssert(fmt, ...) NSLog((@"%@: " fmt), @"error", ##__VA_ARGS__);NSAssert(0,nil);
#else
#   define YD1LOGAssert(...)
#endif

#define YD1_WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define YD1_SS(strongSelf)  __strong __typeof(&*weakSelf)strongSelf = weakSelf;

#define YD1_DEPRECATED(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#define YD1_SAFE_CALL_BLOCK(blockFunc, ...)    \
if (blockFunc) {                        \
blockFunc(__VA_ARGS__);              \
}

#define YD1_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define YD1_UNLOCK(lock) dispatch_semaphore_signal(lock);

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1Object : NSObject

@end

NS_ASSUME_NONNULL_END
