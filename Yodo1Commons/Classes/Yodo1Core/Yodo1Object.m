//
//  Yodo1Object.m
//  Yodo1sdk
//
//  Created by hyx on 2020/3/23.
//

#import "Yodo1Object.h"
#import <objc/runtime.h>

@implementation Yodo1Object

+ (id)unknowMethod:(NSString *)method className:(NSString *)className {
    
    // 在加入Exceptions后断言
    // 收集问题，debug下断言，release时记录
//    [Yodo1CoreCrash.shared methodNotExist:method className:className];
    
    YD1LOG(@"error: unknow method called");
    // 返回nil防止外部持续调用崩溃
    return nil;
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (sig) {
        return sig;
    }
    return [NSMethodSignature signatureWithObjCTypes:"v@:@@"];//签名，进入forwardInvocation
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (sig) {
        return sig;
    }
    return [NSMethodSignature signatureWithObjCTypes:"v@:@@"];//签名，进入forwardInvocation
}

+ (void)forwardInvocation:(NSInvocation *)anInvocation {
    id method = NSStringFromSelector(anInvocation.selector);
    NSString *class = NSStringFromClass(object_getClass(self));
    // 转发到unknow并记录异常
    SEL unknow = NSSelectorFromString(@"unknowMethod:className:");
    anInvocation.selector = unknow;
    [anInvocation setArgument:&method atIndex:2];
    [anInvocation setArgument:&class atIndex:3];
    [anInvocation invokeWithTarget:self.class];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    id method = NSStringFromSelector(anInvocation.selector);
    NSString *class = NSStringFromClass(object_getClass(self));
    // 转发到unknow并记录异常
    SEL unknow = NSSelectorFromString(@"unknowMethod:className:");
    anInvocation.selector = unknow;
    [anInvocation setArgument:&method atIndex:2];
    [anInvocation setArgument:&class atIndex:3];
    [anInvocation invokeWithTarget:self.class];
}

@end
