//
//  UOPAPMConfig.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UOPAPMConfig : NSObject

@property (nonatomic, copy) NSString *hostAppID;

@property (nonatomic, copy, readonly) NSString *sdkAppID;
@property (nonatomic, copy, readonly) NSString *sdkVersion;
@property (nonatomic, copy, readonly) NSString *sdkName;
/// 默认为"App Store"
@property (nonatomic, copy) NSString *channel;

@property (nonatomic, assign) BOOL isDebug;

+ (instancetype)configWithHostAppID:(NSString *)appID
                            channel:(NSString *_Nullable)channel;

@end

NS_ASSUME_NONNULL_END
