#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Share.h"
#import "Yodo1Model.h"

#ifdef __cplusplus
extern "C" {
#endif

    void UnityShareInit() {
        [Yodo1Share.sharedInstance initWithPlist];
    }
    
    void UnityShare(char* paramJson, char* gameObjectName, char* methodName)
    {
        NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
        NSString* ocMethodName = ConvertCharToNSString(methodName);
        NSString* _paramJson = ConvertCharToNSString(paramJson);
        
        Yodo1SMContent* smContent = [Yodo1SMContent yodo1_modelWithJSON:_paramJson];
        
        UIImage* image = [UIImage imageNamed:smContent.contentImage];
        if(image==nil){
            image = [UIImage imageWithContentsOfFile:smContent.contentImage];
        }
        
        UIImage* qrLogo = [UIImage imageNamed:smContent.qrLogo];
        if(qrLogo==nil){
            qrLogo = [UIImage imageWithContentsOfFile:smContent.qrLogo];
        }
        
        UIImage* gameLogo = [UIImage imageNamed:smContent.gameLogo];
        if(gameLogo==nil){
            gameLogo = [UIImage imageWithContentsOfFile:smContent.gameLogo];
        }
        
        ShareContent* content = [[ShareContent alloc]init];
        content.contentImage = image;
        content.contentTitle = smContent.contentTitle;
        content.contentText = smContent.contentText;
        content.contentUrl = smContent.contentUrl;
        content.gameLogo = gameLogo;
        content.qrLogo = qrLogo;
        content.qrText = smContent.qrText;
        content.qrTextX = smContent.qrTextX;
        content.qrImageX = smContent.qrImageX;
        content.gameLogoX = smContent.gameLogoX;
        Yodo1ShareType shareType = (Yodo1ShareType)smContent.shareType;
        content.shareType = shareType;
        ShareContentType contentType = (ShareContentType)smContent.contentType;
        content.contentType = contentType;
        
        [[Yodo1Share sharedInstance]showSocial:content
                                         block:^(Yodo1ShareType shareType, Yodo1ShareContentState state, NSError *error) {
                                             if(ocGameObjName && ocMethodName){
                                                 NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                                                 [dict setObject:[NSNumber numberWithInt:(state == Yodo1ShareContentStateSuccess?1:0)] forKey:@"status"];
                                                 [dict setObject:[NSNumber numberWithInteger:shareType] forKey:@"shareType"];
                                                 
                                                 NSString* msg = [Yd1OpsTools stringWithJSONObject:dict error:nil];
                                                 
                                                 Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                                                  [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                                                  [msg cStringUsingEncoding:NSUTF8StringEncoding] );
                                             }
                                             
                                         }];
    }
    
    char* UnityShareGetSdkVersion() {
        return ConvertNSStringToChar(Y_SHARE_VERSION);
    }
    
    bool UnityShareCheckSNSInstalledWithType(int type)
    {
        Yodo1ShareType kType = (Yodo1ShareType)type;
        if([[Yodo1Share sharedInstance] isInstalledWithType:kType]){
            return true;
        }
        return false;
    }
    
    void UnityShareSetDebugLog(bool debugLog) {
        [Yodo1Share.sharedInstance setDebugLog:debugLog];
    }
#ifdef __cplusplus
}
#endif
