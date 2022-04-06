//
//  Yodo1Ads.h
//
//
//  Created by hyx on 17/7/14.
//
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define K_YODO1_ADS_VERSION  @"0.0.44"

typedef enum {
    Yodo1AdsEventClose          = 0,   //Close
    Yodo1AdsEventFinish         = 1,   //Finish playing
    Yodo1AdsEventClick          = 2,   //Click ad
    Yodo1AdsEventLoaded         = 3,   //Ad load finish
    Yodo1AdsEventShowSuccess    = 4,   //Display success
    Yodo1AdsEventShowFail       = 5,   //display fail
    Yodo1AdsEventSkip           = 6,   //skip
    Yodo1AdsEventLoadFail       = -1,  //Load of Error
}Yodo1AdsEvent;

typedef enum {
    Yodo1AdsBannerAdAlignLeft               = 1 << 0,
    Yodo1AdsBannerAdAlignHorizontalCenter   = 1 << 1,
    Yodo1AdsBannerAdAlignRight              = 1 << 2,
    Yodo1AdsBannerAdAlignTop                = 1 << 3,
    Yodo1AdsBannerAdAlignVerticalCenter     = 1 << 4,
    Yodo1AdsBannerAdAlignBottom             = 1 << 5,
}Yodo1AdsBannerAdAlign;

/**
 *  Yodo1AdsEvent call back
 *  @param adEvent Apecify the ad event.
 *  @param error ad event error.
 */
typedef void (^Yodo1AdsEventCallback)(Yodo1AdsEvent adEvent,NSError* error);
/**
*  Yodo1RewardGame call back
*  @param reward A JSONString of reward information.
*  @param error Reward game error.
*/
typedef void (^Yodo1RewardGameCallback)(NSString * reward, NSError* error);

@interface Yodo1Ads : NSObject

+ (NSString *)sdkVersion;

//Init Yodo1Ads with appkey.
+ (void)initWithAppKey:(NSString *)appKey;

//Enable/Disable log
+ (void)setLogEnable:(BOOL)enable;

#pragma mark- Banner
//Set banner's call back
+ (void)setBannerCallback:(Yodo1AdsEventCallback)callback;

//Set banner's align
+ (void)setBannerAlign:(Yodo1AdsBannerAdAlign)align;

//Set banner's align,User-controlled viewcontroller
+ (void)setBannerAlign:(Yodo1AdsBannerAdAlign)align
        viewcontroller:(UIViewController*)viewcontroller;

//Set banner's offset
+ (void)setBannerOffset:(CGPoint)point;

//Set the Banner Scale scaling factor x axis direction
//multiple sx,y axis direction multiple sy
+ (void)setBannerScale:(CGFloat)sx sy:(CGFloat)sy;

//Check if banner ad is ready to show
+ (BOOL)bannerIsReady;

//Show banner
+ (void)showBanner;

+ (void)showBanner:(NSString *)placement_id;

//Hide banner
+ (void)hideBanner;

//Remove banner
+ (void)removeBanner;

#pragma mark- Interstitial

//Set interstitial's callback
+ (void)setInterstitialCallback:(Yodo1AdsEventCallback)callback;

//Check if interstitial ad is ready to show
+ (BOOL)interstitialIsReady;

//Show interstitial
+ (void)showInterstitial;
//Show interstitial with placement_id
+ (void)showInterstitialWithPlacement:(NSString *)placement_id;

//Show interstitial,User-controlled viewcontroller
+ (void)showInterstitial:(UIViewController*)viewcontroller;
//Show interstitial,User-controlled viewcontroller with placement_id
+ (void)showInterstitial:(UIViewController *)viewcontroller placement:(NSString *)placement_id;

#pragma mark- Video

//Set video callback
+ (void)setVideoCallback:(Yodo1AdsEventCallback)callback;

//Check if video ad is ready to play
+ (BOOL)videoIsReady;

//Play video ad
+ (void)showVideo;

+ (void)showVideoWithPlacement:(NSString *)placement_id;

//Play video ad,User-controlled viewcontroller
+ (void)showVideo:(UIViewController*)viewcontroller;

+ (void)showVideo:(UIViewController *)viewcontroller placement:(NSString *)placement_id;

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

#pragma mark- RewardGame

//Check reward game is enable or not
+ (BOOL)rewardGameIsEnable;

//Show reward game
+ (void)showRewardGame:(Yodo1RewardGameCallback)reward;

#pragma mark- Splash
//Set splash's callback
+ (void)setSplashCallback:(Yodo1AdsEventCallback)callback;
//Show splash ad
//Show splash ad,App main window
+ (void)showSplash:(UIWindow *)window;
+ (void)showSplash:(UIWindow *)window placement:(NSString *)placement_id;

@end
