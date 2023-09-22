#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Model.h"
#import "GameCenterManager.h"
#import "Yodo1GameCenter.h"
#import "Yodo1UCenter.h"

#ifdef __cplusplus
extern "C" {
#endif
    //登录
    void UnityGameCenterLogin(char* callbackGameObj, char* callbackMethod)
    {
        [[Yodo1GameCenter sharedInstance] initGameCenter];
        NSString *ocObjectName = ConvertCharToNSString(callbackGameObj);
        NSString *ocMethodName = ConvertCharToNSString(callbackMethod);
        
        [[Yodo1UCenter shared] loginWitheDeviceId:^(YD1User * _Nullable user, NSError * _Nullable error) {
            if (user != nil) {
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
                    
                    if (user.isnewuser == 1) {
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
                    Yodo1UnitySendMessage([ocObjectName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            } else {
                if(ocObjectName != nil && ocMethodName != nil){
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                    [dict setObject:[NSNumber numberWithInt:3001] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    [dict setObject:@"Convert result to json failed!" forKey:@"msg"];

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
                    Yodo1UnitySendMessage([ocObjectName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                }
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
        [[GameCenterManager sharedManager]saveAndReportAchievement:ConvertCharToNSString(achievementId)
                                                   percentComplete:100.0f shouldDisplayNotification:YES];
    }
    
    //提交分数
    void UnityUpdateScore(char* scoreId, int score)
    {
        [[GameCenterManager sharedManager]saveAndReportScore:score
                                                 leaderboard:ConvertCharToNSString(scoreId)
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
        NSString *_identifier = ConvertCharToNSString(identifier);
        return [[GameCenterManager sharedManager]progressForAchievement:_identifier];
    }
    
    /// 获取指定identifier排行榜的最高分
    int  UnityHighScoreForLeaderboard(const char* identifier)
    {
        NSString *_identifier = ConvertCharToNSString(identifier);
        return [[GameCenterManager sharedManager]highScoreForLeaderboard:_identifier];
    }
#ifdef __cplusplus
}
#endif
