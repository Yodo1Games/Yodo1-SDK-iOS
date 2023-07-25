//
//  Yodo1ShareBySinaWeibo.m
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1ShareBySinaWeibo.h"
#import "Yodo1Share.h"
#import "WeiboSDK.h"
#import "Yodo1Base.h"

@interface Yodo1ShareBySinaWeibo ()<WeiboSDKDelegate>
{
    Yodo1ShareType _shareType;
    ShareCompletionBlock completionBlock;
    BOOL isInited;
}

@end

@implementation Yodo1ShareBySinaWeibo

+ (Yodo1ShareBySinaWeibo *)sharedInstance
{
    static Yodo1ShareBySinaWeibo *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1ShareBySinaWeibo alloc] init];
    });
    return sharedInstance;
}

- (void)initSinaWeiboWithAppKey:(NSString *)appKey universalLink:(NSString *)universalLink {
    isInited = false;
    if ([appKey isEqualToString:@""]||[universalLink isEqualToString:@""]) {
        YD1LOG(@"[Yodo1 Weibo ] Weibo of appKey of universalLink is nil!");
        return;
    }
    isInited = true;
    [WeiboSDK registerApp:appKey universalLink:universalLink];
}

- (void)dealloc {
    
}

- (void)shareWithContent:(ShareContent *)content
                   scene:(Yodo1ShareType)shareType
         completionBlock:(ShareCompletionBlock)aCompletionBlock
{
    if (isInited == false) {
        YD1LOG(@"[Yodo1 weibo share] weibo is not init! ");
        return;
    }
    completionBlock = [aCompletionBlock copy];
    _shareType = shareType;
    
    //新浪微博iPad版本检测不出是否安装客户端
    if (![WeiboSDK isWeiboAppInstalled]) {
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
    
    NSString *status = content.contentText;
    NSString *url = content.contentUrl;
    UIImage *image = content.contentImage;
    
    if (url && url.length>0) {
        status = [NSString stringWithFormat:@"%@ %@",url,status];
    }
    
    if (status && status.length > 139) {
        status = [status substringToIndex:139];
    }
    
    WBMessageObject *message = [WBMessageObject message];
    if (message) {
        message.text = status;
    }
    if (image) {
        WBImageObject *imageObj = [WBImageObject object];
        imageObj.imageData  =  UIImagePNGRepresentation(image);
        message.imageObject = imageObj;
    }
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request completion:^(BOOL success) {
        if (!success && self->completionBlock) {
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"客户端错误",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            self->completionBlock(self->_shareType,Yodo1ShareContentStateFail,error);
        }
        self->completionBlock = nil;
    }];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    return [WeiboSDK handleOpenURL:url delegate:self];
}

#pragma mark - sinaWeiboDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSNotification* notification = [NSNotification notificationWithName:@"didReceiveWeiboRequest" object:request];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            if(completionBlock){
                completionBlock(_shareType,Yodo1ShareContentStateSuccess,nil);
            }
            
        }else if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"share_cancle",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            
            NSError *error = [NSError errorWithDomain:@"SNSShare" code:-1 userInfo:errorDict];
            if(completionBlock){
                completionBlock(_shareType,Yodo1ShareContentStateCancel,error);
            }
        }else{
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"share_failed",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            
            NSError *error = [NSError errorWithDomain:@"SNSShare" code:-1 userInfo:errorDict];
            if(completionBlock){
                completionBlock(_shareType,Yodo1ShareContentStateFail,error);
            }
        }
        completionBlock = nil;
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {    
        NSString *userId = [(WBAuthorizeResponse *)response userID];
        NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
        if (accessToken && userId) {

        }else{
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"authorize_failed",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            
            NSError *error = [NSError errorWithDomain:@"SNSShare" code:-1 userInfo:errorDict];
            
            if(completionBlock){
                completionBlock(_shareType,Yodo1ShareContentStateFail,error);
            }
        }
       completionBlock = nil;
    }
    
    NSNotification* notification = [NSNotification notificationWithName:@"didReceiveWeiboResponse" object:response];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
