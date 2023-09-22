//
//  Yodo1UnityTool.h
//
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    extern void Yodo1UnitySendMessage(const char* goName, const char* functionName, const char* message);
    extern NSString* ConvertCharToNSString(const char* string);
    extern char* ConvertNSStringToChar(NSString* string);
//    extern char* Yodo1MakeStringCopy(const char* string);
    
#ifdef __cplusplus
}
#endif
