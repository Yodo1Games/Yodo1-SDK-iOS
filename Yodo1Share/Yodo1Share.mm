//
//  Yodo1SNS.m
//  localization_sdk
//
//  Created by huafei qu on 13-5-4.
//  Copyright (c) 2015年 yodo1. All rights reserved.
//

#import "Yodo1Share.h"
#import "Yodo1ShareUI.h"

#import <Social/Social.h>
#import "Yodo1ShareByWeChat.h"
#import "Yodo1ShareByQQ.h"
#import "Yodo1ShareBySinaWeibo.h"
#import "Yodo1ShareByFacebook.h"
#import "Yodo1Base.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"

#import "Yodo1Commons.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Reachability.h"
#import "Yodo1Model.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"

#import "Yodo1KeyInfo.h"

#define Yodo1SHARELOG(fmt, ...) NSLog((@"[Yodo1 Share] %s [Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define Y_SHARE_VERSION                  @"1.0.0"

#define Y_SHARE_DEBUG_LOG                  @"y_share_debug_log"

NSString * const kYodo1QQAppId                  = @"QQAppId";
NSString * const kYodo1QQUniversalLink          = @"QQUniversalLink";
NSString * const kYodo1WechatAppId              = @"WechatAppId";
NSString * const kYodo1WechatUniversalLink      = @"WechatUniversalLink";
NSString * const kYodo1SinaWeiboAppKey          = @"SinaAppId";
NSString * const kYodo1SinaWeiboUniversalLink   = @"SinaUniversalLink";
NSString * const kYodo1FacebookAppId            = @"FacebookAppID";
NSString * const kYodo1FacebookDisplayName      = @"FacebookDisplayName";

@interface Yodo1SMContent : NSObject
@property (nonatomic,assign) NSInteger shareType;     //对单个平台分享模式有效
@property (nonatomic,assign) NSInteger contentType;   //分享样式<link,image>
@property (nonatomic,strong) NSString *contentTitle;       //仅对qq和微信有效
@property (nonatomic,strong) NSString *contentText;        //分享描述
@property (nonatomic,strong) NSString *contentImage;       //分享图片
@property (nonatomic,strong) NSString *contentUrl;         //分享URL
@property (nonatomic,strong) NSString *gameLogo;   //game of Logo
@property (nonatomic,assign) float gameLogoX;      //game of logo X偏移量
@property (nonatomic,strong) NSString *qrLogo;      //二维码logo
@property (nonatomic,strong) NSString *qrText;      //二维码右边的文本
@property (nonatomic,assign) float qrTextX;         //文字X偏移量
@property (nonatomic,assign) float qrImageX;        //二维码偏移量
@end

@implementation Yodo1SMContent
@end

@interface Yodo1Share()
{
    BOOL isShow;
}

@property (nonatomic, copy) ShareCompletionBlock completionBlock;
@property (nonatomic, strong) NSString *wechatAppKey;
@property (nonatomic, strong) NSString *wechatUniversalLink;
@property (nonatomic, strong) NSString *qqAppId;
@property (nonatomic, strong) NSString *qqUniversalLink;
@property (nonatomic, strong) NSString *sinaWeiboAppKey;
@property (nonatomic, strong) NSString *sinaWeiboUniversalLink;

- (void)showSocial:(ShareContent *)content
           shareType:(Yodo1ShareType)shareType;

- (NSArray*)shareTypesWithContent:(ShareContent *)content;

@end

@implementation Yodo1Share
@synthesize isYodo1Shared;
@synthesize isLandscapeOrPortrait;

static Yodo1Share* sDefaultInstance;

+ (Yodo1Share*)sharedInstance {
    if(sDefaultInstance == nil){
        sDefaultInstance = [[Yodo1Share alloc] init];
    }
    return sDefaultInstance;
}

- (void)dealloc {
    
}

- (void)initWithConfig:(NSDictionary *)shareAppIds {
    
    BOOL isDebugLog = YES;
    
    if (shareAppIds == nil || [shareAppIds count] < 1) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Yodo1KeyConfig.bundle/Yodo1KeyInfo" ofType:@"plist"];
        NSMutableDictionary *keyInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        shareAppIds = [[NSDictionary alloc]initWithDictionary:keyInfo];
        
        if (plistPath.length <= 0) {
            NSDictionary * plistDic = [[NSBundle mainBundle] infoDictionary];
            shareAppIds = [[NSDictionary alloc]initWithDictionary:plistDic];
            
            if ([[shareAppIds allKeys]containsObject:kYodo1WechatAppId] &&
                [[shareAppIds allKeys]containsObject:kYodo1WechatUniversalLink]) {
                self.wechatAppKey = [shareAppIds objectForKey:kYodo1WechatAppId];
                self.wechatUniversalLink = [shareAppIds objectForKey:kYodo1WechatUniversalLink];
                [[Yodo1ShareByWeChat sharedInstance] initWeixinWithAppKey:self.wechatAppKey universalLink:self.wechatUniversalLink];
            } else {
                
                if (isDebugLog) {
                    Yodo1SHARELOG(@"wechat-share is not set.");
                }
            }
            if ([[shareAppIds allKeys]containsObject:kYodo1QQAppId] &&
                [[shareAppIds allKeys]containsObject:kYodo1QQUniversalLink]) {
                self.qqAppId = [shareAppIds objectForKey:kYodo1QQAppId];
                self.qqUniversalLink = [shareAppIds objectForKey:kYodo1QQUniversalLink];
                [[Yodo1ShareByQQ sharedInstance] initQQWithAppId:self.qqAppId
                                              universalLink:self.qqUniversalLink];
            } else {
        
                if (isDebugLog) {
                    Yodo1SHARELOG(@"QQ-share is not set.");
                }
            }
            
            if ([[shareAppIds allKeys]containsObject:kYodo1SinaWeiboAppKey] &&
                [[shareAppIds allKeys]containsObject:kYodo1SinaWeiboUniversalLink]) {
                self.sinaWeiboAppKey = [shareAppIds objectForKey:kYodo1SinaWeiboAppKey];
                self.sinaWeiboUniversalLink = [shareAppIds objectForKey:kYodo1SinaWeiboUniversalLink];
                [[Yodo1ShareBySinaWeibo sharedInstance] initSinaWeiboWithAppKey:self.sinaWeiboAppKey
                                                             universalLink:self.sinaWeiboUniversalLink];
            } else {
                if (isDebugLog) {
                    Yodo1SHARELOG(@"sina-share is not set.");
                }
            }
            
            NSDictionary * infoPlistDic = [[NSBundle mainBundle] infoDictionary];
            if ([[infoPlistDic allKeys]containsObject:kYodo1FacebookAppId]) {
                [[Yodo1ShareByFacebook sharedInstance] initFacebookWithAppId:nil];
            } else {
                if (isDebugLog) {
                    Yodo1SHARELOG(@"Facebook-share is not set.");
                }
            }
        }
    } else {
        if ([[shareAppIds allKeys]containsObject:kYodo1WechatAppId] &&
            [[shareAppIds allKeys]containsObject:kYodo1WechatUniversalLink]) {
            self.wechatAppKey = [shareAppIds objectForKey:kYodo1WechatAppId];
            self.wechatUniversalLink = [shareAppIds objectForKey:kYodo1WechatUniversalLink];
            [[Yodo1ShareByWeChat sharedInstance] initWeixinWithAppKey:self.wechatAppKey universalLink:self.wechatUniversalLink];
        } else {
            if (isDebugLog) {
                Yodo1SHARELOG(@"wechat-share is not set.");
            }
        }
        if ([[shareAppIds allKeys]containsObject:kYodo1QQAppId] &&
            [[shareAppIds allKeys]containsObject:kYodo1QQUniversalLink]) {
            self.qqAppId = [shareAppIds objectForKey:kYodo1QQAppId];
            self.qqUniversalLink = [shareAppIds objectForKey:kYodo1QQUniversalLink];
            [[Yodo1ShareByQQ sharedInstance] initQQWithAppId:self.qqAppId
                                          universalLink:self.qqUniversalLink];
        } else {
            if (isDebugLog) {
                Yodo1SHARELOG(@"QQ-share is not set.");
            }
        }
        
        if ([[shareAppIds allKeys]containsObject:kYodo1SinaWeiboAppKey] &&
            [[shareAppIds allKeys]containsObject:kYodo1SinaWeiboUniversalLink]) {
            self.sinaWeiboAppKey = [shareAppIds objectForKey:kYodo1SinaWeiboAppKey];
            self.sinaWeiboUniversalLink = [shareAppIds objectForKey:kYodo1SinaWeiboUniversalLink];
            [[Yodo1ShareBySinaWeibo sharedInstance] initSinaWeiboWithAppKey:self.sinaWeiboAppKey
                                                         universalLink:self.sinaWeiboUniversalLink];
        } else {
            if (isDebugLog) {
                Yodo1SHARELOG(@"sina-share is not set.");
            }
        }
        
        NSDictionary * infoPlistDic = [[NSBundle mainBundle] infoDictionary];
        if ([[infoPlistDic allKeys]containsObject:kYodo1FacebookAppId]) {
            [[Yodo1ShareByFacebook sharedInstance] initFacebookWithAppId:nil];
        } else {
            if (isDebugLog) {
                Yodo1SHARELOG(@"Facebook-share is not set.");
            }
        }
    }
}

- (NSArray*)shareTypesWithContent:(ShareContent *)content
{
    NSMutableArray* shareTypes = [NSMutableArray array];
    Yodo1ShareType shareType = content.shareType;
    if ((shareType & Yodo1ShareTypeTencentQQ) && [self isInstalledWithType:Yodo1ShareTypeTencentQQ]) {
        [shareTypes addObject:@(Yodo1ShareTypeTencentQQ)];
    }
    
    if ((shareType & Yodo1ShareTypeWeixinMoments) && [self isInstalledWithType:Yodo1ShareTypeWeixinMoments]) {
        [shareTypes addObject:@(Yodo1ShareTypeWeixinMoments)];
    }
    if ((shareType & Yodo1ShareTypeWeixinContacts) && [self isInstalledWithType:Yodo1ShareTypeWeixinContacts]) {
        [shareTypes addObject:@(Yodo1ShareTypeWeixinContacts)];
    }
    if ((shareType & Yodo1ShareTypeSinaWeibo) && [self isInstalledWithType:Yodo1ShareTypeSinaWeibo]) {
        [shareTypes addObject:@(Yodo1ShareTypeSinaWeibo)];
    }
    if ((shareType & Yodo1ShareTypeFacebook) && [self isInstalledWithType:Yodo1ShareTypeFacebook]) {
        [shareTypes addObject:@(Yodo1ShareTypeFacebook)];
    }
    
    if (shareType & Yodo1ShareTypeAll) {
        if ([self isInstalledWithType:Yodo1ShareTypeTencentQQ]) {
            [shareTypes addObject:@(Yodo1ShareTypeTencentQQ)];
        }
        if ([self isInstalledWithType:Yodo1ShareTypeWeixinMoments]) {
            [shareTypes addObject:@(Yodo1ShareTypeWeixinMoments)];
        }
        if ([self isInstalledWithType:Yodo1ShareTypeWeixinContacts]) {
            [shareTypes addObject:@(Yodo1ShareTypeWeixinContacts)];
        }
        if ([self isInstalledWithType:Yodo1ShareTypeSinaWeibo]) {
            [shareTypes addObject:@(Yodo1ShareTypeSinaWeibo)];
        }
        if ([self isInstalledWithType:Yodo1ShareTypeFacebook]) {
            [shareTypes addObject:@(Yodo1ShareTypeFacebook)];
        }
    }
    return shareTypes;
}

- (void)showSocial:(ShareContent *)content
             block:(ShareCompletionBlock)completionBlock
{
    [Yodo1ShareUI sharedInstance].isLandscapeOrPortrait = self.isLandscapeOrPortrait;
    
    self.completionBlock = completionBlock;
    
    if(![Yodo1Reachability reachability].reachable){
        if (self.completionBlock) {
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"网络连接错误或无网络"}];
            self.completionBlock(Yodo1ShareTypeNone,Yodo1ShareContentStateFail,error);
        }
        return;
    }
    
    NSArray* shareTypes = [self shareTypesWithContent:content];
    
    if ([shareTypes count] == 1){
        self.isYodo1Shared = YES;
        Yodo1ShareType type = (Yodo1ShareType)[[shareTypes firstObject]integerValue];
        [self showSocial:content shareType:type];
    }else {
        self.isYodo1Shared = YES;
        [[Yodo1ShareUI sharedInstance]showShareWithTypes:shareTypes
                                                   block:^(Yodo1ShareType shareType) {
                                                       [self showSocial:content shareType:shareType];
                                                   }];
    }
    
}

- (void)showSocial:(ShareContent *)content
           shareType:(Yodo1ShareType)shareType
{
    switch (shareType) {
        case Yodo1ShareTypeTencentQQ:
        {
            if (![self isInstalledWithType:Yodo1ShareTypeTencentQQ]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1ShareTypeTencentQQ,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[Yodo1ShareByQQ sharedInstance]shareWithContent:content
                                                  scene:Yodo1ShareTypeTencentQQ                                                                                           completionBlock:^(Yodo1ShareType shareType, Yodo1ShareContentState resultCode, NSError *error) {
                                                      if (self.completionBlock) {
                                                          self.completionBlock(Yodo1ShareTypeTencentQQ,resultCode,error);
                                                          self.isYodo1Shared = NO;
                                                      }
                                                  }];
        }
            break;
        case Yodo1ShareTypeWeixinMoments:
        {
            if (![self isInstalledWithType:Yodo1ShareTypeWeixinMoments]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1ShareTypeWeixinMoments,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[Yodo1ShareByWeChat sharedInstance]shareWithContent:content
                                                      scene:Yodo1ShareTypeWeixinMoments
                                            completionBlock:^(Yodo1ShareType shareType, Yodo1ShareContentState resultCode, NSError *error) {
                                                if (self.completionBlock) {
                                                    self.completionBlock(Yodo1ShareTypeWeixinMoments,resultCode,error);
                                                    self.isYodo1Shared = NO;
                                                }
                                            }];
            
        }
            break;
            
        case Yodo1ShareTypeWeixinContacts:
        {
            if (![self isInstalledWithType:Yodo1ShareTypeWeixinContacts]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1ShareTypeWeixinContacts,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[Yodo1ShareByWeChat sharedInstance]shareWithContent:content
                                                      scene:Yodo1ShareTypeWeixinContacts
                                            completionBlock:^(Yodo1ShareType shareType, Yodo1ShareContentState resultCode, NSError *error) {
                                                if (self.completionBlock) {
                                                    self.completionBlock(Yodo1ShareTypeWeixinContacts,resultCode,error);
                                                    self.isYodo1Shared = NO;
                                                }
                                            }];
        }
            break;
            
        case Yodo1ShareTypeSinaWeibo:
        {
            if (![self isInstalledWithType:Yodo1ShareTypeSinaWeibo]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1ShareTypeSinaWeibo,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[Yodo1ShareBySinaWeibo sharedInstance]shareWithContent:content
                                                      scene:Yodo1ShareTypeSinaWeibo
                                            completionBlock:^(Yodo1ShareType shareType, Yodo1ShareContentState resultCode, NSError *error) {
                                                if (self.completionBlock) {
                                                    self.completionBlock(Yodo1ShareTypeSinaWeibo,resultCode,error);
                                                    self.isYodo1Shared = NO;
                                                }
                                            }];
        }
            break;
            
        case Yodo1ShareTypeFacebook:
        {
            if (![self isInstalledWithType:Yodo1ShareTypeFacebook]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1ShareTypeFacebook,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            if (@available(iOS 11.0,*)) {
                [[Yodo1ShareByFacebook sharedInstance]shareWithContent:content
                                                            scene:Yodo1ShareTypeFacebook
                                                  completionBlock:^(Yodo1ShareType shareType, Yodo1ShareContentState resultCode, NSError *error) {
                                                      if (self.completionBlock) {
                                                          self.completionBlock(Yodo1ShareTypeFacebook,resultCode,error);
                                                          self.isYodo1Shared = NO;
                                                      }
                                                  }];
            }else{
                SLComposeViewController *slVc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                if (content.contentText) {
                    [slVc setInitialText:content.contentText];
                }
                if (content.contentImage) {
                    [slVc addImage:content.contentImage];
                }
                if (content.contentUrl) {
                    [slVc addURL:[NSURL URLWithString:content.contentUrl]];
                }
                
                slVc.completionHandler = ^(SLComposeViewControllerResult result){
                    switch (result) {
                        case SLComposeViewControllerResultDone:
                            if (self.completionBlock) {
                                self.completionBlock(Yodo1ShareTypeFacebook,Yodo1ShareContentStateSuccess,nil);
                                self.isYodo1Shared = NO;
                            }
                            break;
                        case SLComposeViewControllerResultCancelled:
                            if (self.completionBlock) {
                                self.completionBlock(Yodo1ShareTypeFacebook,Yodo1ShareContentStateCancel,nil);
                                self.isYodo1Shared = NO;
                            }
                            break;
                    }
                };
                [[Yodo1Commons getRootViewController] presentViewController:slVc animated:YES completion:nil];
            }
        }
            break;
        case Yodo1ShareTypeNone:
        {
            if (self.completionBlock) {
                NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"未选择平台分享",
                                            NSLocalizedFailureReasonErrorKey : @"",
                                            NSLocalizedRecoverySuggestionErrorKey : @""};
                
                NSError *error = [NSError errorWithDomain:@"SNSShare" code:-1 userInfo:errorDict];
                self.completionBlock(Yodo1ShareTypeNone,Yodo1ShareContentStateCancel,error);
                self.isYodo1Shared = NO;
            }
            
        }
            break;
        case Yodo1ShareTypeAll:
        {
        }
            break;
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    //TencentQQ
    NSRange r = [url.absoluteString rangeOfString:self.qqAppId];
    if (r.location != NSNotFound) {
        return [[Yodo1ShareByQQ sharedInstance] application:application openURL:url options:options];
    }
    //Weixin
    r = [url.absoluteString rangeOfString:self.wechatAppKey];
    if (r.location != NSNotFound) {
        return [[Yodo1ShareByWeChat sharedInstance] application:application openURL:url options:options];
    }
    
    //SinaWeibo
    r = [url.absoluteString rangeOfString:self.sinaWeiboAppKey];
    if (r.location != NSNotFound) {
        return [[Yodo1ShareBySinaWeibo sharedInstance] application:application openURL:url options:options];
    }
    
    //Facebook
    r = [url.absoluteString rangeOfString:@"fb"];
    if (r.location != NSNotFound) {
        return [[Yodo1ShareByFacebook sharedInstance] application:application openURL:url options:options];
    }
    return NO;
}

// Still need this for iOS8
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation {
    //Facebook
    NSRange r = [url.absoluteString rangeOfString:@"fb"];
    if (r.location != NSNotFound) {
        return [[Yodo1ShareByFacebook sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return NO;
}

- (BOOL)isInstalledWithType:(Yodo1ShareType)shareType
{
    BOOL isQQInstalled = [QQApiInterface isQQInstalled];
    
    BOOL isSinaWeiboInstalled = [WeiboSDK isWeiboAppInstalled];
    
    BOOL isWeChatInstalled = [WXApi isWXAppInstalled];
    
    BOOL isFacebookAvailable = NO;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]
        && (([SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]) != nil)) {
        isFacebookAvailable = YES;
    }
    
    if (shareType == Yodo1ShareTypeSinaWeibo) {
        return isSinaWeiboInstalled;
    }
    else if (shareType == Yodo1ShareTypeTencentQQ) {
        return isQQInstalled;
    }
    else if (shareType == Yodo1ShareTypeWeixinMoments||shareType == Yodo1ShareTypeWeixinContacts) {
        return isWeChatInstalled;
    }
    else if (shareType == Yodo1ShareTypeFacebook) {
        if (@available(iOS 11.0,*)) {
            return [[Yodo1ShareByFacebook sharedInstance] isInstallFacebook];
        } else {
            return isFacebookAvailable;
        }
    }
    
    return NO;
}

- (NSString *)getSdkVersion {
    return Y_SHARE_VERSION;
}

- (void)setDebugLog:(BOOL)debugLog {
    [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:debugLog] forKey:Y_SHARE_DEBUG_LOG];
}

#ifdef __cplusplus

extern "C" {

    void UnityShareInit() {
        [Yodo1Share.sharedInstance initWithConfig:nil];
    }
    
    void UnityShare(char* paramJson, char* gameObjectName, char* methodName)
    {
        NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
        NSString* ocMethodName = Yodo1CreateNSString(methodName);
        NSString* _paramJson = Yodo1CreateNSString(paramJson);
        
        Yodo1SMContent* smContent = [Yodo1SMContent yodo1_modelWithJSON:_paramJson];
        
        UIImage* image = [UIImage imageNamed:smContent.contentImage];
        if(image==nil){
            image = [UIImage imageWithContentsOfFile:smContent.contentImage];
        }
        
        UIImage* qrLogo = [UIImage imageNamed:smContent.qrLogo];
        if(qrLogo==nil){
            qrLogo = [UIImage imageWithContentsOfFile:smContent.qrLogo];
        }
        
        UIImage* gameLogo = [UIImage imageNamed:smContent.gameLogo];
        if(gameLogo==nil){
            gameLogo = [UIImage imageWithContentsOfFile:smContent.gameLogo];
        }
        
        ShareContent* content = [[ShareContent alloc]init];
        content.contentImage = image;
        content.contentTitle = smContent.contentTitle;
        content.contentText = smContent.contentText;
        content.contentUrl = smContent.contentUrl;
        content.gameLogo = gameLogo;
        content.qrLogo = qrLogo;
        content.qrText = smContent.qrText;
        content.qrTextX = smContent.qrTextX;
        content.qrImageX = smContent.qrImageX;
        content.gameLogoX = smContent.gameLogoX;
        Yodo1ShareType shareType = (Yodo1ShareType)smContent.shareType;
        content.shareType = shareType;
        ShareContentType contentType = (ShareContentType)smContent.contentType;
        content.contentType = contentType;
        
        [[Yodo1Share sharedInstance]showSocial:content
                                         block:^(Yodo1ShareType shareType, Yodo1ShareContentState state, NSError *error) {
                                             if(ocGameObjName && ocMethodName){
                                                 NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                                                 [dict setObject:[NSNumber numberWithInt:(state == Yodo1ShareContentStateSuccess?1:0)] forKey:@"status"];
                                                 [dict setObject:[NSNumber numberWithInteger:shareType] forKey:@"shareType"];
                                                 
                                                 NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:nil];
                                                 
                                                 UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                                                  [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                                                  [msg cStringUsingEncoding:NSUTF8StringEncoding] );
                                             }
                                             
                                         }];
    }
    
    char* UnityShareGetSdkVersion() {
        const char* sdkVersion = Y_SHARE_VERSION.UTF8String;
        Yodo1SHARELOG(@"sdkVersion = %@", Y_SHARE_VERSION);
        return Yodo1MakeStringCopy(sdkVersion);
    }
    
    bool UnityShareCheckSNSInstalledWithType(int type)
    {
        Yodo1ShareType kType = (Yodo1ShareType)type;
        if([[Yodo1Share sharedInstance] isInstalledWithType:kType]){
            return true;
        }
        return false;
    }
    
    void UnityShareSetDebugLog(bool debugLog) {
        [Yodo1Share.sharedInstance setDebugLog:debugLog];
    }
}
#endif

@end
