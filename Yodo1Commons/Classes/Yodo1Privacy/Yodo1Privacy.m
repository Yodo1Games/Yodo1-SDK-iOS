#import <Foundation/Foundation.h>
#import "Yodo1Privacy.h"

@interface Yodo1Privacy ()

@property(nonatomic,strong)NSMutableDictionary *keyInfo;

@end

@implementation Yodo1Privacy

+ (instancetype)shareInstance
{
    static Yodo1Privacy* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1Privacy alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userConsent = YES;
        _ageRestrictedUser = NO;
        _doNotSell = NO;
    }
    return self;
}

- (BOOL)isReportData {
    if (self.ageRestrictedUser) {
        return NO;
    }
    if (!self.userConsent) {
        return NO;
    }
    if (self.doNotSell) {
        return NO;
    }
    return YES;
}

@end
