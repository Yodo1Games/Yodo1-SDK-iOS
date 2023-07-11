//
//  DocumentsStroge.h
//  iCloudDemo
//
//  Created by zhaojun on 16/7/1.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Apple iCloud Document stroge type
 */
@interface DocumentsStroge : NSObject

/**
 * Delete cloud files based on file name
 */
- (void)removeRecordWithId:(NSString* __nullable) fileName;

/**
 * Read file from the cloud server through the file name
 */
- (void)loadToCloud:(NSString* __nullable) fileName completionHandler:(void (^__nullable)(NSString * __nullable results, NSError * __nullable error))completionHandler;

/**
 *  Save files to the cloud server
 */
- (void)saveToCloud:(NSString* __nullable) fileName saveValue:(NSString* __nullable)data;

@end





