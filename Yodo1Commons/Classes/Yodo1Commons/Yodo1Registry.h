//
//  Yodo1Registry.h
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//
//  这次主要修改，适合 视频广告，支付，数据统计分析一起使用。
//  这个公共类，使用的时候，需要输入类型，以便区分，遍历取出对象。
//


#import <Foundation/Foundation.h>

@class Yodo1ClassWrapper;

@interface Yodo1Registry : NSObject {
    NSMutableDictionary *adapterDict;
}

+ (Yodo1Registry *)sharedRegistry;

/*
 @param type注册类型，比如视频广告，支付，数据统计分析
 */
- (void)registerClass:(Class)adapterClass withRegistryType:(NSString*)type;

/*
 @param classType注册类型，比如视频广告，支付，数据统计分析
 */
- (Yodo1ClassWrapper *)adapterClassFor:(NSInteger)adNetworkType classType:(NSString*)classType;

- (void)enableClass:(BOOL)bEnable For:(NSInteger)adNetworkType classType:(NSString*)classType;

- (NSDictionary*)getClassesStatusType:(NSString*)classType
                       replacedString:(NSString*)replacedString
                        replaceString:(NSString*)replaceString;


/**
 *  注册类,存储起来
 *
 *  @param adapterClass 注册的类型
 *  @param typeName     注册的名字
 */
- (void)registerClass:(Class)adapterClass withRegistryTypeName:(NSString*)typeName;

/**
 *  获取注册时的类
 *
 *  @param typeName 注册时候的名字
 *
 *  @return 返回封装类
 */
- (Yodo1ClassWrapper *)adapterClassWithTypeName:(NSString*)typeName;

/**
 *  根据前缀获取注册的类
 *
 *  @param prefix 前缀
 *
 *  @return 注册类词典
 */
- (NSDictionary*)getWrapperWithPrefix:(NSString*)prefix;


@end
