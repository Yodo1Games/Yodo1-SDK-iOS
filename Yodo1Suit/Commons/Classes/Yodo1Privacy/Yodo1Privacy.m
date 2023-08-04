#import <Foundation/Foundation.h>
#import "Yodo1Privacy.h"

@interface Yodo1Privacy ()

@property(nonatomic,strong)NSMutableDictionary *keyInfo;

@end

@implementation Yodo1Privacy

+ (instancetype)shareInstance
{
    static Yodo1Privacy* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1Privacy alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userConsent = YES;
        _ageRestrictedUser = NO;
        _doNotSell = NO;
    }
    return self;
}

- (BOOL)isReportData {
    if (self.ageRestrictedUser) {
        return NO;
    }
    if (!self.userConsent) {
        return NO;
    }
    if (self.doNotSell) {
        return NO;
    }
    return YES;
}

// Test ENV: https://terms.yodo1.me/terms-of-service/ios/com.featherweightgames.stampede/en
// Prod ENV: https://terms.yodo1.com/terms-of-service/ios/com.featherweightgames.stampede/en
- (NSString*)getTermsOfServiceUrl {
    return [self getTermsOfServiceUrlWithLanguageCode:NSLocale.currentLocale.languageCode];
}

- (NSString*)getTermsOfServiceUrlWithLanguageCode:(NSString*)languageCode {
    NSString *bundleId = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString* termsOfServiceUrl = [NSString stringWithFormat:@"https://terms.yodo1.com/terms-of-service/ios/%@/%@", bundleId, languageCode];
    return termsOfServiceUrl;
}

// Test ENV: https://terms.yodo1.me/privacy/ios/com.sgames.steppypants/en
// Prod ENV: https://terms.yodo1.com/privacy/ios/com.sgames.steppypants/en
- (NSString*)getPrivacyPolicyUrl {
    return [self getPrivacyPolicyUrlWithLanguageCode:NSLocale.currentLocale.languageCode];
}

- (NSString*)getPrivacyPolicyUrlWithLanguageCode:(NSString*)languageCode {
    NSString *bundleId = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString* privacyPolicyUrl = [NSString stringWithFormat:@"https://terms.yodo1.com/privacy/ios/%@/%@", bundleId, languageCode];
    return privacyPolicyUrl;
}


@end
