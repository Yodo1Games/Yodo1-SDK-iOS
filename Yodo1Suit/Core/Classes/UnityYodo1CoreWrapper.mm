#import "UnityYodo1CoreWrapper.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Model.h"

#import "Yodo1Suit.h"

#ifdef YODO1_UCCENTER
#import "Yodo1PurchaseManager.h"
#endif

#ifdef __cplusplus

extern "C" {

void Unity3dSetLogEnable(BOOL enable)
{
    [Yodo1Suit setLogEnable:enable];
}

#pragma mark - Init Methods

void Unity3dInitWithAppKey(const char *appKey,const char* gameObject)
{
    NSString* m_appKey = Yodo1CreateNSString(appKey);
    NSCAssert(m_appKey != nil, @"AppKey 没有设置!");
        
    [Yodo1Suit initWithAppKey:m_appKey];
}

void UnityInitSDKWithConfig(const char* sdkConfigJson) {
    NSString* _sdkConfigJson = Yodo1CreateNSString(sdkConfigJson);
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
    return Yodo1MakeStringCopy([[Yodo1Suit getPrivacyPolicyUrl] cStringUsingEncoding:NSUTF8StringEncoding]);
}

char* UnityGetTermsOfServiceURL() {
    return Yodo1MakeStringCopy([[Yodo1Suit getTermsOfServiceUrl] cStringUsingEncoding:NSUTF8StringEncoding]);
}

#pragma mark - Online Config

char* UnityStringParams(const char* key,const char* defaultValue)
{
    NSString* _defaultValue = Yodo1CreateNSString(defaultValue);
    NSString* _key = Yodo1CreateNSString(key);
    NSString* param = [Yodo1Suit stringParamsConfigWithKey:_key defaultValue:_defaultValue];
    YD1LOG(@"defaultValue = %@, key = %@, param = %@", _defaultValue, _key, param);
    return Yodo1MakeStringCopy([param cStringUsingEncoding:NSUTF8StringEncoding]);
}

bool UnityBoolParams(const char* key,bool defaultValue)
{
    bool param = [Yodo1Suit boolParamsConfigWithKey:Yodo1CreateNSString(key) defaultValue:defaultValue];
    YD1LOG(@"defaultValue = %d, key = %@, param = %d", defaultValue, Yodo1CreateNSString(key), param);
    return param;
}

#pragma mark - Submit User

void UnitySubmitUser(const char* jsonUser)
{
    NSString* _jsonUser = Yodo1CreateNSString(jsonUser);
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
    NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
    NSString* ocMethodName = Yodo1CreateNSString(methodName);
    NSString* code = Yodo1CreateNSString(activationCode);

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

                    UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
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

                    UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                     [msg cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        });
    }];
}

#pragma mark - Other

char* UnityGetDeviceId() {
    const char* deviceId = [Yodo1Suit getDeviceId].UTF8String;
    YD1LOG(@"deviceId = %@", Yd1OpsTools.keychainDeviceId);
    return Yodo1MakeStringCopy(deviceId);
}

char* UnityGetSDKVersion() {
    const char* sdkVersion = [Yodo1Suit sdkVersion].UTF8String;
    return Yodo1MakeStringCopy(sdkVersion);
}

char* UnityUserId(){
    const char* userId = Yd1OpsTools.keychainUUID.UTF8String;
    YD1LOG(@"userId = %@", Yd1OpsTools.keychainUUID);
    return Yodo1MakeStringCopy(userId);
}

void UnityOpenWebPage(const char* url, const char* jsonparam) {
    NSString *_url = Yodo1CreateNSString(url);
    NSString *_jsonparam = Yodo1CreateNSString(jsonparam);
    
    YD1LOG(@"url = %@, jsonparam = %@", _url, _jsonparam);
    [Yodo1Suit openWebPage:_url paramter:_jsonparam];
}

char* UnityGetConfigParameter(const char* key) {
    return NULL;
}

char* UnityGetCountryCode() {
    NSString *countrycode = [Yodo1Suit getCountryCode];
    YD1LOG(@"countryCode = %@", countrycode);
    
    return Yodo1MakeStringCopy([countrycode cStringUsingEncoding:NSUTF8StringEncoding]);
}

}
#endif
