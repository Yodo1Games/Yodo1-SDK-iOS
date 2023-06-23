//
//  YD1AgePrivacyView.h
//  gdpr_demo
//
//  Created by yixian huang on 2019/8/26.
//  Copyright © 2019 yixian huang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "YD1AgePrivacyManager.h"

#ifndef YD1AgePrivacyView_h
#define YD1AgePrivacyView_h

typedef void(^AgePrivacyBlock)(BOOL accept,BOOL child,int age);

@interface YD1AgePrivacyView : UIView

@property(nonatomic,copy)AgePrivacyBlock agePrivacyBlock;
@property(nonatomic,strong)NSString* userAgreementURL;
@property(nonatomic,strong)NSString* privacyPolicyURL;
@property(nonatomic,assign)int childAgeLimit;
@end

@interface YD1PrivacyViewController : UIViewController
@property(nonatomic,copy)PrivacyCallback privacyBlock;
@property(nonatomic,strong)NSString* userAgreementURL;
@property(nonatomic,strong)NSString* privacyPolicyURL;
@property(nonatomic,assign)BOOL isAccept;
@end


typedef void(^UpdateAgePrivacyBlock)(BOOL accept);
@interface YD1AgePrivacyUpdateView : UIView
@property(nonatomic,copy)UpdateAgePrivacyBlock agePrivacyUpdateBlock;
@property(nonatomic,strong)NSString* privacyURL;
@end

@interface YD1UISlider : UISlider

@end

@interface PrivacyUtils : NSObject

///设置游戏语言
+ (void)selectLocalLanguage:(NSString*)language
        isSectlocalLanguage:(BOOL)isSelected;

+ (NSString *)preferredLanguage;

///设置 selectLocalLanguage 指定语言 可以加载指定的
+ (NSString *)localizedStringForKey:(NSString *)key
                      defaultString:(NSString *)defaultString;

///specifiedLanguage 指定语言code
///defaultString 默认字符
+ (NSString *)localizedStringForKey:(NSString *)key
                  specifiedLanguage:(NSString *)specifiedLanguage
                        withDefault:(NSString *)defaultString;
@end

#endif /* YD1AgePrivacyView_h */
