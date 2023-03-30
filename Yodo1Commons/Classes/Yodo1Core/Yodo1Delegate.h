//
//  Yodo1Delegate.h
//  Yodo1sdk
//
//  Created by hyx on 2019/8/29.
//

#import <Foundation/Foundation.h>
#import "Yodo1Object.h"

@interface Yodo1Delegate : Yodo1Object

@property (nonatomic, retain) NSObject *delegate;

- (void)cc_performSelector:(SEL)selector params:(id)param,...;

@end
