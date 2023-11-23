#import "Yodo1ReplayAdapterApple.h"
#import <ReplayKit/ReplayKit.h>
#import "Yodo1Commons.h"
#import "Yodo1Object.h"
#import "Yodo1Registry.h"
#import "Yodo1ReplayManager.h"
#import "Yodo1Tool+Commons.h"

@interface Yodo1ReplayAdapterApple ()<RPPreviewViewControllerDelegate, RPScreenRecorderDelegate> {
    __block RPPreviewViewController* _previewViewController;
}

@property (nonatomic, strong) UIViewController *viewController;

@end

@implementation Yodo1ReplayAdapterApple

+ (Yodo1ReplayPlatform)replayPlatform {
    return Yodo1ReplayPlatformApple;
}

+ (void)load {
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"replayPlatform"];
}

- (void)dealloc {
    
}

- (void)initWithConfig:(Yodo1ReplayConfig* _Nonnull)replayConfig delegate:(id<Yodo1ReplayManagerDelegate> __nullable)delegate {
    [super initWithConfig:replayConfig delegate:delegate];
    if (delegate) {
        [delegate replayDidInitialized:YES replayPlatform:Yodo1ReplayPlatformApple withError:nil];
    }
}

- (BOOL)isSupport {
    BOOL result = false;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 && [[RPScreenRecorder sharedRecorder] isAvailable]) {
        result = true;
    }
    return result;
}

- (BOOL)isRecording {
    return [RPScreenRecorder sharedRecorder].isRecording;
}

- (void)setType:(Yodo1ReplayType)type {
}

- (void)startRecord {
    if([self isRecording]){
        return;
    }
    
    self.roundID = [Yodo1Tool shared].nowTimeTimestamp;
    
    [RPScreenRecorder sharedRecorder].delegate = self;
    [RPScreenRecorder sharedRecorder].microphoneEnabled = YES;
    [[RPScreenRecorder sharedRecorder] startRecordingWithHandler:^(NSError * _Nullable error) {
        if (error) {
            YD1LOG(@"RPScreenRecorder startRecording failure ID: %@, error(code: %@, message: %@)", self.roundID ,@(error.code), error.localizedDescription);
        } else {
            YD1LOG(@"RPScreenRecorder startRecording success with ID %@", self.roundID);
        }
        if (self.delegate) {
            [self.delegate replayDidStartRecord:(error == nil ? YES : NO) replayPlatform:Yodo1ReplayPlatformApple roundID:self.roundID withError:error];
        }
    }];
    
    [[RPScreenRecorder sharedRecorder] discardRecordingWithHandler:^{
        YD1LOG(@"RPScreenRecorder discardRecording");
    }];
}

- (void)stopRecord {
    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController* _Nullable previewViewController, NSError* _Nullable error) {
        self->_previewViewController = previewViewController;
        YD1LOG(@"RPScreenRecorder stopRecording success with ID: %@", self.roundID);
        if (self.delegate) {
            [self.delegate replayDidStopRecord:(error == nil ? YES : NO) replayPlatform:Yodo1ReplayPlatformApple roundID:self.roundID withError:error];
        }
    }];
}

- (void)showRecorder:(UIViewController* _Nonnull)viewcontroller {
    self.viewController = viewcontroller;
    if([self isRecording]){
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

- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [super didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [super handleOpenURL:url options:options];
}

#pragma mark- RPPreviewViewControllerDelegate

/* @abstract Called when the view controller is finished. */
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    YD1LOG(@"RPScreenRecorder previewControllerDidFinish");

    [self.viewController dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes {
    YD1LOG(@"RPScreenRecorder previewController didFinishWithActivityTypes");

}

#pragma mark- RPScreenRecorderDelegate

/*! @abstract Called when recording has stopped due to an error.
 @param screenRecorder The instance of the screen recorder.
 @param error An NSError describing why recording has stopped in the RPRecordingErrorDomain.
 @param previewViewController If a partial movie is available before it was stopped, an instance of RPPreviewViewController will be returned.
 */
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithPreviewViewController:(nullable RPPreviewViewController *)previewViewController error:(nullable NSError *)error {
    if (error) {
        YD1LOG(@"RPScreenRecorder didStopRecording failure ID: %@, error(code: %@, message: %@)", self.roundID ,@(error.code), error.localizedDescription);
    } else {
        YD1LOG(@"RPScreenRecorder didStopRecording success with ID %@", self.roundID);
    }
    
    if (self.delegate) {
        [self.delegate replayDidStopRecord:(error == nil ? YES : NO) replayPlatform:Yodo1ReplayPlatformApple roundID:self.roundID withError:error];
    }
}

/*! @abstract Called when the recorder becomes available or stops being available. Check the screen recorder's availability property to check the current availability state. Possible reasons for the recorder to be unavailable include an in-progress Airplay/TVOut session or unsupported hardware.
 @param screenRecorder The instance of the screen recorder.
 */
- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder *)screenRecorder {
    if (screenRecorder.isRecording) {
        YD1LOG(@"RPScreenRecorder recording");
    }
}

@end
