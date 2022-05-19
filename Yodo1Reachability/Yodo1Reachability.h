//
//  Yodo1Reachability.h
//
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Yodo1ReachabilityStatus) {
    Yodo1ReachabilityStatusNone  = 0, ///< Not Reachable
    Yodo1ReachabilityStatusWWAN  = 1, ///< Reachable via WWAN (2G/3G/4G)
    Yodo1ReachabilityStatusWiFi  = 2, ///< Reachable via WiFi
};

typedef NS_ENUM(NSUInteger, Yodo1ReachabilityWWANStatus) {
    Yodo1ReachabilityWWANStatusNone  = 0, ///< Not Reachable vis WWAN
    Yodo1ReachabilityWWANStatus2G = 2, ///< Reachable via 2G (GPRS/EDGE)       10~100Kbps
    Yodo1ReachabilityWWANStatus3G = 3, ///< Reachable via 3G (WCDMA/HSDPA/...) 1~10Mbps
    Yodo1ReachabilityWWANStatus4G = 4, ///< Reachable via 4G (eHRPD/LTE)       100Mbps
};

@interface Yodo1Reachability : NSObject

@property (nonatomic, readonly) SCNetworkReachabilityFlags flags;                           ///< Current flags.
@property (nonatomic, readonly) Yodo1ReachabilityStatus status;                                ///< Current status.
@property (nonatomic, readonly) Yodo1ReachabilityWWANStatus wwanStatus NS_AVAILABLE_IOS(7_0);  ///< Current WWAN status.
@property (nonatomic, readonly, getter=isReachable) BOOL reachable;                         ///< Current reachable status.

/// Notify block which will be called on main thread when network changed.
@property (nullable, nonatomic, copy) void (^notifyBlock)(Yodo1Reachability *reachability);

/// Create an object to check the reachability of the default route.
+ (instancetype)reachability;

@end

NS_ASSUME_NONNULL_END
