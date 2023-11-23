#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BDAudioRecordHookConfig.h"
#import "BDAudioRecordLog.h"
#import "GMAudioRecordStat.h"
#import "GMReplayASBDInfo.h"
#import "GMReplayAudioRecorderDelegate.h"
#import "GMReplayVolumeController.h"
#import "GMStreamCollectManager.h"

FOUNDATION_EXPORT double BDAudioRecordVersionNumber;
FOUNDATION_EXPORT const unsigned char BDAudioRecordVersionString[];

