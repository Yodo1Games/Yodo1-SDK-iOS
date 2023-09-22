//
//  Yodo1Product.m
//  Yodo1Purchase
//
//  Created by 饶加锋 on 2022/12/13.
//

#import "Yodo1Product.h"
#import <StoreKit/StoreKit.h>
#import "RMStore.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Reachability.h"
#import "Yodo1PurchaseUtils.h"

#pragma mark - Yodo1Product

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

-(NSMutableDictionary*)dictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.uniformProductId == nil?@"":self.uniformProductId forKey:@"productId"];
    [dict setObject:self.channelProductId == nil?@"":self.channelProductId forKey:@"marketId"];
    [dict setObject:self.productName == nil?@"":self.productName forKey:@"productName"];
    [dict setObject:self.orderId == nil?@"":self.orderId forKey:@"orderId"];
    
    NSString* price = self.productPrice;
    
    NSString* priceDisplay = [NSString stringWithFormat:@"%@ %@",price,self.currency];
    [dict setObject:priceDisplay == nil?@"":priceDisplay forKey:@"priceDisplay"];
    [dict setObject:self.productPrice == nil?@"":self.productPrice forKey:@"price"];
    [dict setObject:self.productDescription == nil?@"":self.productDescription forKey:@"description"];
    [dict setObject:[NSNumber numberWithInt:(int)self.productType] forKey:@"ProductType"];
    [dict setObject:self.currency == nil?@"":self.currency forKey:@"currency"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"coin"];
    [dict setObject:self.periodUnit == nil?@"":self.periodUnit forKey:@"periodUnit"];

    return dict;
}

@end

#pragma mark - Yodo1ProductManager

@interface Yodo1ProductManager() {
    NSMutableDictionary* _products;
}

@end

@implementation Yodo1ProductManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[Yodo1ProductManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _products = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)initProducts {
    NSString* pathName = @"Yodo1KeyConfig.bundle/Yodo1ProductInfo";
    NSString* path=[NSBundle.mainBundle pathForResource:pathName ofType:@"plist"];
    NSDictionary* productInfo =[NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (productInfo.count == 0) {
        YD1LOG(@"Not found the products information in Yodo1ProductInof.plist file, please check it.");
        return;
    }
    
    for (id key in productInfo){
        NSDictionary* item = [productInfo objectForKey:key];
        Yodo1Product* product = [[Yodo1Product alloc] initWithDict:item productId:key];
        [_products setObject:product forKey:key];
    }
    
    [self requestProducts];

    __weak typeof(self) weakSelf = self;
    [Yodo1Reachability.reachability setNotifyBlock:^(Yodo1Reachability * _Nonnull reachability) {
        if (reachability.reachable) {
            [weakSelf requestProducts];
        }
    }];
}

- (void)requestProducts {
    NSSet* productIds = [NSSet setWithArray:[_products allKeys]];
    [self requestProducts:productIds success:^(NSArray *products) {
    
    } failure:^(NSError *error) {

    }];
}

- (void)requestProducts:(Yodo1ProductsRequestSuccessBlock)successBlock failure:(Yodo1ProductsRequestFailureBlock)failureBlock {
    NSSet* productIds = [NSSet setWithArray:[_products allKeys]];
    [self requestProducts:productIds success:successBlock failure:failureBlock];
}

- (void)requestProducts:(NSSet *)identifiers success:(Yodo1ProductsRequestSuccessBlock)successBlock failure:(Yodo1ProductsRequestFailureBlock)failureBlock {
    NSMutableArray* storeIdentifiersArray = [NSMutableArray array];
    for (NSString* identifier in identifiers) {
        Yodo1Product* yodoProduct = [self productForIdentifier:identifier];
        if (yodoProduct == nil || yodoProduct.channelProductId == nil || yodoProduct.channelProductId.length == 0) {
            continue;
        }
        [storeIdentifiersArray addObject:yodoProduct.channelProductId];
    }
    NSSet* storeIdentifiers = [NSSet setWithArray:storeIdentifiersArray];

    __weak typeof(self) weakSelf = self;
    [RMStore.defaultStore requestProducts:storeIdentifiers success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSArray* yodo1Products = [weakSelf updateProductsWithSKProdcuts:products];
        if (successBlock) {
            successBlock(yodo1Products);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

- (NSArray*)updateProductsWithSKProdcuts:(NSArray *)skProducts {
    NSMutableArray* yodo1Products = [NSMutableArray array];

    for (NSString* productIdentifier in [_products allKeys]) {
        Yodo1Product* product = [_products objectForKey:productIdentifier];
        for (SKProduct* sk in skProducts) {
            if ([sk.productIdentifier isEqualToString:product.channelProductId]) {
                product.productName = sk.localizedTitle;
                product.channelProductId = sk.productIdentifier;
                product.productPrice = [sk.price stringValue];
                product.productDescription = sk.localizedDescription;
                product.currency = [Yd1OpsTools currencyCode:sk.priceLocale];
                product.priceDisplay = [self diplayPrice:sk];
                product.periodUnit = [self periodUnitWithProduct:sk];
                
                [yodo1Products addObject:product];
            }
        }
    }
    
    return yodo1Products;
}

- (Yodo1Product*)productForIdentifier:(NSString*)productIdentifier {
    return [_products objectForKey:productIdentifier];
}

- (Yodo1Product*)productForStoreIdentifier:(NSString*)storeProductIdentifier {
    for (Yodo1Product *product in [_products allValues]) {
        if (product == nil || product.channelProductId == nil || product.channelProductId.length == 0) {
            continue;
        }
        if ([product.channelProductId isEqualToString:storeProductIdentifier]) {
            return product;
        }
    }
    return nil;
}

- (NSString *)diplayPrice:(SKProduct *)product {
    return [NSString stringWithFormat:@"%@ %@",[self productPrice:product],[Yd1OpsTools currencyCode:product.priceLocale]];
}

- (NSString *)productPrice:(SKProduct *)product {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    [numberFormatter setCurrencySymbol:@""];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    return formattedPrice;
}

- (NSString*)periodUnitWithProduct:(SKProduct*)product {
    if (@available(iOS 11.2, *)) {
        NSString* unit = @"";
        int numberOfUnits = (int)product.subscriptionPeriod.numberOfUnits;
        switch (product.subscriptionPeriod.unit)
        {
            case SKProductPeriodUnitDay:
            {
                if (numberOfUnits == 7) {
                    unit = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionWeek" withDefault:@"每周"];
                }else if (numberOfUnits == 30){
                    unit = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionMonth" withDefault:@"每月"];
                } else {
                    unit = [NSString stringWithFormat:[Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionDay" withDefault:@"每%d天"],numberOfUnits];
                }
            }
                break;
            case SKProductPeriodUnitWeek:
            {
                if (numberOfUnits == 1) {
                    unit = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionWeek" withDefault:@"每周"];
                } else {
                    unit = [NSString stringWithFormat:[Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionWeeks" withDefault:@"每%d周"],numberOfUnits];
                }
            }
                break;
            case SKProductPeriodUnitMonth:
            {
                if (numberOfUnits == 1) {
                    unit = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionMonth" withDefault:@"每月"];
                } else {
                    unit = [NSString stringWithFormat:[Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionMonths" withDefault:@"每%d个月"],numberOfUnits];
                }
            }
                break;
            case SKProductPeriodUnitYear:
            {
                if (numberOfUnits == 1) {
                    unit = [Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionYear" withDefault:@"每年"];
                } else {
                    unit = [NSString stringWithFormat:[Yodo1PurchaseUtils localizedStringForKey:@"SubscriptionYears" withDefault:@"每%d年"],numberOfUnits];
                }
            }
                break;
        }
        return unit;
    } else {
        return @"";
    }
    return @"";
}

@end
