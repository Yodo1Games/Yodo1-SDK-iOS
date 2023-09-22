//
//  Yodo1PurchaseUtils.m
//  Yodo1Purchase
//

#import "Yodo1PurchaseUtils.h"
#import "Yodo1Tool+Commons.h"

@implementation Yodo1PurchaseUtils

+ (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString {
    return [Yd1OpsTools localizedString:@"Yodo1SDKStrings" key:key defaultString:defaultString];
}

@end
