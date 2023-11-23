//
//  UOPReplayConfig.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2023/4/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 质量枚举
typedef NS_ENUM(NSInteger, UOPReplayRecordQuality) {
    UOPReplayRecordQualityLow = 0,
    UOPReplayRecordQualityMedium,
    UOPReplayRecordQualityHigh,
};

/// 录制参数类
@interface UOPReplayConfig : NSObject
/// 帧数，默认 30
@property (nonatomic, assign) NSInteger fps;
/// 录制质量，默认 Medium
@property (nonatomic, assign) UOPReplayRecordQuality quality;

@end

NS_ASSUME_NONNULL_END
