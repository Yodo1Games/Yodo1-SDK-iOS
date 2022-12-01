//
//  Yodo1UCenter.m
//  Yodo1UCenter
//
//  Created by yixian huang on 2017/7/24.
//

#import "Yodo1UCenter.h"
#import "Yodo1AFNetworking.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+LoginParameters.h"
#import "Yodo1Model.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1Analytics.h"

@implementation YD1User

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _playerid = [decoder decodeObjectForKey:@"playerid"];
        _nickname = [decoder decodeObjectForKey:@"nickname"];
        _ucuid = [decoder decodeObjectForKey:@"ucuid"];
        _yid = [decoder decodeObjectForKey:@"yid"];
        _uid = [decoder decodeObjectForKey:@"uid"];
        _token = [decoder decodeObjectForKey:@"token"];
        _isOLRealName = [decoder decodeIntForKey:@"isOLRealName"];
        _isRealName = [decoder decodeIntForKey:@"isRealName"];
        _isnewuser = [decoder decodeIntForKey:@"isnewuser"];
        _isnewyaccount = [decoder decodeIntForKey:@"isnewyaccount"];
        _extra = [decoder decodeObjectForKey:@"extra"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (self.playerid) {
        [coder encodeObject:self.playerid forKey:@"playerid"];
    }
    if (self.nickname) {
        [coder encodeObject:self.nickname forKey:@"nickname"];
    }
    if (self.ucuid) {
        [coder encodeObject:self.ucuid forKey:@"ucuid"];
    }
    [coder encodeObject:self.yid forKey:@"yid"];
    [coder encodeObject:self.uid forKey:@"uid"];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeInt:self.isOLRealName forKey:@"isOLRealName"];
    [coder encodeInt:self.isRealName forKey:@"isRealName"];
    [coder encodeInt:self.isnewuser forKey:@"isnewuser"];
    [coder encodeInt:self.isnewyaccount forKey:@"isnewyaccount"];
    if (self.extra) {
        [coder encodeObject:self.extra forKey:@"extra"];
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end


@interface Yodo1UCenter () 

@end

@implementation Yodo1UCenter

+ (instancetype)sharedInstance {
    return [Yodo1Base.shared cc_registerSharedInstance:self block:^{
        ///初始化
        YD1LOG(@"%s",__PRETTY_FUNCTION__);
    }];
}

/**
 *  设备登录
 */
- (void)deviceLoginWithCallback:(void(^)(YD1User* _Nullable user, NSError* _Nullable  error))callback {
    NSString* deviceId = Yd1OpsTools.keychainDeviceId;
    [self loginWithPlayerId:deviceId callback:callback];
}

- (void)loginWithPlayerId:(NSString *)playerId
                       callback:(void(^)(YD1User* _Nullable user, NSError* _Nullable  error))callback {
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Yd1OpsTools.ucapDomain]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString* deviceId = Yd1OpsTools.keychainDeviceId;
    if (playerId && [playerId length] > 0) {
        deviceId = playerId;
    }
    NSString *appKey = @"";
    if ([[Yodo1KeyInfo.shareInstance configInfoForKey:@"GameKey"] length] > 0) {
        appKey = [Yodo1KeyInfo.shareInstance configInfoForKey:@"GameKey"];
    }
    NSString *regionCode = @"";
    if ([[Yodo1KeyInfo.shareInstance configInfoForKey:@"RegionCode"] length] > 0) {
        regionCode = [Yodo1KeyInfo.shareInstance configInfoForKey:@"RegionCode"];
    }
    
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"yodo1.com%@%@",deviceId,appKey]];
    NSDictionary* data = @{
        Yd1OpsTools.gameAppKey:appKey ,Yd1OpsTools.channelCode:kYodo1ChannelCode,Yd1OpsTools.deviceId:deviceId,Yd1OpsTools.regionCode:regionCode};
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:data forKey:Yd1OpsTools.data];
    [parameters setObject:sign forKey:Yd1OpsTools.sign];
    YD1LOG(@"%@===%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil], Yd1OpsTools.ucapDomain);
    [manager POST:Yd1OpsTools.deviceLoginURL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.data]) {
            [Yodo1Analytics.sharedInstance trackEvent:@"sdk_login_usercenter" withValues:@{@"usercenter_login_status":@"success", @"usercenter_error_code":@"0", @"usercenter_error_message":@""}];
            NSDictionary* m_data = (NSDictionary*)[response objectForKey:Yd1OpsTools.data];
            YD1User* user = [YD1User yodo1_modelWithDictionary:m_data];
            [Yd1OpsTools.cached setObject:user forKey:@"yd1User"];
            if (callback) {
                callback(user,nil);
            }
        }else{
            [Yodo1Analytics.sharedInstance trackEvent:@"sdk_login_usercenter" withValues:@{@"usercenter_login_status":@"fail", @"usercenter_error_code":@"1", @"usercenter_error_message":error}];
            if (callback) {
                callback(nil,[NSError errorWithDomain:@"com.yodo1.ucenter" code:errorCode userInfo:@{NSLocalizedDescriptionKey:error}]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.localizedDescription);
        [Yodo1Analytics.sharedInstance trackEvent:@"sdk_login_usercenter" withValues:@{@"usercenter_login_status":@"fail", @"usercenter_error_code":@"1", @"usercenter_error_message":error.localizedDescription}];
        if (callback) {
            callback(nil,error);
        }
    }];
}

/**
 *  获取登录后的user信息
 */
- (YD1User *)getUserInfo {
    YD1User* user = (YD1User*)[Yd1OpsTools.cached objectForKey:@"yd1User"];
    return user;
}

@end
