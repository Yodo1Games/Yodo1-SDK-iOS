#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Constants for supported ad revenue sources.
 */
extern NSString * __nonnull const Yodo1AdRevenueSourceAppLovinMAX;
extern NSString * __nonnull const Yodo1AdRevenueSourceMopub;
extern NSString * __nonnull const Yodo1AdRevenueSourceAdMob;
extern NSString * __nonnull const Yodo1AdRevenueSourceIronSource;
extern NSString * __nonnull const Yodo1AdRevenueSourceAdMost;
extern NSString * __nonnull const Yodo1AdRevenueSourceUnity;
extern NSString * __nonnull const Yodo1AdRevenueSourceHeliumChartboost;
extern NSString * __nonnull const Yodo1AdRevenueSourcePublisher;

@interface Yodo1AdRevenue : NSObject

@property (nonatomic, strong) NSString* source;
@property (nonatomic, assign) double revenue;
@property (nonatomic, strong) NSString* currency;
@property (nonatomic, strong) NSString* networkName;
@property (nonatomic, strong) NSString* unitId;
@property (nonatomic, strong) NSString* placementId;

- (instancetype)initWithSource:(NSString*)source revenue:(double)revenue currency:(NSString*)currency;
- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end

NS_ASSUME_NONNULL_END
