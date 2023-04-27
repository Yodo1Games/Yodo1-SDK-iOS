//
//  Yodo1AntiAddictionNet.h
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1AntiAddictionResponse : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) id data;

@end


@interface Yodo1AntiAddictionNet : NSObject

+ (Yodo1AntiAddictionNet *)manager;

- (void)initWithAppKey:(NSString*)appKey;

- (NSURLSessionDataTask *)GET:(NSString *)path parameters:parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;

- (NSURLSessionDataTask *)POST:(NSString *)path parameters:parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;

- (NSURLSessionDataTask *)DELETE:(NSString *)path parameters:parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;

- (NSURLSessionDataTask *)PUT:(NSString *)path parameters:parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;

- (NSURLSessionDataTask *)request:(NSString *)method path:(NSString *)path parameters:parameters success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
        failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;

@end

NS_ASSUME_NONNULL_END
