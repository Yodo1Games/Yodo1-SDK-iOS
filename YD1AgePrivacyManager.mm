#import "YD1AgePrivacyManager.h"
#import "YD1AgePrivacyView.h"
#import "Yodo1AFNetworking.h"
#import "Yodo1Model.h"
#import "Yodo1YYCache.h"
#import <AdSupport/AdSupport.h>
#include <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1Base.h"
#import "Yodo1Tool+Commons.h"


NSString* const YD1_Default = @"default";
NSString* const YD1_ChineseHans = @"zh";//简体，不一样
NSString* const YD1_English = @"en";
NSString* const YD1_ChineseHant = @"zh-hant";//繁体，不一样
NSString* const YD1_French = @"fr";
NSString* const YD1_German = @"de";
NSString* const YD1_Hindi = @"hi";//没有
NSString* const YD1_Italian = @"it";
NSString* const YD1_Arabic = @"ar";
NSString* const YD1_Spanish = @"es";
NSString* const YD1_Indonesian = @"in";//没有
NSString* const YD1_Japanese = @"ja";
NSString* const YD1_Korean = @"ko";
NSString* const YD1_Portuguese = @"pt";//不一样
NSString* const YD1_Russian = @"ru";
NSString* const YD1_Turkish = @"tr";//没有


NSString* const URL_Privacy = @"https://olc.yodo1api.com";
NSString* const Sub_URL_Privacy = @"/config/userLicense/getInfo";

NSString* const kPrivacyDataKey = @"com.yodo1.privacy.data";

///用户协议
NSString* const kUserAgreementDefault = @"https://www.yodo1.com/en/terms/";
NSString* const kUserAgreementEN = @"https://www.yodo1.com/en/terms/";
NSString* const kUserAgreementZH = @"https://www.yodo1.com/cn/user_agreement/";
NSString* const kUserAgreementJA = @"https://www.yodo1.com/en/jpn-terms-of-use/";
///隐私政策
NSString* const kPrivacyPolicyDefault = @"https://www.yodo1.com/en/privacy/";
NSString* const kPrivacyPolicyEN = @"https://www.yodo1.com/en/privacy/";
NSString* const kPrivacyPolicyZH = @"https://www.yodo1.com/cn/privacy_policy/";
NSString* const kPrivacyPolicyJA = @"https://www.yodo1.com/en/jpn-privacy-policy/";

static bool kOpenSwitch = false;
static int kCurrentYearOld = 16;

static bool isPrivacySelectLanguage = false;
static NSString* yd1PrivacySpecifiedLanguage  = @"en";

///用户协议
NSString* const YD1_UserAgreementName = @"default";
///隐私政策
NSString* const YD1_PrivacyPolicyName = @"privacy";

@implementation PrivacyServiceInfoModel
@end

@implementation PrivacyServiceInfo
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"license_info" : LicenseInfo.class};
}
@end

@implementation LicenseInfo
@end

static YD1AgePrivacyView* kPrivacyView = nil;
static YD1AgePrivacyUpdateView* kPrivacyUpdateView = nil;

static YD1PrivacyViewController* privacyView = nil;

@interface YD1AgePrivacyManager ()  {
    
}

@end

@implementation YD1AgePrivacyManager

static YD1AgePrivacyManager* _instance = nil;

+ (YD1AgePrivacyManager*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YD1AgePrivacyManager alloc]init];
    });
    return _instance;
}

- (Yodo1YYCache *)yyCache {
    if (_yyCache == nil) {
        _yyCache = [[Yodo1YYCache alloc]initWithPath:[YD1AgePrivacyManager cachedPrivacyPath]];
    }
    return _yyCache;
}

+ (void)selectLocalLanguage:(NSString*)language {
    if (language) {
        [PrivacyUtils selectLocalLanguage:language
                      isSectlocalLanguage:YES];
        
        isPrivacySelectLanguage = YES;
        yd1PrivacySpecifiedLanguage = language;
    }else{
        YD1LOG(@"no specified language!");
        [PrivacyUtils selectLocalLanguage:yd1PrivacySpecifiedLanguage
                      isSectlocalLanguage:NO];
        
        isPrivacySelectLanguage = NO;
    }
    kPrivacyView = nil;
    kPrivacyUpdateView = nil;
}

+ (void)startDialogUserConsent:(UIViewController*)viewcontroller
                      isUpdate:(BOOL)isUpdate {
    if (isUpdate) {
        if (kPrivacyUpdateView == nil) {
            kPrivacyUpdateView = [YD1AgePrivacyUpdateView new];
            kPrivacyUpdateView.frame = viewcontroller.view.frame;
            [viewcontroller.view addSubview:kPrivacyUpdateView];
            kPrivacyUpdateView.hidden = YES;
        }
    }else{
        if (kPrivacyView == nil) {
            kPrivacyView = [YD1AgePrivacyView new];
            kPrivacyView.frame = viewcontroller.view.frame;
            [viewcontroller.view addSubview:kPrivacyView];
            kPrivacyView.hidden = YES;
        }
    }
}

+ (NSString*)onlinePrivacyURL:(NSString*)urlKey licenseName:(NSString*)licenseName {
    __block NSString* url = @"";
    [YD1AgePrivacyManager getPrivacyOnlineService:^(PrivacyServiceInfo *info) {
        NSArray* licenseInfo = info.license_info;
        for (LicenseInfo* li in licenseInfo) {
            if ([li.license_name isEqualToString:licenseName]) {
                if (li.license_version) {
                    [YD1AgePrivacyManager.sharedInstance.yyCache setObject:li.license_version forKey:@"licenseVersion"];
                }
                NSDictionary* tmp = li.links;
                if ([[tmp allKeys]containsObject:urlKey]) {
                    for (NSString* key in [tmp allKeys]) {
                        if ([key isEqualToString:urlKey]) {
                            url = [tmp objectForKey:urlKey];
                        }
                    }
                }
            }
        }
    }];
    return url;
}

///urlKey 指定语言
+ (NSString*)currentPrivacyURL:(NSString*)urlKey
                   licenseName:(NSString*)licenseName
                     isOffline:(BOOL)isOffline {
    NSString* url = @"";
    if (isOffline) {//取不到在线参数情况，返回默认的URL
        if ([urlKey isEqualToString:YD1_ChineseHans]) {
            url = kUserAgreementZH;
        }else if ([urlKey isEqualToString:YD1_Japanese]){
            url = kUserAgreementJA;
        }else if ([urlKey isEqualToString:YD1_English]){
            url = kUserAgreementEN;
        }else{//默认是en
            url = kUserAgreementDefault;
        }
    }else{
        url = [YD1AgePrivacyManager onlinePrivacyURL:urlKey
                                         licenseName:licenseName];
        if ([url isEqualToString:@""]) {// 指定语言没有，就取默认的
            url = [YD1AgePrivacyManager onlinePrivacyURL:YD1_Default
                                             licenseName:licenseName];
        }
        if ([url isEqualToString:@""]) {//在没有，就指定默认的
            url = kUserAgreementDefault;
        }
    }
    return url;
}

+ (void)dialogShowUserConsentWithGameAppKey:(NSString*)gameAppKey
                                channelCode:(NSString*)channelCode
                             viewController:(UIViewController*)viewcontroller
                                      block:(PrivacyBlock)privacyBlock {
    
    [YD1AgePrivacyManager startGetPrivacyOnlineServiceWithGameAppKey:gameAppKey channelCode:channelCode block:^(BOOL finish, NSError *error) {
        BOOL isOnline = true;
        if (finish && error == nil) {
            isOnline = false;
        }
        UIViewController * controller = viewcontroller;
        NSString* tmpKey = @"";
        NSString* currentSystemLanguage = [PrivacyUtils preferredLanguage];
        if ([currentSystemLanguage isEqualToString:@"zh-Hans"]) {
            tmpKey = YD1_ChineseHans;
        }else{
            tmpKey = currentSystemLanguage;
        }
        //设置Game Language的时候
        if (isPrivacySelectLanguage) {
            tmpKey = yd1PrivacySpecifiedLanguage;
        }
        
        NSDictionary* saveInfo = (NSDictionary*)[YD1AgePrivacyManager.sharedInstance.yyCache objectForKey:@"OpenPrivacyView"];
        BOOL isOpen = false;
        BOOL isAccept = true;
        BOOL isChild = true;
        int selectOld = 16;
        if (saveInfo) {
            isOpen = [((NSNumber*)[saveInfo objectForKey:@"IsOpen"])boolValue];
            isAccept = [((NSNumber*)[saveInfo objectForKey:@"Accept"])boolValue];
            isChild = [((NSNumber*)[saveInfo objectForKey:@"Child"])boolValue];
            selectOld = [((NSNumber*)[saveInfo objectForKey:@"Age"])intValue];
        }
        
        BOOL is_Need_Update = [((NSNumber*)[YD1AgePrivacyManager.sharedInstance.yyCache objectForKey:@"License_Is_Need_Update"])boolValue];
        if (kOpenSwitch && isOpen && is_Need_Update) {
            //展示更新UI
            if (kPrivacyUpdateView == nil) {
                [YD1AgePrivacyManager startDialogUserConsent:viewcontroller
                                                    isUpdate:YES];
            }
            kPrivacyUpdateView.privacyURL = [YD1AgePrivacyManager currentPrivacyURL:tmpKey licenseName:YD1_UserAgreementName isOffline:isOnline];
            if (controller) {
                kPrivacyUpdateView.hidden = NO;
                [controller.view addSubview:kPrivacyUpdateView];
            }else{
                controller = UIApplication.sharedApplication.keyWindow.rootViewController;
                if (controller) {
                    kPrivacyUpdateView.hidden = NO;
                    [controller.view addSubview:kPrivacyUpdateView];
                }else{
                    YD1LOG(@"rootViewController is nil");
                }
            }
            [kPrivacyUpdateView setAgePrivacyUpdateBlock:^(BOOL accept) {
                if (privacyBlock) {
                    privacyBlock(accept,isChild,selectOld);
                }
                [YD1AgePrivacyManager.sharedInstance.yyCache setObject:[NSNumber numberWithBool:NO] forKey:@"License_Is_Need_Update"];
                kPrivacyUpdateView = nil;
            }];
            return;
        }
        if (isOpen) {
            if (privacyBlock) {
                privacyBlock(isAccept,isChild,selectOld);
            }
            return;
        }
        
        if (kPrivacyView == nil) {
            [YD1AgePrivacyManager startDialogUserConsent:viewcontroller
                                                isUpdate:NO];
        }
        
        kPrivacyView.userAgreementURL = [YD1AgePrivacyManager currentPrivacyURL:tmpKey licenseName:YD1_UserAgreementName isOffline:isOnline];
        kPrivacyView.privacyPolicyURL = [YD1AgePrivacyManager currentPrivacyURL:tmpKey licenseName:YD1_PrivacyPolicyName isOffline:isOnline];
        kPrivacyView.childAgeLimit = kCurrentYearOld;
        
        if (controller) {
            kPrivacyView.hidden = NO;
            [controller.view addSubview:kPrivacyView];
        }else{
            controller = UIApplication.sharedApplication.keyWindow.rootViewController;
            if (controller) {
                kPrivacyView.hidden = NO;
                [controller.view addSubview:kPrivacyView];
            }else{
                YD1LOG(@"rootViewController is nil");
            }
        }
        [kPrivacyView setAgePrivacyBlock:^(BOOL accept, BOOL child,int age) {
            if (privacyBlock) {
                privacyBlock(accept,child,age);
            }else{
                YD1LOG(@"privacyBlock is nil");
            }
            //保存打开过
            NSDictionary* saveInfo = @{@"IsOpen":[NSNumber numberWithBool:YES],
                                       @"Accept":[NSNumber numberWithBool:accept],
                                       @"Child":[NSNumber numberWithBool:child],
                                       @"Age":[NSNumber numberWithInt:age]
            };
            [YD1AgePrivacyManager.sharedInstance.yyCache setObject:saveInfo forKey:@"OpenPrivacyView"];
            kPrivacyView = nil;
        }];
    }];
    
}

+ (void)dialogShowPrivacyViewcontroller:(UIViewController *)viewcontroller
                                  block:(PrivacyCallback)privacyCallback
{
    NSDictionary* saveInfo = (NSDictionary*)[YD1AgePrivacyManager.sharedInstance.yyCache objectForKey:@"OpenPrivacy"];
    BOOL isAccept = false;
    if (saveInfo) {
        isAccept = [((NSNumber*)[saveInfo objectForKey:@"Accept"])boolValue];
    }
    if (isAccept) {
        privacyCallback(YES);
        return;
    }
    UIViewController * controller = viewcontroller;
    if (privacyView == nil) {
        privacyView = [YD1PrivacyViewController new];
    }
    privacyView.userAgreementURL = @"https://gamepolicy.yodo1.com/terms_of_Service_zh.html";
    privacyView.privacyPolicyURL = @"https://gamepolicy.yodo1.com/privacy_policy_zh.html";
    
    if (controller) {
        [controller presentViewController:privacyView animated:YES completion:nil];
        
    }else{
        controller = UIApplication.sharedApplication.keyWindow.rootViewController;
        if (controller) {
            [controller presentViewController:privacyView animated:YES completion:nil];
        }else{
            YD1LOG(@"rootViewController is nil");
        }
    }
    [privacyView setPrivacyBlock:^(BOOL accept) {
        if (privacyCallback) {
            privacyCallback(accept);
        }else{
            YD1LOG(@"privacyBlock is nil");
        }
        //保存打开过
        NSDictionary* saveInfo = @{@"Accept":[NSNumber numberWithBool:accept]};
        [YD1AgePrivacyManager.sharedInstance.yyCache setObject:saveInfo forKey:@"OpenPrivacy"];
        kPrivacyView = nil;
    }];
}

+ (NSString*)currentTimestamp {
    NSTimeInterval timeStamp= [[NSDate date] timeIntervalSince1970];
    NSString *string = [NSString stringWithFormat:@"%f",timeStamp *1000];
    NSString *dateString = [[string componentsSeparatedByString:@"."]objectAtIndex:0];
    return dateString;
}

+ (NSDictionary*)config {
    NSBundle *bundle = [[NSBundle alloc] initWithPath:[[NSBundle mainBundle]
                                                       pathForResource:@"Yodo1Suit"
                                                       ofType:@"bundle"]];
    if (bundle) {
        NSString *configPath = [bundle pathForResource:@"config" ofType:@"plist"];
        if (configPath) {
            NSDictionary *config =[NSDictionary dictionaryWithContentsOfFile:configPath];
            return config;
        }
    }
    return nil;
}

+ (NSString*)publishType {
    NSDictionary* _config = [YD1AgePrivacyManager config];
    NSString* _publishType = @"";
    if (_config && [[_config allKeys]containsObject:@"PublishType"]) {
        _publishType = (NSString*)[_config objectForKey:@"PublishType"];
    }
    return _publishType;
}

+ (NSString*)publishVersion {
    NSDictionary* _config = [YD1AgePrivacyManager config];
    NSString* _publishVersion = @"";
    if (_config && [[_config allKeys]containsObject:@"PublishVersion"]) {
        _publishVersion = (NSString*)[_config objectForKey:@"PublishVersion"];
    }
    return _publishVersion;
}

+ (NSString *)md5StringWithString:(NSString *)string {
    if (string == nil) {
        YD1LOG(@"Input is nil.");
        return nil;
    }
    const char *ptr = [string UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return output;
}

+ (NSString *)appVersion {
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if ([[infoDictionary allKeys] containsObject:@"CFBundleShortVersionString"]) {
        return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    }
    return nil;
}

+ (NSString *)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)cachedPrivacyPath {
    return [NSString stringWithFormat:@"%@/privacy",[YD1AgePrivacyManager documentsPath]];
}

+ (void)startGetPrivacyOnlineServiceWithGameAppKey:(NSString *)gameAppKey
                                       channelCode:(NSString *)channelCode
                                             block:(void (^)(BOOL finish,NSError* error))block {
    if (YD1AgePrivacyManager.sharedInstance.yyCache == nil) {
        YD1AgePrivacyManager.sharedInstance.yyCache = [[Yodo1YYCache alloc]initWithPath:[YD1AgePrivacyManager cachedPrivacyPath]];
    }
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:URL_Privacy]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSMutableDictionary*parameters = [NSMutableDictionary dictionary];
    NSString* game_AppKey = gameAppKey;
    if (gameAppKey == nil) {
        YD1LOG(@"gameAppKey is nil!");
        return;
    }
    NSString* channel_Code = channelCode;
    if (channelCode == nil) {
        channelCode = Yodo1Tool.shared.paymentChannelCodeValue;
    }
    NSString* sdkVersion = [YD1AgePrivacyManager publishVersion];
    NSString* sdkType = [YD1AgePrivacyManager publishType];
    NSString* gameVersion = [YD1AgePrivacyManager appVersion];
    if (gameAppKey == nil) {
        gameVersion = @"";
    }
    NSString* currentTimestamp = [YD1AgePrivacyManager currentTimestamp];
    
    NSString* signString = [NSString stringWithFormat:@"%@%@%@yodo1",game_AppKey,channel_Code,currentTimestamp];
    NSString* sign = [YD1AgePrivacyManager md5StringWithString:signString];
    
    [parameters setObject:gameAppKey forKey:@"game_appkey"];
    [parameters setObject:channelCode forKey:@"channel_code"];
    [parameters setObject:gameVersion forKey:@"game_version"];
    [parameters setObject:sdkType forKey:@"sdk_type"];
    [parameters setObject:sdkVersion forKey:@"sdk_version"];
    [parameters setObject:currentTimestamp forKey:@"timestamp"];
    [parameters setObject:sign forKey:@"sign"];
    
    //    YD1LOG(@"parameters:%@",[YD1AgePrivacyManager stringWithJSONObject:parameters error:nil]);
    [manager POST:Sub_URL_Privacy parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString* response = [YD1AgePrivacyManager stringWithJSONObject:responseObject error:nil];
        if (response) {
            NSDictionary* respo = [YD1AgePrivacyManager JSONObjectWithString:response error:nil];
            if ([[respo allKeys]containsObject:@"error_code"]) {
                int error_code = [[respo objectForKey:@"error_code"]intValue];
                if (error_code == 0) {
                    if ([[respo allKeys]containsObject:@"data"]) {
                        NSDictionary* data = [respo objectForKey:@"data"];
                        //获取现在
                        NSString* currentLicenseVersion = nil;
                        PrivacyServiceInfo* info = [PrivacyServiceInfo yodo1_modelWithDictionary:data];
                        kOpenSwitch = info.open_switch;
                        kCurrentYearOld = info.child_age_limit;
                        for (LicenseInfo* li in info.license_info) {
                            if ([li.license_name isEqualToString:YD1_UserAgreementName]) {
                                if (li.license_version) {
                                    currentLicenseVersion = li.license_version;
                                }
                            }
                        }
                        NSDictionary* oldData = (NSDictionary*)[YD1AgePrivacyManager.sharedInstance.yyCache objectForKey:kPrivacyDataKey];
                        if (oldData) {
                            PrivacyServiceInfo* oldInfo = [PrivacyServiceInfo yodo1_modelWithDictionary:oldData];
                            for (LicenseInfo* li in oldInfo.license_info) {
                                if ([li.license_name isEqualToString:YD1_UserAgreementName]) {
                                    if (li.license_version && currentLicenseVersion != nil) {
                                        //线上和缓存不一样就标志可以更新
                                        if (![currentLicenseVersion isEqualToString:li.license_version]) {
                                            [YD1AgePrivacyManager.sharedInstance.yyCache setObject:[NSNumber numberWithBool:YES] forKey:@"License_Is_Need_Update"];
                                        }
                                    }
                                }
                            }
                        }
                        
                        if ([data count] >0) {
                            [YD1AgePrivacyManager.sharedInstance.yyCache setObject:data forKey:kPrivacyDataKey];
                            if (block) {
                                block(YES,nil);
                            }
                            return;
                        }else{
                            YD1LOG(@"Privacy of data is empty!");
                            if (block) {
                                NSError* error = [NSError errorWithDomain:@"com.yodo1.privacy" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Privacy of data is empty"}];
                                block(YES,error);
                            }
                            return;
                        }
                    }
                }
            }
        }
        if (block) {
            NSError* error = [NSError errorWithDomain:@"com.yodo1.privacy" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"other error!"}];
            block(YES,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            YD1LOG(@"error:%@",error.localizedDescription);
        }
        if (block) {
            block(NO,error);
        }
    }];
}

+ (void)getPrivacyOnlineService:(PrivacyServiceBlock)serviceBlock {
    if (YD1AgePrivacyManager.sharedInstance.yyCache == nil) {
        YD1AgePrivacyManager.sharedInstance.yyCache = [[Yodo1YYCache alloc]initWithPath:[YD1AgePrivacyManager cachedPrivacyPath]];
    }
    NSDictionary* data = (NSDictionary*)[YD1AgePrivacyManager.sharedInstance.yyCache objectForKey:kPrivacyDataKey];
    PrivacyServiceInfo* info = [PrivacyServiceInfo yodo1_modelWithDictionary:data];
    if (serviceBlock) {
        serviceBlock(info);
    }else{
        YD1LOG(@"serviceBlock is nil!");
    }
}

+ (NSString *)stringWithJSONObject:(id)obj error:(NSError**)error {
    if (obj) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSData* data = nil;
            @try {
                data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:error];
            }
            @catch (NSException* exception) {
                *error = [NSError errorWithDomain:[exception description] code:0 userInfo:nil];
                return nil;
            }
            @finally {
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

#ifdef __cplusplus

const char* UNITY3D_YODO1PRIVACY_METHOD     = "Yodo1U3dSDKCallBackResult";
static NSString* kYodo1PrivacyGameObject    = @"Yodo1Suit";//默认

extern "C" {

void Unity3dShowUserConsent(const char *SdkObjectName,const char* SdkMethodName)
{
    NSString* m_appKey = nil;
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        m_appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    }
    
    NSCAssert(m_appKey != nil, @"AppKey is not set!");
    NSString* m_gameObject = Yodo1CreateNSString(SdkObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    NSString* m_methodName = Yodo1CreateNSString(SdkMethodName);
    NSCAssert(m_methodName != nil, @"Unity3d methodName isn't set!");
    UIViewController* rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    if (rootViewController == nil) {
        rootViewController = [Yodo1Commons getRootViewController];
    }
    [YD1AgePrivacyManager dialogShowUserConsentWithGameAppKey:m_appKey
                                                  channelCode:Yodo1Tool.shared.paymentChannelCodeValue
                                               viewController:rootViewController
                                                        block:^(BOOL accept, BOOL child, int age) {
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
            UnitySendMessage([kYodo1PrivacyGameObject cStringUsingEncoding:NSUTF8StringEncoding],UNITY3D_YODO1PRIVACY_METHOD,
                             [msg cStringUsingEncoding:NSUTF8StringEncoding] );
        }
    }];
}
void Unity3dSelectLocalLanguage(const char *language)
{
    [YD1AgePrivacyManager selectLocalLanguage:Yodo1CreateNSString(language)];
}

void Unity3dDialogShowPrivacy(const char* gameObject)
{
    NSString* m_gameObject = Yodo1CreateNSString(gameObject);
    if (m_gameObject) {
        kYodo1PrivacyGameObject = m_gameObject;
    }
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    UIViewController* rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    if (rootViewController == nil) {
        rootViewController = [Yodo1Commons getRootViewController];
    }
    [YD1AgePrivacyManager dialogShowPrivacyViewcontroller:rootViewController
                                                    block:^(BOOL accept) {
        if (kYodo1PrivacyGameObject) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:8001] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithBool:accept] forKey:@"accept"];
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            NSString* jsonError = @"";
            if(parseJSONError){
                jsonError = @"Convert result to json failed!";
                [dict setObject:jsonError forKey:@"error"];
                msg =  [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            }
            UnitySendMessage([kYodo1PrivacyGameObject cStringUsingEncoding:NSUTF8StringEncoding],UNITY3D_YODO1PRIVACY_METHOD,
                             [msg cStringUsingEncoding:NSUTF8StringEncoding] );
        }
    }];
}

}

#endif
