//
//  Yodo1Product.h
//  Yodo1Purchase
//
//  Created by 饶加锋 on 2022/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ProductType) {
    NonConsumables = 0,     //非消耗品
    Consumables,            //消耗品
    Auto_Subscription,      //自动订阅
    None_Auto_Subscription  //非自动订阅
};

#pragma mark - Yodo1Product

@interface Yodo1Product : NSObject

@property (nonatomic, strong) NSString* uniformProductId;
@property (nonatomic, strong) NSString* channelProductId;
@property (nonatomic, strong) NSString* productName;
@property (nonatomic, strong) NSString* productPrice;
@property (nonatomic, strong) NSString* priceDisplay;
@property (nonatomic, strong) NSString* productDescription;
@property (nonatomic, strong) NSString* currency;
@property (nonatomic, strong) NSString* orderId;
@property (nonatomic, assign) ProductType productType;      // 默认0 商品类型,0-非消耗品;1-消耗品;2-自动订阅;3-非自动订阅
@property (nonatomic, strong) NSString* periodUnit;         //订阅时间: 每周，每月，每年,每2个月...

- (instancetype)initWithDict:(NSDictionary*)dictProduct
                   productId:(NSString*)uniformProductId;
- (instancetype)initWithProduct:(Yodo1Product*)product;

-(NSMutableDictionary*)dictionary;

@end


#pragma mark - Yodo1ProductManager

typedef void (^Yodo1ProductsRequestFailureBlock)(NSError *error);
typedef void (^Yodo1ProductsRequestSuccessBlock)(NSArray *products);

@interface Yodo1ProductManager : NSObject

+ (instancetype)shared;

- (void)initProducts;

- (void)requestProducts:(Yodo1ProductsRequestSuccessBlock)successBlock
                failure:(Yodo1ProductsRequestFailureBlock)failureBlock;

- (void)requestProducts:(NSSet*)identifiers
                success:(Yodo1ProductsRequestSuccessBlock)successBlock
                failure:(Yodo1ProductsRequestFailureBlock)failureBlock;

- (Yodo1Product*)productForIdentifier:(NSString*)productIdentifier;

- (Yodo1Product*)productForStoreIdentifier:(NSString*)storeProductIdentifier;

@end

NS_ASSUME_NONNULL_END
