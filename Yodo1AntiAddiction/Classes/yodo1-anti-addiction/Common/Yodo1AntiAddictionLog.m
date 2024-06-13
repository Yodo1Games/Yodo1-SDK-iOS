//
//  Yodo1AntiAddictionLog.m
//  Yodo1AntiAddiction
//
//  Created by Sunmeng on 2024/6/13.
//

#import "Yodo1AntiAddictionLog.h"

@implementation Yodo1AntiAddictionLog

static BOOL enableDebugLoag;
+ (void)setEnableDebugLog:(BOOL)enable {
    enableDebugLoag = enable;
}

+ (BOOL)isEnableDebugLog {
    return enableDebugLoag;
}

@end
