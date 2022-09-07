//
//  Yodo1LiveOps.h
//
//  Created by yixian huang on 2017/7/24.
//  v5.0.0
//

#ifndef Yodo1LiveOps_h
#define Yodo1LiveOps_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol Yodo1LiveOpsInitDelegate <NSObject>
- (void)getLiveOpsInitSuccess:(int)result;
@end

NS_ASSUME_NONNULL_BEGIN

/// Gets the online parameter configuration
@interface Yodo1LiveOps : NSObject

@property (nonatomic, weak) id<Yodo1LiveOpsInitDelegate> delegate;

+ (instancetype)sharedInstance;

- (NSString *)getSdkVersion;

/**
 Initialize according to AppKey and channel
 - Parameters:
 - appKey: Yodo1 app unique AppKey
 */
- (void)initWithAppKey:(NSString *)appKey;

/**
 Gets the online parameter configuration,return NSString Type
 - Parameters:
 - key: Online parameter configuration key
 - defaultValue: Pass in the expected value
 */
- (NSString *)stringValueWithKey:(NSString *)key
                     defaultValue:(NSString *)defaultValue;

/**
 Gets the online parameter configuration,return Bool Type
 - Parameters:
 - key: Online parameter configuration key
 - defaultValue: Pass in the expected value
 */
- (BOOL)booleanValueWithKey:(NSString *)key
             defaultValue:(BOOL)defaultValue;

/**
 Gets the online parameter configuration,return Int Type
 - Parameters:
 - key: Online parameter configuration key
 - defaultValue: Pass in the expected value
 */
- (int)intValueWithKey:(NSString *)key
           defaultValue:(int)defaultValue;

/**
 Gets the online parameter configuration,return Float Type
 - Parameters:
 - key: Online parameter configuration key
 - defaultValue: Pass in the expected value
 */
- (float)floatValueWithKey:(NSString *)key
               defaultValue:(float)defaultValue;

/**
 Gets the online parameter configuration,return Double Type
 - Parameters:
 - key: Online parameter configuration key
 - defaultValue: Pass in the expected value
 */
- (double)doubleValueWithKey:(NSString *)key
               defaultValue:(double)defaultValue;

/**
 * 激活码/优惠券
 */
- (void)verifyWithActivationCode:(NSString *)activationCode
                    callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSDictionary* _Nullable error))callback;

- (void)setDebugLog:(BOOL)debugLog;

@end

NS_ASSUME_NONNULL_END
#endif /* Yodo1LiveOps */
