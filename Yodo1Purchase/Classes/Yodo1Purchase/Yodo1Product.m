//
//  Yodo1Product.m
//  Yodo1Purchase
//
//  Created by 饶加锋 on 2022/12/13.
//

#import "Yodo1Product.h"

@implementation Yodo1Product

- (instancetype)initWithDict:(NSDictionary*)dictProduct
                   productId:(NSString*)uniformProductId {
    self = [super init];
    if (self) {
        self.uniformProductId = uniformProductId;
        self.channelProductId = [dictProduct objectForKey:@"ChannelProductId"];
        self.productName = [dictProduct objectForKey:@"ProductName"];
        self.productPrice = [dictProduct objectForKey:@"ProductPrice"];
        self.priceDisplay = [dictProduct objectForKey:@"PriceDisplay"];
        self.currency = [dictProduct objectForKey:@"Currency"];
        self.productDescription = [dictProduct objectForKey:@"ProductDescription"];
        self.productType = (ProductType)[[dictProduct objectForKey:@"ProductType"] intValue];
        self.periodUnit = [dictProduct objectForKey:@"PeriodUnit"];
        self.orderId = [dictProduct objectForKey:@"OrderId"];
    }
    return self;
}

- (instancetype)initWithProduct:(Yodo1Product*)product {
    self = [super init];
    if (self) {
        self.uniformProductId = product.uniformProductId;
        self.channelProductId = product.channelProductId;
        self.productName = product.productName;
        self.productPrice = product.productPrice;
        self.priceDisplay = product.priceDisplay;
        self.currency = product.currency;
        self.productDescription = product.productDescription;
        self.productType = product.productType;
        self.periodUnit = product.periodUnit;
        self.orderId = product.orderId;
    }
    return self;
}

@end
