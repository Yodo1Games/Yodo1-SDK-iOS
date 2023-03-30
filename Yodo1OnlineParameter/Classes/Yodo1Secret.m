//
//  Yodo1Secret.m
//  Yodo1SDK
//
//  Created by yanpeng on 2020/9/4.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Secret.h"

static inline NSString * _secretRewardGame(void)
{
    return @"7vJvQSZbcMTggaay2pD47l5l";
}
 
@implementation _Yodo1Secret

static Yodo1Secret_t * sec = NULL;
+(Yodo1Secret_t *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sec = malloc(sizeof(Yodo1Secret_t));
        sec->secretRewardGame = _secretRewardGame;
    });
    return sec;
}
 
+ (void)destroy {
    sec ? free(sec) : 0;
    sec = NULL;
}
@end
