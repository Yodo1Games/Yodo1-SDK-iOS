//
//  GMReplayAudioRecorderDelegate.h
//  BDReplay
//
//  Created by Cliffe on 2021/8/3.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GMReplayASBDInfo.h"

/// AudioRecordEvent
typedef NS_ENUM(NSUInteger, BDReplayAudioRecordEventKey) {
    // AudioRecord start 期间的事件
    BDReplayAudioRecordStartCapture = 0,

    // AudioRecord 更新重采样模块事件
    BDReplayAudioRecordUpdateResample,

    // AudioRecord 在写缓存中
    BDReplayAudioRecordWritingBuffer,

    // AudioRecord 在读缓存中
    BDReplayAudioRecordReadingBuffer,

    // AudioRecord stop 期间的事件
    BDReplayAudioRecordStopCapture,
    
    // AudioRecord 闪避事件
    BDReplayAudioRecordDucking,

    // AudioRecord 新增audio track事件
    BDReplayAudioRecordAddNewTrack,
};

typedef NS_ENUM(NSUInteger, BDReplayAudioRecordCode) {
    // 成功
    BDReplayAudioRecordCodeSuccess = 0,
    
    // 没有初始化错误
    BDReplayAudioRecordNotInit = 1,
    
    /// 参数错误
    BDReplayAudioRecordInvalidParam = 10,
    
    /// 没有开始
    BDReplayAudioRecrodNotStart = 11,
    
    /// 忽略
    BDReplayAudioRecordIgnore = 13,
    
    // hook config 创建文件失败
    BDReplayAudioRecordCreateFileError = 20,
    
    // hook config 解析文件失败
    BDReplayAudioRecordParseConfigError = 21,
    
    // hook config 配置的 key 满了
    BDReplayAudioRecordConfigKeyFull = 22,
    
    // 内部错误，未分类的错误，具体需要看 message
    BDReplayAudioRecordCodeInternalError = 100,

    // 停止错误，具体见 message
    BDReplayAudioRecordCodeStopError = 102,

    // 开始 capture 的时候发现没有 hook 成功错误
    BDReplayAudioRecordCodeHookError = 103,

    // AUGraph 更新错误
    BDReplayAudioRecordAUGraphUpdateError = 104,

    // AUGraph 更新忙碌
    BDReplayAudioRecordAUGraphUpdateBusy = 105,

    // 通过 RenderNotify 捕获的数据，出现格式错误
    BDReplayAudioRecordCodeRenderNotifyFormatError = 106,

    // AudioUnitObj 找不到错误
    BDReplayAudioRecordAudioUnitObjNotFound = 107,

    // AudioUnitObj 未开始 capturing
    BDReplayAudioRecordAudioUnitObjNotCapturing = 108,

    // 缓存数据格式匹配错误
    BDReplayAudioRecordDataSizeMisMatch = 109,

    // 读写缓存 numbers 不同
    BDReplayAudioRecordBufferNumbersMisMatch = 110,

    // buffer 操作失败，例如读取失败，写入失败
    BDReplayAudioRecordBufferOperationError = 111,
    
    // pcm 格式错误
    BDReplayAudioRecordUnsupportPCMFormat = 112,
};

typedef NS_ENUM(NSUInteger, BDReplayAudioPCMDataType) {
    // 获取未处理过的PCM数据
    BDReplayAudioPrePCM = 1,
    // 获取经过处理的PCM数据
    BDReplayAudioPostPCM = 2
};

NS_ASSUME_NONNULL_BEGIN

@protocol GMReplayAudioRecorderDelegate <NSObject>

/// 接受捕获到的 audio buffer 数据
- (void)onAudioReceivePCM:(AudioBufferList *)bufferList description:(GMReplayASBDInfo *)info;

/// 监听 BDReplayAudioRecord Event 事件
- (void)onAudioRecordEvent:(BDReplayAudioRecordEventKey)eventKey code:(BDReplayAudioRecordCode)code message:(NSString*) msg;


- (BDReplayAudioPCMDataType)getPCMDataType;

@end

NS_ASSUME_NONNULL_END
