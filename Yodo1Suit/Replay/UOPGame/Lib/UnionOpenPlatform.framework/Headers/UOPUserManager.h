//
//  UOPUserManager.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/21.
//

#import <Foundation/Foundation.h>
#import <UnionOpenPlatform/UOPUser.h>

NS_ASSUME_NONNULL_BEGIN

/// 归因结果通知
/// @discussion UserInfo{kOSDKUserAggregationStatusKey: statusResult}
extern NSString *const kOSDKUserAggregationStatusChageNotificationKey;
/// 归因结果key
/// @discussion 从归因结果通知中取出归因结果，statusResult: (UOPAggregationAttributionType)
extern NSString *const kOSDKUserAggregationStatusKey;

@interface UOPUserManager : NSObject

+ (instancetype)sharedManager;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 当前用户信息，每次登录态发生变化时需要更新
@property (nonatomic, strong) UOPUser *currentUser;
/// 登出或者切换账号时需要调用
- (void)logoutUser;

@end

NS_ASSUME_NONNULL_END
