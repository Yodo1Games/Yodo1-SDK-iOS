#import "Yodo1ReplayManager.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "NSObject+Yodo1Model.h"
#import "Yodo1Tool+Commons.h"

typedef enum {
    Unity_Result_Type_Replay_Init = 5001,
    Unity_Result_Type_Replay_Start_Record = 5002,
    Unity_Result_Type_Replay_Stop_Record = 5003,
    Unity_Result_Type_Replay_Show_Record = 5004,
}UnityResultType_Replay;

static NSString* kYodo1ReplayGameObject;
static NSString* kYodo1ReplayMethodName;

@interface UnityYodo1ReplayWrapper : NSObject<Yodo1ReplayManagerDelegate>

+ (UnityYodo1ReplayWrapper *)sharedInstance;

- (void)initialize:(Yodo1ReplayConfig* _Nonnull)replayConfig;

@end

@implementation UnityYodo1ReplayWrapper

+ (UnityYodo1ReplayWrapper *)sharedInstance {
    static UnityYodo1ReplayWrapper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[UnityYodo1ReplayWrapper alloc] init];
    });
    return _instance;
}

- (void)initialize:(Yodo1ReplayConfig* _Nonnull)replayConfig {
    [[Yodo1ReplayManager sharedInstance] initializeWithConfig:replayConfig delegate:self];
}

#pragma mark Yodo1ReplayManagerDelegate

/// 初始化事件
/// @param success 初始化是否成功
/// @param error Error
- (void)replayDidInitialized:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                   withError:(nullable NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(kYodo1ReplayGameObject && kYodo1ReplayMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Replay_Init] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:(success?1:0)] forKey:@"code"];
            if (error != nil) {
                NSMutableDictionary* errorDict = [NSMutableDictionary dictionary];
                [errorDict setObject:[NSNumber numberWithInt:(int)error.code] forKey:@"code"];
                [errorDict setObject:error.localizedDescription forKey:@"message"];
                NSString* errorMsg = [Yd1OpsTools stringWithJSONObject:errorDict error:nil];
                [dict setObject:errorMsg forKey:@"error"];
            } else {
                [dict setObject:@"" forKey:@"error"];
            }
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Replay_Init] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"error"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([kYodo1ReplayGameObject cStringUsingEncoding:NSUTF8StringEncoding],
                                  [kYodo1ReplayMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                  [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    });
    
}

/// 录制开始事件
/// @param success 本次录制是否成功
/// @param roundID 本次录制标识
/// @param error Error
- (void)replayDidStartRecord:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                     roundID:(nullable NSString *)roundID
                   withError:(nullable NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(kYodo1ReplayGameObject && kYodo1ReplayMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Replay_Start_Record] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:(success?1:0)] forKey:@"code"];
            if (error != nil) {
                NSMutableDictionary* errorDict = [NSMutableDictionary dictionary];
                [errorDict setObject:[NSNumber numberWithInt:(int)error.code] forKey:@"code"];
                [errorDict setObject:error.localizedDescription forKey:@"message"];
                NSString* errorMsg = [Yd1OpsTools stringWithJSONObject:errorDict error:nil];
                [dict setObject:errorMsg forKey:@"error"];
            } else {
                [dict setObject:@"" forKey:@"error"];
            }
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Replay_Start_Record] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"error"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([kYodo1ReplayGameObject cStringUsingEncoding:NSUTF8StringEncoding],
                                  [kYodo1ReplayMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                  [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if(kYodo1ReplayGameObject && kYodo1ReplayMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Replay_Stop_Record] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:(success?1:0)] forKey:@"code"];
            if (error != nil) {
                NSMutableDictionary* errorDict = [NSMutableDictionary dictionary];
                [errorDict setObject:[NSNumber numberWithInt:(int)error.code] forKey:@"code"];
                [errorDict setObject:error.localizedDescription forKey:@"message"];
                NSString* errorMsg = [Yd1OpsTools stringWithJSONObject:errorDict error:nil];
                [dict setObject:errorMsg forKey:@"error"];
            } else {
                [dict setObject:@"" forKey:@"error"];
            }
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Replay_Stop_Record] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"error"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([kYodo1ReplayGameObject cStringUsingEncoding:NSUTF8StringEncoding],
                                  [kYodo1ReplayMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                  [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    });
}

/// 分享录屏事件,  仅Yodo1ReplayPlatformDouyin时有效
/// @param success 本次分享录屏是否成功
/// @param roundID 本次分享录制标识
/// @param error Error
- (void)replayDidShareRecord:(BOOL)success
              replayPlatform:(Yodo1ReplayPlatform)replayPlatform
                     roundID:(nullable NSString *)roundID
                   withError:(nullable NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(kYodo1ReplayGameObject && kYodo1ReplayMethodName) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Replay_Show_Record] forKey:@"resulType"];
            [dict setObject:[NSNumber numberWithInt:(success?1:0)] forKey:@"code"];
            if (error != nil) {
                NSMutableDictionary* errorDict = [NSMutableDictionary dictionary];
                [errorDict setObject:[NSNumber numberWithInt:(int)error.code] forKey:@"code"];
                [errorDict setObject:error.localizedDescription forKey:@"message"];
                NSString* errorMsg = [Yd1OpsTools stringWithJSONObject:errorDict error:nil];
                [dict setObject:errorMsg forKey:@"error"];
            } else {
                [dict setObject:@"" forKey:@"error"];
            }
            
            NSError* parseJSONError = nil;
            NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_Replay_Show_Record] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"error"];
                msg =  [Yd1OpsTools stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([kYodo1ReplayGameObject cStringUsingEncoding:NSUTF8StringEncoding],
                                  [kYodo1ReplayMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                  [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    });
}

@end

#ifdef __cplusplus
extern "C" {
#endif

void UnityReplay_Initialize(const char* configJson, const char* gameObjectName, const char* callbackMethodName) {
    NSString* m_gameObject = ConvertCharToNSString(gameObjectName);
    kYodo1ReplayGameObject = m_gameObject;
    
    NSString* m_methodName = ConvertCharToNSString(callbackMethodName);
    kYodo1ReplayMethodName = m_methodName;
    
    NSString* config = ConvertCharToNSString(configJson);
    NSDictionary* configDict = [Yodo1Commons JSONObjectWithString:config error:nil];
    Yodo1ReplayConfig *replayConfig = [[Yodo1ReplayConfig alloc] initWithDictionary:configDict];
    [[UnityYodo1ReplayWrapper sharedInstance] initialize:replayConfig];
}

bool UnityReplay_IsSupport() {
    return [[Yodo1ReplayManager sharedInstance] isSupport];
}

bool UnityReplay_IsRecording() {
    return [[Yodo1ReplayManager sharedInstance] isRecording];
}

void UnityReplay_SetType(int type) {
    [[Yodo1ReplayManager sharedInstance] setType:(Yodo1ReplayType)type];
}

void UnityReplay_ShowRecorder() {
    [[Yodo1ReplayManager sharedInstance] showRecorder:[Yodo1Commons getRootViewController]];
}

/// 自动模式接口
void UnityReplay_StartRecord() {
    [[Yodo1ReplayManager sharedInstance] startRecord];
}
/// 自动模式接口
void UnityReplay_StopRecord() {
    [[Yodo1ReplayManager sharedInstance] stopRecord];
}


#ifdef __cplusplus
}
#endif

