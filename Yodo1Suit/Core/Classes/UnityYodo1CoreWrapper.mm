#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Model.h"

#import "Yodo1Suit.h"

#ifdef YODO1_UCCENTER
#import "Yodo1PurchaseManager.h"
#endif

#import "Yodo1Alert.h"
#import "YD1AgePrivacyManager.h"
#import "Yodo1KeyInfo.h"

typedef enum {
    Unity_Result_Type_VerifyActivationCode = 7001,
    Unity_Result_Type_UserPrivateInfo = 8001,
}UnityResultType_Core;

#ifdef __cplusplus
extern "C" {
#endif

void Unity3dSetLogEnable(BOOL enable)
{
    [Yodo1Suit setLogEnable:enable];
}

#pragma mark - Init Methods

void Unity3dInitWithAppKey(const char *appKey,const char* gameObject)
{
    NSString* m_appKey = ConvertCharToNSString(appKey);
    NSCAssert(m_appKey != nil, @"AppKey 没有设置!");
        
    [Yodo1Suit initWithAppKey:m_appKey];
}

void UnityInitSDKWithConfig(const char* sdkConfigJson) {
    NSString* _sdkConfigJson = ConvertCharToNSString(sdkConfigJson);
    SDKConfig* yySDKConfig = [SDKConfig yodo1_modelWithJSON:_sdkConfigJson];
    [Yodo1Suit initWithConfig:yySDKConfig];
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

char* UnityGetPrivacyPolicyURL() {
    return ConvertNSStringToChar([Yodo1Suit getPrivacyPolicyUrl]);
}

char* UnityGetTermsOfServiceURL() {
    return ConvertNSStringToChar([Yodo1Suit getTermsOfServiceUrl]);
}

#pragma mark - Online Config

char* UnityStringParams(const char* key,const char* defaultValue)
{
    NSString* _defaultValue = ConvertCharToNSString(defaultValue);
    NSString* _key = ConvertCharToNSString(key);
    NSString* param = [Yodo1Suit stringParamsConfigWithKey:_key defaultValue:_defaultValue];
    YD1LOG(@"defaultValue = %@, key = %@, param = %@", _defaultValue, _key, param);
    return ConvertNSStringToChar(param);
}

bool UnityBoolParams(const char* key,bool defaultValue)
{
    bool param = [Yodo1Suit boolParamsConfigWithKey:ConvertCharToNSString(key) defaultValue:defaultValue];
    YD1LOG(@"defaultValue = %d, key = %@, param = %d", defaultValue, ConvertCharToNSString(key), param);
    return param;
}

#pragma mark - Submit User

void UnitySubmitUser(const char* jsonUser)
{
    NSString* _jsonUser = ConvertCharToNSString(jsonUser);
    NSDictionary* user = [Yodo1Commons JSONObjectWithString:_jsonUser error:nil];
    if (user) {
#ifdef YODO1_UCCENTER
        NSString* playerId = [user objectForKey:@"playerId"];
        NSString* nickName = [user objectForKey:@"nickName"];
        
        Yodo1PurchaseManager.shared.user.playerid = playerId;
        Yodo1PurchaseManager.shared.user.nickname = nickName;
        [Yd1OpsTools.cached setObject:Yodo1PurchaseManager.shared.user
                               forKey:@"yd1User"];
        YD1LOG(@"playerId:%@",playerId);
        YD1LOG(@"nickName:%@",nickName);
#endif
    } else {
        YD1LOG(@"user is not submit!");
    }
}

#pragma mark - 兑换码功能

/**
 *  激活码/优惠券
 */
void UnityVerifyActivationcode(const char* activationCode,const char* gameObjectName, const char* methodName)
{
    NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
    NSString* ocMethodName = ConvertCharToNSString(methodName);
    NSString* code = ConvertCharToNSString(activationCode);

    [Yodo1Suit verifyWithActivationCode:code callback:^(BOOL success, NSDictionary * _Nullable response, NSDictionary * _Nullable error) {
        YD1LOG(@"response=%@ error=%@", response, error);

        dispatch_async(dispatch_get_main_queue(), ^{
            if(ocGameObjName && ocMethodName) {
                if (success) {
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_VerifyActivationCode] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"errorCode"];
                    [dict setObject:@"success" forKey:@"errorMsg"];

                    if (response[@"reward"]) {
                        [dict setObject:response[@"reward"] forKey:@"reward"];
                    } else {
                        [dict setObject:@"" forKey:@"reward"];
                    }

                    if ([response[@"comment"] length] > 0) {
                        [dict setObject:response[@"comment"] forKey:@"rewardDes"];
                    } else {
                        [dict setObject:@"" forKey:@"rewardDes"];
                    }

                    NSError* parseJSONError = nil;
                    NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                    if(parseJSONError){
                        [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                        msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                    }

                    Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                } else {
                    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

                    [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_VerifyActivationCode] forKey:@"resulType"];
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                    int errorCode = [error[@"error_code"] intValue];
                    [dict setObject:[NSNumber numberWithInt:errorCode] forKey:@"errorCode"];
                    [dict setObject:error[@"error"] forKey:@"errorMsg"];
                    [dict setObject:@"" forKey:@"reward"];
                    [dict setObject:@"" forKey:@"rewardDes"];

                    NSError* parseJSONError = nil;
                    NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                    if(parseJSONError){
                        [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                        msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
                    }

                    Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        });
    }];
}

#pragma mark - Other

char* UnityGetDeviceId() {
    return ConvertNSStringToChar([Yodo1Suit getDeviceId]);
}

char* UnityGetSDKVersion() {
    return ConvertNSStringToChar([Yodo1Suit sdkVersion]);
}

char* UnityUserId(){
    return ConvertNSStringToChar(Yd1OpsTools.keychainUUID);
}

void UnityOpenWebPage(const char* url, const char* jsonparam) {
    NSString *_url = ConvertCharToNSString(url);
    NSString *_jsonparam = ConvertCharToNSString(jsonparam);
    
    YD1LOG(@"url = %@, jsonparam = %@", _url, _jsonparam);
    [Yodo1Suit openWebPage:_url paramter:_jsonparam];
}

char* UnityGetConfigParameter(const char* key) {
    return NULL;
}

char* UnityGetCountryCode() {
    NSString *countrycode = [Yodo1Suit getCountryCode];
    YD1LOG(@"countryCode = %@", countrycode);
    
    return ConvertNSStringToChar(countrycode);
}

char* UnityGetVersionName()
{
    NSString* version = [Yodo1Commons appVersion];
    return ConvertNSStringToChar(version);
}

void UnityShowAlert(const char* title,
                    const char* message,
                    const char* confirmButtonStr,
                    const char* cancelButtonStr,
                    const char* middleButtonStr,
                    const char* objName,
                    const char* callbackMethod)
{
    NSString * ocTitle = ConvertCharToNSString(title);
    NSString * ocMessage = ConvertCharToNSString(message);
    NSString * ocConfirmButtonStr = ConvertCharToNSString(confirmButtonStr);
    NSString * ocCancelButtonStr = ConvertCharToNSString(cancelButtonStr);
    NSString * ocMiddleButtonStr = ConvertCharToNSString(middleButtonStr);
    NSString * ocObjName = ConvertCharToNSString(objName);
    NSString * ocCallbackMethod = ConvertCharToNSString(callbackMethod);
    
    [[Yodo1Alert shareInstance] showAlertWithTitle:ocTitle message:ocMessage confirmButtonTitle:ocConfirmButtonStr cancelButtonTitle:ocCancelButtonStr middleButtonTitle:ocMiddleButtonStr callback:^(NSString *action) {
        if(ocObjName && ocCallbackMethod){
            const char* unityGameObjectName = [ocObjName UTF8String];
            const char* unityMethodName = [ocCallbackMethod UTF8String];
            const char* szIsConfirm =[action UTF8String];
            Yodo1UnitySendMessage(unityGameObjectName, unityMethodName, szIsConfirm);
        }
    }];
}

#pragma mark - Will deprecated

const char* UNITY3D_YODO1PRIVACY_METHOD     = "Yodo1U3dSDKCallBackResult";
static NSString* kYodo1PrivacyGameObject    = @"Yodo1Suit";//默认

void Unity3dShowUserConsent(const char *SdkObjectName,const char* SdkMethodName)
{
    NSString* m_appKey = nil;
    if ([[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"]) {
        m_appKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"GameKey"];
    }
    
    NSCAssert(m_appKey != nil, @"AppKey is not set!");
    NSString* m_gameObject = ConvertCharToNSString(SdkObjectName);
    NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
    NSString* m_methodName = ConvertCharToNSString(SdkMethodName);
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
            Yodo1UnitySendMessage([kYodo1PrivacyGameObject cStringUsingEncoding:NSUTF8StringEncoding],UNITY3D_YODO1PRIVACY_METHOD,
                             [msg cStringUsingEncoding:NSUTF8StringEncoding] );
        }
    }];
}

void Unity3dSelectLocalLanguage(const char *language)
{
    [YD1AgePrivacyManager selectLocalLanguage:ConvertCharToNSString(language)];
}

void Unity3dDialogShowPrivacy(const char* gameObject)
{
    NSString* m_gameObject = ConvertCharToNSString(gameObject);
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
            Yodo1UnitySendMessage([kYodo1PrivacyGameObject cStringUsingEncoding:NSUTF8StringEncoding],UNITY3D_YODO1PRIVACY_METHOD,
                             [msg cStringUsingEncoding:NSUTF8StringEncoding] );
        }
    }];
}

#ifdef __cplusplus
}
#endif
