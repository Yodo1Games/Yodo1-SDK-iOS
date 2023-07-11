#import "Yodo1PurchaseDataAnalytics.h"

#import "Yodo1Base.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1AnalyticsManager.h"

/// 超级属性
//static NSString* const __gameName               = @"gameName";
//static NSString* const __gameVersion            = @"gameVersion";
//static NSString* const __gameBundleId           = @"gameBundleId";
/// 付费方式属性
static NSString* const __paymentChannelCode     = @"paymentChannelCode";
static NSString* const __paymentChannelVersion  = @"paymentChannelVersion";
/// IAP的公共属性
static NSString* const __itemCode               = @"itemCode";
static NSString* const __itemName               = @"itemName";
static NSString* const __itemType               = @"itemType";
static NSString* const __itemCurrency           = @"itemCurrency";
static NSString* const __itemPrice              = @"itemPrice";
static NSString* const __channelItemCode        = @"channelItemCode";
/// 属性值
static NSString* const __result                 = @"result";
static NSString* const __success                = @"success";
static NSString* const __fail                   = @"fail";
//static NSString* const __serverVersion          = @"serverVersion";
static NSString* const __yodo1ErrorCode         = @"yodo1ErrorCode";
static NSString* const __yodo1ErrorMessage       = @"yodo1ErrorMessage";
static NSString* const __status                 = @"status";

@interface Yodo1PurchaseDataAnalytics() {
}

@end

@implementation Yodo1PurchaseDataAnalytics

+ (instancetype)shared {
    return [Yodo1Base.shared cc_registerSharedInstance:self block:^{
        [Yodo1PurchaseDataAnalytics.shared initProperties];
    }];
}

- (void)initProperties {
    _superProperty = [NSMutableDictionary dictionary];
    _itemProperty = [NSMutableDictionary dictionary];
    //公共属性
//    [_superProperty setObject:Yodo1PurchaseSdkVersion forKey:__sdkVersion];
    // 付费方式属性
    [_superProperty setObject:Yodo1Tool.shared.paymentChannelCodeValue forKey:__paymentChannelCode];
    [_superProperty setObject:Yodo1PurchaseSdkVersion forKey:__paymentChannelVersion];
}

- (void)updateItemProperties:(Yodo1Product*) product {
    if([self.itemProperty count] > 0){
        [self.itemProperty removeAllObjects];
    }
    [self.itemProperty setObject:product.uniformProductId ? :@"" forKey:__itemCode];
    [self.itemProperty setObject:product.productName ? :@"" forKey:__itemName];
    [self.itemProperty setObject:[NSString stringWithFormat:@"%d",product.productType]  forKey:__itemType];
    [self.itemProperty setObject:product.productPrice ? :@"" forKey:__itemPrice];
    [self.itemProperty setObject:product.currency ? :@"" forKey:__itemCurrency];
    [self.itemProperty setObject:product.channelProductId forKey:__channelItemCode];
}

- (void)trackOrderRequest:(BOOL)success {
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    [properties setObject:success?__success:__fail forKey:__result];
    [properties addEntriesFromDictionary:_superProperty];
    [properties addEntriesFromDictionary:_itemProperty];
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:properties error:nil]);
    [Yodo1AnalyticsManager.sharedInstance trackEvent:@"order_Request" eventValues:properties];
}

- (void)trackOrderPending {
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    [properties addEntriesFromDictionary:_superProperty];
    [properties addEntriesFromDictionary:_itemProperty];
    [Yodo1AnalyticsManager.sharedInstance trackEvent:@"order_Pending" eventValues:properties];
}

- (void)trackOrderItemReceived:(BOOL)success {
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    [properties setObject:success?@"成功":@"失败" forKey:__status];
    [properties addEntriesFromDictionary:_superProperty];
    [properties addEntriesFromDictionary:_itemProperty];
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:properties error:nil]);
    [Yodo1AnalyticsManager.sharedInstance trackEvent:@"order_Item_Received" eventValues:properties];
}

- (void)trackReplaceOrder {
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    [properties addEntriesFromDictionary:_superProperty];
    [properties addEntriesFromDictionary:_itemProperty];
    
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:properties error:nil]);
    [Yodo1AnalyticsManager.sharedInstance trackEvent:@"replace_Order" eventValues:properties];
}

- (void)trackOrderError:(NSNumber*) errorCode errorMessage:(NSString *)errorMessage {
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    [properties addEntriesFromDictionary:_superProperty];
    [properties addEntriesFromDictionary:_itemProperty];
    
    [properties setObject:errorCode forKey:__yodo1ErrorCode];
    [properties setObject:errorMessage forKey:__yodo1ErrorMessage];
    YD1LOG(@"%@",[Yd1OpsTools stringWithJSONObject:properties error:nil]);
    [Yodo1AnalyticsManager.sharedInstance trackEvent:@"order_Error" eventValues:properties];
}

@end
