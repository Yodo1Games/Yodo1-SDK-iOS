//
//  Yodo1iClound.h
//  Yodo1iClound
//
//  Created by zhaojun on 16/3/18.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Yodo1iCloud : NSObject

+ (Yodo1iCloud* __nullable)sharedInstance;

/**
 *  存储信息到云端
 *
 *  @param saveName   存储名
 *  @param saveValsue 存储值
 */
- (void)saveToCloud:(NSString* __nullable)saveName
          saveValue:(NSString* __nullable)saveValsue;

/**
 *  从云端读取数据
 *
 *  @param recordName          存储名
 *  @param completionHandler 回调block
 */
- (void)loadToCloud:(NSString* __nullable)recordName
  completionHandler:(void (^__nullable)(NSString * __nullable results, NSError * __nullable error))completionHandler;

/**
 *  从云端删除数据
 *
 *  @param recordName 存储记录id
 */
- (void)removeRecordWithRecordName:(NSString *__nullable)recordName;

@end
