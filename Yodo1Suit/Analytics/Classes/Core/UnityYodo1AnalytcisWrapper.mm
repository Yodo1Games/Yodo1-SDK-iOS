#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AnalyticsManager.h"
#import "AnalyticsAdapter.h"

typedef enum {
    Unity_Result_Type_GenerateInviteUrl = 4002,
}UnityResultType_Analytcis;

#ifdef __cplusplus
extern "C" {
#endif

    void UnityLogin(const char* jsonUser)
    {
        NSString* _jsonUser = ConvertCharToNSString(jsonUser);
        NSDictionary* user = [Yodo1Commons JSONObjectWithString:_jsonUser error:nil];
        
        if (user) {
            NSString* playerId = [user objectForKey:@"playerId"];
            [[Yodo1AnalyticsManager sharedInstance]login:playerId];
            
            YD1LOG(@"playerId:%@",playerId);
        } else {
            YD1LOG(@"user is not playerId!");
        }
    }
    
    void UnityTrackEvent(const char* eventId, const char* jsonValues) {
        NSString* eventValues = ConvertCharToNSString(jsonValues);
        NSDictionary *eventValuesDict = [Yodo1Commons JSONObjectWithString:eventValues error:nil];
        [[Yodo1AnalyticsManager sharedInstance] trackEvent:ConvertCharToNSString(eventId) eventValues:eventValuesDict];
    }
    
    void UnityTrackUAEvent(const char* eventId, const char* jsonValues) {
        NSString* eventValues = ConvertCharToNSString(jsonValues);
        NSDictionary *eventValuesDict = [Yodo1Commons JSONObjectWithString:eventValues error:nil];
        [[Yodo1AnalyticsManager sharedInstance] trackUAEvent:ConvertCharToNSString(eventId) eventValues:eventValuesDict];
    }
    
    void UnityTrackAdRevenue(const char* jsonRevenue) {
        NSString* revenue = ConvertCharToNSString(jsonRevenue);
        NSDictionary *revenueDict = [Yodo1Commons JSONObjectWithString:revenue error:nil];
        Yodo1AdRevenue* adRevenue = [[Yodo1AdRevenue alloc] initWithDictionary:revenueDict];
        [[Yodo1AnalyticsManager sharedInstance] trackAdRevenue:adRevenue];
    }
    
    void UnityTrackIAPRevenue(const char* jsonRevenue) {
        NSString* revenue = ConvertCharToNSString(jsonRevenue);
        NSDictionary *revenueDict = [Yodo1Commons JSONObjectWithString:revenue error:nil];
        Yodo1IAPRevenue* iapRevenue = [[Yodo1IAPRevenue alloc] initWithDict:revenueDict];
        [[Yodo1AnalyticsManager sharedInstance] trackIAPRevenue:iapRevenue];
    }
    
    // save AppsFlyer deeplink
    void UnitySaveToNativeRuntime(const char*key, const char*valuepairs) {
        NSString *keyString = ConvertCharToNSString(key);
        NSString *valuepairsString = ConvertCharToNSString(valuepairs);
        
        NSDictionary *openUrlDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_DEEPLINK_RESULT]];
        
        if ([[openUrlDic allKeys] containsObject:keyString]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:openUrlDic];
            dict[keyString] = valuepairsString;
            
            [Yd1OpsTools.cached setObject:@{valuepairsString: keyString} forKey:Y_DEEPLINK_RESULT];
        } else {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:openUrlDic];
            [dict setObject:valuepairsString forKey:keyString];
            
            [Yd1OpsTools.cached setObject:@{valuepairsString: keyString} forKey:Y_DEEPLINK_RESULT];
        }
    }
    
    // get AppsFlyer deeplink
    char* UnityGetNativeRuntime(const char*key) {
        NSString *keyString = ConvertCharToNSString(key);
        
        NSDictionary *openUrlDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_DEEPLINK_RESULT]];
        
        if ([[openUrlDic allKeys] containsObject:keyString]) {
            return ConvertNSStringToChar(openUrlDic[keyString]);
        }
        
        return NULL;
    }
    
    void UnityGenerateInviteUrlWithLinkGenerator(const char* dicJson, char* gameObjectName, char* methodName) {
        NSString* ocGameObjName = ConvertCharToNSString(gameObjectName);
        NSString* ocMethodName = ConvertCharToNSString(methodName);
        NSString* _dicJson = ConvertCharToNSString(dicJson);
        
        NSDictionary *dic = [Yodo1Commons JSONObjectWithString:_dicJson error:nil];
        
        [[Yodo1AnalyticsManager sharedInstance] generateInviteUrlWithLinkGenerator:dic CallBack:^(NSString *url, int code, NSString *errorMsg) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* msg = @"";
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:url forKey:@"link"];
                [dict setObject:[NSNumber numberWithInt:code] forKey:@"code"];
                [dict setObject:[NSNumber numberWithInt:Unity_Result_Type_GenerateInviteUrl] forKey:@"resultType"];
                
                NSError* parseJSONError = nil;
                msg = [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
                if(parseJSONError){
                    msg =  [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
                }
                
                Yodo1UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding] );
            });
        }];
    }
    
    void UnityLogInviteAppsFlyerWithEventData(const char *eventData) {
        NSString* _eventData = ConvertCharToNSString(eventData);
        NSDictionary *dicData = [Yodo1Commons JSONObjectWithString:_eventData error:nil];
        [[Yodo1AnalyticsManager sharedInstance] logInviteAppsFlyerWithEventData:dicData];
    }
    
#pragma mark - Unity deprecated Methods
    // TODO - the below methods are deprecated and will be removed later
    
    void UnityEventWithJson(const char* eventId, const char* eventValues) {
        NSString* eventData = ConvertCharToNSString(eventValues);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[Yodo1AnalyticsManager sharedInstance] trackEvent:ConvertCharToNSString(eventId) eventValues:eventDataDic];
    }

    void UnityEventAppsFlyerAnalyticsWithName(const char*eventName, const char* jsonData) {
        NSString* m_EventName = ConvertCharToNSString(eventName);
        NSString* eventData = ConvertCharToNSString(jsonData);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[Yodo1AnalyticsManager sharedInstance] trackUAEvent:m_EventName eventValues:eventDataDic];
    }

    void UnityValidateAndTrackInAppPurchase(const char*productIdentifier,
                                            const char*price,
                                            const char*currency,
                                            const char*transactionId) {
        [[Yodo1AnalyticsManager sharedInstance] validateAndTrackInAppPurchase:ConvertCharToNSString(productIdentifier)
                                                                        price:ConvertCharToNSString(price)
                                                                     currency:ConvertCharToNSString(currency)
                                                                transactionId:ConvertCharToNSString(transactionId)];
    }
    
    void UnityEventAndTrackInAppPurchase(const char*revenue,
                                         const char*currency,
                                         const char*quantity,
                                         const char*contentId,
                                         const char*receiptId) {
        [[Yodo1AnalyticsManager sharedInstance] eventAndTrackInAppPurchase:ConvertCharToNSString(revenue)
                                                                  currency:ConvertCharToNSString(currency)
                                                                  quantity:ConvertCharToNSString(quantity)
                                                                 contentId:ConvertCharToNSString(contentId)
                                                                 receiptId:ConvertCharToNSString(receiptId)];
    }
    
#ifdef __cplusplus
}
#endif
