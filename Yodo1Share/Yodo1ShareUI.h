//
//  Yodo1ShareUI.h
//  ShareManager
//
//  Created by Jerry on 12/31/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Yodo1SMConstant.h"

/**
 分享界面关闭回调

 @param snsType 分享类型平台
 */
typedef void (^Yodo1ShareUIBlock)(Yodo1SNSType snsType);

@interface Yodo1ShareUI : NSObject

@property(nonatomic,assign)BOOL isLandscapeOrPortrait;/*支持横竖屏切换，默认NO*/

+ (Yodo1ShareUI *)sharedInstance;


/**
 展示分享界面

 @param snsTypes 平台类型
        比如 数组：@[@(Yodo1SNSTypeSinaWeibo) ,@(Yodo1SNSTypeWeixinMoments),
                @(Yodo1SNSTypeWeixinContacts), @(Yodo1SNSTypeTencentQQ),
                @(Yodo1SNSTypeFacebook), @(Yodo1SNSTypeTwitter)]
 
 @param bock 关闭界面block
 */
- (void)showShareWithTypes:(NSArray*)snsTypes
                     block:(Yodo1ShareUIBlock)bock;

@end
