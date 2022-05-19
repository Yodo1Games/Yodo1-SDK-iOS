//
//  Yodo1Alert.m
//

#import "Yodo1Alert.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"

@interface Yodo1Alert ()<UIAlertViewDelegate>
{
    NSString* _gameObj;
    NSString* _methodName;
    NSInteger _cancelButtonIndex;
    NSInteger _middleButtonIndex;
}

@end

@implementation Yodo1Alert

static Yodo1Alert* _instance = nil;

+ (Yodo1Alert*) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

- (id)init
{
    self = [super init];
    _gameObj = nil;
    _methodName = nil;
    _cancelButtonIndex = -1;
    _middleButtonIndex = -1;
    return self;
}

- (void)showIOSAlert:(NSString*) title
             message:(NSString*)message
  confirmButtonTitle:(NSString*)confirmButtonStr
   cancelButtonTitle:(NSString*)cancelButtonStr
     middleButtonStr:(NSString*) middleButtonStr
         gameObjName:(NSString*) gameObjName
          methodName:(NSString*)methodName
{
    _gameObj = gameObjName;
    _methodName = methodName;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] < 8.0) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:title
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:nullptr
                                            otherButtonTitles:confirmButtonStr, nullptr,nil];
        
        if(nullptr != cancelButtonStr && ![cancelButtonStr isEqualToString:@""]){
            _cancelButtonIndex = [alert addButtonWithTitle:cancelButtonStr];
        }
        
        if(nullptr != middleButtonStr && ![middleButtonStr isEqualToString:@""]){
            _middleButtonIndex = [alert addButtonWithTitle:middleButtonStr];
        }
        
        [alert show];
    }
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* confirmAction = [UIAlertAction
                                        actionWithTitle:confirmButtonStr
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction* action) {
                                            [[Yodo1Alert shareInstance] confirmButtonPress:@"1" gameObjName:gameObjName methodName:methodName];
                                        }];
        if(nullptr != cancelButtonStr && ![cancelButtonStr isEqualToString:@""]){
            UIAlertAction* cancelAction = [UIAlertAction
                                           actionWithTitle:cancelButtonStr
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction* action) {
                                               [[Yodo1Alert shareInstance] confirmButtonPress:@"0" gameObjName:gameObjName methodName:methodName];
                                           }];
            [alert addAction:cancelAction];
        }
        if(nullptr != middleButtonStr && ![middleButtonStr isEqualToString:@""]){
            UIAlertAction* middleAction = [UIAlertAction
                                           actionWithTitle:middleButtonStr
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction* action) {
                                               [[Yodo1Alert shareInstance] confirmButtonPress:@"2" gameObjName:gameObjName methodName:methodName];
                                           }];
            [alert addAction:middleAction];
        }
        
        [alert addAction:confirmAction];
        
        [[Yodo1Commons getRootViewController]  presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0 && buttonIndex <= 2 && _gameObj != nil && _methodName != nil ) {
        NSString* retData = [NSString stringWithFormat:@"%d", 1];
        if (buttonIndex == _cancelButtonIndex ) {
            retData = [NSString stringWithFormat:@"%d", 0];
        }
        if (buttonIndex == _middleButtonIndex) {
            retData = [NSString stringWithFormat:@"%d", 2];
        }
        [[Yodo1Alert shareInstance] confirmButtonPress:retData gameObjName:_gameObj methodName:_methodName];
    }
}

- (void)confirmButtonPress:(NSString*)isConfirm
               gameObjName:(NSString*)gameObjName
                methodName:(NSString*)methodName
{
#ifndef UNITY_PROJECT
  if(gameObjName && methodName){
    const char* unityGameObjectName = [gameObjName UTF8String];
    const char* unityMethodName = [methodName UTF8String];
    const char* szIsConfirm =[isConfirm UTF8String];
    UnitySendMessage(unityGameObjectName, unityMethodName, szIsConfirm);
  }
#endif
}

@end

extern "C"
{
    void UnityShowAlert(const char* title,
                           const char* message,
                           const char* confirmButtonStr,
                           const char* cancelButtonStr,
                           const char* middleButtonStr,
                           const char* objName,
                           const char* callbackMethod)
    {
        NSString * ocTitle = Yodo1CreateNSString(title);
        NSString * ocMessage = Yodo1CreateNSString(message);
        NSString * ocConfirmButtonStr = Yodo1CreateNSString(confirmButtonStr);
        NSString * ocCancelButtonStr = Yodo1CreateNSString(cancelButtonStr);
        NSString * ocMiddleButtonStr = Yodo1CreateNSString(middleButtonStr);
        NSString * ocObjName = Yodo1CreateNSString(objName);
        NSString * ocCallbackMethod = Yodo1CreateNSString(callbackMethod);
        [[Yodo1Alert shareInstance] showIOSAlert:ocTitle
                                         message:ocMessage
                              confirmButtonTitle:ocConfirmButtonStr
                               cancelButtonTitle:ocCancelButtonStr
                                 middleButtonStr:ocMiddleButtonStr
                                     gameObjName:ocObjName
                                      methodName:ocCallbackMethod];
    }

}
