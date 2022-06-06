//
//  Yodo1GameCenter.h
//  GameCenter
//
//  Created by zhaojun on 16/3/18.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Yodo1GameCenter : NSObject

+ (Yodo1GameCenter*)sharedInstance;

// GameCenter初始化，登录
- (void)initGameCenter;

// 判断是否登录
- (BOOL)gameCenterIsLogin;

// 解锁成就
- (void)achievementsUnlock:(NSString *)identifier;

// 提交分数
- (void)UpdateScore:(int)score leaderboard:(NSString *)identifier;

// 打开挑战榜
- (void)ShowGameCenter;

// 打开排行榜
- (void)LeaderboardsOpen;

// 打开成就榜
- (void)AchievementsOpen;

// 获取指定identifier的成就完成百分比
- (double)ProgressForAchievement:(NSString *)identifier;

// 获取指定identifier排行榜的最高分
- (int)highScoreForLeaderboard:(NSString *)identifier;

@end
