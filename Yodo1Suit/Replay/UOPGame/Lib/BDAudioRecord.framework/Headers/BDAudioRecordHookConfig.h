//
//  BDAudioRecordHookConfig.h
//  BDAudioRecord
//
//  Created on 2022/8/28.
//

#import <Foundation/Foundation.h>

/**
 前一次 BDAudioRecord 的启动状态
 */
@interface BDAudioRecordPreLaunchState : NSObject

// 前一次启动结束时候的 hook 函数 enter count
// 如果 > 0 表示有异常
@property (assign) int preEnterCount;

// 当前这次启动时候剩余的重试次数
@property (assign) int currentRetryCount;

@end

@interface BDAudioRecordHookConfig : NSObject

+ (instancetype)shared;

/**
 * 配置 hook 是否开启，多方同时配置的时候，使用或运算规则
 *  > 一方开启就开启，全部关闭才是关闭
 * @param key 业务方 key，事先约定
 *  * 1001: 高光
 *  * 1002: RTC
 *  * 1003: 直播
 * @param enable 是否开启
 */
- (int)enableHook:(UInt32)key enable:(BOOL)enable;

/**
 * 配置 hook 是否强制关闭，多方同时配置的时候，使用或运算规则，优先级大于 enableHook
 *  > 一方关闭就关闭，全部关闭才关闭
 * @param key 业务方 key，事先约定
 *  * 1001: 高光
 *  * 1002: RTC
 *  * 1003: 直播
 * @param disable 是否关闭
 */
- (int)forceDisableHook:(UInt32)key disable:(BOOL)disable;

/**
 判断当前 hook 的开关状态
 */
- (BOOL)isHookEnable;

/**
* 获取前一次启动的状态，用于日志上报
*/
- (BDAudioRecordPreLaunchState*)getPreLaunchState;

@end
