//
//  UOPUser.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UOPAggregationAttributionType) {
    UOPAggregationAttributionUndefined = 1, //不明确
    UOPAggregationAttributionDone = 2, //直播联运归因
    UOPAggregationAttributionNot = 3, //自然量
};

@interface UOPUser : NSObject
/// 可以标识当前用户唯一id，用户登录态发生变化游戏需要传入
@property (nonatomic, copy) NSString *userID;
/// 用于归因判断，用户账户注册时间戳（秒）
@property (nonatomic, copy) NSString *userRegisterTime;
/// 用于归因判断，用户上次登录时间戳（秒）
@property (nonatomic, copy) NSString *userLastLoginTime;
/// 需要额外透传的用户信息
@property (nonatomic, copy) NSString *extraJson;

/// 用户归因类型，@1表示不明确，@2表示直播联运归因，@3表示自然量
@property (nonatomic, assign, readonly) UOPAggregationAttributionType attributionType;
@end

NS_ASSUME_NONNULL_END
