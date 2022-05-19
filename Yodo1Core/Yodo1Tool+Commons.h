//
//  Yodo1Tool+Commons.h
//  Yodo1UCManager
//
//  Created by yixian huang on 2020/5/5.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Tool.h"

NS_ASSUME_NONNULL_BEGIN

@class CTTelephonyNetworkInfo;

@interface Yodo1Tool (Commons)
- (NSString *)documents;
- (NSString *)cachedPath;
- (id)JSONObjectWithObject:(id)object;
- (NSData *)dataWithJSONObject:(id)obj error:(NSError**)error;
- (id)JSONObjectWithData:(NSData*)data error:(NSError**)error;
- (id)JSONObjectWithString:(NSString*)str error:(NSError**)error;
- (NSString *)stringWithJSONObject:(id)obj error:(NSError**)error;
- (NSString *)signMd5String:(NSString *)origString;
- (NSDictionary *)bundlePlistWithPath:(NSString *)name;
- (NSString *)appName;
- (NSString *)appBid;
- (NSString *)appVersion;
- (NSString *)appBundleVersion;
- (NSDictionary *)appBundle;
///十三位数时间戳
- (NSString *)nowTimeTimestamp;
///十位数时间戳
- (NSString *)nowTimeTenTimestamp;
- (NSString *)idfa;
- (NSString *)idfv;
- (NSString *)networkType;
- (CTTelephonyNetworkInfo *)telephonyInfo;
- (NSString *)networkOperatorName;
- (NSString *)uuid;
- (NSString *)countryCode;
- (NSString *)languageCode;
- (NSString *)language;
- (NSString *)localizedString:(NSString *)bundleName
                          key:(NSString *)key
                defaultString:(NSString *)defaultString;
- (NSString *)currencyCode:(NSLocale *)priceLocale;
- (BOOL)isIPad;
- (NSString *)gameAppKey;
- (NSString *)gameVersion;
- (NSString *)channelId;
- (NSString *)channelCode;
- (NSString *)regionCode;
- (NSString *)deviceId;
- (NSString *)sdkVersion;
- (NSString *)sdkType;
- (NSString *)data;
- (NSString *)error;
- (NSString *)errorCode;
- (NSString *)timeStamp;
- (NSString *)sign;
- (NSString *)orderId;

- (BOOL)archiveObject:(id)object path:(NSString *)path;

- (id)unarchiveClass:(NSSet*)classes path:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
