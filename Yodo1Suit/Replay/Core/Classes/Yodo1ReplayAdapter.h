#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1ReplayConfig.h"
#import "Yodo1ReplayManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1ReplayAdapter : NSObject

@property (nonatomic, weak) id<Yodo1ReplayManagerDelegate> delegate;
@property (nonatomic, strong) NSString* roundID;
@property (nonatomic, strong) NSDictionary* launchOptions;

- (void)initWithConfig:(Yodo1ReplayConfig* _Nonnull)replayConfig delegate:(id<Yodo1ReplayManagerDelegate> __nullable)delegate;

- (BOOL)isSupport;

- (BOOL)isRecording;

- (void)setType:(Yodo1ReplayType)type;

- (void)startRecord;

- (void)stopRecord;

- (void)showRecorder:(UIViewController* _Nonnull)viewcontroller;

#pragma mark - handle URL
- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

@end

NS_ASSUME_NONNULL_END
