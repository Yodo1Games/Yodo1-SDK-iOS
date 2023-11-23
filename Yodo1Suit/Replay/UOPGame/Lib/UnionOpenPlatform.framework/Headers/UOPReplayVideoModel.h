//
//  UOPReplayVideoModel.h
//  UnionOpenPlatform
//
//  Created by yuwei.will on 2023/4/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 视频描述对象
@interface UOPReplayVideoModel : NSObject
/// 视频保存路径
@property (nonatomic, copy) NSString *videoFilePath;

/// 视频文件名
@property (nonatomic, copy) NSString *videoFileName;
/// 视频封面
@property (nonatomic, strong) UIImage *videoCover;
/// 视频封面
@property (nonatomic, strong) NSString *videoCoverFilePath;

/// 视频创建时间戳，单位s
@property (nonatomic, assign) NSTimeInterval createTime;
/// 视频时长，单位s
@property (nonatomic, assign) CGFloat duration;
/// 视频文件大小，单位B
@property (nonatomic, assign) long fileSize;

/// 创建时间戳转换为日期
- (NSString *)covertCreateTimeToDateString;

@end

NS_ASSUME_NONNULL_END
