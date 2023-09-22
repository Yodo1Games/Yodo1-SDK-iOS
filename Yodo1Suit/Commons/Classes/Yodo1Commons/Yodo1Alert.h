//
//  Yodo1Alert.h
//
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^Yodo1AlertCallback)(NSString* action);

@interface Yodo1Alert : NSObject

+ (Yodo1Alert*)shareInstance;

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
        confirmButtonTitle:(NSString*)confirmButtonTitle
         cancelButtonTitle:(NSString*)cancelButtonTitle
         middleButtonTitle:(NSString*)middleButtonTitle
                   callback:(Yodo1AlertCallback)callback;

@end

