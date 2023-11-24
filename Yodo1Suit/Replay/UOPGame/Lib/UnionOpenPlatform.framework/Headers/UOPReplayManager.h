//
//  UOPReplayManager.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2023/4/3.
//

#import <Foundation/Foundation.h>
#import <UnionOpenPlatform/UOPReplayConfig.h>
#import <UnionOpenPlatform/UOPReplayDefine.h>
#import <UnionOpenPlatform/UOPReplayVideoModel.h>

NS_ASSUME_NONNULL_BEGIN

/// 策略类型
typedef NS_ENUM(int, UOPReplayType) {
    /// 关闭
    UOPReplayTypeClose,
    /// 自动模式
    UOPReplayTypeAuto,
    /// 自由模式
    UOPReplayTypeManual
};

/// 画面数据代理
@protocol UOPReplayManagerMetalDataSource <NSObject>

@optional

/// 获取 Metal MTLCommandQueue
/// @abstract 仅画面接口为Metal的需要实现，OpenGL不要实现本方法；
- (id<MTLCommandQueue>)UOPReplayGetMetalMTLCommandQueue;

@end

/// 录制事件代理
@protocol UOPReplayManagerDelegate <NSObject>

@optional

/// 录制开始事件
/// @param roundID 本次录制标识
/// @param code 事件Code，详见 UOPReplayDefine
- (void)replayDidStartRecord:(nullable NSString *)roundID
                    withCode:(UOPReplayErrorCode)code;

/// 录制结束事件
/// @discussion 录制中断，录制结束失败均会触发
/// @param roundID 本次录制标识
/// @param code 事件Code，详见 UOPReplayDefine
/// @param videoPath 视频地址
- (void)replayDidStopRecord:(nullable NSString *)roundID
                   withCode:(UOPReplayErrorCode)code
                  videoPath:(nullable NSString *)videoPath;

@end

/// 录制管理类
@interface UOPReplayManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) id<UOPReplayManagerMetalDataSource> metalDataSource;

@property (nonatomic, weak) id<UOPReplayManagerDelegate> delegate;

/// 设置录制策略
/// @param type 策略类型
/// @param completion 设置完成回调
- (void)setType:(UOPReplayType)type
     completion:(nullable void(^)(UOPReplayErrorCode code))completion;
/// 当前录制策略
@property (readonly) UOPReplayType type;

/// 设置录制参数
/// @param config 录制参数
/// @param completion 设置完成回调
- (void)setConfig:(UOPReplayConfig *)config
       completion:(nullable void(^)(UOPReplayErrorCode code))completion;
/// 当前录制参数
@property (readonly) UOPReplayConfig *config;

/// 功能是否可用
- (BOOL)isSupport;

/// 是否正在录制中
- (BOOL)isRecording;

/// 当前录制时长，单位ms
- (long)currentRecordingDuration;

/// 获取当前已录制视频对象列表
- (NSArray <UOPReplayVideoModel *>*)fetchReplayFileList;

/// 获取当前已录制视频根目录
+ (NSString *)getReplayFolderPath;

/// 删除指定视频及封面文件
- (void)removeReplayFileAtPath:(NSString *)filePath;

/// 删除所有已录制视频和封面文件
- (void)removeAllReplayFile;

@end

/// 自动模式接口
@interface UOPReplayManager (AutoType)

/// 开始录制
/// @discussion 仅自动模式下使用
- (void)startAutoRecord;

/// 结束录制
/// @discussion 仅自动模式下使用
- (void)stopAutoRecord;

@end

NS_ASSUME_NONNULL_END
