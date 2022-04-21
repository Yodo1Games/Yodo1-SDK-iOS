//
//  Yodo1KeyInfo.m
//  foundation_sample
//
//  Created by hyx on 16/3/23.
//  Copyright © 2016年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yodo1KeyInfo.h"

@interface Yodo1KeyInfo ()

@property(nonatomic,strong)NSMutableDictionary *keyInfo;

@end

@implementation Yodo1KeyInfo

+ (instancetype)shareInstance
{
    static Yodo1KeyInfo* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1KeyInfo alloc]init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Yodo1KeyConfig.bundle/Yodo1KeyInfo" ofType:@"plist"];
        _keyInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        if (plistPath.length <= 0) {
            NSDictionary * plistDic = [[NSBundle mainBundle] infoDictionary];
            _keyInfo = [[NSMutableDictionary alloc] initWithDictionary:plistDic];
            // NSAssert(_keyInfo!=nil, @"不存在Info.plist文件");
        }
    }
    return self;
}

- (id)configInfoForKey:(NSString *)key
{
    if (key == nil) return nil;
    if ([_keyInfo count]>0) {
        if ([[_keyInfo allKeys]containsObject:key]) {
            return [_keyInfo objectForKey:key];
        }else{
            NSArray* infoVaulues = [_keyInfo allValues];
            for (id keys in infoVaulues) {
               
                if ([keys isKindOfClass:[NSDictionary class]]) {
                    NSArray * keys2 = [keys allKeys];
                    if ([keys2 containsObject:key]) {
                        for (id keys22 in keys2) {
                            if ([keys22 isEqualToString:key]) {
                                return [keys objectForKey:key];
                            }
                        }
                    }
                    NSArray* infoVaulues2 = [keys allValues];
                    for (id infoKey in infoVaulues2) {
                        if ([infoKey isKindOfClass:[NSDictionary class]]) {
                            if ([[infoKey allKeys]containsObject:key]) {
                                return [infoKey objectForKey:key];
                            }
                        }
                    }
                }
            }
        }
       
    }
    return nil;
}

@end
