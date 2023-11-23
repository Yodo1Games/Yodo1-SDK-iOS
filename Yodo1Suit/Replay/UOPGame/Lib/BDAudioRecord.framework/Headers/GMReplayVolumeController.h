//
//  GMReplayVolumeController.h
//  Pods
//
//  Created by qigengxin on 2022/4/20.
//

#import <Foundation/Foundation.h>

@interface GMReplayVolumeDuckingParam : NSObject <NSCopying>

// if enable ducking
@property (assign) BOOL enable;

// ducking to target gain smooth time in second
// default 0.2f
@property (assign) Float32 attackTime;

// release ducking smooth time in second
// default 1.0f
@property (assign) Float32 releaseTime;

// hold ducking time in second
// default 1.0f
@property (assign) Float32 holdTime;

// the threshold volume (in db) of start ducking
// default -30.0f DB
@property (assign) Float32 threshold;

// the gain (in DB) apply to source audio
// default -20.0f DB
@property (assign) Float32 targetGain;

- (instancetype)initWith:(BOOL) enable;

@end

@interface GMReplayVolumeCompressorParam : NSObject <NSCopying>

// if enable compressor
@property (assign) BOOL enable;

// compressor to target gain smooth time in second
// default 0.05f
@property (assign) Float32 attackTime;

// release compressor smooth time in second
// default 0.1f
@property (assign) Float32 releaseTime;

// the threshold of side chain volume (in DB)
// default -40.0f DB
@property (assign) Float32 sideChainThreshold;

// the threshold volume (in DB) of start compressor
// default -15.0f DB
@property (assign) Float32 threshold;

- (instancetype)initWith:(BOOL) enable;

@end

@protocol GMReplayVolumeControllerDelegate <NSObject>

// global ducking enable changed
- (void)onDuckingGlobalStateChanged:(BOOL)enable;

// global compressor enable changed
- (void)onCompressorGlobalStateChanged:(BOOL)enable;

@end

@interface GMReplayVolumeController : NSObject

- (instancetype)init;

/**
 * 是否启用 ducking
 * @param param ducking 的启用与否和配置参数
 * @return BDReplayAudioRecordCodeSuccess 表示成功
 *         BDReplayAudioRecordIgnore 表示有其它的  VolumeController 占用了 ducking
 *         other 表示错误
 */
- (int)enableDucking:(GMReplayVolumeDuckingParam *)param;

/**
 * 是否启用侧链压缩
 * @param param compressor 的启用与否和配置参数
 * @return BDReplayAudioRecordCodeSuccess 表示成功
 *         BDReplayAudioRecordIgnore 表示有其它的  VolumeController 占用了 ducking
 *         other 表示错误
 */
- (int)enableCompressor:(GMReplayVolumeCompressorParam *)param;

/**
 * 更新 ducking 需要的远端播放音量数值
 */
- (int)updateDuckingVolume:(Float32)volume isDB:(BOOL)isDB;

/**
 * 更新 侧链压缩需要的本地采集音量
 */
- (int)updateCompressorVolume:(Float32)volume isDB:(BOOL)isDB;

// 全局 ducking 和 compressor 状态监听回调
- (void)setDelegate:(id<GMReplayVolumeControllerDelegate>)delegate;

@end
