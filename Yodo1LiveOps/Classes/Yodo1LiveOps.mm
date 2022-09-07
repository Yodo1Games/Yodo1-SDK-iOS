//
//  Yodo1LiveOps.m
//  Yodo1LiveOps
//
//  Created by yixian huang on 2017/7/24.
//

#import "Yodo1LiveOps.h"
#import <CoreLocation/CoreLocation.h>
#import "Yodo1AFNetworking.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"

#define Y_LIVE_OPS_PUBLISH_VERSION      @"1.0.0"
#define Y_LIVE_OPS_CHANNEL_ID           @"AppStore"

#define Y_LIVE_OPS_INIT_OBJECTNAME @"Y_LIVE_OPS_INIT_OBJECTNAME"
#define Y_LIVE_OPS_INIT_METHODNAME @"Y_LIVE_OPS_INIT_METHODNAME"

#define Y_LIVE_OPS_DEBUG_LOG            @"y_live_ops_debug_log"

#define Yodo1LOLOG(fmt, ...) NSLog((@"[Yodo1 LIVE OPS] %s [Line %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

NSString* const Y_LIVE_OPS_URL          = @"https://olc.yodo1api.com";
NSString* const Y_LIVE_OPS_TEST_URL     = @"https://api-olconfig-test.yodo1.com";
NSString* const Y_LIVE_OPS_SUB_URL      = @"/config/getDataV2";
NSString* const Y_LIVE_OPS_STATIC_URL   = @"https://ocd.yodo1api.com/configfiles/";

NSString* const Y_LIVE_OPS_CACHE_DATA_KEY        = @"yodo1OPCacheDataKey";
NSString* const Y_LIVE_OPS_CACHE_IDENTIFER_KEY   = @"yodo1OPCacheIdentiferKey";
NSString* const Y_LIVE_OPS_CACHE_VERIFY_KEY      = @"yodo1OPCacheVerifyKey";

NSString* const Y_LIVE_OPS_CACHE_LOCATION_IDENTIFER_KEY       = @"yodo1OPCacheLocationIdentiferKey";
NSString* const Y_LIVE_OPS_CACHE_LOCATION_IDENTIFER_TT_KEY    = @"yodo1OPCacheLocationIdentiferTTLKey";

///第一次更新在线参数下来的时间戳
NSString* const Y_LIVE_OPS_FIRST_TIMESTAMP_KEY  = @"yodo1FirstTimestampKey";

NSString* const Y_LIVE_OPS_DATA_IDENTIFER       = @"data_identifer";

/// 本地地理标识，由本接口返回
NSString* const Y_LIVE_OPS_LOCATION_IDENTIFER   = @"location_identifer";
///获取的手机当前经度，保留小数点后两位
NSString* const Y_LIVE_OPS_LOCATION_LNG         = @"location_lng";
///获取的手机当前纬度，保留小数点后两位
NSString* const Y_LIVE_OPS_LOCATION_LAT         = @"location_lat";

/// true/false
NSString* const Y_LIVE_OPS_TEST_MODEL           = @"is_test_model";
/// true/false
NSString* const Y_LIVE_OPS_DEBUG_MODEL          = @"is_debug_model";
/// PA/MAS
NSString* const Y_LIVE_OPS_DEVICE_SOURCE        = @"device_source";
NSString* const Y_LIVE_OPS_TEST_LIST            = @"test_list";
NSString* const Y_LIVE_OPS_AD_LIST              = @"ad_list";

///判断是否包含指定的广告测试渠道
NSString* const Y_LIVE_OPS_HAVE_AD_LIST         = @"HaveAdList";

///新的地理标识有效时长
NSString* const Y_LIVE_OPS_LOCATION_IDENTIFER_TTL  = @"location_identifer_ttl";

///上报神策统计的字段
NSString* const Y_LIVE_OPS_REPORT_FIELDS           = @"report_fields";

NSString* const Y_LIVE_OPS_ACTIVATION_CODE         = @"https://activationcode.yodo1api.com/activationcode/activateWithReward";

//测试地址
//http://activationcode-test.yodo1api.com:8805
//https://api-olconfig-test.yodo1.com

typedef enum {
    Y_LIVE_OPS_ErrorCodeTypeSuccess = 0,       //更新成功
    Y_LIVE_OPS_ErrorCodeTypeDataUpdated = 10,  //本地服务已是最新，无需更新
    Y_LIVE_OPS_ErrorCodeTypeDataFail           //更新有异常
}Y_LIVE_OPS_ErrorCodeType;

@interface Yodo1LiveOps ()<CLLocationManagerDelegate> {
    
    __block NSDate* backgroundDate;
    BOOL bInitOPData;
    NSString* _appKey;
    NSString* _channel;
    NSString* _jsonData;
    BOOL bInited;
    BOOL isDebugLog;
}
@property (nonatomic,strong)NSString* latitude;
@property (nonatomic,strong)NSString* longitude;
@property (nonatomic,strong)CLLocationManager *locationManager;

- (void)startLocation;

@end

@implementation Yodo1LiveOps

+ (instancetype)sharedInstance {
    
    return [Yodo1Base.shared cc_registerSharedInstance:self block:^{
        ///初始化
        Yodo1LOLOG(@"%s",__PRETTY_FUNCTION__);
    }];
}

- (NSString *)appKey {
    if (_appKey) {
        return _appKey;
    }
    return @"";
}

- (NSString *)channelId {
    if (_channel) {
        return _channel;
    }
    return @"";
}

- (NSString *)getSdkVersion {
    return Y_LIVE_OPS_PUBLISH_VERSION;
}

- (void)setDebugLog:(BOOL)debugLog {
    [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:debugLog] forKey:Y_LIVE_OPS_DEBUG_LOG];
}

- (void)initWithAppKey:(NSString *)appKey {
    if (bInited) {
        return;
    }
    
    isDebugLog = (BOOL)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_DEBUG_LOG];
    
    bInited = true;
    _appKey = appKey;
    _channel = Y_LIVE_OPS_CHANNEL_ID;
    bInitOPData = true;
    [Yodo1LiveOps.sharedInstance startLocation];
    [Yodo1LiveOps.sharedInstance fetchOnlineData];
}

- (NSString *)stringValueWithKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSDictionary * params = (NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_DATA_KEY];
    if ([[params allKeys]containsObject:key]) {
        id value = [params objectForKey:key];
        if ([NSJSONSerialization isValidJSONObject:value]) {
            NSString* jsonString = [Yd1OpsTools stringWithJSONObject:value error:nil];
            if (jsonString) {
                return jsonString;
            }
        }
        return (NSString*)value;
    }
    return defaultValue;
}

- (BOOL)booleanValueWithKey:(NSString *)key
             defaultValue:(BOOL)defaultValue {
    NSString* value = [Yodo1LiveOps.sharedInstance stringValueWithKey:key
                                                        defaultValue:@""];
    if ([value isKindOfClass:[NSString class]]) {
        if ([[value lowercaseString]isEqualToString:@"on"]) {
            return YES;
        }else if([[value lowercaseString]isEqualToString:@"off"]){
            return NO;
        }
    }
    return defaultValue;
}

- (int)intValueWithKey:(NSString *)key defaultValue:(int)defaultValue {
    NSDictionary * params = (NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_DATA_KEY];
    if ([[params allKeys]containsObject:key]) {
        id value = [params objectForKey:key];
        if ([NSJSONSerialization isValidJSONObject:value]) {
            NSString* jsonString = [Yd1OpsTools stringWithJSONObject:value error:nil];
            if (jsonString) {
                return [jsonString intValue];
            }
        }
        return [value intValue];
    }
    return defaultValue;
}

- (float)floatValueWithKey:(NSString *)key defaultValue:(float)defaultValue {
    NSDictionary * params = (NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_DATA_KEY];
    if ([[params allKeys]containsObject:key]) {
        id value = [params objectForKey:key];
        if ([NSJSONSerialization isValidJSONObject:value]) {
            NSString* jsonString = [Yd1OpsTools stringWithJSONObject:value error:nil];
            if (jsonString) {
                return [jsonString floatValue];
            }
        }
        return [value floatValue];
    }
    return defaultValue;
}

- (double)doubleValueWithKey:(NSString *)key
                defaultValue:(double)defaultValue {
    NSDictionary * params = (NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_DATA_KEY];
    if ([[params allKeys]containsObject:key]) {
        id value = [params objectForKey:key];
        if ([NSJSONSerialization isValidJSONObject:value]) {
            NSString* jsonString = [Yd1OpsTools stringWithJSONObject:value error:nil];
            if (jsonString) {
                return [jsonString doubleValue];
            }
        }
        return [value doubleValue];
    }
    return defaultValue;
}

/**
 * 激活码/优惠券
 */
- (void)verifyWithActivationCode:(NSString *)activationCode
                    callback:(void (^)(BOOL success,NSDictionary* _Nullable response,NSDictionary* _Nullable error))callback {
    
    if (!activationCode || activationCode.length < 1) {
        callback(false,@{}, @{@"error":@"code is empty!"});
        return;
    }
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]init];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSString *channel_code = @"appstore";
    
    NSString *urlString = [NSString stringWithFormat:@"%@?game_appkey=%@&channel_code=%@&activation_code=%@&dev_id=%@", Y_LIVE_OPS_ACTIVATION_CODE, self.appKey, channel_code, activationCode, Yd1OpsTools.keychainDeviceId];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = [Yd1OpsTools JSONObjectWithObject:responseObject];
        int errorCode = -1;
        NSString* error = @"";
        if ([[response allKeys]containsObject:Yd1OpsTools.errorCode]) {
            errorCode = [[response objectForKey:Yd1OpsTools.errorCode] intValue];
        }
        if ([[response allKeys]containsObject:Yd1OpsTools.error]) {
            error = [response objectForKey:Yd1OpsTools.error];
        }
        if (errorCode == 0) {
            callback(true,response,NULL);
        } else {
            callback(false,@{},response);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Yodo1LOLOG(@"%@",error);
        callback(false,@{},@{@"error": error.localizedDescription});
    }];
    
}

- (void)startLocation {
    int status = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled] && status >= 3) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        [_locationManager requestAlwaysAuthorization];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark- data
- (NSDictionary*)parameterDic {
    NSString* dataIdentifer = @"0";
    NSString* identifer = (NSString*)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_IDENTIFER_KEY];
    if (identifer) {
        dataIdentifer = identifer;
    }
    NSDate* firstDate  = (NSDate*)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_FIRST_TIMESTAMP_KEY];
    if (firstDate) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:firstDate];
        NSString* ttl = (NSString*)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_LOCATION_IDENTIFER_TT_KEY];
        if (ttl) {
            double ttlInterval = [ttl doubleValue] *60*60;
            if (time > ttlInterval) {///超过24小时，删除本地地理标识和存储时间戳
                [Yd1OpsTools.cached setObject:nil forKey:Y_LIVE_OPS_CACHE_LOCATION_IDENTIFER_KEY];
                [Yd1OpsTools.cached setObject:nil forKey:Y_LIVE_OPS_FIRST_TIMESTAMP_KEY];
            }
        }
    }
    
    NSString* locationIdentifer = (NSString*)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_LOCATION_IDENTIFER_KEY];
    if (locationIdentifer == nil) {
        locationIdentifer = @"";
    }
    
    NSString* location_lng = self.longitude;
    if (location_lng == nil) {
        location_lng = @"";
    }
    
    NSString* location_lat = self.latitude;
    if (location_lat == nil) {
        location_lat = @"";
    }
    NSString* parameterStr = (NSString *)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_VERIFY_KEY];
    NSDictionary* parameter = [Yd1OpsTools JSONObjectWithString:parameterStr error:nil];
    if (parameter) {
        NSString* mAppKey = [parameter objectForKey:Yd1OpsTools.gameAppKey];
        NSString* mChannelId = [parameter objectForKey:Yd1OpsTools.channelId];
        NSString* mVersion = [parameter objectForKey:Yd1OpsTools.gameVersion];
        if ([mAppKey isEqualToString:_appKey] &&
            [mChannelId isEqualToString:_channel] &&
            [mVersion isEqualToString:Yd1OpsTools.appVersion]) {
            
        }else{
            dataIdentifer = @"0";
        }
    }
    NSString* timestamp = [Yd1OpsTools nowTimeTimestamp];
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"%@%@%@%@yodo1",self.appKey,Yd1OpsTools. appVersion,_channel,timestamp]];
    
    NSDictionary* parameters = @{Yd1OpsTools.gameAppKey:_appKey ,
                                 Yd1OpsTools.channelId:_channel,
                                 Yd1OpsTools.deviceId:Yd1OpsTools.keychainDeviceId,
                                 Yd1OpsTools.gameVersion:Yd1OpsTools.appVersion,
                                 Yd1OpsTools.sdkVersion:Y_LIVE_OPS_PUBLISH_VERSION,
                                 Y_LIVE_OPS_DATA_IDENTIFER:dataIdentifer,
                                 Y_LIVE_OPS_LOCATION_IDENTIFER:locationIdentifer,
                                 Y_LIVE_OPS_LOCATION_LNG:location_lng,
                                 Y_LIVE_OPS_LOCATION_LAT:location_lat,
                                 Yd1OpsTools.timeStamp:timestamp,
                                 Yd1OpsTools.sign:sign
    };
    ///save appkey,version,channelId
    NSString* parametersStr = [Yd1OpsTools stringWithJSONObject:parameters error:nil];
    [Yd1OpsTools.cached setObject:parametersStr forKey:Y_LIVE_OPS_CACHE_VERIFY_KEY];
    return parameters;
}

- (void)fetchStaticData {
    NSString* fileName = [[Yd1OpsTools signMd5String:[NSString stringWithFormat:@"%@",self.appKey]]uppercaseString];
    NSString* staticDataFileName = [NSString stringWithFormat:@"%@.json",fileName];
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:Y_LIVE_OPS_STATIC_URL]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:staticDataFileName parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self saveOnlineConfig:responseObject isStaticData:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Yodo1LOLOG(@"%@",error);
        int code = -1;
        if (error) {
            code = (int)error.code;
        }
    }];
    
}

- (void)saveOnlineConfig:(id)responseObject isStaticData:(BOOL)isStaticData {
    NSString* response = [Yd1OpsTools stringWithJSONObject:responseObject error:nil];
    
    if (isDebugLog) {
        Yodo1LOLOG(@"response:%@",response);
    }
    
    if (responseObject) {
        
        NSString* m_gameObject = (NSString *)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_INIT_OBJECTNAME];
        NSString* m_methodName = (NSString *)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_INIT_METHODNAME];
        
        int code = [responseObject[@"error_code"] intValue];
        
        if (code == 10 || code == 0) {
            [self.delegate getLiveOpsInitSuccess:0];
            
            if (m_gameObject.length > 0 && m_methodName.length > 0) {
                NSString* msg = [Yodo1Commons stringWithJSONObject:@{@"error_code": [NSNumber numberWithInt:code]} error:nil];
                UnitySendMessage([m_gameObject cStringUsingEncoding:NSUTF8StringEncoding],
                                 [m_methodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            
        } else {
            [self.delegate getLiveOpsInitSuccess:code];
        }
            
    }

    if (response) {
        ///开屏广告需要用到这个数值，因为开屏广告有一个Platform_SplashAdShowTime参数控制，再第几次获取onlineConfig后才能开始展示开屏广告
        ///当onlineConfig有更新时需要重置这个值
        ///主要是开屏广告是基于onlineConfig的，为了减少网络延迟，尽量使用本地缓存的onlineConfig数据
        NSInteger updateCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"onlineConfigUpdateCount"];
        updateCount++;
        [[NSUserDefaults standardUserDefaults] setInteger:updateCount forKey:@"onlineConfigUpdateCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDictionary* dic = [Yd1OpsTools JSONObjectWithString:response error:nil];
        if ([[dic allKeys]containsObject:Yd1OpsTools.errorCode]) {
            int error_code = [[dic objectForKey:Yd1OpsTools.errorCode]intValue];            
            if (error_code == Y_LIVE_OPS_ErrorCodeTypeSuccess) {
                ///保存data
                if ([[dic allKeys]containsObject:Yd1OpsTools.data]) {
                    NSDictionary* data = [dic objectForKey:Yd1OpsTools.data];
                    if ([data count] >0) {
                        [Yd1OpsTools.cached setObject:data forKey:Y_LIVE_OPS_CACHE_DATA_KEY];
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"onlineConfigUpdateCount"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }else{
                        if (isDebugLog) {
                            Yodo1LOLOG(@"data is empty");
                        }
                    }
                }
                ///保存identifer
                NSString* dataIdentifer = [dic objectForKey:Y_LIVE_OPS_DATA_IDENTIFER];
                if (dataIdentifer) {
                    [Yd1OpsTools.cached setObject:dataIdentifer forKey:Y_LIVE_OPS_CACHE_IDENTIFER_KEY];
                }
                
                ///保存locationIdentifer
                if ([[dic allKeys]containsObject:Y_LIVE_OPS_LOCATION_IDENTIFER]) {
                    NSString* mLocationIdentifer = [dic objectForKey:Y_LIVE_OPS_LOCATION_IDENTIFER];
                    if (mLocationIdentifer) {
                        [Yd1OpsTools.cached setObject:mLocationIdentifer forKey:Y_LIVE_OPS_CACHE_LOCATION_IDENTIFER_KEY];
                    }
                }
                
                ///保存新的地理标识有效时长
                if ([[dic allKeys]containsObject:Y_LIVE_OPS_LOCATION_IDENTIFER_TTL]) {
                    NSString* locIdentiferTTL = [dic objectForKey:Y_LIVE_OPS_LOCATION_IDENTIFER_TTL];
                    if (locIdentiferTTL) {
                        [Yd1OpsTools.cached setObject:locIdentiferTTL forKey:Y_LIVE_OPS_CACHE_LOCATION_IDENTIFER_TT_KEY];
                    }
                }
                
                ///保存一个时间戳在本地
                NSDate* firstDate  = (NSDate*)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_FIRST_TIMESTAMP_KEY];
                if (!firstDate) {
                    [Yd1OpsTools.cached setObject:[NSDate date] forKey:Y_LIVE_OPS_FIRST_TIMESTAMP_KEY];
                }
                
                ///保存是否是测试设备标志
                [Yd1OpsTools.cached setObject:(dic[Y_LIVE_OPS_TEST_MODEL] ? : @(NO)) forKey:Y_LIVE_OPS_TEST_MODEL];
                ///保存是否是Debug模式
                [Yd1OpsTools.cached setObject:(dic[Y_LIVE_OPS_DEBUG_MODEL] ? : @(NO)) forKey:Y_LIVE_OPS_DEBUG_MODEL];
                ///kDeviceSource测试设备来源
                [Yd1OpsTools.cached setObject:(dic[Y_LIVE_OPS_DEVICE_SOURCE] ? : @"") forKey:Y_LIVE_OPS_DEVICE_SOURCE];
                ///保存是否有指定测试广告渠道
                BOOL isHaveAdList = false;
                if ([[dic allKeys]containsObject:Y_LIVE_OPS_TEST_LIST]) {
                    NSDictionary* testList = [dic objectForKey:Y_LIVE_OPS_TEST_LIST];
                    if (testList && [[testList allKeys]containsObject:Y_LIVE_OPS_AD_LIST]) {
                        NSDictionary* adList = [testList objectForKey:Y_LIVE_OPS_AD_LIST];
                        if (adList && [adList count] > 0) {
                            isHaveAdList = true;
                        }
                    }
                }
                [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:isHaveAdList] forKey:Y_LIVE_OPS_HAVE_AD_LIST];
                
                [Yd1OpsTools.cached setObject:(dic[Y_LIVE_OPS_REPORT_FIELDS] ? : @[]) forKey:Y_LIVE_OPS_REPORT_FIELDS];
            } else {//error_code 10或3
                if ([[dic allKeys]containsObject:Yd1OpsTools.error]) {
                    if (isDebugLog) {
                        Yodo1LOLOG(@"%@",(NSString*)[dic objectForKey:Yd1OpsTools.error]);
                    }
                }
                if (error_code == Y_LIVE_OPS_ErrorCodeTypeDataUpdated) {
                    
                }
                ///本地identifer是否存在
                NSString* identifer = (NSString *)[Yd1OpsTools.cached objectForKey:Y_LIVE_OPS_CACHE_IDENTIFER_KEY];
                if ([identifer length] >0) {
                    if (isDebugLog) {
                        Yodo1LOLOG(@"identifer exists:%@",identifer);
                    }
                }else{
                    if (!isStaticData) {
                        [self fetchStaticData];
                    }
                }
            }
        }
    }
    ///保存一个时间点
    self->backgroundDate = [NSDate date];
}

- (void)fetchOnlineData {
    NSString * m_online_config = [NSUserDefaults.standardUserDefaults stringForKey:@"demoTestOnlineConfig"];
    BOOL isDemoTestOnlineConfig = [m_online_config isEqualToString:@"develop"];
    NSString * baseurl = isDemoTestOnlineConfig ? Y_LIVE_OPS_TEST_URL : Y_LIVE_OPS_URL;
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseurl]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSDictionary* parameters = [self parameterDic];
    [manager POST:Y_LIVE_OPS_SUB_URL parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self saveOnlineConfig:responseObject isStaticData:NO];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Yodo1LOLOG(@"%@",error.localizedDescription);
        [self fetchStaticData];
    }];
}

#pragma mark- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        Yodo1LOLOG(@"Access is denied.");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        Yodo1LOLOG(@"Unable to get location information.");
    }
    if ([error code] == kCLErrorGeocodeCanceled) {
        Yodo1LOLOG(@"Cancel authorization.");
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    CLLocationCoordinate2D coor = currentLocation.coordinate;
    _latitude = [NSString stringWithFormat:@"%.2f",coor.latitude];
    _longitude = [NSString stringWithFormat:@"%.2f",coor.longitude];
    [manager stopUpdatingLocation];
}

#ifdef __cplusplus

extern "C" {
    
    void UnityLiveOpsInitialize(const char* gameKey, const char *SdkObjectName,const char* SdkMethodName) {
        
        NSString* m_gameObject = Yodo1CreateNSString(SdkObjectName);
        NSCAssert(m_gameObject != nil, @"Unity3d gameObject isn't set!");
        NSString* m_methodName = Yodo1CreateNSString(SdkMethodName);
        NSCAssert(m_methodName != nil, @"Unity3d methodName isn't set!");
        
        [Yd1OpsTools.cached setObject:m_gameObject forKey:Y_LIVE_OPS_INIT_OBJECTNAME];
        [Yd1OpsTools.cached setObject:m_methodName forKey:Y_LIVE_OPS_INIT_METHODNAME];
        
        NSString* _gameKey = Yodo1CreateNSString(gameKey);
        [Yodo1LiveOps.sharedInstance initWithAppKey:_gameKey];
    }
    
    char* UnityLiveOpsStringValue(const char* key, const char *defaultValue) {
        
        NSString *param = [Yodo1LiveOps.sharedInstance stringValueWithKey:Yodo1CreateNSString(key) defaultValue:Yodo1CreateNSString(defaultValue)];
        return Yodo1MakeStringCopy([param cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    bool UnityLiveOpsBooleanValue(const char* key, bool defaultValue) {
        
        bool param = [Yodo1LiveOps.sharedInstance booleanValueWithKey:Yodo1CreateNSString(key) defaultValue:defaultValue];
        return param;
    }
    
    int UnityLiveOpsIntValue(const char* key, int defaultValue) {
        
        int param = [Yodo1LiveOps.sharedInstance intValueWithKey:Yodo1CreateNSString(key) defaultValue:defaultValue];
        return param;
    }
    
    float UnityLiveOpsFloatValue(const char* key, float defaultValue) {
        
        float param = [Yodo1LiveOps.sharedInstance floatValueWithKey:Yodo1CreateNSString(key) defaultValue:defaultValue];
        return param;
    }
    
    double UnityLiveOpsDoubleValue(const char* key, double defaultValue) {
        
        double param = [Yodo1LiveOps.sharedInstance doubleValueWithKey:Yodo1CreateNSString(key) defaultValue:defaultValue];
        return param;
    }
    
    char* UnityLiveOpsGetSdkVersion() {
        const char* sdkVersion = Y_LIVE_OPS_PUBLISH_VERSION.UTF8String;
        return Yodo1MakeStringCopy(sdkVersion);
    }
    
    void UnityLiveOpsVerifyActivationCode(const char* activationCode, const char* gameObjectName, const char* methodName) {
        
        NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
        NSString* ocMethodName = Yodo1CreateNSString(methodName);
        
        NSString *_code = Yodo1CreateNSString(activationCode);
        
        [Yodo1LiveOps.sharedInstance verifyWithActivationCode:_code callback:^(BOOL success, NSDictionary * _Nullable response, NSDictionary * _Nullable error) {
            Yodo1LOLOG(@"response=%@ error=%@", response, error);
            
            if (success) {
                if (ocGameObjName && ocMethodName) {
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:response];
                    
                    [dict setObject:[NSNumber numberWithBool:success] forKey:@"resulType"];
                    
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
            } else {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:error];
                [dict setObject:[NSNumber numberWithBool:success] forKey:@"resulType"];
                
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
        }];
    }
    
    void UnityLiveOpsSetDebugLog(bool debugLog) {
        [Yodo1LiveOps.sharedInstance setDebugLog:debugLog];
    }
}
#endif

@end
