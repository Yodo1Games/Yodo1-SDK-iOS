//
//  Yodo1Tool+Storage.m
//  Yodo1UCManager
//
//  Created by yixian huang on 2020/5/5.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"
#import <Security/Security.h>

@implementation Yodo1Tool (Storage)

static Yodo1YYCache* _sharedCached = nil;
- (Yodo1YYCache *)cached {
    if (_sharedCached == nil) {
        _sharedCached = [[Yodo1YYCache alloc]initWithPath:Yodo1Tool.shared.cachedPath];
    }
    return _sharedCached;
}

- (void)saveKeychainWithService:(NSString *)service str:(NSString *)str {
    [self save:service data:str];
}

- (NSString *)keychainWithService:(NSString *)service {
    NSString *str = (NSString *)[self load:service];
    if ([str isKindOfClass:[NSString class]]) {
        return str;
    }
    [self deleteKeyData:service];
    return @"";
}

- (NSString *)keychainUUID {
    NSString *strUUID = (NSString *)[self load:Yd1OpsTools.appBid];
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""]|| !strUUID) {
        //生成一个uuid的方法
        strUUID = [NSUUID UUID].UUIDString;
        //将该uuid保存到keychain
        [self saveKeychainWithService:Yd1OpsTools.appBid str:strUUID];
    }
    return strUUID;
}

- (NSString *)keychainDeviceId {
    NSString* __deviceId = (NSString *)[self load:@"__yodo1__device__id__"];
    if ([__deviceId isEqualToString:@""]||!__deviceId) {
        __deviceId = Yd1OpsTools.idfa;
        if ([__deviceId hasPrefix:@"00000000"]||[__deviceId isEqualToString:@""]) {
            __deviceId = Yd1OpsTools.idfv;
        }
        if ([__deviceId isEqualToString:@""]) {
            __deviceId = [NSUUID UUID].UUIDString;
        }
        [self saveKeychainWithService:@"__yodo1__device__id__" str:__deviceId];
    }
    return __deviceId;
}

#pragma mark private
- (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    // Configure the search setting
    // Since in our simple case we areexpecting only a single attribute to be returned (the password) wecan set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery,(CFTypeRef*)&keyData) ==noErr){
        @try{
            ret =[NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData*)keyData];
        }@catch(NSException *e) {
            YD1LOG(@"Unarchive of %@ failed: %@",service, e);
        }@finally{
            
        }
    }
    if (keyData) {
        CFRelease(keyData);
    }
    return ret;
}

- (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service,(id)kSecAttrService,
            service,(id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

- (void)save:(NSString *)service data:(id)data {
    // Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    // Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    // Add new object to searchdictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data]forKey:(id)kSecValueData];
    // Add item to keychain with the searchdictionary
    SecItemAdd((CFDictionaryRef)keychainQuery,NULL);
}

- (void)deleteKeyData:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end
