//
//  Yodo1Alert.m
//

#import "Yodo1Alert.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"

@interface Yodo1Alert ()<UIAlertViewDelegate>
{
    NSInteger _cancelButtonIndex;
    NSInteger _middleButtonIndex;
    Yodo1AlertCallback _callback;
}

@end

@implementation Yodo1Alert

static Yodo1Alert* _instance = nil;

+ (Yodo1Alert*) shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    _cancelButtonIndex = -1;
    _middleButtonIndex = -1;
    return self;
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message 
        confirmButtonTitle:(NSString*)confirmButtonTitle
         cancelButtonTitle:(NSString*)cancelButtonTitle
         middleButtonTitle:(NSString*)middleButtonTitle
                  callback:(Yodo1AlertCallback)callback {
    _callback = callback;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] < 8.0) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:confirmButtonTitle, nil,nil];
        
        if(nil != cancelButtonTitle && ![cancelButtonTitle isEqualToString:@""]){
            _cancelButtonIndex = [alert addButtonWithTitle:cancelButtonTitle];
        }
        
        if(nil != middleButtonTitle && ![middleButtonTitle isEqualToString:@""]){
            _middleButtonIndex = [alert addButtonWithTitle:middleButtonTitle];
        }
        
        [alert show];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* confirmAction = [UIAlertAction
                                        actionWithTitle:confirmButtonTitle
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction* action) {
            callback(@"1");
        }];
        if(nil != cancelButtonTitle && ![cancelButtonTitle isEqualToString:@""]){
            UIAlertAction* cancelAction = [UIAlertAction
                                           actionWithTitle:cancelButtonTitle
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction* action) {
                callback(@"0");
            }];
            [alert addAction:cancelAction];
        }
        if(nil != middleButtonTitle && ![middleButtonTitle isEqualToString:@""]){
            UIAlertAction* middleAction = [UIAlertAction
                                           actionWithTitle:middleButtonTitle
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction* action) {
                callback(@"2");
            }];
            [alert addAction:middleAction];
        }
        
        [alert addAction:confirmAction];
        
        [[Yodo1Commons getRootViewController]  presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0 && buttonIndex <= 2) {
        NSString* retData = [NSString stringWithFormat:@"%d", 1];
        if (buttonIndex == _cancelButtonIndex ) {
            retData = [NSString stringWithFormat:@"%d", 0];
        }
        if (buttonIndex == _middleButtonIndex) {
            retData = [NSString stringWithFormat:@"%d", 2];
        }
        
        if (_callback) {
            _callback(retData);
        }
    }
}

@end
