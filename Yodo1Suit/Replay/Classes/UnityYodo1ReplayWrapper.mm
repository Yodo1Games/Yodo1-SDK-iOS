#import "Yodo1Replay.h"
#import "Yodo1Commons.h"

#ifdef __cplusplus
extern "C" {
#endif

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
