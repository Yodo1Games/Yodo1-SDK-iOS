#ifndef Yodo1Privacy_h
#define Yodo1Privacy_h

#import <Foundation/Foundation.h>

@interface Yodo1Privacy : NSObject

@property (nonatomic, assign) BOOL userConsent;
@property (nonatomic, assign) BOOL ageRestrictedUser;
@property (nonatomic, assign) BOOL doNotSell;

+ (instancetype)shareInstance;

- (BOOL)isReportData;

@end

#endif /* Yodo1KeyInfo_h */
