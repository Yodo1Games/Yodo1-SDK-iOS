//
//  Yodo1AntiAddictionLog.h
//  Yodo1AntiAddiction
//
//  Created by Sunmeng on 2024/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//#define Yodo1AntiAddictionLog(FORMAT, ...) \
//({\
//if ([Yodo1AntiAddictionLog isEnableDebugLog]) {\
//NSString *file = [[NSString stringWithFormat:@"%s",__FILE__] componentsSeparatedByString:@"/"].lastObject;\
//NSLog(@"[AntiAddiction] %@ - {%s:%d}, %@\n", file, __FUNCTION__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]);\
//}\
//})

#define Yodo1AntiAddictionLog(FORMAT, ...) \
({\
NSString *file = [[NSString stringWithFormat:@"%s",__FILE__] componentsSeparatedByString:@"/"].lastObject;\
NSLog(@"[AntiAddiction] %@ - {%s:%d}, %@\n", file, __FUNCTION__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]);\
})

@interface Yodo1AntiAddictionLog : NSObject

+ (void)setEnableDebugLog:(BOOL)enable;
+ (BOOL)isEnableDebugLog;

@end

NS_ASSUME_NONNULL_END
