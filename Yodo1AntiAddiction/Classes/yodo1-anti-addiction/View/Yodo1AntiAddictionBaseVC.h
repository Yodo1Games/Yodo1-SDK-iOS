//
//  Yodo1AntiAddictionBaseVC.h
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/3.
//

#import <UIKit/UIKit.h>
#import "Yodo1Masonry.h"
#import "Yodo1Toast.h"
#import "Yodo1AntiAddictionHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1AntiAddictionBaseVC : UIViewController

+ (instancetype)loadFromStoryboard;
+ (NSString *)identifier;

- (void)didInitialize;

@end

NS_ASSUME_NONNULL_END
