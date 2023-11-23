//
//  UOPShareError.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UOPShareErrorType) {
    UOPShareErrorTypeAppNotInstalled = 1001, // 未安装
    UOPShareErrorTypeAppNotSupportAPI = 1002, // 不支持的API
    UOPShareErrorTypeAppNotSupportShareType = 1003, // 不支持的分享类型。

    UOPShareErrorTypeInvalidContent = 1004, //分享类型不可用
    UOPShareErrorTypeNoTitle = 1005, //缺少title字段。
    UOPShareErrorTypeNoWebPageURL = 1006, //缺少url字段
    UOPShareErrorTypeNoImage = 1007, //缺少Image字段。
    UOPShareErrorTypeNoVideo = 1008, //缺少videoURL字段。

    UOPShareErrorTypeUserCancel = 1009, //用户取消
    UOPShareErrorTypeNoValidItemInPanel = 1010, //无可用面板

    UOPShareErrorTypeExceedMaxVideoSize = 1011, //超出视频最大大小。
    UOPShareErrorTypeExceedMaxImageSize = 1012, //超出图片最大大小。
    UOPShareErrorTypeExceedMaxTitleSize = 1013,  //超出title最大长度
    UOPShareErrorTypeExceedMaxDescSize = 1014,  //超出desc最大长度
    UOPShareErrorTypeExceedMaxWebPageURLSize = 1015,  //超出url最大长度
    UOPShareErrorTypeExceedMaxFileSize = 1016,  //超出文件最大长度

    UOPShareErrorTypeSendRequestFail = 1017,  //request发送失败

    UOPShareErrorTypeOther = 1018, //其他分享错误

    UOPShareErrorTypeAlbumPermissionDenied = 1019, // 相册权限被拒绝。
    UOPShareErrorTypeOpenThirdAppFail = 1020, //打开三方应用失败。
    UOPShareErrorTypeResourceDownloadFail = 1021, //资源下载失败

    UOPShareStatusCodeSaveVideoToAlbumFailed = 2001, // 保存视频至相册失败
    UOPShareStatusCodeSaveImageToAlbumFailed = 2002, // 保存图片至相册失败
    UOPShareStatusCodeImageIMShareOnlySupportOne = 2003, // 图片分享给好友只支持传入一张
};

@interface UOPShareError : NSObject

+ (NSError *)errorWithDomain:(NSString *)domain
                        code:(UOPShareErrorType)type
                    userInfo:(NSDictionary *_Nullable)userInfo;

@end

NS_ASSUME_NONNULL_END
