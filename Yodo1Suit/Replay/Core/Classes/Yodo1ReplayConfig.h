//
//  Yodo1ReplayConfig.h
//  Yodo1Suit
//
//  Created by Sunmeng on 2023/11/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 平台类型
typedef NS_ENUM(NSInteger, Yodo1ReplayPlatform) {
    Yodo1ReplayPlatformApple,
    Yodo1ReplayPlatformDouyin
};

/// 策略类型
typedef NS_ENUM(NSInteger, Yodo1ReplayType) {
    /// 厂商控制录制
    Yodo1ReplayTypeAuto,
    /// 用户自由录制
    Yodo1ReplayTypeManual
};

typedef NS_ENUM(NSInteger, Yodo1ReplaySharingType) {
    Yodo1ReplaySharingTypeAuto,
    Yodo1ReplaySharingTypeManual
};


@interface Yodo1ReplayDouyinConfig : NSObject

@property (nonatomic, strong, nonnull) NSString * appId;
@property (nonatomic, strong, nonnull) NSString * clientKey;

@property (nonatomic, assign) Yodo1ReplayType replayType;

@property (nonatomic, strong, nonnull) NSString * hashtag;

@end

@interface Yodo1ReplayConfig : NSObject

@property (nonatomic, assign) Yodo1ReplayPlatform replayPlatform;
@property (nonatomic, assign) Yodo1ReplaySharingType sharingType;

@property (nonatomic, strong) Yodo1ReplayDouyinConfig* douyinConfig;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end

NS_ASSUME_NONNULL_END
