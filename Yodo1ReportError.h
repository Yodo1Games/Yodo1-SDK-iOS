//
//  Yodo1ReportError.h
//
//  Created by yixian huang on 2017/7/24.
//
//

#ifndef Yodo1ReportError_h
#define Yodo1ReportError_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString* const kYodo1StepId;
FOUNDATION_EXPORT NSString* const kYodo1StepDes;
FOUNDATION_EXPORT NSString* const kYodo1Target;
FOUNDATION_EXPORT NSString* const kYodo1TypeId;
FOUNDATION_EXPORT NSString* const kYodo1TypeDes;
FOUNDATION_EXPORT NSString* const kYodo1AdviceSolver;
FOUNDATION_EXPORT NSString* const kYodo1Time;
FOUNDATION_EXPORT NSString* const kYodo1Extra;

FOUNDATION_EXPORT NSString* const kYodo1ReportErrorDataName;

typedef NS_OPTIONS(NSInteger, RecordType) {
    RecordTypeClientAd,//客户端广告类型
};

NSString *NSStringFromRecordType(RecordType);

typedef NS_OPTIONS(NSInteger, SolverType) {
    SolverTypeOps,//Ops
    SolverTypeQa,//qa
    SolverTypeIt,//it
    SolverTypeBd,//bd
};


NSString *NSStringFromSolverType(SolverType);

typedef NS_OPTIONS(NSUInteger, StepId) {
    StepIdInitBannerAD,           //初始化Banner广告
    StepIdRequestBannerAD,        //请求Banner广告
    StepIdShowBannerAD,           //展示Banner广告
    StepIdInitInterstitialAD,     //初始化插屏广告
    StepIdRequestInterstitialAD,  //请求插屏广告
    StepIdShowInterstitialAD,     //展示插屏广告
    StepIdInitVideoAD,            //初始化激励视频广告
    StepIdRequestVideoAD,         //请求激励视频广告
    StepIdShowVideoAD,            //展示激励视频广告
    StepIdInitSplashAD,           //初始化开屏广告
    StepIdRequestSplashAD,        //请求开屏广告
    StepIdShowSplashAD,           //展示开屏广告
};

NSString *NSStringFromStepId(StepId);
NSString *NSStringFromStepIdDes(StepId);

typedef NS_OPTIONS(NSUInteger, TypeId) {
    TypeIdAppParameterInvalid = 1000,//应用ID无效或者不存在
    TypeIdAdvertParameterInvalid,   //广告位ID无效或者不存在
    TypeIdBundleIdParameterInvalid, //应用ID和应用包名不匹配
    TypeIdAdLoadFail,//广告请求失败
    TypeIdAdShowFail,//展示广告失败
};

NSString *NSStringFromTypeId(TypeId);
NSString *NSStringFromTypeIdDes(TypeId);

NSString *NSStringFromErrorCode(int);

@class ErrorData;

@interface Yodo1ReportError:NSObject

+ (instancetype)instance;

- (void)initWithAppKey:(NSString *)appKey channel:(NSString*)channel;

- (BOOL)isInitialized;

- (void)uploadReportError;

- (BOOL)saveErrorData:(ErrorData*)errorData;

- (void)createErrorData:(NSDictionary*)params;

+ (NSString*)currentTimestamp;

@end

NS_ASSUME_NONNULL_END
#endif /* Yodo1ReportError_h */
