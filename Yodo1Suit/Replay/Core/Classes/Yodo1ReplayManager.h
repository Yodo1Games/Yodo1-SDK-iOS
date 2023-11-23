//
//  Yodo1ReplayManager.h
//  Yodo1Suit
//
//  Created by Sunmeng on 2023/11/16.
//

#import <Foundation/Foundation.h>
#import "Yodo1ReplayConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// 录制事件代理
@protocol Yodo1ReplayManagerDelegate <NSObject>

@optional

/// 初始化事件
/// @param success 初始化是否成功
/// @param error Error
- (void)replayDidInitialized:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                   withError:(nullable NSError*)error;

/// 录制开始事件
/// @param success 本次录制是否成功
/// @param roundID 本次录制标识
/// @param error Error
- (void)replayDidStartRecord:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                     roundID:(nullable NSString *)roundID
                   withError:(nullable NSError*)error;

/// 录制结束事件
/// @discussion 录制中断，录制结束失败均会触发
/// @param success 本次录制停止是否成功
/// @param roundID 本次录制标识
/// @param error Error
- (void)replayDidStopRecord:(BOOL)success
             replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                    roundID:(nullable NSString *)roundID
                  withError:(nullable NSError*)error;

/// 分享录屏事件,  仅Yodo1ReplayPlatformDouyin时有效
/// @param success 本次分享录屏是否成功
/// @param roundID 本次分享录制标识
/// @param error Error
- (void)replayDidShareRecord:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                     roundID:(nullable NSString *)roundID
                   withError:(nullable NSError*)error;

@end

/// 录制管理类
@interface Yodo1ReplayManager : NSObject

+ (Yodo1ReplayManager*)sharedInstance;

- (void)initializeWithConfig:(Yodo1ReplayConfig* _Nonnull)replayConfig delegate:(id<Yodo1ReplayManagerDelegate> __nullable)delegate;

- (BOOL)isSupport;

- (BOOL)isRecording;

- (void)setType:(Yodo1ReplayType) type;

#pragma mark - handle URL
- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

@end

/// 自动模式接口
@interface Yodo1ReplayManager (AutoType)

/// 开始录制
/// @discussion 仅自动模式下使用
- (void)startRecord;

/// 结束录制
/// @discussion 仅自动模式下使用
- (void)stopRecord;

@end

@interface Yodo1ReplayManager (ManualSharing)

- (void)showRecorder:(UIViewController* _Nonnull)viewcontroller;

@end


NS_ASSUME_NONNULL_END
