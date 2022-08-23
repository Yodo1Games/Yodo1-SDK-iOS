//
//  DocumentsStroge.m
//  iCloudDemo
//
//  Created by zhaojun on 16/7/1.
//  Copyright © 2016年 zhaojun. All rights reserved.
//
#import <UIKit/UIDevice.h>

#import "DocumentsStroge.h"
#import "CloudDocument.h"
#import "ImageCloudDocument.h"
#import "Yodo1Object.h"

@interface DocumentsStroge ()
{
    NSMutableDictionary* _iCloudDict;
    NSURL* _url;
}

/**
 * CloudDocument based on the name of the file
 */
- (CloudDocument*)getDocumentbyFileName:(NSString*) fileName;

/**
 * Change existing file data
 */
- (void)changeCloudFileData:(NSString*) fileName data:(NSString *)newData;

- (void)createCloudFile:(NSString*) fileName data:(NSString *)data;

- (BOOL)hasCacheFile:(NSString*)fileName;

@end

@implementation DocumentsStroge

- (id)init {
    self = [super init];
    _iCloudDict = [NSMutableDictionary new];
    _url = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:[NSString stringWithFormat:@"iCloud.%@",[[NSBundle mainBundle] bundleIdentifier]]];
    if (_url != nil){
        _url = [_url URLByAppendingPathComponent:@"Documents"];
    }
    return self;
}

- (CloudDocument*)getDocumentbyFileName:(NSString*) fileName
{
    CloudDocument* ret = [_iCloudDict objectForKey:fileName];
    if (ret == nil){
        if (_url != nil){
            NSString* fileType = @"dat";
            BOOL isJpg = NO;
            if (fileName != nil && ![fileName isEqualToString:@""]){
                if ([fileName rangeOfString:@".jpg"].length > 0 || [fileName rangeOfString:@".JPG"].length > 0 || [fileName rangeOfString:@".png"].length > 0 || [fileName rangeOfString:@".PNG"].length > 0)
                {
                    isJpg = YES;
                    fileType = @"jpg";
                }
            }
            NSURL* url = [_url URLByAppendingPathComponent:fileName];
            if (url != nil){
                if (! [[fileName pathExtension] isEqualToString:fileType]) {
                    url = [url URLByAppendingPathExtension:fileType];
                }
                if (isJpg){
                    ret = [[ImageCloudDocument alloc] initWithFileURL:url];
                }
                else {
                    ret = [[CloudDocument alloc] initWithFileURL:url];
                }
                [_iCloudDict setObject:ret forKey:fileName];
            }
        }
        else {
            YD1LOG(@"url error : please check Capabilities -> iCloud -> iCloud Documents item whether or not to choose !!! OR Whether the device is open iCloud function !!!");
        }
    }
    return ret;
}

- (void)changeCloudFileData:(NSString*) fileName data:(NSString *)newData
{
    CloudDocument* doc = [self getDocumentbyFileName:fileName];
    if (doc != nil /*&& (doc.documentState & UIDocumentStateInConflict)*/) {
        [NSFileVersion removeOtherVersionsOfItemAtURL:doc.fileURL error:NULL];
        for (NSFileVersion* version in [NSFileVersion unresolvedConflictVersionsOfItemAtURL:doc.fileURL]) {
            version.resolved = YES;
        }
        [doc setData:newData];
        [doc updateChangeCount:UIDocumentChangeDone];
    }
}

- (void)createCloudFile:(NSString*) fileName data:(NSString *)data
{
    CloudDocument* doc = [self getDocumentbyFileName:fileName];
    if (doc != nil) {
        [doc setData:data];
        [doc saveToURL:doc.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success){
                YD1LOG(@"createCloudFile Successed !");
            }
        }];
    }
}

- (void)removeRecordWithId:(NSString*) fileName
{
    CloudDocument* doc = [self getDocumentbyFileName:fileName];
    if (doc != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [coordinator coordinateWritingItemAtURL:doc.fileURL options:NSFileCoordinatorWritingForDeleting error:NULL byAccessor:^(NSURL *newURL) {
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                [fileManager removeItemAtURL:newURL error:NULL];
                YD1LOG(@"deleteFileToCloud name : %@ successed !", fileName);
            }];
        });
    }
}

- (void)loadToCloud:(NSString*) fileName completionHandler:(void (^__nullable)(NSString * __nullable results, NSError * __nullable error))completionHandler
{
    CloudDocument* doc = [self getDocumentbyFileName:fileName];
    if (doc != nil) {
        [doc openWithCompletionHandler:^(BOOL success) {
            if (success){
                if (completionHandler != nil) {
                    NSString* pData = [doc getData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(pData, nil);
                    });
                }
            } else {
                if (completionHandler != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(@"", [NSError errorWithDomain:[NSString stringWithFormat:@"Open \"%@\" Error !", fileName] code:-1 userInfo:nil]);
                    });
                }
            }
        }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(@"", [NSError errorWithDomain:[NSString stringWithFormat:@"Open \"%@\" Error !", fileName] code:-1 userInfo:nil]);
        });
    }
}

- (void)saveToCloud:(NSString*) fileName saveValue:(NSString *)data
{
    if ([self hasCacheFile:fileName]){
        [self changeCloudFileData:fileName data:data];
    }
    else {
        [self createCloudFile:fileName data:data];
    }
}

- (BOOL)hasCacheFile:(NSString*)fileName
{
    return [_iCloudDict objectForKey:fileName] != nil;
}

@end
