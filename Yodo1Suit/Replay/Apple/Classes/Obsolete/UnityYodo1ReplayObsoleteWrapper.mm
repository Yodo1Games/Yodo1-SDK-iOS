#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "NSObject+Yodo1Model.h"
#import "Yodo1Tool+Commons.h"

#import "Yodo1Replay.h"

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark - Obsolete
void UnityStartScreenRecorder()
{
    [[Yodo1Replay sharedInstance]startScreenRecorder];
}

bool UnitySupportReplay()
{
    return [[Yodo1Replay sharedInstance]bSupportReplay];
}

void UnityStopScreenRecorder()
{
    [[Yodo1Replay sharedInstance]stopScreenRecorder];
}

void UnityShowRecorder ()
{
    [[Yodo1Replay sharedInstance]showRecorder:[Yodo1Commons getRootViewController]];
}


#ifdef __cplusplus
}
#endif

