//
//  Yodo1UAAdapterBase.m
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1UAAdapterBase.h"


@implementation Yodo1UAAdapterBase

- (id)initWithAnalytics:(UAInitConfig*)initConfig
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setCustomUserId:(NSString *)userId{}

- (void)setAdditionalData:(NSDictionary *)customData{}

- (void)trackEvent:(NSString *)eventName withValues:(NSDictionary *)eventData {}

- (void)validateAndTrackInAppPurchase:(NSString*)productIdentifier
                                price:(NSString*)price
                             currency:(NSString*)currency
                        transactionId:(NSString*)transactionId{}

- (void)setDeeplink{}

- (void)useReceiptValidationSandbox:(BOOL)isConsent{}

@end
