#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AdjustTokenUtils : NSObject

+ (AdjustTokenUtils*)shared;

- (NSString*)getEventToken:(NSString*) eventName;

@end
