//
//  Yodo1Suit.m
//
//  Created by hyx on 17/7/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define YODO1_SUIT
#define YODO1_ANALYTICS

#define YODO1UcapDomain @"https://uc-ap.yodo1api.com/uc_ap"
#define YODO1DeviceLoginURL @"channel/device/login"

#import "Yodo1Suit.h"
#import "Yodo1UnityTool.h"

#import "Yd1OnlineParameter.h"
#import "YD1AgePrivacyManager.h"
#import "Yodo1ReportError.h"
#import <Bugly/Bugly.h>
#import "YD1LogView.h"
#import "Yodo1Commons.h"
#import "Yodo1AdConfigHelper.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AFNetworking.h"

//#ifdef YODO1_ANALYTICS
#import "Yodo1AnalyticsManager.h"
#import "ThinkingAnalyticsSDK.h"
#import "Yodo1KeyInfo.h"
//#endif

#import <AppTrackingTransparency/AppTrackingTransparency.h>

//Unity3d
const char* UNITY3D_YODO1SUIT_METHOD     = "Yodo1U3dSDKCallBackResult";
static NSString* kYodo1SuitGameObject    = @"Yodo1Suit";//默认

@interface Yodo1SuitDelegate : NSObject

+ (instancetype)instance;

+ (UIViewController*)getRootViewController;

+ (UIViewController*)topMostViewController:(UIViewController*)controller;

+ (NSString *)stringWithJSONObject:(id)obj error:(NSError**)error;

+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error;

@end

@implementation Yodo1SuitDelegate

+ (instancetype)instance {
    static Yodo1SuitDelegate *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1SuitDelegate alloc] init];
    });
    
    return sharedInstance;
}

+ (UIViewController*)getRootViewController {
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray* windows = [[UIApplication sharedApplication] windows];
        for (UIWindow* _window in windows) {
            if (_window.windowLevel == UIWindowLevelNormal) {
                window = _window;
                break;
            }
        }
    }
    UIViewController* viewController = nil;
    for (UIView* subView in [window subviews]) {
        UIResponder* responder = [subView nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            viewController = [self topMostViewController:(UIViewController*)responder];
        }
    }
    if (!viewController) {
        viewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    return viewController;
}

+ (UIViewController*)topMostViewController:(UIViewController*)controller {
    BOOL isPresenting = NO;
    do {
        // this path is called only on iOS 6+, so -presentedViewController is fine here.
        UIViewController* presented = [controller presentedViewController];
        isPresenting = presented != nil;
        if (presented != nil) {
            controller = presented;
        }
        
    } while (isPresenting);
    
    return controller;
}

+ (NSString*)stringWithJSONObject:(id)obj error:(NSError**)error {
    if (obj) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSData* data = nil;
            @try {
                data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:error];
            }
            @catch (NSException* exception)
            {
                *error = [NSError errorWithDomain:[exception description] code:0 userInfo:nil];
                return nil;
            }
            @finally
            {
            }
            
            if (data) {
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
    }
    return nil;
}

+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error {
    if (str) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            return [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingAllowFragments
                                                     error:error];
        }
    }
    return nil;
}

@end


#pragma mark- ///OC实现

@interface Yodo1Suit ()

+ (NSDictionary*)config;

+ (NSString*)publishType;

+ (NSString*)publishVersion;

@end

@implementation Yodo1Suit

static BOOL bYodo1SuitInited = NO;
static NSString* yd1AppKey = @"";


+ (void)initWithAppKey:(NSString *)appKey {
    if (bYodo1SuitInited) {
        NSLog(@"[Yodo1 Ads] has already been initialized");
        return;
    }
    bYodo1SuitInited = true;
    [NSNotificationCenter.defaultCenter addObserver:[Yodo1Suit class] selector:@selector(onlineParamete:) name:kYodo1OnlineConfigFinishedNotification object:nil];
    
    
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
        NSLog(@"[Yodo1 Ads] plist中设置GameKey");
    }
    
    //初始化在线参数
    [Yd1OnlineParameter.shared initWithAppKey:appKey channelId:@"AppStore"];
    yd1AppKey = appKey;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(startTime) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(endTime) name:UIApplicationWillResignActiveNotification object:nil];
}


+ (void)startTime {
    if ([Yodo1AdConfigHelper.instance isSensorsSwitch]) {
        [ThinkingAnalyticsSDK.sharedInstance timeEvent:@"end"];
//        [ThinkingAnalyticsSDK.sharedInstance track:@"startup" properties:@{}];
    }
#ifdef YODO1_ANALYTICS
    if (Yodo1AnalyticsManager.enable) {
        [Yodo1AnalyticsManager.sharedInstance beginEvent:@"end"];
        [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"startup" eventData:@{}];
    }
#endif
}

+ (void)endTime {
    if ([Yodo1AdConfigHelper.instance isSensorsSwitch]) {
        [ThinkingAnalyticsSDK.sharedInstance timeEvent:@"end"];
    }
#ifdef YODO1_ANALYTICS
    if (Yodo1AnalyticsManager.enable) {
        [Yodo1AnalyticsManager.sharedInstance endEvent:@"end"];
    }
#endif
}

+ (void)onlineParamete:(NSNotification *)notif  {
    //初始化错误上报系统
    NSString* feedback = [Yd1OnlineParameter.shared stringConfigWithKey:@"Platform_Feedback_SwitchAd" defaultValue:@"off"];
    if ([feedback isEqualToString:@"on"]) {//默认是关
        [[Yodo1ReportError instance]initWithAppKey:yd1AppKey channel:@"appstore"];
        //每次启动游戏都会上传一次
        [[Yodo1ReportError instance]uploadReportError];
    }
    
    if (Yd1OnlineParameter.shared.bTestDevice && Yd1OnlineParameter.shared.bFromPA) {
        [YD1LogView startLog:yd1AppKey];
    }
    
    NSDictionary* object = [notif object];
    BOOL isVerifyBundleidSwitch = Yodo1AdConfigHelper.instance.isVerifyBundleidSwitch;
    NSString * bid = Yodo1AdConfigHelper.instance.verifyBundleid;
    if (isVerifyBundleidSwitch && bid.length) {
        NSString * bundle_id = [Yodo1Commons appBundleId];
        if (![bid isEqualToString:bundle_id]) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"App Bundle id does not match appkey! Please check your appkey or bundle id, You can find them at the MAS Developer's website." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [[Yodo1Commons getRootViewController] presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    
    //初始化数数统计
    NSDictionary * tdConfig = Yodo1AdConfigHelper.instance.thinkDataConfig;
    NSString* sensorSwitch = tdConfig[kTD_Switch];
    BOOL bTDSwitch = true;
    if (sensorSwitch && [sensorSwitch isEqualToString:@"off"]) {
        bTDSwitch = false;
    }
    [Yodo1Tool.shared.cached setObject:[NSNumber numberWithBool:bTDSwitch]
                                forKey:@"ThinkingDataSwitch"];
    [Yodo1AdConfigHelper.instance setSensorsSwitch:bTDSwitch];
    
    if (bTDSwitch) {
        NSString* appId = tdConfig[kTD_AppId];
        NSString* configURL = tdConfig[kTD_ServerUrl];
        BOOL bTDLogEnable = [tdConfig[kTD_Switch_DebugMode] isEqualToString:@"on"];
        if (appId && appId.length==0) {
            appId = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"ThinkingAppId"];
        }
        if (configURL && configURL.length == 0) {
            configURL = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"ThinkingServerUrl"];
        }
        
        TDConfig *config = [TDConfig new];
        config.appid = appId;
        config.configureURL = configURL;
        if(bTDLogEnable){
            config.debugMode = ThinkingAnalyticsDebug;
        }
        
        [ThinkingAnalyticsSDK startWithConfig:config];
#ifdef DEBUG
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
#endif
        
//        [ThinkingAnalyticsSDK.sharedInstance setSuperProperties:@{@"channel_code":@"appstore"}];
        
        //设置访客ID
        [ThinkingAnalyticsSDK.sharedInstance identify:Yodo1Tool.shared.keychainDeviceId];
        
        [Yodo1Suit devideLogin];
        
        NSLog(@"[ Yodo1 ]:DistinctId ->%@(%@)(%@)(%@)",ThinkingAnalyticsSDK.sharedInstance.getDistinctId, Yodo1Tool.shared.keychainDeviceId, Yodo1Tool.shared.idfv, Yodo1Tool.shared.idfa);
        
        NSString* bundleId = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        [ThinkingAnalyticsSDK.sharedInstance user_setOnce:@{@"yID":@"",@"game":bundleId,@"channel":@"appstore"}];
        [ThinkingAnalyticsSDK.sharedInstance setSuperProperties:@{@"gameKey":[[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"],
                                                                         @"gameBundleId":bundleId,
                                                                         @"sdkType":[Yodo1Suit publishType],
                                                                         @"publishChannelCode":@"appstore",
                                                                  @"sdkVersion":[Yodo1Suit publishVersion]}];
        NSDictionary * reportFields = [Yodo1AdConfigHelper instance].report_fields;
        if (reportFields) {
            [ThinkingAnalyticsSDK.sharedInstance setSuperProperties:reportFields];
        }
//        [ThinkingAnalyticsSDK.sharedInstance track:@"setCCPA"
//                   properties:@{@"result":[Yodo1AdConfigHelper.instance isDoNotSell]?@"No":@"Yes"}];
//
//        [ThinkingAnalyticsSDK.sharedInstance track:@"setGDPR"
//                   properties:@{@"result":[Yodo1AdConfigHelper.instance isUserConsent]?@"Yes":@"No"}];
//
//        [ThinkingAnalyticsSDK.sharedInstance track:@"setCOPPA"
//                   properties:@{@"result":[Yodo1AdConfigHelper.instance isTagForUnderAgeOfConsent]?@"Yes":@"No"}];
    }
    
    // 自动埋点 关闭
    [[ThinkingAnalyticsSDK sharedInstance] enableAutoTrack:
    ThinkingAnalyticsEventTypeAppStart |
    ThinkingAnalyticsEventTypeAppEnd |
    ThinkingAnalyticsEventTypeAppViewScreen |
    ThinkingAnalyticsEventTypeAppClick |
    ThinkingAnalyticsEventTypeAppInstall |
    ThinkingAnalyticsEventTypeAppViewCrash
    ];
    
    //初始化第三方统计 mas sdk 才初始化
#ifdef YODO1_ANALYTICS
    [Yodo1AnalyticsManager.sharedInstance initializeAnalyticsWithConfig:nil];
#endif
    
    //在线参数控制ATT是否弹出
    if (@available(iOS 14, *)) {
        if ([Yodo1AdConfigHelper.instance isATTMasterSwitch]) {
            if (ATTrackingManager.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusNotDetermined) {
                [Yodo1AdConfigHelper.instance setShowATTDialogEnabled:YES];
                [[Yodo1Tool.shared cached]setObject:[NSNumber numberWithBool:YES] forKey:@"ShenCeShowATTDialogEnabled"];
                [[Yodo1Tool.shared cached]setObject:[NSNumber numberWithBool:YES] forKey:@"UmengShowATTDialogEnabled"];
            }
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                //神策
//                if (bTDSwitch) {
//                    if (![Yodo1AdConfigHelper.instance ShenCeATTDialogRunOneTimes]) {
//                        NSNumber* bRunOneTimes = (NSNumber *)[[Yodo1Tool.shared cached]objectForKey:@"ShenCeShowATTDialogEnabled"];
//                        if ([bRunOneTimes boolValue]) {
//                            [ThinkingAnalyticsSDK.sharedInstance track:@"showATTDialog" properties:@{@"result":@"active"}];
//                        }
//                        if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
//                            [ThinkingAnalyticsSDK.sharedInstance track:@"showATTDialog" properties:@{@"result":@"agree"}];
//                        } else {
//                            [ThinkingAnalyticsSDK.sharedInstance track:@"showATTDialog" properties:@{@"result":@"disagree"}];
//                        }
//                        [Yodo1AdConfigHelper.instance setShenCeATTDialogRunOneTimes:YES];
//                        [[Yodo1Tool.shared cached]setObject:[NSNumber numberWithBool:NO] forKey:@"ShenCeShowATTDialogEnabled"];
//                    }
//                }
#ifdef YODO1_ANALYTICS
                //友盟统计
                if (![Yodo1AdConfigHelper.instance UmengATTDialogRunOneTimes]) {
                    NSNumber* bRunOneTimes = (NSNumber *)[[Yodo1Tool.shared cached]objectForKey:@"UmengShowATTDialogEnabled"];
                    if ([bRunOneTimes boolValue]) {
                        [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"showATTDialog" eventData:@{@"result":@"active"}];
                    }
                    if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                        [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"showATTDialog" eventData:@{@"result":@"agree"}];
                    } else {
                        [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"showATTDialog" eventData:@{@"result":@"disagree"}];
                    }
                    [Yodo1AdConfigHelper.instance setUmengATTDialogRunOneTimes:YES];
                    [[Yodo1Tool.shared cached]setObject:[NSNumber numberWithBool:NO] forKey:@"UmengShowATTDialogEnabled"];
                }
#endif
            }];
        }
    }
    
    if (object && bTDSwitch) {
        int code = [[object objectForKey:@"code"]intValue];
        NSString * result = (code == 0 || code == 10) ? @"success" : @"fail";
//        [ThinkingAnalyticsSDK.sharedInstance track:@"onlineParameter" properties:@{@"result":result,@"errorCode":[NSString stringWithFormat:@"%d",code ? : 10]}];
#ifdef YODO1_ANALYTICS
        [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"onlineParameter" eventData:@{@"result":result,@"errorCode":[NSNumber numberWithInt:code]}];
#endif
    }
    [NSNotificationCenter.defaultCenter removeObserver:[Yodo1Suit class] name:kYodo1OnlineConfigFinishedNotification object:nil];
    ///Bugly
    NSString* buglyAppId = [Yd1OnlineParameter.shared stringConfigWithKey:@"BuglyAnalytic_AppId" defaultValue:@""];
    if (buglyAppId.length > 0 && [Yodo1Suit isUserConsent] && ![Yodo1Suit isTagForUnderAgeOfConsent]) {
        BuglyConfig* buglyConfig = [[BuglyConfig alloc]init];
#ifdef DEBUG
        buglyConfig.debugMode = YES;
#endif
        buglyConfig.channel = @"appstore";
        
        [Bugly startWithAppId:buglyAppId config:buglyConfig];
        
        NSString* sdkInfo = [NSString stringWithFormat:@"%@,%@",[Yodo1Suit publishType],[Yodo1Suit publishVersion]];
        
        [Bugly setUserIdentifier:Bugly.buglyDeviceId];
        [Bugly setUserValue:@"appstore" forKey:@"ChannelCode"];
        [Bugly setUserValue:[[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"] forKey:@"GameKey"];
        [Bugly setUserValue:Yodo1Tool.shared.keychainDeviceId forKey:@"DeviceID"];
        [Bugly setUserValue:sdkInfo forKey:@"SdkInfo"];
        [Bugly setUserValue:Yodo1Tool.shared.idfa forKey:@"IDFA"];
        [Bugly setUserValue:Yodo1Tool.shared.idfv forKey:@"IDFV"];
        [Bugly setUserValue:[Yodo1Commons territory] forKey:@"CountryCode"];
    }
    
    
#ifdef YODO1_ANALYTICS
    if (Yodo1AnalyticsManager.enable) {
        [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"setCOPPA"
                                                   eventData:@{@"result":[Yodo1AdConfigHelper.instance isTagForUnderAgeOfConsent]?@"Yes":@"No"}];
        [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"setGDPR"
                                                   eventData:@{@"result":[Yodo1AdConfigHelper.instance isUserConsent]?@"Yes":@"No"}];
        [Yodo1AnalyticsManager.sharedInstance eventAnalytics:@"setCCPA"
                                                   eventData:@{@"result":[Yodo1AdConfigHelper.instance isDoNotSell]?@"No":@"Yes"}];
    }
#endif
    //启动统计
    [Yodo1Suit startTime];
}

+ (void)devideLogin {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"YODO1LoginYID"]) {
        Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:YODO1UcapDomain]];
        manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        NSString* deviceId = Yd1OpsTools.keychainDeviceId;
        NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"yodo1.com%@%@",deviceId,Yd1OParameter.appKey]];
        NSDictionary* data = @{
            Yd1OpsTools.gameAppKey:Yd1OParameter.appKey ,Yd1OpsTools.channelCode:Yd1OParameter.channelId,Yd1OpsTools.deviceId:deviceId,Yd1OpsTools.regionCode:@"" };
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:data forKey:Yd1OpsTools.data];
        [parameters setObject:sign forKey:Yd1OpsTools.sign];
        YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:parameters error:nil]);
        [manager POST:YODO1DeviceLoginURL
           parameters:parameters
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
            int errorCode = -1;
            NSString* error = @"";
            if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
                errorCode = [[response objectForKey:Yd1OpsTools.errorCode]intValue];
            }
            if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
                error = [response objectForKey:Yd1OpsTools.error];
            }
            if ([[response allKeys]containsObject:Yd1OpsTools.data]) {
                NSDictionary* m_data = (NSDictionary*)[response objectForKey:Yd1OpsTools.data];
                YD1LOG(@"m_data:%@", m_data);
                NSString *yid = m_data[@"yid"];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:yid forKey:@"YODO1LoginYID"];
                
                if (yid.length > 0) {
                    [ThinkingAnalyticsSDK.sharedInstance login:yid];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            YD1LOG(@"%@",error.localizedDescription);
            return;
        }];
    } else {
        [ThinkingAnalyticsSDK.sharedInstance login:[[NSUserDefaults standardUserDefaults] objectForKey:@"YODO1LoginYID"]];
    }
}

+ (NSDictionary*)config {
    NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle]pathForResource:@"Yodo1Suit" ofType:@"bundle"]];
    if (!bundle) {return nil;}
    NSString *configPath = [bundle pathForResource:@"config" ofType:@"plist"];
    if (!configPath.length) {return nil;}
    return [NSDictionary dictionaryWithContentsOfFile:configPath];
}

+ (NSString*)publishType {
    NSDictionary* _config = [Yodo1Suit config];
    NSString* _publishType = @"";
    if (_config && [[_config allKeys]containsObject:@"PublishType"]) {
        _publishType = (NSString*)[_config objectForKey:@"PublishType"];
    }
    return _publishType;
}

+ (NSString*)publishVersion {
    NSDictionary* _config = [Yodo1Suit config];
    NSString* _publishVersion = @"";
    if (_config && [[_config allKeys]containsObject:@"PublishVersion"]) {
        _publishVersion = (NSString*)[_config objectForKey:@"PublishVersion"];
    }
    return _publishVersion;
}

+ (NSString *)sdkVersion {
    return [self publishVersion];
}

+ (void)setLogEnable:(BOOL)enable {
    //    [[Yodo1Analytics instance]setDebugMode:enable];
}

+ (void)setUserConsent:(BOOL)consent {
#ifdef YODO1_SUIT
    [[Yodo1AdConfigHelper instance]setUserConsent:consent];
#endif
}

+ (BOOL)isUserConsent {
#ifdef YODO1_SUIT
    return [Yodo1AdConfigHelper.instance isUserConsent];
#endif
    return YES;
}

+ (void)setTagForUnderAgeOfConsent:(BOOL)isBelowConsentAge {
#ifdef YODO1_SUIT
    [[Yodo1AdConfigHelper instance]setTagForUnderAgeOfConsent:isBelowConsentAge];
#endif
}

+ (BOOL)isTagForUnderAgeOfConsent {
#ifdef YODO1_SUIT
    return [Yodo1AdConfigHelper.instance isTagForUnderAgeOfConsent];
#endif
    return NO;
}

+ (void)setDoNotSell:(BOOL)doNotSell {
#ifdef YODO1_SUIT
    [[Yodo1AdConfigHelper instance]setDoNotSell:doNotSell];
#endif
}

+ (BOOL)isDoNotSell {
#ifdef YODO1_SUIT
    return [Yodo1AdConfigHelper.instance isDoNotSell];
#endif
    return NO;
}

@end


#pragma mark- ///Unity3d

extern "C" {

void Unity3dInitWithAppKey(const char *appKey,const char* gameObject)
{
    NSString* m_appKey = Yodo1CreateNSString(appKey);
    NSCAssert(m_appKey != nil, @"AppKey 没有设置!");
    
    NSString* m_gameObject = Yodo1CreateNSString(gameObject);
    if (m_gameObject) {
        kYodo1SuitGameObject = m_gameObject;
    }
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    
    [Yodo1Suit initWithAppKey:m_appKey];
}

void Unity3dSetLogEnable(BOOL enable)
{
    [Yodo1Suit setLogEnable:enable];
}

#pragma mark - Privacy

void UnitySetUserConsent(BOOL consent)
{
    [Yodo1Suit setUserConsent:consent];
}

bool UnityGetUserConsent()
{
    return [Yodo1Suit isUserConsent];
}

void UnitySetTagForUnderAgeOfConsent(BOOL underAgeOfConsent)
{
    [Yodo1Suit setTagForUnderAgeOfConsent:underAgeOfConsent];
}

bool UnityGetTagForUnderAgeOfConsent()
{
    return [Yodo1Suit isTagForUnderAgeOfConsent];
}

void UnitySetDoNotSell(BOOL doNotSell)
{
    [Yodo1Suit setDoNotSell:doNotSell];
}

bool UnityGetDoNotSell()
{
    return [Yodo1Suit isDoNotSell];
}

void UnityShowUserConsent(const char *SdkObjectName,const char* SdkMethodName)
{
    NSString* m_appKey = nil;
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        m_appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    }
    NSCAssert(m_appKey != nil, @"AppKey 没有设置!");
    NSString* m_gameObject = Yodo1CreateNSString(SdkObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    NSString* m_methodName = Yodo1CreateNSString(SdkMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d methodName isn't set!");
    UIViewController* rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    if (rootViewController == nil) {
        rootViewController = [Yodo1Commons getRootViewController];
    }
    [YD1AgePrivacyManager dialogShowUserConsentWithGameAppKey:m_appKey channelCode:@"appstore" viewController:rootViewController block:^(BOOL accept, BOOL child, int age) {
        if (m_gameObject && m_methodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:8001] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:age] forKey:@"age"];
            [dict setObject:[NSNumber numberWithBool:child] forKey:@"isChild"];
            [dict setObject:[NSNumber numberWithBool:accept] forKey:@"accept"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            NSString* jsonError = @"";
            if(parseJSONError){
                jsonError = @"Convert result to json failed!";
                [dict setObject:jsonError forKey:@"error"];
                msg =  [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            }
            
            UnitySendMessage([kYodo1SuitGameObject cStringUsingEncoding:NSUTF8StringEncoding],UNITY3D_YODO1SUIT_METHOD,
                             [msg cStringUsingEncoding:NSUTF8StringEncoding] );
        }
    }];
}
}
