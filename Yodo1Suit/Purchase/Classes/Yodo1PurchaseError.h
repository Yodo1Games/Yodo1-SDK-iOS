//
//  Yodo1PaymentError.h
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PaymentErrorCode) {
    PaymentErrorCodeUnKnow = -2,            //Error code indicating that an unknown or unexpected error occurred.
    PaymentErrorCodeNotNetwork = -1,        //Error code indicating that no network
    PaymentErrorCodeFail = 0,               //
    PaymentErrorCodeSuccess = 1,            //
    PaymentErrorCodeCancelled = 2,          //Error code indicating that the user canceled a payment request.
    PaymentErrorCodeVerifyOrderFail = 3,    //Error code indicating that failed to verify order by IAP payment.
    PaymentErrorCodeCannelForPrivacy = 4,   //Error code indicating that purchase cancelled when the user click the Terms of Service and Privacy Agreement buttons.
    PaymentErrorCodeUserLoginFail = 103,    //Error code indicating that the user is not logged in Yodo1 ucenter
    PaymentErrorCodeLossOrderId = 203,      //丢失订单
    PaymentErrorCodeUserFail = 205,         //设备不允许支付
    PaymentErrorCodeCreateOrder = 206,      //Failed to create the order from IAP payment
    PaymentErrorCodeOwn = 208,              //用户已经拥有该商品
    PaymentErrorCodeInvalidProductId = 209, //Error code indicating that the product identifier is invalid.
    PaymentErrorCodeAppleFail = 210,
};

NS_ASSUME_NONNULL_END
