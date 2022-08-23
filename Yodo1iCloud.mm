//
//  Yodo1iCloud.mm
//  Yodo1iCloud
//
//  Created by zhaojun on 16/3/18.
//  Copyright © 2016年 zhaojun. All rights reserved.
//
#import <GameKit/GameKit.h>
#import <CloudKit/CloudKit.h>

#import "Yodo1iCloud.h"
#import "Yodo1Commons.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Object.h"
#import "KeyValueStroge.h"
#import "DocumentsStroge.h"

@interface Yodo1iCloud()
{
    //这个主要为了兼容之前版本的数据
    KeyValueStroge *mKVStroge;
    DocumentsStroge *mDocStroge;
}

@end

@implementation Yodo1iCloud

static Yodo1iCloud* _instance = nil;
+ (Yodo1iCloud*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [Yodo1iCloud new];
    });
    return _instance;
}

- (id) init
{
    self = [super init];
    if (self) {
        mKVStroge = [KeyValueStroge new];
        mDocStroge = [DocumentsStroge new];
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark- iCloud

- (void)saveToCloud:(NSString * __nullable)saveName
          saveValue:(NSString * __nullable)saveValue
{
    // KVStroge
    NSInteger split = [saveName rangeOfString : @"."].location;
    if (split != NSNotFound){
        NSString* key = [saveName substringToIndex:split];
        [mKVStroge saveToCloud:key saveValue:saveValue];
    }
    
    // DocStroge
    [mDocStroge saveToCloud:saveName saveValue:saveValue];
}

- (void)loadToCloud:(NSString* __nullable) recordName
  completionHandler:(void (^)(NSString* __nullable results, NSError * __nullable error))completionHandler
{
    NSInteger split = [recordName rangeOfString : @"."].location;
    NSString* key = recordName;
    if (split != NSNotFound){
        key = [recordName substringToIndex:split];
    }
    [mKVStroge loadToCloud:key completionHandler:^(NSString * _Nullable results, NSError * _Nullable error) {
        if (error == nil) {
            if (completionHandler != nil){
                completionHandler(results, error);
            }
            [mDocStroge saveToCloud:recordName saveValue:results];
        }
        else {
            [mDocStroge loadToCloud:recordName completionHandler:completionHandler];
        }
        [mKVStroge removeRecordWithId:key];
    }];
}

- (void)removeRecordWithRecordName:(NSString *)recordName
{
    // KVStroge
    NSInteger split = [recordName rangeOfString : @"."].location;
    NSString* key = recordName;
    if (split != NSNotFound){
        key = [recordName substringToIndex:split];
    }
    [mKVStroge removeRecordWithId:key];
    
    // DocStroge
    [mDocStroge removeRecordWithId:recordName];
    
}

#pragma mark- Unity 接口

#ifdef __cplusplus
extern "C" {
    
#pragma mark- Unity of iClound
    
    void UnitySaveToCloud(const char* saveName,const char* saveValue)
    {
        NSString* pName = Yodo1CreateNSString(saveName);
        NSString* pData = Yodo1CreateNSString(saveValue);
        [[Yodo1iCloud sharedInstance] saveToCloud:pName saveValue:pData];
    }
    
    void UnityLoadToCloud(const char* saveName, const char* gameObjcetName, const char* callbackName)
    {
        NSString* ocGameObjName = Yodo1CreateNSString(gameObjcetName);
        NSString* ocMethodName = Yodo1CreateNSString(callbackName);
        NSString* name = Yodo1CreateNSString(saveName);
        [[Yodo1iCloud sharedInstance] loadToCloud:name completionHandler:^(NSString *results, NSError *error) {
            if (error != nil){
                YD1LOG(@"LoadToCloud error : %@", error.description);
            }
            
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:6001] forKey:@"resulType"];
            if(error == nil){
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
            }else{
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            }
            
            [dict setObject:name forKey:@"saveName"];
            [dict setObject:results == nil ? @"" : results forKey:@"saveValue"];
            

            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:6001] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }];
    }
    
    void UnityRemoveRecordWithRecordName(const char* saveName)
    {
        NSString* _saveName = Yodo1CreateNSString(saveName);
        [[Yodo1iCloud sharedInstance] removeRecordWithRecordName:_saveName];
    }
}
#endif
@end


