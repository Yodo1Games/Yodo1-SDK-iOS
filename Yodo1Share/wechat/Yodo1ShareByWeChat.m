//
//  Yodo1ShareByWeChat.m
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1ShareByWeChat.h"
#import "WXApi.h"
#import "Yodo1ShareWeChatHelper.h"
#import "Yodo1Share.h"
#import "Yodo1Base.h"

@interface Yodo1ShareByWeChat ()<WXApiDelegate>
{
    Yodo1ShareType _shareType;
    ShareCompletionBlock completionBlock;
    BOOL isInited;
}


@end

@implementation Yodo1ShareByWeChat

+ (Yodo1ShareByWeChat *)sharedInstance
{
    static Yodo1ShareByWeChat *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1ShareByWeChat alloc] init];
    });
    return sharedInstance;
}

- (void)initWeixinWithAppKey:(NSString *)appKey
               universalLink:(NSString *)universalLink
{
    isInited = false;
    if ([appKey isEqualToString:@""]) {
        YD1LOG(@"[Yodo1 WeChat ] WeChat of appKey is nil!");
        return;
    }
    isInited = true;
    [WXApi registerApp:appKey universalLink:universalLink];
}

- (void)dealloc {
    
}

- (void)shareWithContent:(ShareContent *)content
                   scene:(Yodo1ShareType)shareType
         completionBlock:(ShareCompletionBlock)aCompletionBlock
{
    if (isInited == false) {
        YD1LOG(@"[Yodo1 Wechat share] WeChat is not init! ");
        return;
    }
    completionBlock = [aCompletionBlock copy];
    _shareType = shareType;
    if (![WXApi isWXAppInstalled]) {
        if(completionBlock){
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"客户端没有安装",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            completionBlock(shareType,Yodo1ShareContentStateUnInstalled,error);
        }
        completionBlock = nil;
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    UIImage *image = content.contentImage;
    
    if (image) {
        WXImageObject *ext = [WXImageObject object];
        //根据url和logo生成二维码
        UIImage *qrImage = [Yodo1ShareWeChatHelper qrImageForString:content.contentUrl
                                                imageSize:200.0f
                                                   Topimg:content.qrLogo];
        UIImage *postImage = nil;
        UIImage *thumbImage = nil;
        NSDictionary* optionDic = @{@"gameLogoX":[NSNumber numberWithFloat:content.gameLogoX],
                                    @"qrTextX":[NSNumber numberWithFloat:content.qrTextX],
                                    @"qrImageX":[NSNumber numberWithFloat:content.qrImageX]};
        if (qrImage) {
            //合成分享图
            postImage = [Yodo1ShareWeChatHelper addImage:qrImage
                                       toImage:image
                                     shareLogo:content.gameLogo
                                        qrText:content.qrText
                                whiteBackgroud:YES
                                     optionDic:optionDic
                         ];
        }
        if (postImage) {
            ext.imageData = UIImagePNGRepresentation(postImage);
        }else{
            ext.imageData = UIImagePNGRepresentation(image);
        }
        if (postImage) {
            thumbImage = [Yodo1ShareWeChatHelper yodo1ResizedImageToSize:CGSizeMake(256.f, 256.f) sourceImage:postImage];
            if (thumbImage) {
                [message setThumbImage:thumbImage];
            }
        }
        message.mediaObject = ext;
    }else{
        message.description = content.contentText;
        message.title = content.contentTitle;
        if (content.qrLogo) {
            [message setThumbImage:content.qrLogo];
        }
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = content.contentUrl;
        message.mediaObject = ext;
    }
   
    SendMessageToWXReq* request = [[SendMessageToWXReq alloc] init];
    request.bText = NO;
    request.message = message;
    _shareType = shareType;
    if (shareType == Yodo1ShareTypeWeixinContacts) {
        request.scene = WXSceneSession;

    }else if (shareType == Yodo1ShareTypeWeixinMoments){
        request.scene = WXSceneTimeline;
        request.message.title = content.contentTitle;
    }
    [WXApi sendReq:request completion:^(BOOL success) {
            if (!success) {
                if (self->completionBlock) {
                    NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"客户端错误",
                                                NSLocalizedFailureReasonErrorKey : @"",
                                                NSLocalizedRecoverySuggestionErrorKey : @""};
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
                    self->completionBlock(shareType,Yodo1ShareContentStateFail,error);
                }
                self->completionBlock = nil;
            }
    }];
}


#pragma mark - WXApiDelegate

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if ([resp errCode] == 0) {
            if (completionBlock) {
                completionBlock(_shareType,Yodo1ShareContentStateSuccess,nil);
            }
            
        }else{
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"share_failed",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            if (completionBlock) {
                completionBlock(_shareType,Yodo1ShareContentStateFail,error);
            }
        }
        completionBlock = nil;
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}

@end
