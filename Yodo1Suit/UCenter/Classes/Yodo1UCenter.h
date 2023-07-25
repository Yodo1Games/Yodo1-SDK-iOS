//
//  Yodo1UCenter.h
//
//  Created by yixian huang on 2017/7/24.
//
//

#ifndef Yodo1UCenter_h
#define Yodo1UCenter_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YD1User : NSObject <NSSecureCoding>
/// 玩家Id
@property(nonatomic,strong)NSString* playerid;
/// 玩家昵称
@property(nonatomic,strong)NSString* nickname;
/// ucuid
@property(nonatomic,strong)NSString* ucuid;

/// 用户在每个游戏中对应的id
@property(nonatomic,strong)NSString* yid;
/// 用户的唯一id
@property(nonatomic,strong)NSString* uid;
/// token
@property(nonatomic,strong)NSString* token;
/// 标志用户是否联网登记实名制信息;0为未联网登记, 1为联网验证登记
@property(nonatomic,assign)int isOLRealName;
/// 标志用户是否本地登记实名制信息;0为未本地登记，1为本地验证登记
@property(nonatomic,assign)int isRealName;
/// 是否是新用户
@property(nonatomic,assign)int isnewuser;
/// 是否是新注册的用户
@property(nonatomic,assign)int isnewyaccount;
/// extra
@property(nonatomic,strong)NSString* extra;

@end



@interface Yodo1UCenter:NSObject

@property(nonatomic,strong)NSString* gameAppKey;
@property(nonatomic,strong)NSString* regionCode;

+ (instancetype)shared;

- (void)init:(NSString *)appKey regionCode:(NSString *)regionCode;

/// Log in to the Yodo1 user center with device ID
///
/// - Parameter callback: YD1User. NSError
- (void)loginWitheDeviceId:(void(^)(YD1User* _Nullable user, NSError* _Nullable  error))callback;


/// Log in to the Yodo1 user center with player ID
///
/// @param playerId Your player ID
/// @param callback YD1User, NSError
- (void)loginWithPlayerId:(NSString *)playerId
                 callback:(void(^)(YD1User* _Nullable user, NSError* _Nullable  error))callback;

/**
 *  设备登录
 *  @param playerId 是玩家id
 */
- (void)deviceLoginWithPlayerId:(NSString *)playerId
                       callback:(void(^)(YD1User* _Nullable user, NSError* _Nullable  error))callback DEPRECATED_MSG_ATTRIBUTE("Please use [Yodo1UCenter shared] loginWithPlayerId: callback:]");

- (YD1User *)getUserInfo;

@end

NS_ASSUME_NONNULL_END
#endif /* Yodo1UCenter_h */
