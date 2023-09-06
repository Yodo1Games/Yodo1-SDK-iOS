#ifndef Yodo1Privacy_h
#define Yodo1Privacy_h

#import <Foundation/Foundation.h>

@interface Yodo1Privacy : NSObject

@property (nonatomic, assign) BOOL userConsent;
@property (nonatomic, assign) BOOL ageRestrictedUser;
@property (nonatomic, assign) BOOL doNotSell;

+ (instancetype)shareInstance;

- (BOOL)isReportData;

- (NSString*)getTermsOfServiceUrl;
- (NSString*)getTermsOfServiceUrlWithLanguageCode:(NSString*)languageCode;
- (NSString*)getPrivacyPolicyUrl;
- (NSString*)getPrivacyPolicyUrlWithLanguageCode:(NSString*)languageCode;

@end

#endif /* Yodo1Privacy_h */
