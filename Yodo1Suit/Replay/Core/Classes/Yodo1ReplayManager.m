//
//  Yodo1ReplayManager.m
//  Yodo1Suit
//
//  Created by Sunmeng on 2023/11/16.
//

#import "Yodo1ReplayManager.h"
#import "Yodo1ReplayAdapter.h"
#import "Yodo1Registry.h"
#import "Yodo1ClassWrapper.h"
#import "Yodo1Commons.h"
#import "Yodo1AnalyticsManager.h"

@interface Yodo1ReplayManager()<Yodo1ReplayManagerDelegate>

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, strong) NSMutableDictionary* replayDict;
@property (nonatomic, strong) Yodo1ReplayConfig* replayConfig;
@property (nonatomic, weak) id<Yodo1ReplayManagerDelegate> delegate;

@end

@implementation Yodo1ReplayManager

+ (Yodo1ReplayManager *)sharedInstance {
    static Yodo1ReplayManager* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1ReplayManager alloc] init];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _isInitialized = NO;
        
        NSDictionary* dic = [[Yodo1Registry sharedRegistry] getClassesStatusType:@"replayPlatform"
                                                                  replacedString:@"ReplayAdapter"
                                                                   replaceString:@"ReplayPlatform"];
        if (dic) {
            _replayDict = [[NSMutableDictionary alloc] init];
            NSArray* keyArray = [dic allKeys];
            for (id key in keyArray) {
                Class adapterClass = [[[Yodo1Registry sharedRegistry] adapterClassFor:[key integerValue] classType:@"replayPlatform"] theYodo1Class];
                Yodo1ReplayAdapter* adapter = [[adapterClass alloc] init];
                [_replayDict setObject:adapter forKey:[NSNumber numberWithInt:[key intValue]]];
            }
        }
    }
    return self;
}

- (void)dealloc {
    self.replayDict = nil;
    self.replayConfig = nil;
    self.delegate = nil;
}

- (void)initializeWithConfig:(Yodo1ReplayConfig* _Nonnull)replayConfig delegate:(id<Yodo1ReplayManagerDelegate> __nullable)delegate {
    if (self.isInitialized) {
        return;
    }
    
    self.replayConfig = replayConfig;
    self.delegate = delegate;
    
    for (id key in [self.replayDict allKeys]) {
        if ([key integerValue] == self.replayConfig.replayPlatform){
            Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
            [adapter initWithConfig:replayConfig delegate:self];
            break;
        }
    }
    
    self.isInitialized = YES;
}

- (BOOL)isSupport {
    BOOL ret = NO;
    for (id key in [self.replayDict allKeys]) {
        if ([key integerValue] == self.replayConfig.replayPlatform){
            Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
            ret = [adapter isSupport];
            break;
        }
    }
    return ret;
}

- (BOOL)isRecording {
    BOOL ret = NO;
    for (id key in [self.replayDict allKeys]) {
        if ([key integerValue] == self.replayConfig.replayPlatform){
            Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
            ret = [adapter isRecording];
            break;
        }
    }
    return ret;
}

- (void)setType:(Yodo1ReplayType) type {
    for (id key in [self.replayDict allKeys]) {
        if ([key integerValue] == self.replayConfig.replayPlatform){
            Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
            [adapter setType:type];
            break;
        }
    }
}

- (void)startRecord {
    for (id key in [self.replayDict allKeys]) {
        if ([key integerValue] == self.replayConfig.replayPlatform){
            Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
            [adapter startRecord];
            break;
        }
    }
}

- (void)stopRecord {
    for (id key in [self.replayDict allKeys]) {
        if ([key integerValue] == self.replayConfig.replayPlatform){
            Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
            [adapter stopRecord];
            break;
        }
    }
}

- (void)showRecorder:(UIViewController* _Nonnull)viewcontroller {
    if (self.replayConfig.sharingType == Yodo1ReplaySharingTypeAuto) {
        return;
    }
    [self showAutoRecorder:viewcontroller];
}

- (void)showAutoRecorder:(UIViewController* _Nonnull)viewcontroller {
    for (id key in [self.replayDict allKeys]) {
        if ([key integerValue] == self.replayConfig.replayPlatform){
            Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
            [adapter showRecorder:viewcontroller];
            break;
        }
    }
}

- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    for (id key in [self.replayDict allKeys]) {
        Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
        [adapter didFinishLaunchingWithOptions:launchOptions];
    }
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    for (id key in [self.replayDict allKeys]) {
        Yodo1ReplayAdapter* adapter = [self.replayDict objectForKey:key];
        [adapter handleOpenURL:url options:options];
    }
    return YES;
}

- (NSMutableDictionary*)getProperties:(BOOL)success method:(Yodo1ReplayPlatform)platform contentId:(NSString*)contentId withError:(NSError*)error {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    
    // screen_record_result
    NSString* result = (success == YES ? @"success" : @"fail");
    [properties setObject:result forKey:@"screen_record_result"];
    
    // screen_record_method
    NSString* method = @"";
    if (platform == Yodo1ReplayPlatformApple) {
        method = @"apple";
    } else if (platform == Yodo1ReplayPlatformDouyin) {
        method = @"douyin";
    }
    [properties setObject:method forKey:@"screen_record_method"];
    
    // screen_record_content_id
    if (contentId != nil && contentId.length > 0) {
        [properties setObject:contentId forKey:@"screen_record_content_id"];
    }
    
    // screen_record_error_code & screen_record_error_message
    if (error != nil) {
        [properties setObject:@(error.code) forKey:@"screen_record_error_code"];
        if (error.localizedDescription != nil && error.localizedDescription.length > 0) {
            [properties setObject:error.localizedDescription forKey:@"screen_record_error_message"];
        }
    }
    
    // screen_record_type
    NSString* type = @"";
    if (self.replayConfig.douyinConfig.replayType == Yodo1ReplayTypeAuto) {
        type = @"auto";
    } else if (self.replayConfig.douyinConfig.replayType == Yodo1ReplayTypeManual) {
        type = @"manual";
    }
    [properties setObject:type forKey:@"screen_record_type"];

    return properties;
}

#pragma mark Yodo1ReplayManagerDelegate
- (void)replayDidInitialized:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                   withError:(nullable NSError*)error {
    NSMutableDictionary *properties = [self getProperties:success method:replayPlatform contentId:nil withError:error];
    [[Yodo1AnalyticsManager sharedInstance] trackEvent:@"screen_record_init" eventValues:properties];

    if (self.delegate) {
        [self.delegate replayDidInitialized:success replayPlatform:replayPlatform withError:error];
    }
}

/// 录制开始事件
/// @param success 本次录制是否成功
/// @param roundID 本次录制标识
/// @param error Error
- (void)replayDidStartRecord:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                     roundID:(nullable NSString *)roundID
                   withError:(nullable NSError*)error {
    NSMutableDictionary *properties = [self getProperties:success method:replayPlatform contentId:roundID withError:error];
    [[Yodo1AnalyticsManager sharedInstance] trackEvent:@"screen_record_start" eventValues:properties];
    if (self.delegate) {
        [self.delegate replayDidStartRecord:success replayPlatform:replayPlatform roundID:roundID withError:error];
    }
}

/// 录制结束事件
/// @discussion 录制中断，录制结束失败均会触发
/// @param success 本次录制停止是否成功
/// @param roundID 本次录制标识
/// @param error Error
- (void)replayDidStopRecord:(BOOL)success
             replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                    roundID:(nullable NSString *)roundID
                  withError:(nullable NSError*)error {
    NSMutableDictionary *properties = [self getProperties:success method:replayPlatform contentId:roundID withError:error];
    [[Yodo1AnalyticsManager sharedInstance] trackEvent:@"screen_record_complete" eventValues:properties];
    
    if (self.delegate) {
        [self.delegate replayDidStopRecord:success replayPlatform:replayPlatform roundID:roundID withError:error];
    }
    
    if (success && self.replayConfig.sharingType == Yodo1ReplaySharingTypeAuto) {
        UIViewController *controller = [Yodo1Commons getRootViewController];
        [self showAutoRecorder:controller];
    }
}

/// 分享录屏事件,  仅Yodo1ReplayPlatformDouyin时有效
/// @param success 本次分享录屏是否成功
/// @param roundID 本次分享录制标识
/// @param error Error
- (void)replayDidShareRecord:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                     roundID:(nullable NSString *)roundID
                   withError:(nullable NSError*)error {
    NSMutableDictionary *properties = [self getProperties:success method:replayPlatform contentId:roundID withError:error];
    [[Yodo1AnalyticsManager sharedInstance] trackEvent:@"screen_record_share" eventValues:properties];
    
    if (self.delegate) {
        [self.delegate replayDidShareRecord:success replayPlatform:replayPlatform roundID:roundID withError:error];
    }
}

@end
