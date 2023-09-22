//
//  UnityYodo1AntiAddiction.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/4.
//
#import <Foundation/Foundation.h>

#import "UnityYodo1AntiAddiction.h"
#import "Yodo1AntiAddictionUtils.h"
#import "Yodo1AntiAddiction.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Model.h"
static NSString *kLog_TAG             = @"[Yodo1-AntiAddiction-SDK] ";


static NSString *kRESULT_TYPE         = @"result_type";
static NSString *kRESULT_CODE         = @"code";
static NSString *kRESULT_BOOL         = @"state";
static NSString *kRESULT_ERROR        = @"error";
static NSString *kRESULT_EVENT_ACTION = @"event_action";
static NSString *kRESULT_EVENT_CODE   = @"event_code";
static NSString *kRESULT_TITLE        = @"title";
static NSString *kRESULT_CONTENT      = @"content";
static NSString *kRESULT_LIMIT        = @"hasLimit";
static NSString *kRESULT_ALERT_MSG    = @"alertMsg";

@interface Yodo1U3dAntiAddictionDelegate:NSObject <Yodo1AntiAddictionDelegate>
{
    NSString* _gameObjectName;
    NSString* _callbackName;
}
@end

@implementation Yodo1U3dAntiAddictionDelegate
+ (Yodo1U3dAntiAddictionDelegate *)shared {
    static Yodo1U3dAntiAddictionDelegate *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1U3dAntiAddictionDelegate alloc] init];
    });
    return sharedInstance;
}

- (void)initWith:(NSString*)gameObjectName  callbackName: (NSString*)callbackName
{
    _gameObjectName = gameObjectName;
    _callbackName = callbackName;
}

/// SDK初始化回调
- (void)onInitFinish:(BOOL)result message:(NSString *)message
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInteger:ResulTypeInit] forKey:kRESULT_TYPE];
    [dict setObject:[[NSNumber alloc]initWithBool:result] forKey:kRESULT_BOOL];
    [dict setObject:message forKey:kRESULT_CONTENT];
    
    NSError* parseJSONError = nil;
    NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
    if(parseJSONError){
        [dict setObject:[NSNumber numberWithInt:ResulTypeInit] forKey:kRESULT_TYPE];
        [dict setObject:[[NSNumber alloc]initWithBool:result] forKey:kRESULT_BOOL];
        [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
        msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
    }
    Yodo1UnitySendMessage([_gameObjectName cStringUsingEncoding:NSUTF8StringEncoding],
                     [_callbackName cStringUsingEncoding:NSUTF8StringEncoding],
                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
}

/// 游戏通知
/// 返回YES 表示由游戏自己处理通知，否则SDK会使用默认处理方式
- (BOOL)onTimeLimitNotify:(Yodo1AntiAddictionEvent *)event title:(NSString *)title message:(NSString *)message
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInteger:ResulTypeTimeLimit] forKey:kRESULT_TYPE];
    [dict setObject:[NSNumber numberWithInteger:[event action]] forKey:kRESULT_EVENT_ACTION];
    [dict setObject:[NSNumber numberWithInteger:[event eventCode]] forKey:kRESULT_EVENT_CODE];
    [dict setObject:title forKey:kRESULT_TITLE];
    [dict setObject:message forKey:kRESULT_CONTENT];
    
    NSError* parseJSONError = nil;
    NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
    if(parseJSONError){
        [dict setObject:[NSNumber numberWithInt:ResulTypeTimeLimit] forKey:kRESULT_TYPE];
        [dict setObject:[NSNumber numberWithInteger:[event action]] forKey:kRESULT_EVENT_ACTION];
        [dict setObject:[NSNumber numberWithInteger:[event eventCode]] forKey:kRESULT_EVENT_CODE];
        [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
        msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
    }
    Yodo1UnitySendMessage([_gameObjectName cStringUsingEncoding:NSUTF8StringEncoding],
                     [_callbackName cStringUsingEncoding:NSUTF8StringEncoding],
                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
    return YES;
}

@end


#ifdef __cplusplus
extern "C" {
#endif
    void UnityInit(const char* appKey, const char*extraSettings, const char* regionCode, const char* gameObjectName, const char* methodName)
    {
        NSLog(@"%@UnityCall %s, appKey = %s, extraSettings = %s, regionCode = %s",kLog_TAG, __FUNCTION__, appKey, extraSettings, regionCode);
        NSString* ocAppKey = ConvertCharToNSString(appKey);
        NSString* ocExtraSettings = ConvertCharToNSString(extraSettings);
        NSString* ocRegionCode = ConvertCharToNSString(regionCode);
        NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
        NSString* ocMethodName = ConvertCharToNSString(methodName);
        [[Yodo1U3dAntiAddictionDelegate shared] initWith:ocGameObjName callbackName:ocMethodName];
        [[Yodo1AntiAddiction shared] init:ocAppKey regionCode:ocRegionCode delegate:[Yodo1U3dAntiAddictionDelegate shared]];
    }

    void UnityVerifyCertificationInfo(const char* accountId, const char* gameObjectName, const char* methodName)
    {
        NSLog(@"%@UnityCall %s, accountId = %s",kLog_TAG, __FUNCTION__, accountId);
        NSString* ocAccountId = ConvertCharToNSString(accountId);
        NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
        NSString* ocMethodName = ConvertCharToNSString(methodName);
        
        
        [[Yodo1AntiAddiction shared] verifyCertificationInfo:ocAccountId success:^BOOL(id data) {
            Yodo1AntiAddictionEvent* event = data;
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInteger:ResulTypeCertification] forKey:kRESULT_TYPE];
            [dict setObject:[NSNumber numberWithInteger:event.action] forKey:kRESULT_EVENT_ACTION];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInteger:ResulTypeCertification] forKey:kRESULT_TYPE];
                [dict setObject:[NSNumber numberWithInteger:event.action] forKey:kRESULT_EVENT_ACTION];
                [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
                msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            return YES;
        } failure:^BOOL(NSError *error) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInteger:ResulTypeCertification] forKey:kRESULT_TYPE];
            [dict setObject:[NSNumber numberWithInteger:Yodo1AntiAddictionActionEndGame] forKey:kRESULT_EVENT_ACTION];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInteger:ResulTypeCertification] forKey:kRESULT_TYPE];
                [dict setObject:[NSNumber numberWithInteger:Yodo1AntiAddictionActionEndGame] forKey:kRESULT_EVENT_ACTION];
                [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
                msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            return YES;
        }];
    }
    
    void UnityOnline(const char* gameObjectName, const char*  methodName)
    {
        NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
        NSString* ocMethodName = ConvertCharToNSString(methodName);
        [Yodo1AntiAddiction.shared online:^(BOOL result, NSString * _Nonnull content) {
            
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyBehaviorReult] forKey:kRESULT_TYPE];
            [dict setObject:[[NSNumber alloc]initWithBool:result] forKey:kRESULT_BOOL];
            [dict setObject:content? :@"" forKey:kRESULT_CONTENT];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyPurchase] forKey:kRESULT_TYPE];
                [dict setObject:[[NSNumber alloc]initWithBool:result] forKey:kRESULT_BOOL];
                [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
                msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);

        }];
        
    }

    void UnityOffline(const char* gameObjectName, const char*  methodName)
    {
        NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
        NSString* ocMethodName = ConvertCharToNSString(methodName);
        [Yodo1AntiAddiction.shared offline:^(BOOL result, NSString * _Nonnull content) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyBehaviorReult] forKey:kRESULT_TYPE];
            [dict setObject:[[NSNumber alloc]initWithBool:result] forKey:kRESULT_BOOL];
            [dict setObject:content? :@"" forKey:kRESULT_CONTENT];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyPurchase] forKey:kRESULT_TYPE];
                [dict setObject:[[NSNumber alloc]initWithBool:result] forKey:kRESULT_BOOL];
                [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
                msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);

        }];
    }

    void UnityPlayerDisconnection(const char* gameObjectName, const char*  methodName)
    {
        NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
        NSString* ocMethodName = ConvertCharToNSString(methodName);
        [Yodo1AntiAddiction.shared setDisconnection:^(NSString * _Nonnull title, NSString * _Nonnull content) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyDisconnected] forKey:kRESULT_TYPE];
            [dict setObject:content? :@"" forKey:kRESULT_CONTENT];
            [dict setObject:title? :@"" forKey:kRESULT_TITLE];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyPurchase] forKey:kRESULT_TYPE];
                [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
                [dict setObject:title? :@"" forKey:kRESULT_TITLE];
                msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);

        }];
    }


    void UnityVerifyPurchase(double price, const char*  currency, const char* gameObjectName, const char*  methodName)
    {
        NSLog(@"%@UnityCall %s, price = %f, currency = %s",kLog_TAG, __FUNCTION__, price, currency);
        NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
        NSString* ocMethodName = ConvertCharToNSString(methodName);
        [[Yodo1AntiAddiction shared] verifyPurchase:(NSInteger)price success:^(id data) {
            id hasLimit = data[kRESULT_LIMIT];
            id alertMsg = data[kRESULT_ALERT_MSG];
            
            BOOL isAllow = [hasLimit boolValue] == NO;
            
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyPurchase] forKey:kRESULT_TYPE];
            [dict setObject:[[NSNumber alloc]initWithBool:isAllow] forKey:kRESULT_BOOL];
            [dict setObject:alertMsg forKey:kRESULT_CONTENT];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyPurchase] forKey:kRESULT_TYPE];
                [dict setObject:[[NSNumber alloc]initWithBool:isAllow] forKey:kRESULT_BOOL];
                [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
                msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            return YES;
        } failure:^(NSError *error) {
            BOOL isAllow = NO;
            //error.localizedDescription
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyPurchase] forKey:kRESULT_TYPE];
            [dict setObject:[[NSNumber alloc]initWithBool:isAllow] forKey:kRESULT_BOOL];
            [dict setObject:error.localizedDescription forKey:kRESULT_CONTENT];
             
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInteger:ResulTypeVerifyPurchase] forKey:kRESULT_TYPE];
                [dict setObject:[[NSNumber alloc]initWithBool:isAllow] forKey:kRESULT_BOOL];
                [dict setObject:@"Convert result to json failed!" forKey:kRESULT_CONTENT];
                msg =  [Yodo1AntiAddictionUtils stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            return YES;
        }];
    }


    void UnityReportProductReceipt(const char* receipt)
    {
        NSString* receiptJson = ConvertCharToNSString(receipt);
        NSLog(@"%@UnityCall %s receipt = %@",kLog_TAG, __FUNCTION__, receiptJson);
        Yodo1AntiAddictionProductReceipt* receiptData = [Yodo1AntiAddictionProductReceipt yodo1_modelWithJSON:receiptJson];
        receiptData.spendDate = [Yodo1AntiAddictionUtils dateString:[NSDate date]];
        [[Yodo1AntiAddiction shared] reportProductReceipt:receiptData success:^(id data) {
            NSLog(@"%@%s %@",kLog_TAG, __FUNCTION__, @"上报成功");
            return YES;
        } failure:^(NSError *error) {
            NSLog(@"%@%s : %@ : %@",kLog_TAG, __FUNCTION__, @"上报失败", error.localizedDescription);
            return YES;
        }];
    }

    bool UnityIsGuestUser()
    {
        NSLog(@"%@UnityCall %s",kLog_TAG, __FUNCTION__);
        return [[Yodo1AntiAddiction shared] isGuestUser];
    }

    bool UnityIsChineseMainland()
    {
        NSLog(@"%@UnityCall %s",kLog_TAG, __FUNCTION__);
        return Yodo1AntiAddiction.shared.isChineseMainland;
    }
#ifdef __cplusplus
}
#endif
