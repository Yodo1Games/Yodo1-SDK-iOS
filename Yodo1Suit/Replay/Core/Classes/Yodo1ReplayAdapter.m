#import "Yodo1ReplayAdapter.h"
#import "Yodo1Tool+Commons.h"

@implementation Yodo1ReplayAdapter

- (void)initWithConfig:(Yodo1ReplayConfig* _Nonnull)replayConfig delegate:(id<Yodo1ReplayManagerDelegate> __nullable)delegate {
    _delegate = delegate;
}

- (BOOL)isSupport {
    return NO;
}

- (BOOL)isRecording {
    return NO;
}

- (void)setType:(Yodo1ReplayType)type{}

- (void)startRecord{}

- (void)stopRecord{}

- (void)showRecorder:(UIViewController* _Nonnull)viewcontroller {}

- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.launchOptions = launchOptions;
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options { return NO; }

@end
