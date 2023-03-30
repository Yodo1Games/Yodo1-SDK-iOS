//
//  Yodo1CoreBase.m
//  Yodo1sdk
//
//  Created by hyx on 2019/8/30.
//

#import "Yodo1CoreBase.h"

@implementation Yodo1CoreBase

static Yodo1CoreBase *userManager = nil;
static dispatch_once_t onceToken;

+ (instancetype)shared {
    dispatch_once(&onceToken, ^{
        userManager = [[Yodo1CoreBase alloc]init];
        
        userManager.sharedAppDelegate = [[NSMutableDictionary alloc]init];
        userManager.sharedInstanceDic = [[NSMutableDictionary alloc]init];
        userManager.sharedObjDic = [[NSMutableDictionary alloc]init];
        userManager.sharedObjBindDic = [[NSMutableDictionary alloc]init];
    });
    return userManager;
}

@end
