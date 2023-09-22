//
//  Yodo1Reachability.m
//

#import "Yodo1Reachability.h"
#import <objc/message.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

static Yodo1ReachabilityStatus Yodo1ReachabilityStatusFromFlags(SCNetworkReachabilityFlags flags, BOOL allowWWAN) {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return Yodo1ReachabilityStatusNone;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
        (flags & kSCNetworkReachabilityFlagsTransientConnection)) {
        return Yodo1ReachabilityStatusNone;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) && allowWWAN) {
        return Yodo1ReachabilityStatusWWAN;
    }
    
    return Yodo1ReachabilityStatusWiFi;
}

static void Yodo1ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    Yodo1Reachability *self = ((__bridge Yodo1Reachability *)info);
    if (self.notifyBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.notifyBlock(self);
        });
    }
}

@interface Yodo1Reachability ()
@property (nonatomic, assign) SCNetworkReachabilityRef ref;
@property (nonatomic, assign) BOOL scheduled;
@property (nonatomic, assign) BOOL allowWWAN;
@end

@implementation Yodo1Reachability

+ (dispatch_queue_t)sharedQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.yodo1.analytics.reachability", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (instancetype)init {
    /*
     See Apple's Reachability implementation and readme:
     The address 0.0.0.0, which reachability treats as a special token that 
     causes it to actually monitor the general routing status of the device, 
     both IPv4 and IPv6.
     https://developer.apple.com/library/ios/samplecode/Reachability/Listings/ReadMe_md.html#//apple_ref/doc/uid/DTS40007324-ReadMe_md-DontLinkElementID_11
     */
    struct sockaddr_in zero_addr;
    bzero(&zero_addr, sizeof(zero_addr));
    zero_addr.sin_len = sizeof(zero_addr);
    zero_addr.sin_family = AF_INET;
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zero_addr);
    return [self initWithRef:ref];
}

- (instancetype)initWithRef:(SCNetworkReachabilityRef)ref {
    if (!ref) return nil;
    self = super.init;
    if (!self) return nil;
    _ref = ref;
    _allowWWAN = YES;
    return self;
}

- (void)dealloc {
    self.notifyBlock = nil;
    self.scheduled = NO;
    CFRelease(self.ref);
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)setScheduled:(BOOL)scheduled {
    if (_scheduled == scheduled) return;
    _scheduled = scheduled;
    if (scheduled) {
        SCNetworkReachabilityContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
        SCNetworkReachabilitySetCallback(self.ref, Yodo1ReachabilityCallback, &context);
        SCNetworkReachabilitySetDispatchQueue(self.ref, [self.class sharedQueue]);
    } else {
        SCNetworkReachabilitySetDispatchQueue(self.ref, NULL);
    }
}

- (SCNetworkReachabilityFlags)flags {
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(self.ref, &flags);
    return flags;
}

- (Yodo1ReachabilityStatus)status {
    return Yodo1ReachabilityStatusFromFlags(self.flags, self.allowWWAN);
}

- (Yodo1ReachabilityWWANStatus)wwanStatus {
    NSString* radio = [self currentRadio];
    if ([radio isEqualToString:@"NULL"]) {
        return Yodo1ReachabilityWWANStatusNone;
    } else if ([radio isEqualToString:@"2G"]) {
        return Yodo1ReachabilityWWANStatus2G;
    } else if ([radio isEqualToString:@"3G"]) {
        return Yodo1ReachabilityWWANStatus3G;
    } else if ([radio isEqualToString:@"4G"]) {
        return Yodo1ReachabilityWWANStatus4G;
    } else if ([radio isEqualToString:@"5G"]) {
        return Yodo1ReachabilityWWANStatus5G;
    }
    return Yodo1ReachabilityWWANStatusNone;
}

- (NSString*)networkType {
    NSString* type = @"NONE";
    Yodo1ReachabilityStatus reachStatus = [Yodo1Reachability reachability].status;
    if (reachStatus == Yodo1ReachabilityStatusWiFi) {
        type = @"WIFI";
    }else if(reachStatus == Yodo1ReachabilityStatusWWAN){
        if (![[self currentRadio] isEqualToString:@"NULL"]) {
            type = [self currentRadio];
        }
    }
    return type;
}

- (BOOL)isReachable {
    return self.status != Yodo1ReachabilityStatusNone;
}

+ (instancetype)reachability {
    static Yodo1Reachability *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1Reachability alloc] init];
    });
    return sharedInstance;
}

- (void)setNotifyBlock:(void (^)(Yodo1Reachability *reachability))notifyBlock {
    _notifyBlock = [notifyBlock copy];
    self.scheduled = (self.notifyBlock != nil);
}

- (NSString *)currentRadio {
    NSString *networkType = @"NULL";
    @try {
        static CTTelephonyNetworkInfo *info = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            info = [[CTTelephonyNetworkInfo alloc] init];
        });
        NSString *currentRadio = nil;
#ifdef __IPHONE_12_0
        if (@available(iOS 12.0, *)) {
            NSDictionary *serviceCurrentRadio = [info serviceCurrentRadioAccessTechnology];
            if ([serviceCurrentRadio isKindOfClass:[NSDictionary class]] && serviceCurrentRadio.allValues.count>0) {
                currentRadio = serviceCurrentRadio.allValues[0];
            }
        }
#endif
        if (currentRadio == nil && [info.currentRadioAccessTechnology isKindOfClass:[NSString class]]) {
            currentRadio = info.currentRadioAccessTechnology;
        }
        
        if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
            networkType = @"4G";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyeHRPD] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyHSDPA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            networkType = @"3G";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyEdge] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyGPRS]) {
            networkType = @"2G";
        }
#ifdef __IPHONE_14_1
        else if (@available(iOS 14.1, *)) {
            if ([currentRadio isKindOfClass:[NSString class]]) {
                if([currentRadio isEqualToString:CTRadioAccessTechnologyNRNSA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyNR]) {
                    networkType = @"5G";
                }
            }
        }
#endif
    } @catch (NSException *exception) {
//        TDLogError(@"%@: %@", self, exception);
    }
    
    return networkType;
}

@end
