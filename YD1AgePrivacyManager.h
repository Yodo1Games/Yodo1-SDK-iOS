#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString* const YD1_Default;//默认
FOUNDATION_EXPORT NSString* const YD1_ChineseHans;// 简体中文
FOUNDATION_EXPORT NSString* const YD1_ChineseHant;// 繁体中文
FOUNDATION_EXPORT NSString* const YD1_English;// 英文
FOUNDATION_EXPORT NSString* const YD1_French;// 法语
FOUNDATION_EXPORT NSString* const YD1_German;// 德语
FOUNDATION_EXPORT NSString* const YD1_Hindi;// 印地语
FOUNDATION_EXPORT NSString* const YD1_Italian;// 意大利语
FOUNDATION_EXPORT NSString* const YD1_Arabic;// 阿拉伯语
FOUNDATION_EXPORT NSString* const YD1_Spanish;// 西班牙语
FOUNDATION_EXPORT NSString* const YD1_Indonesian;// 印度尼西亚文
FOUNDATION_EXPORT NSString* const YD1_Japanese;// 日语
FOUNDATION_EXPORT NSString* const YD1_Korean;// 韩语
FOUNDATION_EXPORT NSString* const YD1_Portuguese;// 葡萄牙语
FOUNDATION_EXPORT NSString* const YD1_Russian;// 俄语
FOUNDATION_EXPORT NSString* const YD1_Turkish;// 土耳其语

@class PrivacyServiceInfo;
@class LicenseInfo;
@class Yodo1YYCache;

///accept 是否同意隐私协议；adults是否是成年人；age 选择的年龄
typedef void(^PrivacyBlock)(BOOL accept,BOOL child,int age);
typedef void(^PrivacyServiceBlock)(PrivacyServiceInfo* info);
typedef void(^PrivacyCallback)(BOOL accept);

@interface PrivacyServiceInfoModel : NSObject
@property(nonatomic,copy)NSString* error_code;//错误码
@property(nonatomic,copy)NSString* error;//错误描述
@property(nonatomic,strong)PrivacyServiceInfo* data;//业务数据
@end

@interface PrivacyServiceInfo : NSObject
@property(nonatomic,assign)BOOL open_switch;//用户协议模块是否开启
@property(nonatomic,assign)int child_age_limit;//判定是否成年的年龄标准
@property(nonatomic,strong)NSArray* license_info;//当前的用户协议信息列表
@end

@interface LicenseInfo : NSObject
@property(nonatomic,copy)NSString* license_name;//协议名称
@property(nonatomic,copy)NSString* license_version;//协议版本，用于判定是否需要用户进行审阅
@property(nonatomic,assign)long last_update_time;//协议最后更新时间戳
@property(nonatomic,strong)NSDictionary* links;//协议文本链接
@end

@interface YD1AgePrivacyManager : NSObject

@property(nonatomic,strong)Yodo1YYCache* yyCache;

+ (YD1AgePrivacyManager*)sharedInstance;

///设置本地语言
+ (void)selectLocalLanguage:(NSString*)language;

///初始化隐私政策UI
+ (void)startDialogUserConsent:(UIViewController*)viewcontroller
                      isUpdate:(BOOL)isUpdate;

///隐私政策弹框
+ (void)dialogShowUserConsentWithGameAppKey:(NSString*)gameAppKey
                                channelCode:(NSString*)channelCode
                             viewController:(UIViewController*)viewcontroller
                                      block:(PrivacyBlock)privacyBlock;

+ (void)dialogShowPrivacyViewcontroller:(UIViewController*)viewcontroller
                                  block:(PrivacyCallback)privacyCallback;

///获取隐私服务
+ (void)startGetPrivacyOnlineServiceWithGameAppKey:(NSString*)gameAppKey
                                       channelCode:(NSString*)channelCode
                                             block:(void (^)(BOOL finish,NSError* error))block;
//读取配置
+ (void)getPrivacyOnlineService:(PrivacyServiceBlock)serviceBlock;

@end
