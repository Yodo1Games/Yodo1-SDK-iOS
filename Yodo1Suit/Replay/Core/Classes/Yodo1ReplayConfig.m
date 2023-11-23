//
//  Yodo1ReplayConfig.m
//  Yodo1Suit
//
//  Created by Sunmeng on 2023/11/16.
//

#import "Yodo1ReplayConfig.h"

@implementation Yodo1ReplayDouyinConfig

@end

@implementation Yodo1ReplayConfig

- (id)init{
    self = [super init];
    if (self) {
        _replayPlatform = Yodo1ReplayPlatformApple;
        _sharingType = Yodo1ReplaySharingTypeAuto;
        _douyinConfig = [[Yodo1ReplayDouyinConfig alloc] init];
        _douyinConfig.replayType = Yodo1ReplayTypeAuto;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _replayPlatform = (Yodo1ReplayPlatform)[[dict objectForKey:@"replay_platform"] intValue];
        _sharingType = (Yodo1ReplaySharingType)[[dict objectForKey:@"sharing_type"] intValue];
        _douyinConfig = [[Yodo1ReplayDouyinConfig alloc] init];
        _douyinConfig.appId = [dict objectForKey:@"douyin_app_id"];
        _douyinConfig.clientKey = [dict objectForKey:@"douyin_client_key"];
        _douyinConfig.hashtag = [dict objectForKey:@"douyin_hash_tag"];
        _douyinConfig.replayType = (Yodo1ReplayType)[[dict objectForKey:@"douyin_replay_type"] intValue];
    }
    return self;
}



@end
