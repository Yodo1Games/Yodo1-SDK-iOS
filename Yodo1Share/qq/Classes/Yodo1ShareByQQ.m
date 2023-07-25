//
//  Yodo1ShareByQQ.m
//  foundation
//
//  Created by Nyxon on 14-8-4.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1ShareByQQ.h"
#import "Yodo1Base.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

@interface Yodo1ShareByQQ ()<QQApiInterfaceDelegate,TencentSessionDelegate>
{
    Yodo1ShareType _shareType;
    ShareCompletionBlock completionBlock;
    BOOL isInited;
    NSString* _appId;
}

@end

@implementation Yodo1ShareByQQ

+ (Yodo1ShareByQQ *)sharedInstance
{
    static Yodo1ShareByQQ *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1ShareByQQ alloc] init];
    });
    return sharedInstance;
}

-(void)initQQWithAppId:(NSString *)appId
         universalLink:(NSString *)universalLink
{
    if ([appId isEqualToString:@""]) {
        YD1LOG(@"[Yodo1 QQ ] QQ of appId is nil!");
        return;
    }
    isInited = true;
    _appId = appId;
    TencentOAuth* oAuth = [[TencentOAuth alloc] initWithAppId:appId
                                             andUniversalLink:universalLink
                                                  andDelegate:self];
    YD1LOG(@"QQ of appId:%@,universalLink:%@",oAuth.appId,oAuth.universalLink);
}

-(void)dealloc{
    
}

- (void)shareWithContent:(ShareContent *)content
                   scene:(Yodo1ShareType)shareType
         completionBlock:(ShareCompletionBlock)aCompletionBlock
{
    if (isInited == false) {
        YD1LOG(@"[Yodo1 QQ share] QQ is not init! ");
        return;
    }
    completionBlock = [aCompletionBlock copy];
    _shareType = shareType;
    
    if (![QQApiInterface isQQInstalled]) {
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
    NSString *title = nil;
    if (content.contentTitle.length > 0) {
        title = content.contentTitle;
    }
    NSString *url = content.contentUrl;
    UIImage *image = content.contentImage;
    
   
    if (status && status.length>512) {
        status = [status substringToIndex:512];
    }
    if (title == nil) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        if ([[infoDictionary allKeys] containsObject:@"CFBundleDisplayName"]) {
            title = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        }
        if (!title && [[infoDictionary allKeys] containsObject:@"CFBundleName"]) {
            title = [infoDictionary objectForKey:@"CFBundleName"];
        }
    }
    
    QQApiNewsObject *qqApiObject = nil;
    NSData *data = nil;
    
    if (image) {
        data =  UIImageJPEGRepresentation(image,0.5);
    }
    
    qqApiObject = [QQApiNewsObject
                   objectWithURL:[NSURL URLWithString:url]
                   title:title
                   description:status
                   previewImageData:data];
    
    SendMessageToQQReq *request = [SendMessageToQQReq reqWithContent:qqApiObject];
    QQApiSendResultCode result  = [QQApiInterface sendReq:request];
    if (result != EQQAPISENDSUCESS) {
        YD1LOG(@"shared fail.");
        if (completionBlock) {
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"客户端错误",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            completionBlock(_shareType,Yodo1ShareContentStateFail,error);
        }
        completionBlock = nil;
    }

    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    NSString* tencentSt = [NSString stringWithFormat:@"tencent%@://",_appId];
    NSRange schemeRange = [url.absoluteString rangeOfString:tencentSt];
    NSString *schemePath = [url.absoluteString substringFromIndex:schemeRange.location+schemeRange.length];
    NSString *universallink = [NSString stringWithFormat:@"https://qm.qq.com/qq_conn/%@/tencent%@/%s",_appId,_appId, [schemePath UTF8String]];
    url = [NSURL URLWithString:universallink];
    
    if (YES == [TencentOAuth CanHandleUniversalLink:url])
    {
        [QQApiInterface handleOpenUniversallink:url delegate:self];
        return [TencentOAuth HandleUniversalLink:url];
    }
    return  YES;
}

#pragma mark - QQApiInterfaceDelegate
- (void)onResp:(QQBaseResp *)resp;

{
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        if ([[resp result] integerValue] == 0) {
            if (completionBlock) {
                completionBlock(_shareType,Yodo1ShareContentStateSuccess,nil);
            }
            
        }else{
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"share_failed",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            if (completionBlock) {
                completionBlock(_shareType,Yodo1ShareContentStateCancel,error);
            }
        }
        completionBlock = nil;
    }
}

- (void)onReq:(QQBaseReq *)req
{
    
}

- (void)isOnlineResponse:(NSDictionary *)response{
    
}

#pragma mark- TencentSessionDelegate

- (void)tencentDidLogin
{
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"not_login",
                                NSLocalizedFailureReasonErrorKey : @"",
                                NSLocalizedRecoverySuggestionErrorKey : @""};
    NSError *error = [NSError errorWithDomain:@"SNSShare" code:-1 userInfo:errorDict];
    if (completionBlock) {
        completionBlock(_shareType,Yodo1ShareContentStateFail,error);
    }
    completionBlock = nil;
    
}
- (void)tencentDidNotNetWork{
    
    NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"not_network",
                                NSLocalizedFailureReasonErrorKey : @"",
                                NSLocalizedRecoverySuggestionErrorKey : @""};
    
    NSError *error = [NSError errorWithDomain:@"SNSShare" code:-1 userInfo:errorDict];
    if (completionBlock) {
        completionBlock(_shareType,Yodo1ShareContentStateFail,error);
    }
    completionBlock = nil;
}

- (void)addShareResponse:(APIResponse*) response
{

}

@end
