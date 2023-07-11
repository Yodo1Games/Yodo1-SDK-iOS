#import <Foundation/Foundation.h>

#import "Yodo1Product.h"

NS_ASSUME_NONNULL_BEGIN

#define Yodo1PurchaseSdkVersion @"6.2.2"

@interface Yodo1PurchaseDataAnalytics : NSObject

@property (nonatomic,strong)NSMutableDictionary* superProperty;
@property (nonatomic,strong)NSMutableDictionary* itemProperty;

+ (instancetype)shared;

- (void)updateItemProperties:(Yodo1Product*) product;

- (void)trackOrderRequest:(BOOL)success;

- (void)trackOrderPending;

- (void)trackOrderItemReceived:(BOOL)success;

- (void)trackReplaceOrder;

- (void)trackOrderError:(NSNumber*) errorCode errorMessage:(NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
