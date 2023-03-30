//
//  Yodo1Registry.m
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1Registry.h"
#import "Yodo1ClassWrapper.h"

@implementation Yodo1Registry
static Yodo1Registry* instance;

+ (Yodo1Registry *)sharedRegistry{
    if (!instance) {
        instance = [[Yodo1Registry alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        adapterDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerClass:(Class)adapterClass withRegistryType:(NSString*)type {
    // have to do all these to avoid compiler warnings...
    NSInteger (*netTypeMethod)(id, SEL);
    SEL setNetworkTypeSelector = sel_registerName([type cStringUsingEncoding:NSUTF8StringEncoding]);
    netTypeMethod = (NSInteger (*)(id, SEL))[adapterClass methodForSelector:setNetworkTypeSelector];
    NSInteger netType = netTypeMethod(adapterClass,setNetworkTypeSelector);
    NSString* keyString = [NSString stringWithFormat:@"%@%ld",type,(long)netType];
    Yodo1ClassWrapper *wrapper = [[Yodo1ClassWrapper alloc] initWithClass:adapterClass classType:type];
    [adapterDict setObject:wrapper forKey:keyString];
}

- (Yodo1ClassWrapper *)adapterClassFor:(NSInteger)adNetworkType classType:(NSString*)classType {
    NSString* keyString = [NSString stringWithFormat:@"%@%ld",classType,(long)adNetworkType];
    Yodo1ClassWrapper *wrapper = [adapterDict objectForKey:keyString];
    if (nil != wrapper && !wrapper.theEnable) return nil;
    return wrapper;
}

- (void)enableClass:(BOOL)bEnable For:(NSInteger)adNetworkType classType:(NSString*)classType {
    NSString* keyString = [NSString stringWithFormat:@"%@%ld",classType,(long)adNetworkType];
    Yodo1ClassWrapper *wrapper = [adapterDict objectForKey:keyString];
    if (nil == wrapper) return;
    
    wrapper.theEnable = bEnable;
}

- (NSDictionary*)getClassesStatusType:(NSString *)classType
                       replacedString:(NSString *)replacedString
                        replaceString:(NSString *)replaceString
{
    
    
    NSArray *keyArr = [adapterDict allKeys];
    NSMutableDictionary *dicInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    
    for (id key in keyArr) {
        Yodo1ClassWrapper *wrapper = [adapterDict objectForKey:key];
        if (nil == wrapper || wrapper.theHide) continue;
        if (![classType isEqualToString:wrapper.type] ) continue;
        
        NSString *name = NSStringFromClass(wrapper.theYodo1Class);
        
        name = [name stringByReplacingOccurrencesOfString:replacedString withString:replaceString];
        
        NSString *orderType = [key stringByReplacingOccurrencesOfString:classType withString:@""];
        
        [dicInfo setObject:name forKey:[NSNumber numberWithInt:[orderType intValue]]];
        
    }
    return dicInfo;
}

- (void)registerClass:(Class)adapterClass withRegistryTypeName:(NSString *)typeName
{
    Yodo1ClassWrapper *wrapper = [[Yodo1ClassWrapper alloc] initWithClass:adapterClass classType:typeName];
    [adapterDict setObject:wrapper forKey:typeName];
}

- (Yodo1ClassWrapper *)adapterClassWithTypeName:(NSString*)typeName {
    Yodo1ClassWrapper *wrapper = [adapterDict objectForKey:typeName];
    if (nil != wrapper && !wrapper.theEnable) return nil;
    return wrapper;
}

-(NSDictionary *)getWrapperWithPrefix:(NSString *)prefix
{
    
    NSArray *keyArr = [adapterDict allKeys];
    NSMutableDictionary *dicInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    
    for (id key in keyArr) {
        Yodo1ClassWrapper *wrapper = [adapterDict objectForKey:key];
        if (nil == wrapper || wrapper.theHide) continue;
        if (![wrapper.type hasPrefix:prefix] ) continue;
        
        NSString *name = NSStringFromClass(wrapper.theYodo1Class);
        
        
        NSString *orderType = [wrapper.type stringByReplacingOccurrencesOfString:prefix withString:@""];
        
        [dicInfo setObject:name forKey:orderType];
        
    }
    return dicInfo;
}

- (void)dealloc {
    
}

@end
