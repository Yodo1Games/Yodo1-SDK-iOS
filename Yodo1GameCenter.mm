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
#import "Yd1UCenter.h"

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
        NSLog(@"Finished Presenting Authentication Controller");
    }];
}

- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation {
    NSLog(@"GC Availabilty: %@", availabilityInformation);
    BOOL bGameCenterAvailable = false;
    if ([[availabilityInformation objectForKey:@"status"] isEqualToString:@"GameCenter Available"]) {
        NSLog(@"Game Center is online, the current player is logged in, and this app is setup.");
        bGameCenterAvailable = true;
    } else {
        NSLog(@"GameCenter Unavailable");
    }
    
    GKLocalPlayer *player = [[GameCenterManager sharedManager] localPlayerData];
    NSLog(@"alias:%@,playerID:%@,displayName:%@",player.alias,player.playerID,player.displayName);
    if (player) {
        if ([player isUnderage] == NO) {
            NSLog(@"Player is not underage and is signed-in");
            [[GameCenterManager sharedManager] localPlayerPhoto:^(UIImage *playerPhoto) {
                
            }];
        } else {
             NSLog(@"Underage player, %@, signed in.", player.displayName);
        }
    } else {
        NSLog(@"No GameCenter player found.");
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error {
    NSLog(@"GCM Error: %@", error);
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedAchievement:(GKAchievement *)achievement withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Achievement: %@", achievement);
        NSLog(@"Reported achievement with %.1f percent completed", achievement.percentComplete);
    } else {
        NSLog(@"GCM Error while reporting achievement: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedScore:(GKScore *)score withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Score: %@", score);
    } else {
        NSLog(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveScore:(GKScore *)score {
    NSLog(@"Saved GCM Score with value: %lld", score.value);
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveAchievement:(GKAchievement *)achievement {
    NSLog(@"Saved GCM Achievement: %@", achievement);
}

#pragma mark- Unity 接口

#ifdef __cplusplus
extern "C" {
    
    //登录
    void UnityGameCenterLogin(char* callbackGameObj, char* callbackMethod)
    {
        [[Yodo1GameCenter sharedInstance]initGameCenter];
        NSString *ocObjectName = Yodo1CreateNSString(callbackGameObj);
        NSString *ocMethodName = Yodo1CreateNSString(callbackMethod);
        [Yd1UCenter.shared deviceLoginWithPlayerId:@"" callback:^(YD1User * _Nullable user, NSError * _Nullable error) {
            
            if (error) {
                return;
            }
            
            if(ocObjectName != nil && ocMethodName != nil){
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:[NSNumber numberWithInt:3001] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                

                NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
                [dataDict setObject:user.uid forKey:@"opsUid"];
                [dataDict setObject:user.token forKey:@"opsToken"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"thirdpartyChannel"];
                [dataDict setObject:@"Yodo1" forKey:@"from"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"level"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"age"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"gender"];
                [dataDict setObject:[NSNumber numberWithBool:true] forKey:@"isLogin"];
                
                int isnew = user.isnewuser;
                if (isnew == 1) {
                    [dataDict setObject:[NSNumber numberWithBool:true] forKey:@"isNewUser"];
                } else {
                    [dataDict setObject:[NSNumber numberWithBool:false] forKey:@"isNewUser"];
                }
                
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"partyid"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"partyroleid"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"power"];
                [dataDict setObject:user.yid forKey:@"yid"];
                [dataDict setObject:user.uid forKey:@"userId"];
                
                [dict setObject:dataDict forKey:@"data"];
                
                NSError* parseJSONError = nil;
                NSString* msg = [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    [dict setObject:[NSNumber numberWithInt:3001] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                    msg =  [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
                } else {
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"error_code"];
                }
                UnitySendMessage([ocObjectName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
        }];
    }
    
    //是否登录
    bool UnityGameCenterIsLogin ()
    {
        return [[GameCenterManager sharedManager]isGameCenterAvailable];
    }
    
    //解锁成就
    void UnityAchievementsUnlock (char* achievementId)
    {
        [[GameCenterManager sharedManager]saveAndReportAchievement:Yodo1CreateNSString(achievementId)
                                                   percentComplete:100.0f shouldDisplayNotification:YES];
    }
    
    //提交分数
    void UnityUpdateScore(char* scoreId, int score)
    {
        [[GameCenterManager sharedManager]saveAndReportScore:score
                                                 leaderboard:Yodo1CreateNSString(scoreId)
                                                   sortOrder:GameCenterSortOrderHighToLow];
    }
    
    //打开挑战榜
    void UnityShowGameCenter ()
    {
        [[GameCenterManager sharedManager]presentChallengesOnViewController:[Yodo1Commons getRootViewController]];
    }
    
    //打开排行榜
    void UnityLeaderboardsOpen ()
    {
        [[GameCenterManager sharedManager]presentLeaderboardsOnViewController:[Yodo1Commons getRootViewController]];
    }
    
    //打开成就
    void UnityAchievementsOpen()
    {
        [[GameCenterManager sharedManager]presentAchievementsOnViewController:[Yodo1Commons getRootViewController]];
    }
    
    //获取指定identifier的成就完成百分比
    double UnityProgressForAchievement(const char* identifier)
    {
        NSString *_identifier = Yodo1CreateNSString(identifier);
        return [[GameCenterManager sharedManager]progressForAchievement:_identifier];
    }
    
    /// 获取指定identifier排行榜的最高分
    int  UnityHighScoreForLeaderboard(const char* identifier)
    {
        NSString *_identifier = Yodo1CreateNSString(identifier);
        return [[GameCenterManager sharedManager]highScoreForLeaderboard:_identifier];
    }
}
#endif
@end


