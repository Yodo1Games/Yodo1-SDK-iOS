//
//  Yodo1UnityTool.mm
//

#import "Yodo1UnityTool.h"

#ifdef __cplusplus
extern "C" {
#endif

void Yodo1UnitySendMessage(const char* goName, const char* functionName, const char* message) {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:ConvertCharToNSString(goName) forKey:@"object_name"];
    [dict setObject:ConvertCharToNSString(functionName) forKey:@"function_name"];
    [dict setObject:ConvertCharToNSString(message) forKey:@"message"];
    
    Class sendMessageWrapper = NSClassFromString(@"Yodo1UnitySendMessageWrapper");
    if (sendMessageWrapper) {
        SEL sel = NSSelectorFromString(@"sendMessageToGOWithDictionary:");
        if (sel && [sendMessageWrapper respondsToSelector:sel]) {
            [sendMessageWrapper performSelector:sel withObject:dict afterDelay:0];
        }
    }
}

NSString* ConvertCharToNSString(const char* string)
{
    return string ? [NSString stringWithUTF8String:string] : [NSString stringWithUTF8String:""];
}

char* ConvertNSStringToChar(NSString* string)
{
    if (string == nil) {
        string = @"";
    }
    
    const char * cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (cString == NULL)
        return NULL;
    char* res = (char*)malloc(strlen(cString) + 1);
    strcpy(res, cString);
    return res;
}

#ifdef __cplusplus
}
#endif
