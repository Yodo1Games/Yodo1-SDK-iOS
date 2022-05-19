//
//  Yodo1ClassWrapper.h
//  foundationsample
//
//  Created by hyx on 14-10-14.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Yodo1ClassWrapper : NSObject

/**
 *
 *  @param c         c
 *  @param classType 注册类型，比如视频广告，支付，数据统计分析
 *
 *  @return return value
 */
- (id)initWithClass:(Class)c classType:(NSString*)classType;

@property (nonatomic, readonly) Class theYodo1Class;
@property (nonatomic, assign) BOOL	theEnable;
@property (nonatomic, assign) BOOL	theHide;
@property (nonatomic,readonly) NSString* type;

@end
