//
//  Constant.h
//  ShareManager
//
//  Created by Jerry on 12/23/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *	@brief	发布内容状态
 */
typedef enum{
    Yodo1ShareContentStateBegan = 0,              /**< 开始 */
    Yodo1ShareContentStateSuccess = 1,            /**< 成功 */
    Yodo1ShareContentStateFail = 2,               /**< 失败 */
    Yodo1ShareContentStateUnInstalled = 3,        /**< 未安装 */
    Yodo1ShareContentStateCancel = 4,             /**< 取消 */
    Yodo1ShareContentStateNotSupport = 5          /**< 设备不支持 */
}Yodo1ShareContentState;

typedef NS_ENUM(NSInteger, Yodo1ShareType) {
    Yodo1ShareTypeNone = -1,
    Yodo1ShareTypeTencentQQ       = 1 << 0,/**< QQ分享 >*/
    Yodo1ShareTypeWeixinMoments   = 1 << 1,/**< 朋友圈 >*/
    Yodo1ShareTypeWeixinContacts  = 1 << 2,/**< 聊天界面 >*/
    Yodo1ShareTypeSinaWeibo       = 1 << 3,/**< 新浪微博 >*/
    Yodo1ShareTypeFacebook        = 1 << 4,/**< Facebook > */
    Yodo1ShareTypeAll             = 1 << 5
};

typedef enum {
    LINK,
    IMAGE
}ShareContentType;

typedef void (^ShareCompletionBlock) (Yodo1ShareType shareType,Yodo1ShareContentState state,NSError *error);

@interface ShareContent : NSObject
@property (nonatomic,assign) Yodo1ShareType shareType;      //平台分享类型
@property (nonatomic,assign) ShareContentType contentType;  //分享内容类型
@property (nonatomic,strong) NSString *contentTitle;        //仅对qq和微信有效
@property (nonatomic,strong) NSString *contentText;         //分享描述
@property (nonatomic,strong) UIImage *contentImage;         //分享图片
@property (nonatomic,strong) NSString *contentUrl;          //分享URL
@property (nonatomic,strong) UIImage *qrLogo;               //二维码logo
@property (nonatomic,strong) NSString *qrText;              //二维码右边的文本
@property (nonatomic,assign) float qrTextX;                 //文字X偏移量
@property (nonatomic,assign) float qrImageX;                //二维码偏移量
@property (nonatomic,strong) UIImage *gameLogo;             //Share App of Logo
@property (nonatomic,assign) float gameLogoX;               //sharelogoX偏移量

@end

