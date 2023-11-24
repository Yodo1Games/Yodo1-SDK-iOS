//
//  UOPReplayDefine.h
//  Pods
//
//  Created by ByteDance on 2023/4/4.
//

#ifndef UOPReplayDefine_h
#define UOPReplayDefine_h

typedef NS_ENUM(NSInteger, UOPReplayErrorCode) {
    // 开始录制阶段
    UOPReplayErrorCodeSuccess = 0,
    UOPReplayErrorCodeAlreadyRecording = 1,     // 已经开始录制
    UOPReplayErrorCodeDeviceNotSupport = 2,     // 设备不支持
    UOPReplayErrorCodeFeatureNotSupport = 3,    // 功能不支持
    UOPReplayErrorCodeNoDiskSpace = 4,          // 设备空间不足
    UOPReplayErrorCodeTypeNoConfig = 5,         // 未完成初始化配置
    UOPReplayErrorCodeTypeNotMatch = 6,         // 在手动录制下调用自动录制接口

    // 结束录制阶段
    UOPReplayErrorCodeNoRecording = 9,          // 未在录制
    UOPReplayErrorCodeGPUFullError = 10,        // 画面采集失败
    UOPReplayErrorCodeEnterBackground = 11,     // 进入后台中断
    UOPReplayErrorCodeSourceFileNotExist = 12,  // 文件存储错误
    UOPReplayErrorCodeTooShort = 13,            // 录制时长过短
    UOPReplayErrorCodeOverTime = 14,            // 录制超时
    UOPReplayErrorCodeRotateScreen = 15,        // 录制中旋转屏幕

    // iOS 特有
    UOPReplayErrorCodeOther = 9999,
};

#endif /* UOPReplayDefine_h */
