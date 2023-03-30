//
//  KeyValueStroge.h
//  iCloudDemo
//
//  Created by zhaojun on 16/7/4.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyValueStroge : NSObject

/**
 * Store information to the iCloud
 */
- (void)saveToCloud:(NSString* __nullable) saveName saveValue:(NSString* __nullable)saveValsue;

/**
 * eading data from the iCloud
 */
- (void)loadToCloud:(NSString* __nullable) saveName completionHandler:(void (^__nullable)(NSString * __nullable results, NSError * __nullable error))completionHandler;

/**
 * remove the record
 */
- (void)removeRecordWithId:(NSString *__nullable)recordId;

@end
