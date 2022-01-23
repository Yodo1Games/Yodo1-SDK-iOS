//
//  OpenSuitShareUI.h
//  ShareManager
//
//  Created by Jerry on 12/31/14.
//  Copyright (c) 2016 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "OpenSuitSMConstant.h"

/**
 分享界面关闭回调

 @param snsType 分享类型平台
 */
typedef void (^OpenSuitShareUIBlock)(Yodo1SNSType snsType);

@interface OpenSuitShareUI : NSObject

@property(nonatomic,assign)BOOL isLandscapeOrPortrait;/*支持横竖屏切换，默认NO*/

+ (OpenSuitShareUI *)sharedInstance;


/**
 展示分享界面

 @param snsTypes 平台类型
        比如 数组：@[@(Yodo1SNSTypeSinaWeibo) ,@(Yodo1SNSTypeWeixinMoments),
                @(Yodo1SNSTypeWeixinContacts), @(Yodo1SNSTypeTencentQQ),
                @(Yodo1SNSTypeFacebook), @(Yodo1SNSTypeTwitter)]
 
 @param bock 关闭界面block
 */
- (void)showShareWithTypes:(NSArray*)snsTypes
                     block:(OpenSuitShareUIBlock)bock;

@end
