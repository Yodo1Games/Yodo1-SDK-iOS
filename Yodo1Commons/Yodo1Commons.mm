//
//  Yodo1Commons.m
//  Yodo1Commons
//
//  Created by hyx on 15/1/5.
//  Copyright (c) 2015年 yodo1. All rights reserved.
//

#import "Yodo1Commons.h"
#import "zlib.h"
#import <sys/time.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "Yodo1UnityTool.h"

#include <CommonCrypto/CommonDigest.h>

#define TAG_ALERT_NETWORK_UNAVAILABLE 65536

NSString* const kUIPasteboardTypeListString = @"UIPasteboardTypeListString";
NSString* const kUIPasteboardTypeListURL = @"UIPasteboardTypeListURL";
NSString* const kUIPasteboardTypeListImage = @"UIPasteboardTypeListImage";
NSString* const kUIPasteboardTypeListColor = @"UIPasteboardTypeListColor";

@implementation Yodo1CommonsUITouchEventBlocker
@synthesize delegate;
@synthesize touchBlock;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.touchBlock = nil;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (delegate && [delegate respondsToSelector:@selector(blockerTouchesBegan:withEvent:)]) {
        [delegate blockerTouchesBegan:touches withEvent:event];
    }
    if (touchBlock) {
        touchBlock(Yodo1CommonsUIBlockerTouchEventBegan, touches, event);
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (delegate && [delegate respondsToSelector:@selector(blockerTouchesCancelled:withEvent:)]) {
        [delegate blockerTouchesCancelled:touches withEvent:event];
    }
    if (touchBlock) {
        touchBlock(Yodo1CommonsUIBlockerTouchEventCancelled, touches, event);
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (delegate && [delegate respondsToSelector:@selector(blockerTouchesEnded:withEvent:)]) {
        [delegate blockerTouchesEnded:touches withEvent:event];
    }
    if (touchBlock) {
        touchBlock(Yodo1CommonsUIBlockerTouchEventEnded, touches, event);
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (delegate && [delegate respondsToSelector:@selector(blockerTouchesMoved:withEvent:)]) {
        [delegate blockerTouchesMoved:touches withEvent:event];
    }
    if (touchBlock) {
        touchBlock(Yodo1CommonsUIBlockerTouchEventMoved, touches, event);
    }
}

@end


@implementation Yodo1Commons

static Yodo1Commons* _instance = nil;
+ (Yodo1Commons *)sharedInstance
{
    if (_instance == nil) {
        _instance = [[Yodo1Commons alloc]init];
    }
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
}


+ (BOOL)fileCRCVerifyWithFileName:(NSString*)filename referenceCrc:(const unsigned long)referenceCrc
{
    NSData* fileData = [NSData dataWithContentsOfFile:filename];
    uLong realCrc = crc32(0, (Bytef*)fileData.bytes, (uInt)fileData.length);
    
    if (realCrc != referenceCrc) {
#if DEBUG
        printf("crc of %s is %lx, expected=%lx\n", [filename UTF8String], realCrc, referenceCrc);
#endif
        return NO;
    }
    
    return YES;
}

+ (UIWindow *)getTopWindow {
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    NSArray* windows = [[UIApplication sharedApplication] windows];
    if (windows.count == 1) {return window;}
    for (UIWindow* _window in windows) {
        if (_window.windowLevel == UIWindowLevelAlert) {continue;}
        if (_window.windowLevel > window.windowLevel) {window = _window;}
    }
    return window;
}

+ (UIViewController*)getRootViewController
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray* windows = [[UIApplication sharedApplication] windows];
        for (UIWindow* _window in windows) {
            if (_window.windowLevel == UIWindowLevelNormal) {
                window = _window;
                break;
            }
        }
    }
    UIViewController* viewController = nil;
    for (UIView* subView in [window subviews]) {
        UIResponder* responder = [subView nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            viewController = [self topMostViewController:(UIViewController*)responder];
        }
    }
    if (!viewController) {
        viewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    return viewController;
}

+ (UIViewController*)topMostViewController:(UIViewController*)controller
{
    BOOL isPresenting = NO;
    do {
        // this path is called only on iOS 6+, so -presentedViewController is fine here.
        UIViewController* presented = [controller presentedViewController];
        isPresenting = presented != nil;
        if (presented != nil) {
            controller = presented;
        }
        
    } while (isPresenting);
    
    return controller;
}

+ (NSString*)switcherWithVersion:(NSString*)switcher
{
    if (switcher) {
        NSString* version = [Yodo1Commons appVersion];
        if (version == nil) {
            version = @"1.0";
        }
        NSArray* a = [version componentsSeparatedByString:@"."];
        NSString* v1 = [NSString stringWithFormat:@"%@", (a && a.count > 0) ? [a objectAtIndex:0] : @"1"];
        NSString* v2 = (a && a.count > 1) ? [NSString stringWithFormat:@"%@", [a objectAtIndex:1]] : @"0";
        NSString* v3 = (a && a.count > 2) ? [NSString stringWithFormat:@"%@", [a objectAtIndex:2]] : @"0";
        NSString* v4 = (a && a.count > 3) ? [NSString stringWithFormat:@"%@", [a objectAtIndex:3]] : nil;
        NSString* s = [NSString stringWithFormat:@"%@_%@_%@_%@", switcher, v1, v2, v3];
        if (v4) {
            s = [NSString stringWithFormat:@"%@_%@_%@_%@_%@", switcher, v1, v2, v3,v4];
        }
        return s;
    }
    return nil;
}

+ (NSString*)appName
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if ([[infoDictionary allKeys] containsObject:@"CFBundleDisplayName"]) {
        return [infoDictionary objectForKey:@"CFBundleDisplayName"];
    }
    if ([[infoDictionary allKeys] containsObject:@"CFBundleName"]) {
        return [infoDictionary objectForKey:@"CFBundleName"];
    }
    return nil;
}

+ (NSString*)appVersion
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if ([[infoDictionary allKeys]containsObject:@"CFBundleShortVersionString"]) {
        return infoDictionary[@"CFBundleShortVersionString"];
    }
    return nil;
}

+ (NSString*)appBundleId
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if ([[infoDictionary allKeys]containsObject:@"CFBundleIdentifier"]) {
        return infoDictionary[@"CFBundleIdentifier"];
    }
    return nil;
}

+ (NSString*)deviceModel
{
#if TARGET_IPHONE_SIMULATOR
    return @"Simulator";
#else
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char* machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString* platform = nil;
    
    if (machine == NULL) {
        platform = @"Simulator";
    }
    else {
        platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    }
    free(machine);
    return platform;
#endif
}

+ (UIImage*)createResizeableImageFromSourceImage:(UIImage*)sourceImage
{
    if (sourceImage) {
        int edgeInVertical = sourceImage.size.height / 2;
        int edgeInHorizontal = sourceImage.size.width / 2;
        if ([sourceImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            return [sourceImage resizableImageWithCapInsets:UIEdgeInsetsMake(edgeInVertical, edgeInHorizontal, edgeInVertical - 1, edgeInHorizontal - 1)];
        }
        else {
            return [sourceImage stretchableImageWithLeftCapWidth:edgeInHorizontal - 1 topCapHeight:edgeInVertical - 1];
        }
    }
    return nil;
}

+ (UIImage*)createResizeableImageFromSourceImage:(UIImage*)sourceImage horizontalOffset:(float)horizontalOffset verticalOffet:(float)verticalOffset
{
    if (sourceImage) {
        int edgeInVertical = (int)(sourceImage.size.height * verticalOffset);
        int edgeInHorizontal = (int)(sourceImage.size.width * horizontalOffset);
        if ([sourceImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            return [sourceImage resizableImageWithCapInsets:UIEdgeInsetsMake(edgeInVertical, edgeInHorizontal, sourceImage.size.height - edgeInVertical - 1, sourceImage.size.width - edgeInHorizontal - 1)];
        }
        else {
            return [sourceImage stretchableImageWithLeftCapWidth:edgeInHorizontal - 1 topCapHeight:edgeInVertical - 1];
        }
    }
    return nil;
}

+ (void)showBounceAnim:(UIView*)view delegate:(id)delegate
{
    CAKeyframeAnimation* animation = nil;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    animation.delegate = delegate;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray* values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3, 0.3, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:animation forKey:nil];
}

#define TAG_INFO_DIALOG ('i' + 'n' + 'f' + '0')
#define TAG_LOADING_DIALOG ('l' + 'o' + 'a' + 'd')
+ (void)hideLoading:(UIView*)parentView
{
    if (parentView) {
        UIView* v = [parentView viewWithTag:TAG_LOADING_DIALOG];
        if (v) {
            [v removeFromSuperview];
        }
    }
}

+ (void)showLoading:(UIView*)parentView
{
    if (parentView == nil) {
        return;
    }
    [Yodo1Commons hideLoading:parentView];
    CGRect rect = parentView.bounds;
    float width = rect.size.width;
    float height = rect.size.height;
    Yodo1CommonsUITouchEventBlocker* v = [[Yodo1CommonsUITouchEventBlocker alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    v.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.3];
    v.tag = 'l' + 'o' + 'a' + 'd';
    [parentView addSubview:v];
    
    UIView* blockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 72)];
    blockView.center = CGPointMake((int)width / 2, (int)height / 2);
    blockView.tag = 'i' + 'n' + 'd' + 'i';
    blockView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    blockView.layer.masksToBounds = NO;
    blockView.layer.cornerRadius = 10;
    
    [v addSubview:blockView];
    //xb review : av may have not been released
    UIActivityIndicatorView* av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    av.center = CGPointMake(blockView.frame.size.width / 3, blockView.frame.size.height / 2);
    
    [av startAnimating];
    [blockView addSubview:av];
    
    UILabel* tip = [[UILabel alloc] init];
    tip.textAlignment = NSTextAlignmentLeft;
    tip.text = @"请稍侯...";
    tip.backgroundColor = [UIColor clearColor];
    tip.textColor = [UIColor whiteColor];
    tip.font = [UIFont systemFontOfSize:16];
    [tip sizeToFit];
    tip.center = CGPointMake(blockView.frame.size.width * 2 / 3, blockView.frame.size.height / 2);
    
    //Re-locate loading anim and text.
    int x = (blockView.frame.size.width - (av.frame.size.width + tip.frame.size.width)) / 2;
    CGRect frame = av.frame;
    frame.origin.x = x;
    [av setFrame:frame];
    
    frame = tip.frame;
    frame.origin.x = x + 10 + av.frame.size.width;
    [tip setFrame:frame];
    
    [blockView addSubview:tip];
}

+ (void)resizeLoading:(UIView*)parentView
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    float width = 0;
    float height = 0;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        width = [[UIApplication sharedApplication] keyWindow].bounds.size.width;
        height = [[UIApplication sharedApplication] keyWindow].bounds.size.height;
    }
    else {
        width = [[UIApplication sharedApplication] keyWindow].bounds.size.height;
        height = [[UIApplication sharedApplication] keyWindow].bounds.size.width;
    }
    UIView* view = [parentView viewWithTag:'l' + 'o' + 'a' + 'd'];
    if (view) {
        view.frame = CGRectMake(0, 0, width, height);
        
        [view viewWithTag:'i' + 'n' + 'd' + 'i'].center = CGPointMake((width) / 2, (height) / 2);
    }
}

+ (BOOL)isIpad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)isOrientationLandscape
{
    UIDeviceOrientation screenOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    return screenOrientation == UIDeviceOrientationLandscapeLeft || screenOrientation == UIDeviceOrientationLandscapeRight;
}

+ (NSString*)systemLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (long long)timeNowAsMilliSeconds
{
    struct timeval time;
    gettimeofday(&time, NULL);
    return (time.tv_sec * 1000) + (time.tv_usec / 1000);
}

+ (long long)timeNowAsSeconds
{
    struct timeval time;
    gettimeofday(&time, NULL);
    return time.tv_sec;
}

+ (NSString*)deviceId
{
    return [Yodo1Commons deviceMacAddress];
}

+ (NSString*)idfaString {
    NSBundle* adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    if (adSupportBundle == nil) {
        return @"";
    }
    else {
        [adSupportBundle load];
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        if (asIdentifierMClass == nil) {
            return @"";
        }
        else {
            ASIdentifierManager* asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            }
            else {
                NSString* uuid = @"";
                if (asIM.advertisingTrackingEnabled) {
                    uuid = [asIM.advertisingIdentifier UUIDString];
                    if(uuid){
                        return uuid;
                    }
                }
                else {
                    uuid = [asIM.advertisingIdentifier UUIDString];
                    if(uuid){
                        return uuid;
                    }
                }
            }
        }
    }
    return @"";
}

+ (NSString*)idfvString
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        NSString *idfv = [[UIDevice currentDevice].identifierForVendor UUIDString];
        if (idfv) {
            return idfv;
        }
    }
    
    return @"";
}

+ (NSString*)deviceMacAddress
{
    int mib[6];
    size_t len;
    char* buf;
    unsigned char* ptr;
    struct if_msghdr* ifm;
    struct sockaddr_dl* sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = (char*)malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr*)buf;
    sdl = (struct sockaddr_dl*)(ifm + 1);
    ptr = (unsigned char*)LLADDR(sdl);
    NSString* outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    free(buf);
    
    return outstring;
}

+ (CGSize)sizeByWrapContentForView:(UIView*)view
{
    if (view) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView* v = (UIImageView*)view;
            UIImage* img = [v image];
            if (img == nil) {
                img = [v highlightedImage];
            }
            if (img) {
                return img.size;
            }
        }
        else if ([view isKindOfClass:[UITextView class]]) {
            
        }
        else if ([view isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)view;
            UIFont* font = [label font];
            if (font) {
                NSString* s = [label text];
                if (s == nil) {
                    s = @"";
                }
                CGSize size = [s sizeWithAttributes:@{NSFontAttributeName:font}];
                size.width = roundf(size.width);
                size.height = roundf(size.height);
                return size;
            }
        }
        else if ([view isKindOfClass:[UIButton class]]) {
            UIButton* btn = (UIButton*)view;
            CGFloat w = 0;
            CGFloat h = 0;
            UIImage* img = [btn imageForState:UIControlStateNormal];
            if (img == nil) {
                img = [btn imageForState:UIControlStateHighlighted];
            }
            if (img) {
                w = img.size.width;
                h = img.size.height;
            }
            
            NSString* title = [btn titleForState:UIControlStateNormal];
            if (title == nil) {
                title = @"";
            }
            UIFont* font = [[btn titleLabel] font];
            if (font) {
                CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:font}];
                w = MAX(size.width, w);
                h = MAX(size.height, h);
            }
            
            return CGSizeMake(w, h);
        }
        else if ([view isKindOfClass:[UISearchBar class]]) {
            return CGSizeMake(44, 44);
        }
    }
    return CGSizeZero;
}

+ (UIImage*)resizableImageFromImage:(UIImage*)sourceImage
{
    if (sourceImage) {
        NSInteger edgeInVertical = (NSInteger)sourceImage.size.height / 2;
        NSInteger edgeInHorizontal = (NSInteger)sourceImage.size.width / 2;
        if ([sourceImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            return [sourceImage resizableImageWithCapInsets:UIEdgeInsetsMake(edgeInVertical, edgeInHorizontal, edgeInVertical - 1, edgeInHorizontal - 1)];
        }
        else {
            return [sourceImage stretchableImageWithLeftCapWidth:edgeInHorizontal - 1 topCapHeight:edgeInVertical - 1];
        }
    }
    return nil;
}

+ (void)hideInfo:(UIView*)parentView
{
    if (parentView) {
        UIView* v = [parentView viewWithTag:TAG_INFO_DIALOG];
        if (v) {
            [v removeFromSuperview];
        }
    }
}

+ (void)showInfo:(UIView*)parentView info:(NSString*)info
{
    if (parentView == nil) {
        return;
    }
    [Yodo1Commons hideInfo:parentView];
    CGRect rect = parentView.bounds;
    int width = (int)rect.size.width;
    int height = (int)rect.size.height;
    
    Yodo1CommonsUITouchEventBlocker* blockView = [[Yodo1CommonsUITouchEventBlocker alloc] initWithFrame:CGRectMake(0, 0, 180, 72)];
    blockView.center = CGPointMake((int)width / 2, (int)height / 2);
    blockView.tag = TAG_INFO_DIALOG;
    blockView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    blockView.layer.masksToBounds = NO;
    blockView.layer.cornerRadius = 10;
    [parentView addSubview:blockView];
    
    [parentView addSubview:blockView];
    
    UILabel* tip = [[UILabel alloc] init];
    tip.textAlignment = NSTextAlignmentLeft;
    
    tip.text = info;
    tip.backgroundColor = [UIColor clearColor];
    tip.textColor = [UIColor whiteColor];
    tip.font = [UIFont systemFontOfSize:16];
    [tip sizeToFit];
    tip.center = CGPointMake(blockView.frame.size.width / 2, blockView.frame.size.height / 2);
    [blockView addSubview:tip];
}

+ (id)JSONObjectWithData:(NSData*)data error:(NSError**)error
{
    if (data) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        }
    }
    return nil;
}

+ (id)JSONObjectWithString:(NSString*)str error:(NSError**)error
{
    if (str) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            return [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:error];
        }
    }
    return nil;
}

+ (NSData*)dataWithJSONObject:(id)obj error:(NSError**)error
{
    if (obj) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            @try {
                return [NSJSONSerialization dataWithJSONObject:obj options:0 error:error];
            }
            @catch (NSException* exception)
            {
                *error = [NSError errorWithDomain:[exception description] code:0 userInfo:nil];
                return nil;
            }
            @finally
            {
            }
        }
    }
    return nil;
}

+ (NSString*)stringWithJSONObject:(id)obj error:(NSError**)error
{
    if (obj) {
        if (NSClassFromString(@"NSJSONSerialization")) {
            NSData* data = nil;
            @try {
                data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:error];
            }
            @catch (NSException* exception)
            {
                *error = [NSError errorWithDomain:[exception description] code:0 userInfo:nil];
                return nil;
            }
            @finally
            {
            }
            
            if (data) {
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
    }
    return nil;
}

+ (NSString *)md5StringFromString:(NSString *)string
{
    if (string == nil) {
        NSLog(@"Input is nil.");
        return nil;
    }
    
    const char *ptr = [string UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (UIImage *)imagePathFromCustomBundle:(NSString *)path {
    if (!path) {
        return nil;
    }
    NSString *main_images_dir_path = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:path];
    return [UIImage imageWithContentsOfFile:main_images_dir_path];
}


+ (UIImage*)yodo1ResizedImageToSize:(CGSize)dstSize sourceImage:(UIImage*)sourceImage
{
    if (sourceImage == nil) {
        return nil;
    }
    
    CGImageRef imgRef = sourceImage.CGImage;
    // the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
    CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
    
    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(srcSize, dstSize)) {
        return sourceImage;
    }
    
    CGFloat scaleRatio = dstSize.width / srcSize.width;
    UIImageOrientation orient = sourceImage.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    /////////////////////////////////////////////////////////////////////////////
    // The actual resize: draw the image on a new context, applying a transform matrix
    UIGraphicsBeginImageContextWithOptions(dstSize, NO, sourceImage.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) {
        return nil;
    }
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -srcSize.height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -srcSize.height);
    }
    
    CGContextConcatCTM(context, transform);
    
    // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}



/////////////////////////////////////////////////////////////////////////////



+ (UIImage*)yodo1ResizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale sourceImage:(UIImage*)sourceImage
{
    if (sourceImage == nil) {
        return nil;
    }
    // get the image size (independant of imageOrientation)
    CGImageRef imgRef = sourceImage.CGImage;
    CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which depends on the imageOrientation)!
    
    // adjust boundingSize to make it independant on imageOrientation too for farther computations
    UIImageOrientation orient = sourceImage.imageOrientation;
    switch (orient) {
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
            break;
        default:
            // NOP
            break;
    }
    
    // Compute the target CGRect in order to keep aspect-ratio
    CGSize dstSize;
    
    if ( !scale && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height) ) {
        //NSLog(@"Image is smaller, and we asked not to scale it in this case (scaleIfSmaller:NO)");
        dstSize = srcSize; // no resize (we could directly return 'self' here, but we draw the image anyway to take image orientation into account)
    } else {		
        CGFloat wRatio = boundingSize.width / srcSize.width;
        CGFloat hRatio = boundingSize.height / srcSize.height;
        
        if (wRatio < hRatio) {
            //NSLog(@"Width imposed, Height scaled ; ratio = %f",wRatio);
            dstSize = CGSizeMake(boundingSize.width, floorf(srcSize.height * wRatio));
        } else {
            //NSLog(@"Height imposed, Width scaled ; ratio = %f",hRatio);
            dstSize = CGSizeMake(floorf(srcSize.width * hRatio), boundingSize.height);
        }
    }
    
    return [Yodo1Commons yodo1ResizedImageToSize:dstSize sourceImage:sourceImage];
}

+ (Yodo1ConnectionType)connectionType
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    Yodo1ConnectionType type = Yodo1ConnectionTypeUnknown;
    for (id child in children)
    {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            type = (Yodo1ConnectionType)[[child valueForKeyPath:@"dataNetworkType"] intValue];
        }
    }
    return type;
}

+(void)saveValueToPasteboard:(id)value forPasteboardType:(NSString *)pasteboardType
{
    if (value==nil) {
        return;
    }
    NSString* _pasteboardType = [UIPasteboardTypeListString objectAtIndex:0];
    if ([pasteboardType isEqualToString:@"UIPasteboardTypeListString"]) {
        _pasteboardType = [UIPasteboardTypeListString objectAtIndex:0];
    }else if ([pasteboardType isEqualToString:@"UIPasteboardTypeListURL"]){
        _pasteboardType = [UIPasteboardTypeListURL objectAtIndex:0];
    }else if ([pasteboardType isEqualToString:@"UIPasteboardTypeListImage"]){
        _pasteboardType = [UIPasteboardTypeListImage objectAtIndex:0];
    }else if ([pasteboardType isEqualToString:@"UIPasteboardTypeListColor"]){
        _pasteboardType = [UIPasteboardTypeListColor objectAtIndex:0];
    }
    
    [[UIPasteboard generalPasteboard] setValue:value forPasteboardType:_pasteboardType];
}

+ (void)saveImageToPhotos:(UIImage *)savedImage callback:(void (^)(BOOL))callback
{
    if (savedImage ==nil) {
        NSLog(@"The saved image does not exist.");
        if(callback)callback(NO);
        return;
    }
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)([callback copy]));
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (contextInfo) {
        void (^callback)(BOOL success) = (__bridge void(^)(BOOL))contextInfo;
        if (error != NULL) {
            callback(NO);
        }else{
            callback(YES);
        }
    }
}

+ (NSString *)localizedStringForKey:(NSString *)key bundleName:(NSString *)bundleName withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:bundleName ofType:@"bundle"];
        if (bundlePath == nil) {
            bundlePath = [NSBundle.mainBundle pathForResource:bundleName ofType:@"bundle"];
        }
        bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *language = [[NSLocale preferredLanguages] count]? [NSLocale preferredLanguages][0]: @"en";
        if (![[bundle localizations] containsObject:language])
        {
            language = [language componentsSeparatedByString:@"-"][0];
        }
        if ([[bundle localizations] containsObject:language])
        {
            bundlePath = [bundle pathForResource:language ofType:@"lproj"];
        }
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

+ (NSString *)territory
{
    NSString* terri = [[NSLocale currentLocale] localeIdentifier];
    NSArray *terriArrayWord = [terri componentsSeparatedByString:@"_"];
    NSString*stTerri = [terriArrayWord objectAtIndex:terriArrayWord.count - 1];
    NSLog(@"stTerri:%@",stTerri);
    return stTerri;
}

+ (NSString *)language
{
    NSString* lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSArray * langArrayWord = [lang componentsSeparatedByString:@"-"];
    NSString* langSt = [langArrayWord objectAtIndex:0];
    if (langArrayWord.count >=3) {
        langSt = [NSString stringWithFormat:@"%@-%@",
                  [langArrayWord objectAtIndex:0],
                  [langArrayWord objectAtIndex:1]];
    }
    NSLog(@"lang:%@",langSt);
    return langSt;
}

+ (NSString *)localizedStringForKeyWithBundleName:(NSString *)bundleName
                                              key:(NSString *)key
                                      withDefault:(NSString *)defaultString
{
    if (bundleName==nil) {
        return nil;
    }
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:bundleName ofType:@"bundle"];
        
        if (bundlePath == nil) {
            bundlePath = [NSBundle.mainBundle pathForResource:bundleName ofType:@"bundle"];
        }
        
        bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *language = [[NSLocale preferredLanguages] count]? [Yodo1Commons language]: @"en";
        
        if ([[bundle localizations] containsObject:language])
        {
            bundlePath = [bundle pathForResource:language ofType:@"lproj"];
        }else{
            NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString* locSt = @"en";//默认英文
            if ([[infoDictionary allKeys] containsObject:@"CFBundleDevelopmentRegion"]) {
                locSt = [infoDictionary objectForKey:@"CFBundleDevelopmentRegion"];
            }
            if ([locSt isEqualToString:@"zh_CN"]) {
                locSt = @"zh-Hans";//中文
            }
            bundlePath = [bundle pathForResource:locSt ofType:@"lproj"];
        }
        
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    return [Yodo1Commons localizedStringForKeyWithBundleName:@"Yodo1SDKStrings" key:key withDefault:defaultString];
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    return success;
}

+ (void)addSkipBackupAttributeToFolder:(NSURL*)folder
{
    [Yodo1Commons addSkipBackupAttributeToItemAtURL:folder];
    
    NSError* error = nil;
    NSArray* folderContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[folder path] error:&error];
    
    for (NSString* item in folderContent)
    {
        NSString* path = [folder.path stringByAppendingPathComponent:item];
        [Yodo1Commons addSkipBackupAttributeToFolder:[NSURL fileURLWithPath:path]];
    }
}

#pragma mark- Unity 接口

#ifdef __cplusplus
extern "C" {
#endif 
    
#pragma mark- Unity of iClound
    /**
     *  获取iOS App版本号
     *
     *  @return 版本号
     */
    char* UnityGetVersionName()
    {
        NSString* version = [Yodo1Commons appVersion];
        return Yodo1MakeStringCopy(version.UTF8String);;
    }
    
    
#ifdef __cplusplus
}
#endif

@end

@implementation YD1Preferences

+ (BOOL)hasKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key] != nil;
}

+ (NSString *)getString:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

+ (NSNumber *)getInteger:(NSString *)key {
    return [NSNumber numberWithLong:[[NSUserDefaults standardUserDefaults] integerForKey:key]];
}

+ (NSNumber *)getLong:(NSString *)key {
    return [NSNumber numberWithLong:[[[NSUserDefaults standardUserDefaults] objectForKey:key] longValue]];
}

+ (NSNumber *)getBoolean:(NSString*)key {
    return [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:key]];
}

+ (NSNumber *)getFloat:(NSString*)key {
    return [NSNumber numberWithFloat:[[[NSUserDefaults standardUserDefaults] objectForKey:key] floatValue]];
}

+ (void)setString:(NSString*)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setInteger:(int)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSNumber numberWithInt:value] integerValue] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setFloat:(float)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setFloat:[[NSNumber numberWithFloat:value] floatValue] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setBoolean:(BOOL)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSNumber numberWithBool:value] boolValue] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setLong:(long)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:value] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
