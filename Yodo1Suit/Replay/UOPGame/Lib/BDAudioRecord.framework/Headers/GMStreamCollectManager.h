//
//  GMStreamCollectManager.h
//  BDReplay
//
//  Created by Cliffe on 2021/8/19.
//  Audio Stream Collect

#import <Foundation/Foundation.h>
#import "GMReplayAudioRecorderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMStreamCollectManager : NSObject

/**
 判断Hook方法是否生效。该值会在开始采集音频流后生效（非采集状态下均为NO）。
 建议在收到首帧音频流的时候进行判断，如果为NO，则说明Hook失败。
*/
@property (nonatomic, readonly) BOOL isHookSuccess;

/**
 判断当前这次启动 Hook 是否已经开启
 */
@property (nonatomic, readonly) BOOL isHookStarted;

+ (instancetype)sharedManager;

/**
 开启音频流采集，主线程调用
 @param listener 回调数据会通过Listener返回。Listener回调的数据不要修改。
 @return 如果成功返回YES，否则返回NO
*/
- (BOOL)startAudioStreamCollect:(id <GMReplayAudioRecorderDelegate>)listener;

/**
 停止音频流采集，主线程调用
 @param listener 需要停止的Listener
 @return 如果成功返回YES，否则返回NO
*/
- (BOOL)stopAudioStreamCollect:(id<GMReplayAudioRecorderDelegate>)listener;

/**
 可以通过BufferList和Info信息返回SampleBufferRef，返回后，需要自行处理生命周期并自行销毁，presentationTimeStamp可传kCMTimeZero
*/
- (CMSampleBufferRef)createSampleBufferFromAudioBufferList:(AudioBufferList *)bufferList description:(GMReplayASBDInfo *)info atPresentationTimeStamp:(CMTime)presentationTimeStamp;

/**
 可粗略判断bufferList是否正确
 @return YES代表有错误，数据无法使用，NO代表没有错误
*/
- (BOOL)checkAudioRealTimeError:(AudioBufferList *)bufferList;

/**
 *  更新 Ducking 用的 volume 数值
 *  @param trackId 用于区分 ducking volume 的调用方，只有第一个 enable 调用方的 volume update 才有效，第二个需要等第一个 disable ducking
 *  @param micVolume 麦克风采集音量
 *  @param remoteVolme 远端输入音量
 *  @param isDB 输入的音量是否是 DB
 *  @return BDReplayAudioRecordCodeSuccess 成功，其它失败
 */
- (int)updateDuckingVolume:(int)trackId micVolume:(float)micVolume remoteVolume:(float)remoteVolume isDB:(BOOL)isDB;

@end

NS_ASSUME_NONNULL_END
