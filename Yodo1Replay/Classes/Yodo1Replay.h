//
//  Yodo1Replay.h
//  Yodo1Replay
//
//  Created by zhaojun on 16/3/18.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Yodo1Replay : NSObject

+ (Yodo1Replay* __nullable)sharedInstance;

- (BOOL)bSupportReplay;

- (void)startScreenRecorder;

- (void)stopScreenRecorder;

- (void)showRecorder:(UIViewController* __nullable)viewcontroller;

@end
