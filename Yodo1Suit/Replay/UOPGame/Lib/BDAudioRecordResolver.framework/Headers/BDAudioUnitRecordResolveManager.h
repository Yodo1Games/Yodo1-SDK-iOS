//
//  BDAudioUnitRecordResolveManager.h
//  BDReplay
//
//  Created by Cliffe on 2021/8/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

#define BDAudioNewRegisterAudioUnitNotification @"BDAudioNewRegisterAudioUnitNotification"
#define BDAudioNewRegisterAuGraphNotification @"BDAudioNewRegisterAuGraphNotification"
#define BDAudioNewRegisteredObject @"BDAudioNewRegisteredObject"

@interface BDAudioUnitRecordResolveManager : NSObject

+ (id)sharedManager;

/**
 注册非游戏方使用的AudioUnit
 @param audioUnit audioUnit
*/
- (void)registerNonGameUsedAudioUnit:(AudioUnit)audioUnit;

/**
 去除非游戏方使用的AudioUnit
 @param audioUnit audioUnit
*/
- (void)unregisterNonGameUsedAudioUnit:(AudioUnit)audioUnit;

/**
 注册非游戏方使用的AUGraph
 @param auGraph auGraph
*/
- (void)registerNonGameUsedAuGraph:(AUGraph)auGraph;

/**
 去除非游戏方使用的AUGraph
 @param auGraph auGraph
*/
- (void)unregisterNonGameUsedAuGraph:(AUGraph)auGraph;

/**
 注册RTC方使用的AudioUnit
 @param audioUnit audioUnit
*/
- (void)registerRTCUsedAudioUnit:(AudioUnit)audioUnit;

/**
 去除RTC方使用的AudioUnit
 @param audioUnit audioUnit
*/
- (void)unregisterRTCUsedAudioUnit:(AudioUnit)audioUnit;

/**
 判断某个audioUnit是否在决议库列表中（包含RTC用的audioUnit）
 @param audioUnit audioUnit
 @return 如果存在返回YES，否则返回NO
*/
- (BOOL)existAudioUnit:(AudioUnit)audioUnit;

/**
 判断某个auGraph是否在决议库列表中（包含RTC用的auGraph）
 @param auGraph auGraph
 @return 如果存在返回YES，否则返回NO
*/
- (BOOL)existAuGraph:(AUGraph)auGraph;

@end

NS_ASSUME_NONNULL_END
