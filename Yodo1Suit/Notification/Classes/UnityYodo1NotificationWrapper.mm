#import "Yodo1UnityTool.h"
#import "Yodo1LocalNotification.h"

#ifdef __cplusplus
extern "C" {
#endif
    void UnityRegisterLocalNotification(const char* notificationKey, int notificationId, const char* alertTime, const char* title, const char* msg)
    {
        NSString * ocKey = ConvertCharToNSString(notificationKey);
        NSString * ocTitle = ConvertCharToNSString(title);
        NSString * ocMsg = ConvertCharToNSString(msg);
        
        NSString * nsAlertTime = ConvertCharToNSString(alertTime);
        NSInteger alertTimeInteter = [nsAlertTime integerValue];
        
        [Yodo1LocalNotification registerLocalNotification:ocKey notificationId:notificationId
                                        alertTime:alertTimeInteter title:ocTitle msg:ocMsg];
    }

    void UnityCancelLocalNotificationWithKey(const char* notificationKey, int notificationId)
    {
        NSString * ocKey = ConvertCharToNSString(notificationKey);
        [Yodo1LocalNotification cancelLocalNotificationWithKey:ocKey notificationId:notificationId];
    }
#ifdef __cplusplus
}
#endif
