//
//  UOPServiceShareProtocol.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/23.
//

#ifndef UOPServiceShareProtocol_h
#define UOPServiceShareProtocol_h
#import <UnionOpenPlatform/UOPSingletonService.h>

typedef NS_ENUM(NSInteger, UOPThirdShareType) {
    UOPThirdShareTypeDouyin
};

// 支持的内容类型
typedef NS_ENUM(NSInteger, UOPShareDouyinContentType) {
    UOPShareDouyinContentTypeVideo, // 视频
    UOPShareDouyinContentTypeImage, // 图片
    UOPShareDouyinContentTypeLink   // 链接
};

// 分享至抖音
typedef NS_ENUM(NSInteger, UOPShareDouyinWay) {
    UOPShareDouyinWayPublish, // 发布到至抖音
    UOPShareDouyinWayIM,      // 发送给抖音好友
    UOPShareDouyinWayCapture, // 打开抖音拍摄器
};

/// 分享内容基础结构协议
@protocol UOPServiceShareBaseContentProtocol <NSObject>
/// 透传参数
/// @discussion 可选入参
@property (nonatomic, strong, nullable) NSDictionary *extraInfo;
/// 当前承载 ViewController
/// @discussion 可选入参
@property (nonatomic, weak, nullable) UIViewController *presentVC;
/// 目标平台类型
/// @discussion 只读参数，在子类中已赋值
@property (nonatomic, assign, readonly) UOPThirdShareType platformType;

@end

/// 分享行为完成回调
@protocol UOPServiceShareResponseProtocol <NSObject>

@property (nonatomic, strong) NSError * _Nullable error;

@end

/**
 设置分享的资源标示，传入资源（包括本地路径、网络路径和系统相册的local identifier）注意点：

 若分享的为图片，则图片的宽高比应满足：1/2.2<=宽高比<=2.2。
 若分享的为视频，视频分辨率应满足：1/2.2<=宽高像素比<=2.2，且总时长大于3s。
 若分享的为图片个数应该超过1个，图片或视频个数最多12个。
 带品牌logo或品牌水印的视频，会命中抖音的审核逻辑，有比较大的概率导致分享视频推荐降权处理/分享视频下架处理/分享账号被封禁处理。强烈建议第三方应用自行处理好分享内容中的不合规水印。
 分享的话题审核依旧遵循抖音的审核逻辑，强烈建议第三方谨慎拟定话题名称，避免强导流行为。
 */

/// 抖音分享内容基础结构协议
@protocol UOPShareDouyinContentProtocol <UOPServiceShareBaseContentProtocol>

@property (nonatomic, copy) NSString * _Nullable state;

/// 话题，不需要携带#号
@property (nonatomic, copy) NSString * _Nullable hashtag;
/// 分享方式
@property (nonatomic, assign) UOPShareDouyinWay shareWay;
/// 内容类型
/// @discussion 只读参数，在子类中已赋值
@property (nonatomic, assign, readonly) UOPShareDouyinContentType contentType;

@end

/// 抖音视频分享结构协议
/// @attention 仅支持抖音发布分享；视频分辨率应满足 1/2.2<=宽高像素比<=2.2；且总时长大于3s；
@protocol UOPShareDouyinVideoContentProtocol <UOPShareDouyinContentProtocol>

/// 系统相册的视频ID列表
/// @attention 最优先判断的字段；允许分享[1, 12]个视频；
@property (nonatomic, strong) NSArray * _Nullable localIdentifiers;
/// 本地视频地址
/// @attention 第二优先级；只支持单视频；
@property (nonatomic, copy) NSString * _Nullable videoPath;
/// 网络视频下载地址
/// @attention 第三优先级；只支持单视频；
@property (nonatomic, copy) NSString * _Nullable videoUrl;

@end

/// 抖音图片分享结构协议
/// @attention 支持抖音发布分享，支持抖音好友分享；图片的宽高比应满足：1/2.2<=宽高比<=2.2；
@protocol UOPShareDouyinImageContentProtocol <UOPShareDouyinContentProtocol>

/// 系统相册的图片ID列表
/// @attention 最优先判断的字段；允许分享[1, 12]个图片；如果内容 > 1个，只支持发布到抖音，不支持分享给好友；
@property (nonatomic, strong) NSArray * _Nullable localIdentifiers;
/// 网络图片下载地址
/// @attention 第二优先级；只支持单图片；
@property (nonatomic, copy) NSString * _Nullable imageUrl;
/// 本地图片路径地址
/// @attention 第三优先级；只支持单图片
@property (nonatomic, copy) NSString * _Nullable imagePath;

@end

/// 抖音链接分享结构协议
/// @attention 仅支持抖音好友分享；
@protocol UOPShareDouyinLinkContentProtocol <UOPShareDouyinContentProtocol>

/// 标题
@property (nonatomic, copy) NSString * _Nonnull linkTitle;
/// 链接URL
@property (nonatomic, copy) NSString * _Nonnull linkUrlString;
/// 链接描述
@property (nonatomic, copy) NSString * _Nonnull linkDesc;
/// 缩略图
@property (nonatomic, copy) NSString * _Nonnull linkThumbImageUrlString;

@end

/// 分享行为协议
@protocol UOPServiceShareProtocol <UOPSingletonService>

/// 执行分享操作
/// @param content 分享内容，需遵循 UOPServiceShareBaseContentProtocol 协议
/// @param completion 分享行为完成回调
/// @discussion 接入方无需关注此协议，为SDK内部调用方法；执行分享见 UOPShareManager ；
- (void)shareContent:(_Nonnull id<UOPServiceShareBaseContentProtocol>)content completion:(void(^_Nullable)(_Nonnull id<UOPServiceShareResponseProtocol>))completion;

@end


#endif /* UOPServiceShareProtocol_h */
