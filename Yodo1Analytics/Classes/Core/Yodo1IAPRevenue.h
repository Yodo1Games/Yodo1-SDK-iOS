#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1IAPRevenue : NSObject

@property (nonatomic, strong) NSString* revenue;
@property (nonatomic, strong) NSString* currency;
@property (nonatomic, strong) NSString* productIdentifier;
@property (nonatomic, strong) NSString* transactionId;
@property (nonatomic, strong) NSString* receiptId;

- (instancetype)initWithDict:(NSDictionary*)dic;

@end

NS_ASSUME_NONNULL_END
