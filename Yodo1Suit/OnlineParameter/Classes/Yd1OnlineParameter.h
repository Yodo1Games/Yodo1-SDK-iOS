//
//  Yd1OnlineParameter.h
//
//  Created by yixian huang on 2017/7/24.
//  v5.0.0
//

#ifndef Yd1OnlineParameter_h
#define Yd1OnlineParameter_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define Yd1OParameter  Yd1OnlineParameter.shared

typedef NS_ENUM(NSUInteger, Yd1AdsConfigType) {
    Yd1AdsConfigTypeBanner,
    Yd1AdsConfigTypeInterstitial,
    Yd1AdsConfigTypeVideo
};

FOUNDATION_EXPORT NSString* const kYodo1OnlineConfigFinishedNotification;
typedef void (^OPCachedCompletionHandler)(void);

/// Gets the online parameter configuration
@interface Yd1OnlineParameter : NSObject

@property (nonatomic,assign,readonly)BOOL bTestDevice;
@property (nonatomic,assign,readonly)BOOL bDebugModel;
@property (nonatomic,assign,readonly)BOOL bFromPA;
@property (nonatomic,assign,readonly)BOOL bFromMAS;
@property (nonatomic,assign,readonly)BOOL bAdListEmpty;
@property (nonatomic,strong,readonly)NSString *appKey;
@property (nonatomic,strong,readonly)NSString *channelId;
@property (nonatomic,strong,readonly)NSString *publishType;
@property (nonatomic,strong,readonly)NSString *publishVersion;

+ (instancetype)shared;

/**
 Complete the callback cache
 - parameters:
 - handler: callback
 */
- (void)cachedCompletionHandler:(OPCachedCompletionHandler)handler;

/**
 Initialize according to AppKey and channel
 - Parameters:
 - appKey: Yodo1 app unique AppKey
 - channelId: Distribution channels
 */
- (void)initWithAppKey:(NSString *)appKey
             channelId:(NSString *)channelId;

/**
 Gets the online parameter configuration,return NSString Type
 - Parameters:
 - key: Online parameter configuration key
 - defaultValue: Pass in the expected value
 */
- (NSString *)stringConfigWithKey:(NSString *)key
                     defaultValue:(NSString *)defaultValue;

/**
 Gets the online parameter configuration,return Bool Type
 - Parameters:
 - key: Online parameter configuration key
 - defaultValue: Pass in the expected value
 */
- (BOOL)boolConfigWithKey:(NSString *)key
             defaultValue:(BOOL)defaultValue;

///
- (NSString *)adsAppKeyPlatform:(NSString *)platform;

///
- (NSString *)ratioPlatform:(NSString *)platform
                       type:(Yd1AdsConfigType)type;
///
- (NSString *)showTimesPlatform:(NSString *)platform
                           type:(Yd1AdsConfigType)type;

///priority
- (NSArray *)configPriorityType:(Yd1AdsConfigType)type;

- (NSArray *)reportFields;

- (NSDictionary *)rewardGameConfig;

- (void)rewardGameReward:(NSDictionary *)para response:(void(^)(NSDictionary * rewardData))response;

///ads is eanble
- (BOOL)eableAdsType:(Yd1AdsConfigType)type;

@end

NS_ASSUME_NONNULL_END
#endif /* Yd1OnlineParameter_h */
