//
//  Yd1OnlineParameter.m
//  Yd1OnlineParameter
//
//  Created by yixian huang on 2017/7/24.
//

#import "Yd1OnlineParameter.h"
#import <CoreLocation/CoreLocation.h>
#import "Yodo1AFNetworking.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Secret.h"

NSString* const kOnlineParameterUrl         = @"https://olc.yodo1api.com";
NSString* const kTestOnlineParameterUrl     = @"https://api-olconfig-test.yodo1.com";

NSString* const kOnlineParameterSubUrl      = @"/config/getDataV2";
NSString* const kStaticOnlineParameterUrl   = @"https://ocd.yodo1api.com/configfiles/";

NSString* const kRewardGameParameterUrl     = @"https://tyche-api.yodo1.com";
NSString* const kRewardGameParameterSubUrl  = @"/api/activity/config";

NSString* const kYodo1OPCacheDataKey        = @"yodo1OPCacheDataKey";
NSString* const kYodo1OPCacheIdentiferKey   = @"yodo1OPCacheIdentiferKey";
NSString* const kYodo1OPCacheVerifyKey      = @"yodo1OPCacheVerifyKey";
NSString* const kYodo1OPCacheRewardGameKey  = @"yodo1OPCacheRewardGameKey";

NSString* const kYodo1OPCacheLocationIdentiferKey       = @"yodo1OPCacheLocationIdentiferKey";
NSString* const kYodo1OPCacheLocationIdentiferTTLKey    = @"yodo1OPCacheLocationIdentiferTTLKey";

///第一次更新在线参数下来的时间戳
NSString* const kYodo1FirstTimestampKey = @"yodo1FirstTimestampKey";

NSString* const kYodo1LongitudeKey      = @"Yodo1LongitudeKey";
NSString* const kYodo1latitudeKey       = @"Yodo1latitudeKey";

NSString* const kYodo1DataIdentifer = @"data_identifer";

/// 本地地理标识，由本接口返回
NSString* const kYodo1LocationIdentifer  = @"location_identifer";
///获取的手机当前经度，保留小数点后两位
NSString* const kYodo1LocationLNG        = @"location_lng";
///获取的手机当前纬度，保留小数点后两位
NSString* const kYodo1LocationLAT        = @"location_lat";

/// true/false
NSString* const kIsTestModel    = @"is_test_model";
/// true/false
NSString* const kIsDebugModel    = @"is_debug_model";
/// PA/MAS
NSString* const kDeviceSource   = @"device_source";
NSString* const kTestList       = @"test_list";
NSString* const kAdList         = @"ad_list";

///判断是否包含指定的广告测试渠道
NSString* const kHaveAdList     = @"HaveAdList";

///新的地理标识有效时长
NSString* const kYodo1LocationIdentiferTTL  = @"location_identifer_ttl";

///更新config的时间间隔
NSString* const kYodo1UpdateInterval     = @"Platform_Online_UploadInterval";
NSString* const kYodo1OnlineConfigFinishedNotification = @"com.yodo1.kYodo1OnlineConfigFinished";
///上报神策统计的字段
NSString* const kReportFields                    = @"report_fields";

typedef enum {
    ErrorCodeTypeSuccess = 0,       //更新成功
    ErrorCodeTypeDataUpdated = 10,  //本地服务已是最新，无需更新
    ErrorCodeTypeDataFail           //更新有异常
}ErrorCodeType;

@interface Yd1OnlineParameter ()<CLLocationManagerDelegate> {
    
    __block NSDate* backgroundDate;
    BOOL bInitOPData;
    NSString* _appKey;
    NSString* _channel;
    NSString* _jsonData;
    BOOL bInited;
}
@property (nonatomic,strong)NSString* latitude;
@property (nonatomic,strong)NSString* longitude;
@property (nonatomic,strong)CLLocationManager *locationManager;
@property (nonatomic,strong)NSMutableArray<OPCachedCompletionHandler>* cachedCallbacks;
@property (nonatomic,strong)NSMutableDictionary* channelControls;
@property (nonatomic,strong)NSMutableDictionary* channelAppKeys;

- (void)startLocation;

- (id)adsConfigKey:(NSString *)key;

///ads control
- (NSArray *)adsControlType:(Yd1AdsConfigType)type;

///ads config
- (NSDictionary *)adsConfigAppKeysType:(Yd1AdsConfigType)type;

- (void)configAppKeys:(NSDictionary*)config;

- (NSString *)valueWithPlatform:(NSArray *)config
                   withPlatform:(NSString *)platform
                       typeName:(NSString *)typeName;

- (void)configControlsType:(Yd1AdsConfigType)type;


@end

@implementation Yd1OnlineParameter

+ (instancetype)shared {
    return [Yodo1Base.shared cc_registerSharedInstance:self block:^{
        ///初始化
        YD1LOG(@"%s",__PRETTY_FUNCTION__);
        Yd1OnlineParameter.shared.cachedCallbacks = [NSMutableArray array];
    }];
}

- (void)cachedCompletionHandler:(OPCachedCompletionHandler)handler {
    if (handler) {
        [self.cachedCallbacks addObject:[handler copy]];
    }
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

- (void)initWithAppKey:(NSString *)kAppKey
             channelId:(NSString *)kChannel {
    if (bInited) {
        return;
    }
    bInited = true;
    _appKey = kAppKey;
    _channel = kChannel;
    bInitOPData = true;
    [Yd1OnlineParameter.shared startLocation];
    [Yd1OnlineParameter.shared fetchOnlineData];
    [Yd1OnlineParameter.shared fetchRewardGameConfig];
}

- (NSString *)stringConfigWithKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSDictionary * params = (NSDictionary *)[Yd1OpsTools.cached objectForKey:kYodo1OPCacheDataKey];
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
    return @"";
}

- (BOOL)boolConfigWithKey:(NSString *)key
             defaultValue:(BOOL)defaultValue {
    NSString* value = [Yd1OnlineParameter.shared stringConfigWithKey:key
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

- (BOOL)bFromPA {
    NSString* deviceString = (NSString*)[Yd1OpsTools.cached objectForKey:kDeviceSource];
    if (deviceString && [kDeviceSource isKindOfClass:[NSString class]]
        && [deviceString isEqualToString:@"PA"]) {
        return YES;
    }
    return NO;
}

- (BOOL)bFromMAS {
    NSString* deviceString = (NSString*)[Yd1OpsTools.cached objectForKey:kDeviceSource];
    if (deviceString && [kDeviceSource isKindOfClass:[NSString class]]
        && [deviceString isEqualToString:@"MAS"]) {
        return YES;
    }
    return NO;
}

- (BOOL)bTestDevice {
    return [(NSNumber*)[Yd1OpsTools.cached objectForKey:kIsTestModel] boolValue];
}

- (BOOL)bDebugModel {
    return [(NSNumber *)[Yd1OpsTools.cached objectForKey:kIsDebugModel] boolValue];
}

- (BOOL)bAdListEmpty {
    return [(NSNumber*)[Yd1OpsTools.cached objectForKey:kHaveAdList] boolValue];
}

#pragma mark- ads config appkeys

- (id)adsConfigKey:(NSString *)key {
    NSString * jsonString = [self stringConfigWithKey:key defaultValue:@""];
    id jsonArray = [Yd1OpsTools JSONObjectWithString:jsonString error:nil];
    return jsonArray;
}

- (NSArray *)adsControlType:(Yd1AdsConfigType)type {
    id config = nil;
    switch (type) {
        case Yd1AdsConfigTypeBanner:
            config = [self adsConfigKey:@"Platform_BannerAdControl"];
            break;
        case Yd1AdsConfigTypeInterstitial:
            config = [self adsConfigKey:@"Platform_InterstitialAdControl"];
            break;
        case Yd1AdsConfigTypeVideo:
            config = [self adsConfigKey:@"Platform_VideoAdControl"];
            break;
    }
    if (config) {
        return (NSArray*)config;
    }
    return @[];
}

- (NSDictionary *)adsConfigAppKeysType:(Yd1AdsConfigType)type {
    id config = nil;
    switch (type) {
        case Yd1AdsConfigTypeBanner:
            config = (NSDictionary*)[self adsConfigKey:@"Platform_BannerAdConfig"];
            break;
        case Yd1AdsConfigTypeInterstitial:
            config = [self adsConfigKey:@"Platform_InterstitialAdConfig"];
            break;
        case Yd1AdsConfigTypeVideo:
            config = [self adsConfigKey:@"Platform_VideoAdConfig"];
            break;
    }
    if (config) {
        return (NSDictionary*)config;
    }
    return @{};
}

- (BOOL)eableAdsType:(Yd1AdsConfigType)type {
    switch (type) {
        case Yd1AdsConfigTypeBanner:
            return [self boolConfigWithKey:@"Platform_BannerAdMasterSwitch" defaultValue:NO];
        case Yd1AdsConfigTypeInterstitial:
            return [self boolConfigWithKey:@"Platform_InterstitialAdMasterSwitch" defaultValue:NO];
        case Yd1AdsConfigTypeVideo:
            return [self boolConfigWithKey:@"Platform_VideoAdMasterSwitch" defaultValue:NO];
    }
    return NO;
}

- (NSString *)adsAppKeyPlatform:(NSString *)platform {
    if (self.channelAppKeys == nil) {
        self.channelAppKeys = [NSMutableDictionary dictionary];
    }
    if ([self.channelAppKeys count] < 1) {
        [self configAppKeys:[self adsConfigAppKeysType:Yd1AdsConfigTypeBanner]];
        [self configAppKeys:[self adsConfigAppKeysType:Yd1AdsConfigTypeInterstitial]];
        [self configAppKeys:[self adsConfigAppKeysType:Yd1AdsConfigTypeVideo]];
    }
    if ([[self.channelAppKeys allKeys]containsObject:platform]) {
        return [self.channelAppKeys objectForKey:platform];
    }
    return @"";
}

- (NSString *)ratioPlatform:(NSString *)platform
                       type:(Yd1AdsConfigType)type {
    NSString * ratio = [self valueWithPlatform:[self adsControlType:type]
                                  withPlatform:platform
                                      typeName:@"ratio"];
    return ratio;
}

- (NSString *)showTimesPlatform:(NSString *)platform
                           type:(Yd1AdsConfigType)type {
    NSString * showTimes = [self valueWithPlatform:[self adsControlType:type]
                                      withPlatform:platform
                                          typeName:@"maxShowTimes"];
    return showTimes;
}

- (NSArray*)configPriorityType:(Yd1AdsConfigType)type {
    
    if (self.channelControls == nil) {
        self.channelControls = [NSMutableDictionary dictionary];
    }
    if ([self.channelControls count] < 1) {
        [self configControlsType:Yd1AdsConfigTypeBanner];
        [self configControlsType:Yd1AdsConfigTypeInterstitial];
        [self configControlsType:Yd1AdsConfigTypeVideo];
    }
    NSString* weightKey = [NSString stringWithFormat:@"%lu",(unsigned long)type];
    return [self.channelControls objectForKey:weightKey];
}

- (void)configControlsType:(Yd1AdsConfigType)type {
    NSMutableArray* configArray = [NSMutableArray array];
    for (id key in [self adsControlType:type]) {
        NSDictionary* keyDic = (NSDictionary*)key;
        NSArray* weightArray = [keyDic allKeys];
        if ([weightArray count] > 0) {
            NSString* weightKey = [weightArray firstObject];
            if (weightKey) {
                [configArray addObject:weightKey];
            }
        }
    }
    NSString* weightKey = [NSString stringWithFormat:@"%lu",(unsigned long)type];
    [self.channelControls setValue:configArray forKey:weightKey];
}

- (void)configAppKeys:(NSDictionary*)config {
    if ([config count] > 0) {
        NSArray* configValue = [config allValues];
        for (id key in configValue) {
            NSDictionary* keyDic = (NSDictionary*)key;
            for (id mKey in [keyDic allKeys]) {
                NSString* appId = [keyDic objectForKey:mKey];
                if (appId) {
                    [self.channelAppKeys setValue:appId forKey:mKey];
                }
            }
        }
    }
}

- (NSString *)valueWithPlatform:(NSArray *)config
                   withPlatform:(NSString *)platform
                       typeName:(NSString *)typeName {
    for (id key in config) {
        NSDictionary* keyDic = (NSDictionary*)key;
        if ([[keyDic allKeys]containsObject:platform]) {
            NSArray* valueArray= [keyDic allValues];
            if ([valueArray count] > 0) {
                NSDictionary* valueDic = [valueArray firstObject];
                if ([[valueDic allKeys]containsObject:typeName]) {
                    NSString* percent = [valueDic objectForKey:typeName];
                    if (percent) {
                        return percent;
                    }
                }
            }
        }
    }
    return @"";
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

-(NSArray *)reportFields {
    return (NSArray *)[Yd1OpsTools.cached objectForKey:kReportFields];
}

#pragma mark- data

- (NSString*)publishType {
    NSDictionary* _config = [Yd1OpsTools bundlePlistWithPath:@"Yodo1Suit.bundle/config"];
    NSString* _publishType = @"";
    if (_config && [[_config allKeys]containsObject:@"PublishType"]) {
        _publishType = (NSString*)[_config objectForKey:@"PublishType"];
    }
    return _publishType;
}

- (NSString*)publishVersion {
    NSDictionary* _config = [Yd1OpsTools bundlePlistWithPath:@"Yodo1Suit.bundle/config"];
    NSString* _publishVersion = @"";
    if (_config && [[_config allKeys]containsObject:@"PublishVersion"]) {
        _publishVersion = (NSString*)[_config objectForKey:@"PublishVersion"];
    }
    return _publishVersion;
}

- (NSDictionary*)parameterDic {
    NSString* dataIdentifer = @"0";
    NSString* identifer = (NSString*)[Yd1OpsTools.cached objectForKey:kYodo1OPCacheIdentiferKey];
    if (identifer) {
        dataIdentifer = identifer;
    }
    NSDate* firstDate  = (NSDate*)[Yd1OpsTools.cached objectForKey:kYodo1FirstTimestampKey];
    if (firstDate) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:firstDate];
        NSString* ttl = (NSString*)[Yd1OpsTools.cached objectForKey:kYodo1OPCacheLocationIdentiferTTLKey];
        if (ttl) {
            double ttlInterval = [ttl doubleValue] *60*60;
            if (time > ttlInterval) {///超过24小时，删除本地地理标识和存储时间戳
                [Yd1OpsTools.cached setObject:nil forKey:kYodo1OPCacheLocationIdentiferKey];
                [Yd1OpsTools.cached setObject:nil forKey:kYodo1FirstTimestampKey];
            }
        }
    }
    
    NSString* locationIdentifer = (NSString*)[Yd1OpsTools.cached objectForKey:kYodo1OPCacheLocationIdentiferKey];
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
    NSString* parameterStr = (NSString *)[Yd1OpsTools.cached objectForKey:kYodo1OPCacheVerifyKey];
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
                                 Yd1OpsTools.sdkType:[self publishType],
                                 Yd1OpsTools.sdkVersion:[self publishVersion],
                                 kYodo1DataIdentifer:dataIdentifer,
                                 kYodo1LocationIdentifer:locationIdentifer,
                                 kYodo1LocationLNG:location_lng,
                                 kYodo1LocationLAT:location_lat,
                                 Yd1OpsTools.timeStamp:timestamp,
                                 Yd1OpsTools.sign:sign
    };
    ///save appkey,version,channelId
    NSString* parametersStr = [Yd1OpsTools stringWithJSONObject:parameters error:nil];
    [Yd1OpsTools.cached setObject:parametersStr forKey:kYodo1OPCacheVerifyKey];
    return parameters;
}

- (void)fetchStaticData {
    NSString* fileName = [[Yd1OpsTools signMd5String:[NSString stringWithFormat:@"%@",self.appKey]]uppercaseString];
    NSString* staticDataFileName = [NSString stringWithFormat:@"%@.json",fileName];
    
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:kStaticOnlineParameterUrl]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:staticDataFileName parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self saveOnlineConfig:responseObject isStaticData:YES];
        for (OPCachedCompletionHandler callback in self.cachedCallbacks) {
            if (callback) {
                callback();
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error);
        for (OPCachedCompletionHandler callback in self.cachedCallbacks) {
            if (callback) {
                callback();
            }
        }
        int code = -1;
        if (error) {
            code = (int)error.code;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kYodo1OnlineConfigFinishedNotification object:@{@"result":@"fail",@"code":[NSNumber numberWithInt:code]}];
    }];
    
}

- (void)saveOnlineConfig:(id)responseObject isStaticData:(BOOL)isStaticData {
    NSString* response = [Yd1OpsTools stringWithJSONObject:responseObject error:nil];
#ifdef DEBUG
    NSLog(@"[ Yodo1 ]-------------------online-------------------");
    NSLog(@"[ Yodo1 ]response:%@",response);
    NSLog(@"[ Yodo1 ]-------------------online-------------------");
#endif
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
            if (error_code == ErrorCodeTypeSuccess) {
                ///保存data
                if ([[dic allKeys]containsObject:Yd1OpsTools.data]) {
                    NSDictionary* data = [dic objectForKey:Yd1OpsTools.data];
                    if ([data count] >0) {
                        [Yd1OpsTools.cached setObject:data forKey:kYodo1OPCacheDataKey];
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"onlineConfigUpdateCount"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }else{
                        YD1LOG(@"data is empty");
                    }
                }
                ///保存identifer
                NSString* dataIdentifer = [dic objectForKey:kYodo1DataIdentifer];
                if (dataIdentifer) {
                    [Yd1OpsTools.cached setObject:dataIdentifer forKey:kYodo1OPCacheIdentiferKey];
                }
                
                ///保存locationIdentifer
                if ([[dic allKeys]containsObject:kYodo1LocationIdentifer]) {
                    NSString* mLocationIdentifer = [dic objectForKey:kYodo1LocationIdentifer];
                    if (mLocationIdentifer) {
                        [Yd1OpsTools.cached setObject:mLocationIdentifer forKey:kYodo1OPCacheLocationIdentiferKey];
                    }
                }
                
                ///保存新的地理标识有效时长
                if ([[dic allKeys]containsObject:kYodo1LocationIdentiferTTL]) {
                    NSString* locIdentiferTTL = [dic objectForKey:kYodo1LocationIdentiferTTL];
                    if (locIdentiferTTL) {
                        [Yd1OpsTools.cached setObject:locIdentiferTTL forKey:kYodo1OPCacheLocationIdentiferTTLKey];
                    }
                }
                
                ///保存一个时间戳在本地
                NSDate* firstDate  = (NSDate*)[Yd1OpsTools.cached objectForKey:kYodo1FirstTimestampKey];
                if (!firstDate) {
                    [Yd1OpsTools.cached setObject:[NSDate date] forKey:kYodo1FirstTimestampKey];
                }
                
                ///保存是否是测试设备标志
                [Yd1OpsTools.cached setObject:(dic[kIsTestModel] ? : @(NO)) forKey:kIsTestModel];
                ///保存是否是Debug模式
                [Yd1OpsTools.cached setObject:(dic[kIsDebugModel] ? : @(NO)) forKey:kIsDebugModel];
                ///kDeviceSource测试设备来源
                [Yd1OpsTools.cached setObject:(dic[kDeviceSource] ? : @"") forKey:kDeviceSource];
                ///保存是否有指定测试广告渠道
                BOOL isHaveAdList = false;
                if ([[dic allKeys]containsObject:kTestList]) {
                    NSDictionary* testList = [dic objectForKey:kTestList];
                    if (testList && [[testList allKeys]containsObject:kAdList]) {
                        NSDictionary* adList = [testList objectForKey:kAdList];
                        if (adList && [adList count] > 0) {
                            isHaveAdList = true;
                        }
                    }
                }
                [Yd1OpsTools.cached setObject:[NSNumber numberWithBool:isHaveAdList] forKey:kHaveAdList];
                
                [Yd1OpsTools.cached setObject:(dic[kReportFields] ? : @[]) forKey:kReportFields];
            } else {//error_code 10或3
                if ([[dic allKeys]containsObject:Yd1OpsTools.error]) {
                    YD1LOG(@"%@",(NSString*)[dic objectForKey:Yd1OpsTools.error]);
                }
                if (error_code == ErrorCodeTypeDataUpdated) {
                    
                }
                ///本地identifer是否存在
                NSString* identifer = (NSString *)[Yd1OpsTools.cached objectForKey:kYodo1OPCacheIdentiferKey];
                if ([identifer length] >0) {
                    YD1LOG(@"identifer存在:%@",identifer);
                }else{
                    if (!isStaticData) {
                        [self fetchStaticData];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:kYodo1OnlineConfigFinishedNotification object:@{@"result":@"success",@"code":[NSNumber numberWithInt:error_code]}];
        }
    }
    ///保存一个时间点
    self->backgroundDate = [NSDate date];
}

- (void)fetchOnlineData {
    NSString * m_online_config = [NSUserDefaults.standardUserDefaults stringForKey:@"demoTestOnlineConfig"];
    BOOL isDemoTestOnlineConfig = [m_online_config isEqualToString:@"develop"];
    NSString * baseurl = isDemoTestOnlineConfig ? kTestOnlineParameterUrl : kOnlineParameterUrl;
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseurl]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSDictionary* parameters = [self parameterDic];
    [manager POST:kOnlineParameterSubUrl parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self saveOnlineConfig:responseObject isStaticData:NO];
        for (OPCachedCompletionHandler callback in self.cachedCallbacks) {
            if (callback) {
                callback();
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.localizedDescription);
        [self fetchStaticData];
    }];
}

- (void)fetchRewardGameConfig {
    if (!_appKey.length) {return;}
    NSString * baseurl = kRewardGameParameterUrl;
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseurl]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSString* timestamp = [Yd1OpsTools nowTimeTimestamp];
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"%@%@%@%@",_appKey,Yd1OpsTools. keychainDeviceId,timestamp,Yodo1Secret->secretRewardGame()]];
    NSDictionary* parameters = @{@"appkey":_appKey,@"device_id":Yd1OpsTools.keychainDeviceId,
                                 @"timestamp":timestamp,@"sign":sign,@"la":Yd1OpsTools.language};
    [manager POST:kRewardGameParameterSubUrl parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#if DEBUG
        NSLog(@"respone - %@",responseObject);
#endif
        if ([responseObject[@"code"] intValue]) {return;}
        id data = responseObject[@"data"];
        if ([data isKindOfClass:NSDictionary.class]) {
            [Yd1OpsTools.cached setObject:responseObject[@"data"] forKey:kYodo1OPCacheRewardGameKey];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.localizedDescription);
        [Yd1OpsTools.cached setObject:@{} forKey:kYodo1OPCacheRewardGameKey];
    }];
}

-(NSDictionary *)rewardGameConfig {
    NSDictionary * config = (NSDictionary *)[Yd1OpsTools.cached objectForKey:kYodo1OPCacheRewardGameKey];
    if (config.count) {return config;}
    [self fetchRewardGameConfig];
    return nil;
}

- (void)rewardGameReward:(NSDictionary *)para response:(void(^)(NSDictionary * rewardData))response {
    if (!_appKey.length) {return;}
    NSString * baseurl = kRewardGameParameterUrl;
    Yodo1AFHTTPSessionManager *manager = [[Yodo1AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseurl]];
    manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSMutableDictionary* parameters = para.mutableCopy;
    NSString* timestamp = [Yd1OpsTools nowTimeTimestamp];
    NSString* sign = [Yd1OpsTools signMd5String:[NSString stringWithFormat:@"%@%@%@%@",_appKey,Yd1OpsTools. keychainDeviceId,timestamp,Yodo1Secret->secretRewardGame()]];
    [parameters addEntriesFromDictionary:@{@"appkey":_appKey,@"device_id":Yd1OpsTools.keychainDeviceId,
                                           @"timestamp":timestamp,@"sign":sign,@"la":Yd1OpsTools.language}];
    [manager POST:kRewardGameParameterSubUrl parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#if DEBUG
        NSLog(@"respone - %@",responseObject);
#endif
        NSDictionary * rewardData = responseObject[@"data"];
        if (rewardData && response) {response(rewardData);}
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YD1LOG(@"%@",error.localizedDescription);
        if (response) {response(nil);}
    }];
}

#pragma mark- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        YD1LOG(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        YD1LOG(@"无法获取位置信息");
    }
    if ([error code] == kCLErrorGeocodeCanceled) {
        YD1LOG(@"取消授权");
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

@end
