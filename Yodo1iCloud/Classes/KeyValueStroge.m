//
//  KeyValueStroge.m
//  iCloudDemo
//
//  Created by zhaojun on 16/7/4.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import <CloudKit/CloudKit.h>
#import "Yodo1Object.h"
#import "KeyValueStroge.h"

static NSString* DATA_KEY = @"Yodo1Game";

@interface KeyValueStroge ()
{
    NSString* mCKContainerIdentifier;
}

- (CKDatabase*)privateCloudDatabase;

- (NSString*)getKeyByStr:(NSString*)str;

@end

@implementation KeyValueStroge

- (id) init
{
    self = [super init];
    mCKContainerIdentifier = [NSString stringWithFormat:@"iCloud.%@",[[NSBundle mainBundle] bundleIdentifier]];
    return  self;
}

- (CKDatabase*)privateCloudDatabase
{
    CKDatabase* bRet = nil;
    if ([CKContainer respondsToSelector:@selector(containerWithIdentifier:)]) {
        CKContainer* container = nil;
        @try {
            container = [CKContainer containerWithIdentifier:mCKContainerIdentifier];
        }
        @catch (NSException* e) {
            container = nil;
        }
        if (container != nil && [container respondsToSelector:@selector(privateCloudDatabase)]){
            bRet = [container privateCloudDatabase];
        }
    }
    return bRet;
}

- (NSString*)getKeyByStr:(NSString*)str
{
    NSString* ret = @"";
    if (str != nil && ![str isEqualToString:@""]) {
        ret = [str stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    }
    return ret;
}

- (void)saveToCloud:(NSString * __nullable)saveName saveValue:(NSString * __nullable)saveValue
{
    YD1LOG(@"saveName : %@, saveValue length : %lu", saveName, [saveValue length]);
    CKDatabase* cloudDataBase = [self privateCloudDatabase];
    if (cloudDataBase != nil && [cloudDataBase respondsToSelector:@selector(fetchRecordWithID:completionHandler:)]){
        NSString* key = [self getKeyByStr:saveName];
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:key];
        [cloudDataBase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                YD1LOG(@"Create New CKRecord !");
                record = [[CKRecord alloc] initWithRecordType:key recordID:[[CKRecordID alloc] initWithRecordName:key]];
            }
            record[DATA_KEY] = saveValue;
            YD1LOG(@"saveToCloud recordName : %@", record.recordID.recordName);
            [cloudDataBase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                if (error == nil){
                    YD1LOG(@"saveToCloud Successed recordID is : %@ ", key);
                }
                else {
                    YD1LOG(@"saveToCloud error : %@", error.description);
                }
            }];
        }];
    }
    else {
        YD1LOG(@"iCloud Server Error !" );
    }
}

- (void)loadToCloud:(NSString* __nullable) saveName completionHandler:(void (^)(NSString* __nullable results, NSError * __nullable error))completionHandler
{
    CKDatabase* cloudDataBase = [self privateCloudDatabase];
    if (cloudDataBase != nil && [cloudDataBase respondsToSelector:@selector(fetchRecordWithID:completionHandler:)]){
        NSString* key = [self getKeyByStr:saveName];
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:key];
        [cloudDataBase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
            NSString* ret = @"";
            if (error) {
                YD1LOG(@"fetchRecordWithID error : %@", error.description);
            }
            else {
                if (record != nil) {
                    ret = [record valueForKey:DATA_KEY];
                    YD1LOG(@"fetchRecordWithID Successed recordID is : %@", record.recordID.recordName);
                } else {
                    YD1LOG(@"fetchRecordWithID Successed, but record is nil");
                }
            }
            if (completionHandler) {
                completionHandler(ret, error);
            }
        }];
    }
    else {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:@"iCloud Server Error !" code:-100 userInfo:nil];
            completionHandler(@"", error);
        }
    }
}

- (void)removeRecordWithId:(NSString *)recordId  {
    CKDatabase* cloudDataBase = [self privateCloudDatabase];
    if (cloudDataBase != nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString* key = [self getKeyByStr:recordId];
            CKRecordID *pRecordID = [[CKRecordID alloc] initWithRecordName:key];
            [cloudDataBase deleteRecordWithID:pRecordID completionHandler:^(CKRecordID *recordID, NSError *error) {
                if (error) {
                    YD1LOG(@"deleteRecordWithID error : %@", error.description);
                }
                else {
                    YD1LOG(@"deleteRecordWithID  Successed ! recordId : %@", recordID.recordName);
                }
            }];
        });
    }
}
@end
