#import "Yodo1IAPRevenue.h"

@implementation Yodo1IAPRevenue

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        self.revenue = [dict objectForKey:@"revenue"];
        self.currency = [dict objectForKey:@"currency"];
        self.productIdentifier = [dict objectForKey:@"product_identifier"];
        self.transactionId = [dict objectForKey:@"transaction_id"];
        self.receiptId = [dict objectForKey:@"receipt_id"];
    }
    return self;
}

@end
