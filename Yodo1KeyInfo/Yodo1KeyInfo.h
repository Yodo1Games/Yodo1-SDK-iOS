//
//  Yodo1KeyInfo.h
//  foundation_sample
//
//  Created by hyx on 16/3/23.
//  Copyright © 2016年 yodo1. All rights reserved.
//

#ifndef Yodo1KeyInfo_h
#define Yodo1KeyInfo_h

#import <Foundation/Foundation.h>

@interface Yodo1KeyInfo : NSObject

/**
 *  Yodo1KeyInfo实例
 *
 *  @return Yodo1KeyInfo单例
 */
+ (instancetype)shareInstance;

/**
 *  根据key取得各平台配置的值
 *  暂时不支持 value为数组
 *  @param key Yodo1KeyInfo.plist里面的键值
 *
 *  @return 返回Key对应的Value
 */
- (id)configInfoForKey:(NSString*)key;

@end

#endif /* Yodo1KeyInfo_h */
