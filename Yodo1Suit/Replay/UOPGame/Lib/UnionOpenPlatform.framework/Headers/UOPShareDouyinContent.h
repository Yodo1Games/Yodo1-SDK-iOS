//
//  UOPShareDouyinContent.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/10.
//

#import "UOPShareBaseContent.h"
#import <UnionOpenPlatform/UOPServiceShareProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 抖音内容分享抽象基类
@interface UOPShareDouyinContent : UOPShareBaseContent<UOPShareDouyinContentProtocol>

@end

/// 抖音视频分享
/// @attention 仅支持抖音发布分享；视频分辨率应满足 1/2.2<=宽高像素比<=2.2；且总时长大于3s；
@interface UOPShareDouyinVideoContent : UOPShareDouyinContent<UOPShareDouyinVideoContentProtocol>

@end

/// 抖音图片分享
/// @attention 支持抖音发布分享，支持抖音好友分享；图片的宽高比应满足：1/2.2<=宽高比<=2.2；
@interface UOPShareDouyinImageContent : UOPShareDouyinContent<UOPShareDouyinImageContentProtocol>

@end

NS_ASSUME_NONNULL_END
