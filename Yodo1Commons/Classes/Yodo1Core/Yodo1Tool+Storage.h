//
//  Yodo1Tool+Storage.h
//  Yodo1UCManager
//
//  Created by yixian huang on 2020/5/5.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Tool.h"
#import "Yodo1YYCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1Tool (Storage)

/// cache
- (Yodo1YYCache*)cached;

/// keychain
- (void)saveKeychainWithService:(NSString *)service str:(NSString *)str;
- (NSString *)keychainWithService:(NSString *)service;

- (NSString *)keychainUUID;
/// device id
- (NSString *)keychainDeviceId;

@end

NS_ASSUME_NONNULL_END
