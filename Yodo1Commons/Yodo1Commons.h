//
//  Yodo1Commons.h
//  Yodo1Commons
//
//  Created by hyx on 15/1/5.
//  Copyright (c) 2015年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//剪贴板类型
extern NSString* const kUIPasteboardTypeListString;
extern NSString* const kUIPasteboardTypeListURL;
extern NSString* const kUIPasteboardTypeListImage;
extern NSString* const kUIPasteboardTypeListColor;

typedef NS_ENUM(NSUInteger, Yodo1CommonsUIBlockerTouchEvent) {
    Yodo1CommonsUIBlockerTouchEventBegan,
    Yodo1CommonsUIBlockerTouchEventCancelled,
    Yodo1CommonsUIBlockerTouchEventEnded,
    Yodo1CommonsUIBlockerTouchEventMoved
};

typedef enum {
    QRPointRect = 0,
    QRPointRound
}QRPointType;

typedef enum {
    QRPositionNormal = 0,
    QRPositionRound
}QRPositionType;

enum {
    qr_margin = 3
};

typedef NS_ENUM(NSUInteger, Yodo1ConnectionType) {
    Yodo1ConnectionTypeUnknown,
    Yodo1ConnectionTypeCellular2G,
    Yodo1ConnectionTypeCellular3G,
    Yodo1ConnectionTypeCellular4G,
    Yodo1ConnectionTypeWiFi
};

typedef void (^Yodo1CommonsUIBlockerTouchBlock)(Yodo1CommonsUIBlockerTouchEvent eventType, NSSet* touches, UIEvent* event);

@protocol UITouchBlockerDelegate <NSObject>
@optional
- (void)blockerTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)blockerTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)blockerTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)blockerTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
@end

@interface Yodo1CommonsUITouchEventBlocker : UIView
@property (nonatomic, assign) id<UITouchBlockerDelegate> delegate;
@property (nonatomic, strong) Yodo1CommonsUIBlockerTouchBlock touchBlock;
@end

@interface Yodo1Commons : NSObject

/**
 *  Yodo1Commons单例
 *
 *  @return Yodo1Commons实例
 */
+ (Yodo1Commons*)sharedInstance;

/**
 *  验证文件
 *
 *  @param filename     文件名
 *  @param referenceCrc 第一次运行时候的验证码
 *
 *  @return YES验证成功，NO验证失败
 */
+ (BOOL)fileCRCVerifyWithFileName:(NSString*)filename referenceCrc:(const unsigned long)referenceCrc;

/**
 *  获取最上层可用的Window
 *
 *  @return TopWindow
 */
+ (UIWindow *)getTopWindow;

/**
 *  获取RootViewController
 *
 *  @return RootViewController
 */
+ (UIViewController*)getRootViewController;

/**
 *  获取传入UIViewController的上一级的UIViewController
 *
 *  @param controller controller
 *
 *  @return UIViewController
 */
+ (UIViewController*)topMostViewController:(UIViewController*)controller;


+ (NSString*)switcherWithVersion:(NSString*)switcher;

/**
 *  获取当前应用的名字
 *
 *  @return 应用名
 */
+ (NSString*)appName;

/**
 *  获取应用版本号
 *
 *  @return 版本号
 */
+ (NSString*)appVersion;

/**
 *  获取用bundle id
 *
 *  @return bundle id
 */
+ (NSString*)appBundleId;

+ (NSString*)deviceModel;

+ (UIImage*)createResizeableImageFromSourceImage:(UIImage*)sourceImage;

+ (UIImage*)createResizeableImageFromSourceImage:(UIImage*)sourceImage horizontalOffset:(float)horizontalOffset verticalOffet:(float)verticalOffset;

+ (void)showBounceAnim:(UIView*)view delegate:(id)delegate;

+ (void)showLoading:(UIView*)parentView;

+ (void)hideLoading:(UIView*)parentView;

+ (void)resizeLoading:(UIView*)parentView;


/**
 *  检测当前设备是否为横屏
 *
 *  @return YES横屏，NO竖屏
 */
+ (BOOL)isOrientationLandscape;

/**
 *  检测设备是否为iPad
 *
 *  @return YES为iPad,NO为iPhone
 */
+ (BOOL)isIpad;

/**
 *  获取当前系统语言简码
 *
 *  @return 语言简码
 */
+ (NSString*)systemLanguage;

/**
 *  获取当前系统时间(相对1970年1月1日0时0分0秒的增量)，以毫秒为单位。
 *
 *  @return 返回时间
 */
+ (long long)timeNowAsMilliSeconds;

/**
 *  获取当前系统时间(相对1970年1月1日0时0分0秒的增量)，以秒为单位。
 *
 *  @return 返回时间
 */
+ (long long)timeNowAsSeconds;

/**
 *  获取设备的唯一标示符。
 *
 *  @return 唯一标示符
 */
+ (NSString*)deviceId;

/**
 *  获取设备Mac地址
 *
 *  @return 获取设备Mac地址
 */
+ (NSString*)deviceMacAddress;

/**
 *  idfaString
 *
 *  @return idfaString
 */
+ (NSString*)idfaString;

/**
 *  idfvString
 *
 *  @return idfvString
 */
+ (NSString*)idfvString;

+ (CGSize)sizeByWrapContentForView:(UIView*)view;

+ (UIImage*)resizableImageFromImage:(UIImage*)sourceImage;

+ (void)showInfo:(UIView*)parentView info:(NSString*)info;

+ (void)hideInfo:(UIView*)parentView;

/**
 *  JSON对象
 *
 *  @param data  JSON of Data
 *  @param error error
 *
 *  @return JSON对象
 */
+ (id)JSONObjectWithData:(NSData*)data error:(NSError**)error;

/**
 *  JSON对象
 *
 *  @param str   JSON字符串
 *  @param error error
 *
 *  @return JSON对象
 */
+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error;

/**
 *  JSON of Data
 *
 *  @param obj   JSON对象
 *  @param error error
 *
 *  @return JSON of Data
 */
+ (NSData*)dataWithJSONObject:(id)obj error:(NSError**)error;

/**
 *  JSON of String
 *
 *  @param obj   JSON对象
 *  @param error error
 *
 *  @return JSON of String
 */
+ (NSString*)stringWithJSONObject:(id)obj error:(NSError**)error;

/**
 *  md5
 *
 *  @param string 字符串
 *
 *  @return md5
 */
+ (NSString *)md5StringFromString:(NSString *)string;

/**
 *  通过bundle生成图片
 *
 *  @param path 路径比如xxx.bundle/xxx/name.png
 *
 *  @return return UIImage对象
 */
+ (UIImage*)imagePathFromCustomBundle:(NSString *)path;

/**
 *  指定大小重新生成图片
 *
 *  @param dstSize     重新生成UIImage的size
 *  @param sourceImage 源UIImage对象
 *
 *  @return return 重新生成的UIImage
 */
+ (UIImage*)yodo1ResizedImageToSize:(CGSize)dstSize sourceImage:(UIImage*)sourceImage;

+ (UIImage*)yodo1ResizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale sourceImage:(UIImage*)sourceImage;

/**
 *  判断当前网络状态
 *
 *  @return 网络状态
 */
+ (Yodo1ConnectionType)connectionType;

/**
 *  保存值到剪贴板
 *
 *  @param value          可以是字符串，url,image
 *  @param pasteboardType 剪贴板保存类型kUIPasteboardTypeListString，kUIPasteboardTypeListURL，kUIPasteboardTypeListImage，kUIPasteboardTypeListColor
 */
+ (void)saveValueToPasteboard:(id)value forPasteboardType:(NSString*)pasteboardType;

/**
 *  保存图片到系统相册
 *
 *  @param savedImage 需要保存的图片
 *  @param callback   回调
 */
+ (void)saveImageToPhotos:(UIImage*)savedImage callback:(void(^)(BOOL success))callback;

/**
 *  本地化多语言获取字符串
 *
 *  @param key           等号左边字符
 *  @param bundleName    bundle的名字
 *  @param defaultString 默认字符串
 *
 *  @return 多语言字符（根据当前系统获取）
 */
+ (NSString *)localizedStringForKey:(NSString *)key
                         bundleName:(NSString *)bundleName
                        withDefault:(NSString *)defaultString;

/**
 *  获取区域简码
 *
 *  @return 返回区域简码
 */
+ (NSString *)territory;

/**
 *  获取语言字符串
 *
 *  @return 语言字符串
 */
+ (NSString *)language;

+ (NSString *)localizedStringForKeyWithBundleName:(NSString *)bundleName
                                              key:(NSString*)key
                                      withDefault:(NSString *)defaultString;

+ (NSString*)localizedStringForKey:(NSString*)key
                       withDefault:(NSString *)defaultString;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+ (void)addSkipBackupAttributeToFolder:(NSURL*)folder;


@end

@interface YD1Preferences : NSObject
+ (BOOL)hasKey:(NSString *)key;
+ (NSString *)getString:(NSString *)key;
+ (NSNumber *)getInteger:(NSString *)key;
+ (NSNumber *)getLong:(NSString *)key;
+ (NSNumber *)getBoolean:(NSString*)key;
+ (NSNumber *)getFloat:(NSString*)key;
+ (void)setString:(NSString*)value forKey:(NSString*)key;
+ (void)setInteger:(int)value forKey:(NSString*)key;
+ (void)setFloat:(float)value forKey:(NSString*)key;
+ (void)setBoolean:(BOOL)value forKey:(NSString*)key;
+ (void)setLong:(long)value forKey:(NSString*)key;
+ (void)removeKey:(NSString *)key;
@end
