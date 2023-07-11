#import "Yodo1AdRevenue.h"

NSString * const Yodo1AdRevenueSourceAppLovinMAX = @"applovin_max_sdk";
NSString * const Yodo1AdRevenueSourceMopub = @"mopub";
NSString * const Yodo1AdRevenueSourceAdMob = @"admob_sdk";
NSString * const Yodo1AdRevenueSourceIronSource = @"ironsource_sdk";
NSString * const Yodo1AdRevenueSourceAdMost = @"admost_sdk";
NSString * const Yodo1AdRevenueSourceUnity = @"unity_sdk";
NSString * const Yodo1AdRevenueSourceHeliumChartboost = @"helium_chartboost_sdk";
NSString * const Yodo1AdRevenueSourcePublisher = @"publisher_sdk";

@implementation Yodo1AdRevenue

- (instancetype)initWithSource:(NSString*)source revenue:(double)revenue currency:(NSString*)currency {
    self = [super init];
    if (self) {
        self.source = source;
        self.revenue = revenue;
        self.currency = currency;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        self.source = [dict objectForKey:@"source"];
        self.revenue = [[dict objectForKey:@"revenue"] doubleValue];
        self.currency = [dict objectForKey:@"currency"];
        self.networkName = [dict objectForKey:@"network_name"];
        self.unitId = [dict objectForKey:@"unit_id"];
        self.placementId = [dict objectForKey:@"placement_id"];
    }
    return self;
}

@end
