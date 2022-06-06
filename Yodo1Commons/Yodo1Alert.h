//
//  Yodo1Alert.h
//
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Yodo1Alert : NSObject

+ (Yodo1Alert*)shareInstance;

- (void)showIOSAlert:(NSString*) title
             message:(NSString*) message
  confirmButtonTitle:(NSString*) confirmButtonStr
   cancelButtonTitle:(NSString*) cancelButtonStr
     middleButtonStr:(NSString*) middleButtonStr
         gameObjName:(NSString*) gameObjName
          methodName:(NSString*)methodName;

- (void)confirmButtonPress:(NSString*)isConfirm
               gameObjName:(NSString*) gameObjName
                methodName:(NSString*)methodName;

@end

