//
//  Yodo1ReplayAdapterDouyin.m
//  Pods
//
//  Created by Sunmeng on 2023/11/16.
//

#import "Yodo1ReplayAdapterDouyin.h"
#import "Yodo1ReplayManager.h"
#import "Yodo1Registry.h"
#import "Yodo1Tool+Commons.h"
#import <UnionOpenPlatform/UOPManager.h>
// 抖音授权能力需引入
#import <UnionOpenPlatform/UOPAuthManager.h>
// 抖音录屏能力需引入
#import <UnionOpenPlatform/UOPReplayManager.h>
// 抖音分享能力需引入
#import <UnionOpenPlatform/UOPShareManager.h>
#import <UnionOpenPlatform/UOPShareDouyinContent.h>
#import "Yodo1KeyInfo.h"

@interface Yodo1ReplayAdapterDouyin()<UOPReplayManagerDelegate>

@property (nonatomic, assign) Yodo1ReplayType replayType;
@property (nonatomic, strong, nonnull) NSString * videoPath;
@property (nonatomic, strong, nonnull) NSString * hashtag;

@end

@implementation Yodo1ReplayAdapterDouyin

+ (Yodo1ReplayPlatform)replayPlatform {
    return Yodo1ReplayPlatformDouyin;
}

+ (void)load {
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"replayPlatform"];
}

- (void)initWithConfig:(Yodo1ReplayConfig* _Nonnull)replayConfig delegate:(id<Yodo1ReplayManagerDelegate> __nullable)delegate {
    [super initWithConfig:replayConfig delegate:delegate];
    
    [[UOPReplayManager sharedManager] removeAllReplayFile];
    
    NSString* appId = replayConfig.douyinConfig.appId;
    if (appId == nil || appId.length == 0) {
        replayConfig.douyinConfig.appId = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"DouyinAppId"];;
    }
    
    NSString* clientKey = replayConfig.douyinConfig.clientKey;
    if (clientKey == nil || clientKey.length == 0) {
        replayConfig.douyinConfig.clientKey = [[Yodo1KeyInfo shareInstance] configInfoForKey:@"DouyinClientKey"];
    }
    
    UOPConfigManager *config = [UOPConfigManager sharedConfiguration];
    config.appId = replayConfig.douyinConfig.appId;
    config.unionMode = UOPGameUnionModeUnionCP;
    config.channel = @"App Store";
#ifdef DEBUG
    // 注意：debug，logNoEncrypt 在线上环境务必设置为NO，或者不执行赋值
    config.debug = YES;
    config.logNoEncrypt = YES;
#endif
    
    self.hashtag = replayConfig.douyinConfig.hashtag;
    
    __weak Yodo1ReplayAdapterDouyin* weakSelf = self;
    [[UOPManager sharedManager] startConfig:config launchOptions:self.launchOptions complete:^(NSError * _Nullable error) {
        if (error) {
            YD1LOG(@"DouyinReplay, 初始化失败：%@", error);
            if (self.delegate) {
                [self.delegate replayDidInitialized:NO replayPlatform:Yodo1ReplayPlatformDouyin withError:error];
            }
        } else {
            YD1LOG(@"DouyinReplay 初始化完成");
            
//            [UOPAuthManager registerAppKey:replayConfig.douyinConfig.clientKey forPlatform:UOPThirdAuthTypeDouyin];
//            [UOPAuthManager didFinishLaunchingWithOptions:weakSelf.launchOptions];
            
            [UOPShareManager registerAppKey:replayConfig.douyinConfig.clientKey forPlatform:UOPThirdShareTypeDouyin];
            [UOPShareManager didFinishLaunchingWithOptions:weakSelf.launchOptions];
            
            [weakSelf setType:replayConfig.douyinConfig.replayType];
            
            if (self.delegate) {
                [self.delegate replayDidInitialized:YES replayPlatform:Yodo1ReplayPlatformDouyin withError:nil];
            }
        }
    }];
}

- (BOOL)isSupport {
    return [[UOPReplayManager sharedManager] isSupport];
}

- (BOOL)isRecording {
    return [[UOPReplayManager sharedManager] isRecording];
}

- (void)setType:(Yodo1ReplayType)type {
    UOPReplayConfig *config = [[UOPReplayConfig alloc] init];
    config.fps = 30;
    config.quality = UOPReplayRecordQualityMedium;
    [[UOPReplayManager sharedManager] setConfig:config completion:^(UOPReplayErrorCode code) {
        YD1LOG(@"DouyinReplay, setConfig completion code: %ld", code);
    }];
    
    self.replayType = type;
    
    UOPReplayType uopReplayType = UOPReplayTypeAuto;
    if (type == Yodo1ReplayTypeAuto) {
        uopReplayType = UOPReplayTypeAuto;
    } else if (type == Yodo1ReplayTypeManual) {
        uopReplayType = UOPReplayTypeManual;
    }
    [[UOPReplayManager sharedManager] setType:uopReplayType completion:^(UOPReplayErrorCode code) {
        YD1LOG(@"DouyinReplay, setType completion code: %ld", code);
    }];
    [UOPReplayManager sharedManager].delegate = self;
}

- (void)startRecord {
    if ([self isRecording]) {
        return;
    }
    if (self.replayType == Yodo1ReplayTypeAuto) {
        [[UOPReplayManager sharedManager] startAutoRecord];
    }
}

- (void)stopRecord {
    if (self.replayType == Yodo1ReplayTypeAuto) {
        [[UOPReplayManager sharedManager] stopAutoRecord];
    }
}

- (void)showRecorder:(UIViewController* _Nonnull)viewcontroller {
    if (self.isRecording) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"录屏已完成，是否分享到抖音？"
                                                                   message:@"若取消分享，录屏视频将被删除"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        NSError* error = [NSError errorWithDomain:@"com.yodo1.replay"
                                             code:1009
                                         userInfo:@{NSLocalizedDescriptionKey:@"用户取消"}];
        [self videoShareAction:NO withError:error];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [self videoShareAction:YES withError:nil];
    }]];
    [viewcontroller presentViewController:alert animated:YES completion:nil];
}

- (void)authAction {
    UOPAuthRequest *req = [[UOPAuthRequest alloc] init];
    // 在抖音开放平台应用状态为”测试应用“时，需要额外增加"trial.whitelist"，并且在抖音开放平台注册白名单用户；
    // 正式上线时不需要携带"trial.whitelist"
    req.permissions = [NSOrderedSet orderedSetWithArray:@[@"user_info", @"trial.whitelist"]];
    [UOPAuthManager authPlatform:UOPThirdAuthTypeDouyin request:req result:^(UOPAuthResponse * _Nonnull resp) {
        if (resp.isSuccess) {
            // 授权成功
            NSLog(@"授权第一阶段成功, code: %@", resp.code);
//            [self OAuthRequest:resp.code];
            [self videoShareAction:YES withError:nil];
        } else {
            // 授权失败
            NSLog(@"授权失败, error:(%@, %@)", @(resp.error.code), resp.error.localizedDescription);
            [self videoShareAction:NO withError:resp.error];
        }
    }];
}

- (void)videoShareAction:(BOOL)confirm withError:(NSError*)error {
    if (confirm) {
#ifdef DEBUG
        if (self.videoPath == nil || self.videoPath.length == 0) {
            NSString *testVideoPath = [[NSBundle mainBundle] pathForResource:@"share_test_video" ofType:@"mp4"];
            self.videoPath = testVideoPath;
        }
#endif
        UOPShareDouyinVideoContent *videoC = [UOPShareDouyinVideoContent new];
        videoC.videoPath = self.videoPath;
        videoC.shareWay = UOPShareDouyinWayPublish;
        videoC.hashtag = self.hashtag;
        [[UOPShareManager sharedManager] shareContent:videoC completion:^(UOPShareResponse * _Nonnull resp) {
            [[UOPReplayManager sharedManager] removeReplayFileAtPath:self.videoPath];
            if (resp.error) {
                NSLog(@"分享失败: %@", resp.error);
                [self.delegate replayDidShareRecord:NO replayPlatform:Yodo1ReplayPlatformDouyin roundID:self.roundID withError:resp.error];
            } else {
                NSLog(@"分享成功");
                [self.delegate replayDidShareRecord:YES replayPlatform:Yodo1ReplayPlatformDouyin roundID:self.roundID withError:nil];
            }
        }];
    } else {
        [[UOPReplayManager sharedManager] removeReplayFileAtPath:self.videoPath];
        if (self.delegate) {
            NSError* error = [NSError errorWithDomain:@"com.yodo1.replay"
                                                 code:1009
                                             userInfo:@{NSLocalizedDescriptionKey:@"用户取消"}];
            [self.delegate replayDidShareRecord:NO replayPlatform:Yodo1ReplayPlatformDouyin roundID:self.roundID withError:error];
        }
    }
}

- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [super didFinishLaunchingWithOptions:launchOptions];
//    [UOPAuthManager didFinishLaunchingWithOptions:launchOptions];
//    [UOPShareManager didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [super handleOpenURL:url options:options];
    if ([UOPAuthManager handleOpenURL:url options:options]) {
        return YES;
    }
    return [UOPShareManager handleOpenURL:url options:options];
}

- (NSError*) getError:(UOPReplayErrorCode)code {
    NSString* message = @"";
    switch (code) {
        case UOPReplayErrorCodeSuccess:
            message = @"";
            break;
        case UOPReplayErrorCodeAlreadyRecording:
            message = @"已经开始录制";
            break;
        case UOPReplayErrorCodeDeviceNotSupport:
            message = @"设备不支持";
            break;
        case UOPReplayErrorCodeFeatureNotSupport:
            message = @"功能不支持";
            break;
        case UOPReplayErrorCodeNoDiskSpace:
            message = @"设备空间不足";
            break;
        case UOPReplayErrorCodeTypeNoConfig:
            message = @"未完成初始化配置";
            break;
        case UOPReplayErrorCodeTypeNotMatch:
            message = @"在手动录制下调用自动录制接口";
            break;
        case UOPReplayErrorCodeNoRecording:
            message = @"未在录制";
            break;
        case UOPReplayErrorCodeGPUFullError:
            message = @"画面采集失败";
            break;
        case UOPReplayErrorCodeEnterBackground:
            message = @"进入后台中断";
            break;
        case UOPReplayErrorCodeSourceFileNotExist:
            message = @"文件存储错误";
            break;
        case UOPReplayErrorCodeTooShort:
            message = @"录制时长过短";
            break;
        case UOPReplayErrorCodeOverTime:
            message = @"录制超时";
            break;
        case UOPReplayErrorCodeRotateScreen:
            message = @"录制时长过短";
            break;
        default:
            message = @"";
            break;
    }
    NSError* error = [NSError errorWithDomain:@"com.yodo1.replay"
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey:message}];
    return error;
}

#pragma mark - UOPReplayManagerDelegate

- (void)replayDidStartRecord:(nullable NSString *)roundID
                    withCode:(UOPReplayErrorCode)code {
    YD1LOG(@"DouyinReplay replayDidStartRecord, roundID: %@, UOPReplayErrorCode: %@", roundID, @(code));
    [[UOPReplayManager sharedManager] removeReplayFileAtPath:self.videoPath];
    if (UOPReplayErrorCodeSuccess == code) {
        YD1LOG(@"DouyinReplay 录制开始");
        if (self.delegate) {
            [self.delegate replayDidStartRecord:YES replayPlatform:Yodo1ReplayPlatformDouyin roundID:roundID withError:nil];
        }
    } else {
        if (self.delegate) {
            [self.delegate replayDidStartRecord:NO replayPlatform:Yodo1ReplayPlatformDouyin roundID:roundID withError:[self getError:code]];
        }
    }
}

- (void)replayDidStopRecord:(nullable NSString *)roundID
                   withCode:(UOPReplayErrorCode)code
                  videoPath:(nullable NSString *)videoPath {
    YD1LOG(@"DouyinReplay replayDidStopRecord, roundID: %@, UOPReplayErrorCode: %@", roundID, @(code));
    self.roundID = roundID;
    if (UOPReplayErrorCodeSuccess == code) {
        self.videoPath = videoPath;
        YD1LOG(@"DouyinReplay 录制结束, 文件保存在: %@", videoPath);
        if (self.delegate) {
            [self.delegate replayDidStopRecord:YES replayPlatform:Yodo1ReplayPlatformDouyin roundID:roundID withError:nil];
        }
    } else {
        if (self.delegate) {
            [self.delegate replayDidStopRecord:NO replayPlatform:Yodo1ReplayPlatformDouyin roundID:roundID withError:[self getError:code]];
        }
    }
}

@end
