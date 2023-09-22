#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1iCloud.h"

typedef enum {
    Unity_Result_Type_iCloudGetValue = 6001,
}UnityResultType_iCloud;

#ifdef __cplusplus
extern "C" {
#endif

    void UnitySaveToCloud(const char* saveName,const char* saveValue)
    {
        NSString* pName = ConvertCharToNSString(saveName);
        NSString* pData = ConvertCharToNSString(saveValue);
        [[Yodo1iCloud sharedInstance] saveToCloud:pName saveValue:pData];
    }
    
    void UnityLoadToCloud(const char* saveName, const char* gameObjcetName, const char* callbackName)
    {
        NSString* ocGameObjName = ConvertCharToNSString(gameObjcetName);
        NSString* ocMethodName = ConvertCharToNSString(callbackName);
        NSString* name = ConvertCharToNSString(saveName);
        [[Yodo1iCloud sharedInstance] loadToCloud:name completionHandler:^(NSString *results, NSError *error) {
            if (error != nil){
                YD1LOG(@"LoadToCloud error : %@", error.description);
            }
            
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_iCloudGetValue] forKey:@"resulType"];
            if(error == nil){
                [dict setObject:[NSNumber numberWithInt:1] forKey:@"code"];
            }else{
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
            }
            
            [dict setObject:name forKey:@"saveName"];
            [dict setObject:results == nil ? @"" : results forKey:@"saveValue"];
            

            NSError* parseJSONError = nil;
            NSString* msg = [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            if(parseJSONError){
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_iCloudGetValue] forKey:@"resulType"];
                [dict setObject:[NSNumber numberWithInt:0] forKey:@"code"];
                [dict setObject:@"Convert result to json failed!" forKey:@"msg"];
                msg =  [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
            }
            Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                             [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                             [msg cStringUsingEncoding:NSUTF8StringEncoding]);
        }];
    }
    
    void UnityRemoveRecordWithRecordName(const char* saveName)
    {
        NSString* _saveName = ConvertCharToNSString(saveName);
        [[Yodo1iCloud sharedInstance] removeRecordWithRecordName:_saveName];
    }

#ifdef __cplusplus
}
#endif
