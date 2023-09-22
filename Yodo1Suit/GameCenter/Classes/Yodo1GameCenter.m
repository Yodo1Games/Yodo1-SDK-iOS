//
//  Yodo1GameCenter.mm
//  GameCenter
//
//  Created by zhaojun on 16/3/18.
//  Copyright © 2016年 zhaojun. All rights reserved.
//
#import <GameKit/GameKit.h>

#import "Yodo1GameCenter.h"
#import "Yodo1Commons.h"
#import "GameCenterManager.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Base.h"
#import "Yodo1AnalyticsManager.h"
#import "Yodo1UCenter.h"

@interface Yodo1GameCenter ()<GameCenterManagerDelegate>

@end

@implementation Yodo1GameCenter

static Yodo1GameCenter* _instance = nil;

+ (Yodo1GameCenter*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [Yodo1GameCenter new];
    });
    return _instance;
}

- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)initGameCenter {
    
    NSString* key = [[NSBundle mainBundle] bundleIdentifier];
    if(key == nil){
        key = @"com.yodo1.gamecenter";
    }
    [[GameCenterManager sharedManager]setupManagerAndSetShouldCryptWithKey:key];
    [[GameCenterManager sharedManager]setDelegate:[Yodo1GameCenter sharedInstance]];
}

- (void)dealloc {
}

#pragma mark- GameCenterManagerDelegate

/// Required Delegate Method called when the user needs to be authenticated using the GameCenter Login View Controller
- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController
{
    [[Yodo1Commons getRootViewController] presentViewController:gameCenterLoginController animated:YES completion:^{
        YD1LOG(@"Finished Presenting Authentication Controller");
    }];
}

- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation {
    YD1LOG(@"GC Availabilty: %@", availabilityInformation);
    BOOL bGameCenterAvailable = false;
    if ([[availabilityInformation objectForKey:@"status"] isEqualToString:@"GameCenter Available"]) {
        YD1LOG(@"Game Center is online, the current player is logged in, and this app is setup.");
        bGameCenterAvailable = true;
    } else {
        YD1LOG(@"GameCenter Unavailable");
    }
    
    GKLocalPlayer *player = [[GameCenterManager sharedManager] localPlayerData];
    YD1LOG(@"alias:%@,playerID:%@,displayName:%@",player.alias,player.playerID,player.displayName);
    if (player) {
        if ([player isUnderage] == NO) {
            YD1LOG(@"Player is not underage and is signed-in");
            [[GameCenterManager sharedManager] localPlayerPhoto:^(UIImage *playerPhoto) {
                
            }];
        } else {
            YD1LOG(@"Underage player, %@, signed in.", player.displayName);
        }
        [Yodo1AnalyticsManager.sharedInstance trackEvent:@"sdk_login_channel" eventValues:@{@"channel_login_status":@"success", @"channel_error_code":@"0", @"channel_error_message":@"", @"channel_sdk_version":@"GameCenter"}];
        
    } else {
        YD1LOG(@"No GameCenter player found.");
        [Yodo1AnalyticsManager.sharedInstance trackEvent:@"sdk_login_channel" eventValues:@{@"channel_login_status":@"fail", @"channel_error_code":@"1", @"channel_error_message":@"No GameCenter player found.", @"channel_sdk_version":@"GameCenter"}];
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error {
    YD1LOG(@"GCM Error: %@", error);
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedAchievement:(GKAchievement *)achievement withError:(NSError *)error {
    if (!error) {
        YD1LOG(@"GCM Reported Achievement: %@", achievement);
        YD1LOG(@"Reported achievement with %.1f percent completed", achievement.percentComplete);
    } else {
        YD1LOG(@"GCM Error while reporting achievement: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedScore:(GKScore *)score withError:(NSError *)error {
    if (!error) {
        YD1LOG(@"GCM Reported Score: %@", score);
    } else {
        YD1LOG(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveScore:(GKScore *)score {
    YD1LOG(@"Saved GCM Score with value: %lld", score.value);
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveAchievement:(GKAchievement *)achievement {
    YD1LOG(@"Saved GCM Achievement: %@", achievement);
}

#pragma mark- API

// 判断是否登录
- (BOOL)gameCenterIsLogin {
    return [[GameCenterManager sharedManager]isGameCenterAvailable];
}

// 解锁成就
- (void)achievementsUnlock:(NSString *)identifier {
    YD1LOG(@"identifier = %@", identifier);
    [[GameCenterManager sharedManager]saveAndReportAchievement:identifier
                                               percentComplete:100.0f shouldDisplayNotification:YES];
}

// 提交分数
- (void)UpdateScore:(int)score leaderboard:(NSString *)identifier {
    YD1LOG(@"score = %d, identifier = %@", score, identifier);
    [[GameCenterManager sharedManager]saveAndReportScore:score
                                             leaderboard:identifier
                                               sortOrder:GameCenterSortOrderHighToLow];
}

// 打开挑战榜
- (void)ShowGameCenter {
    YD1LOG(@"Open the challenge list.");
    [[GameCenterManager sharedManager]presentChallengesOnViewController:[Yodo1Commons getRootViewController]];
}

// 打开排行榜
- (void)LeaderboardsOpen {
    YD1LOG(@"Open leaderboard.");
    [[GameCenterManager sharedManager]presentLeaderboardsOnViewController:[Yodo1Commons getRootViewController]];
}

// 打开成就榜
- (void)AchievementsOpen {
    YD1LOG(@"Open the achievement list");
    [[GameCenterManager sharedManager]presentAchievementsOnViewController:[Yodo1Commons getRootViewController]];
}

// 获取指定identifier的成就完成百分比
- (double)ProgressForAchievement:(NSString *)identifier {
    YD1LOG(@"identifier = %@", identifier);
    return [[GameCenterManager sharedManager]progressForAchievement:identifier];
}

// 获取指定identifier排行榜的最高分
- (int)highScoreForLeaderboard:(NSString *)identifier {
    YD1LOG(@"identifier = %@", identifier);
    return [[GameCenterManager sharedManager]highScoreForLeaderboard:identifier];
}

@end
