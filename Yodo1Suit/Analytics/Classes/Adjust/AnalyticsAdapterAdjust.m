
#import "AnalyticsAdapterAdjust.h"
#import "Adjust.h"
#import "Yodo1Registry.h"
#import "Yodo1Commons.h"
#import "Yodo1KeyInfo.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "AdjustTokenUtils.h"
#import "Yodo1Privacy.h"

NSString* const YODO1_ADJUST_APP_TOKEN = @"AdjustAppToken";
NSString* const YODO1_ADJUST_ENVIRONMENT = @"AdjustEnvironmentSandbox";

@interface AnalyticsAdapterAdjust()<AdjustDelegate>

@end

@implementation AnalyticsAdapterAdjust

+ (AnalyticsType)analyticsType {
    return AnalyticsTypeAdjust;
}

+ (void)load {
    [[Yodo1Registry sharedRegistry] registerClass:self withRegistryType:@"analyticsType"];
}

- (id)initWithConfig:(AnalyticsInitConfig *)initConfig {
    self = [super init];
    if (self) {
        NSString* appToken = [[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_ADJUST_APP_TOKEN];
        if(appToken == nil || appToken.length <= 0) {
            YD1LOG(@"Failed to initialize Adjust SDK with invalid app token. Please check your configuration.");
            return self;
        }
        
        BOOL isSandbox = [[[Yodo1KeyInfo shareInstance] configInfoForKey:YODO1_ADJUST_ENVIRONMENT] boolValue];
        NSString *environment = ADJEnvironmentProduction;
        if (isSandbox) {
            environment = ADJEnvironmentSandbox;
        }
        
        YD1LOG(@"Initializing Adjust SDK with app token(%@) and environment(%@).", appToken, environment);
        ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment];
        if (initConfig != nil && initConfig.debugEnabled) {
            //Log TAG: [Adjust]
            [adjustConfig setLogLevel:ADJLogLevelVerbose];
        }
        [adjustConfig setDelegate:self];
        [adjustConfig setLinkMeEnabled:YES]; // reference link: https://help.adjust.com/en/article/linkme
        [adjustConfig setSendInBackground:YES];
        [adjustConfig setCoppaCompliantEnabled:Yodo1Privacy.shareInstance.ageRestrictedUser]; // Apps for children: https://help.adjust.com/zh/article/apps-for-children-ios-sdk
        [Adjust appDidLaunch:adjustConfig];
        
        [Adjust checkForNewAttStatus];
    }
    return self;
}

#pragma mark - UA in-app events

- (void)trackUAEvent:(NSString *_Nonnull)eventName eventValues:(NSDictionary * _Nullable)eventValues {
    NSString* eventToken = [[AdjustTokenUtils shared] getEventToken:eventName];
    if (eventToken == nil || eventToken.length <= 0) {
        YD1LOG(@"Failed to report the event(%@) to Adjust with invalid event token.", eventName);
        return;
    }
    
    ADJEvent *event = [ADJEvent eventWithEventToken:eventToken];
    if (eventValues != nil) {
        for (NSString *key in eventValues) {
            [event addCallbackParameter:key value:eventValues[key]];
        }
    }
    [Adjust trackEvent:event];
}

- (void)trackAdRevenue:(Yodo1AdRevenue*)adRevenue{
    if (adRevenue == nil) {
        return;
    }
    if (adRevenue.source == nil || adRevenue.source.length <= 0) {
        return;
    }
    
    NSString* adjSource = ADJAdRevenueSourceAppLovinMAX;
    if ([adRevenue.source containsString:@"applovin"]) {
        adjSource = ADJAdRevenueSourceAppLovinMAX;
    } else if ([adRevenue.source containsString:@"mopub"]) {
        adjSource = ADJAdRevenueSourceMopub;
    } else if ([adRevenue.source containsString:@"admob"]) {
        adjSource = ADJAdRevenueSourceAdMob;
    } else if ([adRevenue.source containsString:@"ironsource"]) {
        adjSource = ADJAdRevenueSourceIronSource;
    } else if ([adRevenue.source containsString:@"admost"]) {
        adjSource = ADJAdRevenueSourceAdMost;
    } else if ([adRevenue.source containsString:@"unity"]) {
        adjSource = ADJAdRevenueSourceUnity;
    } else if ([adRevenue.source containsString:@"chartboost"]) {
        adjSource = ADJAdRevenueSourceHeliumChartboost;
    } else {
        return;
    }
    
    double revenue = adRevenue.revenue;
    if (revenue <= 0 || revenue >= 1.0) {
        return;
    }
    
    ADJAdRevenue *adjRevenue = [[ADJAdRevenue alloc] initWithSource:adjSource];
    // pass revenue and currency values
    [adjRevenue setRevenue:revenue currency:adRevenue.currency];
    // pass optional parameters
    [adjRevenue setAdImpressionsCount:1];
    if (adRevenue.unitId != nil && adRevenue.unitId.length > 0) {
        [adjRevenue setAdRevenueUnit:adRevenue.unitId];
    }
    if (adRevenue.placementId != nil && adRevenue.placementId.length > 0) {
        [adjRevenue setAdRevenuePlacement:adRevenue.placementId];
    }
    if (adRevenue.networkName != nil && adRevenue.networkName.length > 0) {
        [adjRevenue setAdRevenueNetwork:adRevenue.networkName];
    }
    
    // track ad revenue
    [Adjust trackAdRevenue:adjRevenue];
}

- (void)trackIAPRevenue:(Yodo1IAPRevenue*)iapRevenue{
    if (iapRevenue == nil) {
        return;
    }
    NSString* eventToken = [[AdjustTokenUtils shared] getEventToken:@"sdk_iap_purchase"];
    if (eventToken == nil || eventToken.length <= 0) {
        return;
    }
    
    float revenueDoulbe = [iapRevenue.revenue doubleValue];
    
    ADJEvent *event = [ADJEvent eventWithEventToken:eventToken];
    [event setRevenue:revenueDoulbe currency:iapRevenue.currency];
    [event setProductId: iapRevenue.productIdentifier];
    if (iapRevenue.transactionId != nil && iapRevenue.transactionId.length > 0) {
        [event setTransactionId:iapRevenue.transactionId];
    }
    NSData *receipt = nil;
    if (iapRevenue.receiptId != nil && iapRevenue.receiptId.length > 0) {
        receipt = [[NSData alloc] initWithBase64EncodedString:iapRevenue.receiptId options:0];
    }
//    ADJPurchase *purchase = [[ADJPurchase alloc] initWithTransactionId:iapRevenue.transactionId productId:iapRevenue.productIdentifier andReceipt:receipt];
//    [Adjust verifyPurchase:purchase completionHandler:^(ADJPurchaseVerificationResult * _Nonnull verificationResult) {
//        NSLog(@"Purchase verification response arrived!");
//        NSLog(@"Status: %@", verificationResult.verificationStatus);
//        NSLog(@"Code: %d", verificationResult.code);
//        NSLog(@"Message: %@", verificationResult.message);
//    }];
    if (receipt != nil) {
        [event setReceipt:receipt];
    }
    [Adjust trackEvent:event];
}

#pragma mark - Deep Link
- (void)handleOpenUrl:(NSURL * _Nonnull)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [self handleIncomingURL:url];
}

- (void)continueUserActivity:(NSUserActivity * _Nonnull)userActivity {
    NSURL *incomingURL = [userActivity webpageURL];
    [self handleIncomingURL:incomingURL];
}

- (void)handleIncomingURL:(NSURL *)url {
    NSURL *incomingURL = url;
    BOOL validURL = (incomingURL != nil && ([[incomingURL absoluteString] containsString:@"adj.st"] || [[incomingURL absoluteString] containsString:@"adjust.com"] || [[incomingURL absoluteString] containsString:@"adj_t"]));
    if (validURL == NO) {
        return;
    }
    
    // call the below method to resolve deep link
    [ADJLinkResolution resolveLinkWithUrl:incomingURL resolveUrlSuffixArray:nil callback:^(NSURL* _Nullable resolvedURL) {
        // add your code below to handle deep link
        // (e.g., open deep link content)
        // resolvedURL object contains the deep link
        YD1LOG(@"resolvedURL. %@", resolvedURL.absoluteString);
        
        NSMutableDictionary* dict = [self getUrlParameterWithUrl:resolvedURL];
        [dict setObject:resolvedURL.host forKey:@"host"];
        [dict setObject:resolvedURL.path forKey:@"path"];
        [dict setObject:resolvedURL.scheme forKey:@"scheme"];
        [dict setObject:resolvedURL.absoluteString forKey:@"link"];
        
        NSString *deepLinkValue = [dict objectForKey:@"adj_label"];
        [dict setObject:(deepLinkValue == nil ? @"" : deepLinkValue) forKey:@"deep_link_value"];
        
        YD1LOG(@"dict. %@", dict);

        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:[self dictionaryToJson:dict] forKey:Y_AF_DEEPLINK];
        [resultDict setObject:[Adjust adid] forKey:Y_AF_ID];
        [self.delegate yodo1DeeplinkResult:resultDict];
        
        // call the below method to send deep link to Adjust backend
        [Adjust appWillOpenUrl:resolvedURL];
    }];
}

- (NSMutableDictionary *)getUrlParameterWithUrl:(NSURL *)url {
    NSMutableDictionary *parm = [[NSMutableDictionary alloc] init];
    //传入url创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    //回调遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];
    return parm;
}

//字典转json格式字符串：
- (NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - Device Identifiers

- (NSDictionary*)deviceIdentifiers {
    NSDictionary *identifier = [[NSDictionary alloc] initWithObjectsAndKeys:[Adjust adid], @"adj_adid", nil];
    return identifier;
}

#pragma mark - AdjustDelegate

/**
 * @brief Optional delegate method that gets called when the attribution information changed.
 *
 * @param attribution The attribution information.
 *
 * @note See ADJAttribution for details.
 */
- (void)adjustAttributionChanged:(nullable ADJAttribution *)attribution {
    YD1LOG(@"adjustAttributionChanged. %@", attribution.dictionary);
}

/**
 * @brief Optional delegate method that gets called when an event is tracked with success.
 *
 * @param successResponse The response information from tracking with success
 *
 * @note See ADJEventSuccess for details.
 */
- (void)adjustEventTrackingSucceeded:(nullable ADJEventSuccess *)successResponse {
    YD1LOG(@"adjustEventTrackingSucceeded, the event(%@) tracking to Adjust succeeded with response %@", successResponse.eventToken, successResponse.jsonResponse);
}

/**
 * @brief Optional delegate method that gets called when an event is tracked with failure.
 *
 * @param failureResponse The response information from tracking with failure
 *
 * @note See ADJEventFailure for details.
 */
- (void)adjustEventTrackingFailed:(nullable ADJEventFailure *)failureResponse {
    YD1LOG(@"adjustEventTrackingFailed, the event(%@) tracking to Adjust failed with response %@", failureResponse.eventToken, failureResponse.jsonResponse);
}

/**
 * @brief Optional delegate method that gets called when an session is tracked with success.
 *
 * @param sessionSuccessResponseData The response information from tracking with success
 *
 * @note See ADJSessionSuccess for details.
 */
- (void)adjustSessionTrackingSucceeded:(nullable ADJSessionSuccess *)sessionSuccessResponseData {
    YD1LOG(@"adjustSessionTrackingSucceeded, the session tracking to Adjust succeeded with response %@", sessionSuccessResponseData.jsonResponse);
}

/**
 * @brief Optional delegate method that gets called when an session is tracked with failure.
 *
 * @param sessionFailureResponseData The response information from tracking with failure
 *
 * @note See ADJSessionFailure for details.
 */
- (void)adjustSessionTrackingFailed:(nullable ADJSessionFailure *)sessionFailureResponseData {
    YD1LOG(@"adjustSessionTrackingFailed, the session tracking to Adjust failed with response %@", sessionFailureResponseData.jsonResponse);
}

/**
 * @brief Optional delegate method that gets called when a deferred deep link is about to be opened by the adjust SDK.
 *
 * @param deeplink The deep link url that was received by the adjust SDK to be opened.
 *
 * @return Boolean that indicates whether the deep link should be opened by the adjust SDK or not.
 */
- (BOOL)adjustDeeplinkResponse:(nullable NSURL *)deeplink {
    NSLog(@"adjustDeeplinkResponse deeplink: %@", deeplink.absoluteString);
    [self handleIncomingURL:deeplink];
    return NO;
}

/**
 * @brief Optional SKAdNetwork pre 4.0 style delegate method that gets called when Adjust SDK sets conversion value for the user.
 *
 * @param conversionValue Conversion value used by Adjust SDK to invoke updateConversionValue: API.
 */
- (void)adjustConversionValueUpdated:(nullable NSNumber *)conversionValue {
    NSLog(@"adjustConversionValueUpdated Conversion value: %@", conversionValue);
}

/**
 * @brief Optional SKAdNetwork 4.0 style delegate method that gets called when Adjust SDK sets conversion value for the user.
 *        You can use this callback even with using pre 4.0 SKAdNetwork.
 *        In that case you can expect coarseValue and lockWindow values to be nil.
 *
 * @param fineValue Conversion value set by Adjust SDK.
 * @param coarseValue Coarse value set by Adjust SDK.
 * @param lockWindow Lock window set by Adjust SDK.
 */
- (void)adjustConversionValueUpdated:(nullable NSNumber *)fineValue
                         coarseValue:(nullable NSString *)coarseValue
                          lockWindow:(nullable NSNumber *)lockWindow {
    NSLog(@"Fine conversion value: %@", fineValue);
    NSLog(@"Coarse conversion value: %@", coarseValue);
    NSLog(@"Will send before conversion value window ends: %u", [lockWindow boolValue]);
}

@end
