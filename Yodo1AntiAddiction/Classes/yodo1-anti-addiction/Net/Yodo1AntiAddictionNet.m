//
//  Yodo1NetworkManager.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/3.
//

#import "Yodo1AntiAddictionNet.h"
#import "Yodo1AFNetworking.h"
#import "Yodo1Model.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AntiAddictionHelper.h"
#import "Yodo1AntiAddictionUserManager.h"

#define Yodo1Anti_Debug 0

@implementation Yodo1AntiAddictionResponse

@end

@interface Yodo1AntiAddictionNet()

@property (nonatomic, strong) Yodo1AFHTTPSessionManager *manager;
@property (nonatomic, copy) NSString *appKey;

@end

@implementation Yodo1AntiAddictionNet

+ (Yodo1AntiAddictionNet *)manager {
    static Yodo1AntiAddictionNet *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1AntiAddictionNet alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
#if Yodo1Anti_Debug
        NSURL *baseURL = [NSURL URLWithString:@"https://ais-frontend-test.yodo1api.com/ais"];
#else
        //    https://ais-frontend.yodo1api.com/ais
        NSURL *baseURL = [NSURL URLWithString:@"https://ais.yodo1api.com/ais"];
#endif
        _manager = [[Yodo1AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        _manager.requestSerializer = [Yodo1AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [Yodo1AFJSONResponseSerializer serializer];
#if Yodo1Anti_Debug
        Yodo1AFSecurityPolicy *security = [Yodo1AFSecurityPolicy policyWithPinningMode:Yodo1AFSSLPinningModeNone];
        [security setValidatesDomainName:NO];
        security.allowInvalidCertificates = YES;
        _manager.securityPolicy = security;
#endif
    }
    return self;
}

- (void)initWithAppKey:(NSString*)appKey {
    self.appKey = appKey;
    if (self.appKey == nil || appKey.length == 0) {
        NSLog(@"Anti do not set AppKey!");
    }
}

- (NSURLSessionDataTask *)GET:(NSString *)path
                   parameters:parameters
                      success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    return [self request:@"GET" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)path
                    parameters:parameters
                       success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                       failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    return [self request:@"POST" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)path
                      parameters:parameters
                         success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                         failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    return [self request:@"DELETE" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)PUT:(NSString *)path
                   parameters:parameters
                      success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    return [self request:@"PUT" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)request:(NSString *)method
                             path:(NSString *)path
                       parameters:parameters
                          success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                          failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:method URLString:path parameters:parameters success:success failure:failure];
    [dataTask resume];
    return dataTask;
}


- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:method
                                                                       URLString:[[NSURL URLWithString:URLString relativeToURL:_manager.baseURL] absoluteString]
                                                                      parameters:parameters
                                                                           error:&serializationError];
    
    [request setValue:self.appKey forHTTPHeaderField:@"game-id"];
    [request setValue:[Yodo1Tool shared].publishChannelCodeValue forHTTPHeaderField:@"channel-id"];
    [request setValue:[[Yodo1AntiAddictionHelper shared] getSdkVersion] forHTTPHeaderField:@"sdk-version"];
    [request setValue:[Yodo1Tool shared].keychainDeviceId forHTTPHeaderField:@"device-id"];
    [request setValue:[Yodo1Tool shared].appVersion forHTTPHeaderField:@"game-version"];
    
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    if (user) {
        if (user.uid) {
            [request setValue:user.uid forHTTPHeaderField:@"uid"];
        }
        if (user.yid) {
            [request setValue:user.yid forHTTPHeaderField:@"yid"];
        }
    }
    
    
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:request
                              uploadProgress:nil
                            downloadProgress:nil
                           completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    return dataTask;
}

@end
