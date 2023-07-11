//
//  Yodo1Basic.m
//  Joyhus
//
//  Created by hyx on 2019/8/6.
//  Copyright © 2019 hyx. All rights reserved.
//

#import "Yodo1Base.h"
#import <malloc/malloc.h>
#import "Yodo1CoreBase.h"

@implementation Yodo1Base

static Yodo1Base *userManager = nil;
static dispatch_once_t onceToken;

+ (void)load {
    [self cc_willInit];
}

+ (instancetype)shared {
    dispatch_once(&onceToken, ^{
        userManager = [[Yodo1Base alloc]init];
    });
    return userManager;
}

+ (void)cc_willInit {
    
#if DEBUG
    [Yodo1Base shared].debug = YES;
#else
    [Yodo1Base shared].debug = NO;
#endif
}

- (id)cc_init:(Class)aClass {
    return [aClass new];
}

- (id)cc_getAppDelegate:(Class)aClass {
    NSString *classStr = NSStringFromClass(aClass);
    return Yodo1CoreBase.shared.sharedAppDelegate[classStr];
}

- (id)cc_registerAppDelegate:(id)module {
    NSString *classStr = NSStringFromClass([module class]);
    id obj = Yodo1CoreBase.shared.sharedAppDelegate[classStr];
    if (!obj) {
        obj = [[module alloc]init];
        [Yodo1CoreBase.shared.sharedAppDelegate setObject:obj forKey:classStr];
    }
    return obj;
}

- (id)cc_registerSharedInstance:(id)shared {
    NSString *classStr = NSStringFromClass([shared class]);
    id obj = Yodo1CoreBase.shared.sharedInstanceDic[classStr];
    if (!obj) {
        obj = [[shared alloc]init];
        [Yodo1CoreBase.shared.sharedInstanceDic setObject:obj forKey:classStr];
    }
    return obj;
}

- (id)cc_registerSharedInstance:(id)shared block:(void(^)(void))block {
    NSString *classStr = NSStringFromClass([shared class]);
    id obj = Yodo1CoreBase.shared.sharedInstanceDic[classStr];
    if (!obj) {
        obj = [[shared alloc]init];
        [Yodo1CoreBase.shared.sharedInstanceDic setObject:obj forKey:classStr];
        block();
    }
    return obj;
}

- (id)cc_shared:(NSString *)key {
    return Yodo1CoreBase.shared.sharedObjDic[key];
}

- (id)cc_removeShared:(NSString *)key {
    return [self cc_setShared:key obj:nil];
}

- (id)cc_bind:(NSString *)key {
    return Yodo1CoreBase.shared.sharedObjBindDic[key];
}

- (id)cc_setShared:(NSString *)key obj:(id)obj {
    if (!key) {
        return [self cc_shared:key];
    }
    if (!obj) {
        [Yodo1CoreBase.shared.sharedObjDic removeObjectForKey:key];
        return [self cc_shared:key];
    }
    if (Yodo1CoreBase.shared.sharedObjDic[key]) {
        YD1LOGAssert(@"'%@' has been setted! use 'resetShared' to overlap",key);
    }
    [Yodo1CoreBase.shared.sharedObjDic setObject:obj forKey:key];
    return [self cc_shared:key];
}

- (id)cc_resetShared:(NSString *)key obj:(id)obj {
    if (!key) {
        return [self cc_shared:key];
    }
    if (!obj) {
        [Yodo1CoreBase.shared.sharedObjDic removeObjectForKey:key];
        return [self cc_shared:key];
    }
    [Yodo1CoreBase.shared.sharedObjDic setObject:obj forKey:key];
    return [self cc_shared:key];
}

- (id)cc_setBind:(NSString *)key value:(id)value {
    if (!key) {
        return [self cc_bind:key];
    }
    if (!value) {
        [Yodo1CoreBase.shared.sharedObjBindDic removeObjectForKey:key];
        return [self cc_bind:key];
    }
    [Yodo1CoreBase.shared.sharedObjBindDic setObject:value forKey:key];
    return [self cc_bind:key];
}

@end
