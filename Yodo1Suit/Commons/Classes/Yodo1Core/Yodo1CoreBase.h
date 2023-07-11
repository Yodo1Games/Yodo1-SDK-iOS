//
//  Yodo1CoreBase.h
//  Yodo1sdk
//
//  Created by hyx on 2019/8/30.
//

#import <Foundation/Foundation.h>
#import "Yodo1Object.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark this file is private, do not import
@interface Yodo1CoreBase : Yodo1Object

// lifecycle/runloop for moduler
@property (nonatomic,retain) NSMutableDictionary *sharedAppDelegate;

// dispatch_once
@property (nonatomic,retain) NSMutableDictionary *sharedInstanceDic;

@property (nonatomic,retain) NSMutableDictionary *sharedObjDic;
@property (nonatomic,retain) NSMutableDictionary *sharedObjBindDic;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
