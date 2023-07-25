#import "UnityYodo1AnalytcisWrapper.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Commons.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yodo1AnalyticsManager.h"
#import "AnalyticsAdapter.h"

#ifdef __cplusplus

extern "C" {
    
    void UnityLogin(const char* jsonUser)
    {
        NSString* _jsonUser = Yodo1CreateNSString(jsonUser);
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
        NSString* eventValues = Yodo1CreateNSString(jsonValues);
        NSDictionary *eventValuesDict = [Yodo1Commons JSONObjectWithString:eventValues error:nil];
        [[Yodo1AnalyticsManager sharedInstance] trackEvent:Yodo1CreateNSString(eventId) eventValues:eventValuesDict];
    }
    
    void UnityTrackUAEvent(const char* eventId, const char* jsonValues) {
        NSString* eventValues = Yodo1CreateNSString(jsonValues);
        NSDictionary *eventValuesDict = [Yodo1Commons JSONObjectWithString:eventValues error:nil];
        [[Yodo1AnalyticsManager sharedInstance] trackUAEvent:Yodo1CreateNSString(eventId) eventValues:eventValuesDict];
    }
    
    void UnityTrackAdRevenue(const char* jsonRevenue) {
        NSString* revenue = Yodo1CreateNSString(jsonRevenue);
        NSDictionary *revenueDict = [Yodo1Commons JSONObjectWithString:revenue error:nil];
        Yodo1AdRevenue* adRevenue = [[Yodo1AdRevenue alloc] initWithDictionary:revenueDict];
        [[Yodo1AnalyticsManager sharedInstance] trackAdRevenue:adRevenue];
    }
    
    void UnityTrackIAPRevenue(const char* jsonRevenue) {
        NSString* revenue = Yodo1CreateNSString(jsonRevenue);
        NSDictionary *revenueDict = [Yodo1Commons JSONObjectWithString:revenue error:nil];
        Yodo1IAPRevenue* iapRevenue = [[Yodo1IAPRevenue alloc] initWithDict:revenueDict];
        [[Yodo1AnalyticsManager sharedInstance] trackIAPRevenue:iapRevenue];
    }
    
    // save AppsFlyer deeplink
    void UnitySaveToNativeRuntime(const char*key, const char*valuepairs) {
        NSString *keyString = Yodo1CreateNSString(key);
        NSString *valuepairsString = Yodo1CreateNSString(valuepairs);
        
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
        NSString *keyString = Yodo1CreateNSString(key);
        
        NSDictionary *openUrlDic = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[Yd1OpsTools.cached objectForKey:Y_DEEPLINK_RESULT]];
        
        if ([[openUrlDic allKeys] containsObject:keyString]) {
            NSString *msg = openUrlDic[keyString];
            return Yodo1MakeStringCopy(msg.UTF8String);
        }
        
        return NULL;
    }
    
    void UnityGenerateInviteUrlWithLinkGenerator(const char* dicJson, char* gameObjectName, char* methodName) {
        NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
        NSString* ocMethodName = Yodo1CreateNSString(methodName);
        NSString* _dicJson = Yodo1CreateNSString(dicJson);
        
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
                
                UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                 [msg cStringUsingEncoding:NSUTF8StringEncoding] );
            });
        }];
    }
    
    void UnityLogInviteAppsFlyerWithEventData(const char *eventData) {
        NSString* _eventData = Yodo1CreateNSString(eventData);
        NSDictionary *dicData = [Yodo1Commons JSONObjectWithString:_eventData error:nil];
        [[Yodo1AnalyticsManager sharedInstance] logInviteAppsFlyerWithEventData:dicData];
    }
    
#pragma mark - Unity deprecated Methods
    // TODO - the below methods are deprecated and will be removed later
    
    void UnityEventWithJson(const char* eventId, const char* eventValues) {
        NSString* eventData = Yodo1CreateNSString(eventValues);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[Yodo1AnalyticsManager sharedInstance] trackEvent:Yodo1CreateNSString(eventId) eventValues:eventDataDic];
    }

    void UnityEventAppsFlyerAnalyticsWithName(const char*eventName, const char* jsonData) {
        NSString* m_EventName = Yodo1CreateNSString(eventName);
        NSString* eventData = Yodo1CreateNSString(jsonData);
        NSDictionary *eventDataDic = [Yodo1Commons JSONObjectWithString:eventData error:nil];
        [[Yodo1AnalyticsManager sharedInstance] trackUAEvent:m_EventName eventValues:eventDataDic];
    }

    void UnityValidateAndTrackInAppPurchase(const char*productIdentifier,
                                            const char*price,
                                            const char*currency,
                                            const char*transactionId) {
        [[Yodo1AnalyticsManager sharedInstance] validateAndTrackInAppPurchase:Yodo1CreateNSString(productIdentifier)
                                                                        price:Yodo1CreateNSString(price)
                                                                     currency:Yodo1CreateNSString(currency)
                                                                transactionId:Yodo1CreateNSString(transactionId)];
    }
    
    void UnityEventAndTrackInAppPurchase(const char*revenue,
                                         const char*currency,
                                         const char*quantity,
                                         const char*contentId,
                                         const char*receiptId) {
        [[Yodo1AnalyticsManager sharedInstance] eventAndTrackInAppPurchase:Yodo1CreateNSString(revenue)
                                                                  currency:Yodo1CreateNSString(currency)
                                                                  quantity:Yodo1CreateNSString(quantity)
                                                                 contentId:Yodo1CreateNSString(contentId)
                                                                 receiptId:Yodo1CreateNSString(receiptId)];
    }
    
    
}
#endif
