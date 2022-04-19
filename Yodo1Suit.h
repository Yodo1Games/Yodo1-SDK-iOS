//
//  Yodo1Suit.h
//
//
//  Created by hyx on 17/7/14.
//
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define K_YODO1_SUIT_VERSION  @"1.5.1.3"

@interface Yodo1Suit : NSObject

+ (NSString *)sdkVersion;

//Init Yodo1Suit with appkey.
+ (void)initWithAppKey:(NSString *)appKey;

//Enable/Disable log
+ (void)setLogEnable:(BOOL)enable;

//This can be used by the integrating App to indicate if
//the user falls in any of the GDPR applicable countries
//(European Economic Area).
//consent YES User consents (Behavioral and Contextual Ads).
//NO if they are not.
+ (void)setUserConsent:(BOOL)consent;

// return YES
// Agrees to collect data. The default is to collect data
+ (BOOL)isUserConsent;

//In the US, the Children’s Online Privacy Protection Act (COPPA) imposes
//certain requirements on operators of online services that (a)
//have actual knowledge that the connected user is a child under 13 years of age,
//or (b) operate services (including apps) that are directed to children under 13.
//isBelowConsentAge YES if the user is affected by COPPA, NO if they are not.
+ (void)setTagForUnderAgeOfConsent:(BOOL)isBelowConsentAge;

// return YES It means
// under the age of 16
+ (BOOL)isTagForUnderAgeOfConsent;

//Set whether or not user has opted out of the sale of their personal information.
//doNotSell 'YES' if the user has opted out of the sale of their personal information.
+ (void)setDoNotSell:(BOOL)doNotSell;

// return YES
// Indicates that the user has chosen not to
// sell their personal information
+ (BOOL)isDoNotSell;

@end
