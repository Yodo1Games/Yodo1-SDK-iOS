//
//  Yodo1Replay.mm
//  Yodo1Replay
//
//  Created by zhaojun on 16/3/18.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <ReplayKit/ReplayKit.h>
#import "Yodo1Commons.h"
#import "Yodo1Replay.h"
#import "Yodo1Object.h"

@interface Yodo1Replay ()<RPPreviewViewControllerDelegate, RPScreenRecorderDelegate>
{
    __block RPPreviewViewController* _previewViewController;
}

@property (nonatomic, strong) NSString *ocObjectName;
@property (nonatomic, strong) NSString *ocMethodName;
@property (nonatomic, strong) UIViewController *viewController;

@end

@implementation Yodo1Replay

static Yodo1Replay* _instance = nil;
+ (Yodo1Replay*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [Yodo1Replay new];
    });
    return _instance;
}

- (BOOL)bSupportReplay
{
    BOOL result = false;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 && [[RPScreenRecorder sharedRecorder] isAvailable]) {
        result = true;
    }
    return result;
}

- (void)startScreenRecorder
{
    if([RPScreenRecorder sharedRecorder].isRecording){
        return;
    }
    [RPScreenRecorder sharedRecorder].delegate = self;
    [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:YES
                                                                   handler:^(NSError* _Nullable error) {
        YD1LOG(@"recorder error:%@", error);
    }];
    [[RPScreenRecorder sharedRecorder]discardRecordingWithHandler:^{
        YD1LOG(@"recorder interrupt");
    }];
}

- (void)stopScreenRecorder
{
    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController* _Nullable previewViewController, NSError* _Nullable error) {
        self->_previewViewController = previewViewController;
    }];
}

- (void)showRecorder:(UIViewController *)viewcontroller
{
    self.viewController = viewcontroller;
    if([RPScreenRecorder sharedRecorder].isRecording){
        return;
    }
    
    if (_previewViewController) {
        _previewViewController.previewControllerDelegate = self;
        if ([_previewViewController respondsToSelector:@selector(popoverPresentationController)])  // iPad(特性)
        {
            _previewViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        
        [self.viewController presentViewController:_previewViewController
                                          animated:YES
                                        completion:^{
            [UIApplication sharedApplication].statusBarHidden = YES;
            self->_previewViewController = nil;
        }];
    }
}

#pragma mark- RPPreviewViewControllerDelegate

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController
{
    [self.viewController dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes
{
    
}

#pragma mark- RPScreenRecorderDelegate

/*! @abstract Called when recording has stopped due to an error.
 @param screenRecorder The instance of the screen recorder.
 @param error An NSError describing why recording has stopped in the RPRecordingErrorDomain.
 @param previewViewController If a partial movie is available before it was stopped, an instance of RPPreviewViewController will be returned.
 */
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithPreviewViewController:(nullable RPPreviewViewController *)previewViewController error:(nullable NSError *)error {
    if (error != nil) {
        YD1LOG(@"record failure with error, %@", error.localizedDescription);
    }
}

/*! @abstract Called when the recorder becomes available or stops being available. Check the screen recorder's availability property to check the current availability state. Possible reasons for the recorder to be unavailable include an in-progress Airplay/TVOut session or unsupported hardware.
 @param screenRecorder The instance of the screen recorder.
 */
- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder *)screenRecorder
{
    if (screenRecorder.isRecording) {
        YD1LOG(@"recording");
    }
}

@end
