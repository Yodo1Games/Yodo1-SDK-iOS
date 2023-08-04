//
//  YD1AgePrivacyView.m
//  gdpr_demo
//
//  Created by yixian huang on 2019/8/26.
//  Copyright © 2019 yixian huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YD1AgePrivacyView.h"
#import "YD1Layout.h"
#import "Yodo1Base.h"

#define RGBACOLOR(R, G, B, A) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:A]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static bool isSelectLanguage = false;
static NSString* yd1SpecifiedLanguage  = @"en";
static NSBundle *yd1Bundle = nil;

@interface YD1AgePrivacyView () {
    UILabel* titleAge;
    YD1UISlider* slider;
}

@end

@implementation YD1AgePrivacyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self createUI];
}

- (void)createUI {
    self.backgroundColor = [UIColor clearColor];
    UIView* backgroundView = [UIView new];
    backgroundView.frame = self.frame;
    backgroundView.backgroundColor = [UIColor colorWithRed:0.5
                                                     green:0.5
                                                      blue:0.5
                                                     alpha:0.3f];
    [self addSubview:backgroundView];
    
    UIView* ageView = [UIView new];
    ageView.backgroundColor = UIColor.whiteColor;
    [backgroundView addSubview:ageView];
    [ageView makeLayout:^(YD1MakeLayout *make) {
        make.width.yd1_equalTo(315);
        make.height.yd1_equalTo(315);
        make.center.yd1_equalTo(self);
    }];
    
    UIView* titleBackground = [UIView new];
    titleBackground.backgroundColor = UIColorFromRGB(0xff359ff2);
    [ageView addSubview:titleBackground];
    [titleBackground makeLayout:^(YD1MakeLayout *make) {
        make.width.yd1_equalTo(ageView.yd1_width);
        make.height.yd1_equalTo(40);
    }];
    
    UILabel* title = [UILabel new];
    [titleBackground addSubview:title];
    title.text = [PrivacyUtils localizedStringForKey:@"privacyTitle"
                                       defaultString:@"How old are you?"];
    title.adjustsFontSizeToFitWidth = YES;
    title.textAlignment = NSTextAlignmentCenter;
    
    [title makeLayout:^(YD1MakeLayout *make) {
        make.center.yd1_equalTo(titleBackground.yd1_center);
        make.width.yd1_equalTo(titleBackground.yd1_width);
        make.height.yd1_equalTo(titleBackground.yd1_height);
    }];
    
    titleAge = [UILabel new];
    titleAge.text = [self ageWithValue:@"0"];
    titleAge.textColor = UIColor.blackColor;
    titleAge.textAlignment = NSTextAlignmentCenter;
    [ageView addSubview:titleAge];
    [titleAge makeLayout:^(YD1MakeLayout *make) {
        make.centerX.yd1_equalTo(ageView.yd1_centerX);
        make.top.yd1_equalTo(titleBackground.yd1_bottom).offset(10);
        make.width.yd1_equalTo(ageView.yd1_width);
        make.height.yd1_equalTo(30);
    }];
    
    NSArray *scoreLabels =  @[@"0",@"20",@"40",@"60",@"80"];
    [scoreLabels enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *la = [UILabel new];
        la.text = obj;
        la.textAlignment = NSTextAlignmentCenter;
        la.font = [UIFont systemFontOfSize:12.f];
        la.textColor = [UIColor grayColor];
        [ageView addSubview:la];
        [la makeLayout:^(YD1MakeLayout *make) {
            make.size.yd1_equalTo(CGSizeMake(25, 14));
            make.top.yd1_equalTo(self->titleAge.yd1_bottom).offset(10);
            float x = 24 + 60*idx;
            make.left.yd1_equalTo(ageView.yd1_left).offset(x);
        }];
    }];
    
    slider = [YD1UISlider new];
    slider.minimumValue = 0;
    slider.maximumValue = 80;
    slider.value  = 0;
    slider.continuous = YES;
    slider.minimumTrackTintColor= [UIColor orangeColor];
    slider.maximumTrackTintColor=[UIColor grayColor];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [ageView addSubview:slider];
    [slider makeLayout:^(YD1MakeLayout *make) {
        make.centerX.yd1_equalTo(ageView.yd1_centerX);
        make.top.yd1_equalTo(self->titleAge.yd1_bottom).offset(35);
        make.width.yd1_equalTo(246);
    }];
    
    UILabel* titlePrompt = [UILabel new];
    titlePrompt.textColor = UIColor.blackColor;
    titlePrompt.numberOfLines = 2;
    titlePrompt.font = [UIFont systemFontOfSize:12.f];
    titlePrompt.textAlignment = NSTextAlignmentCenter;
    titlePrompt.adjustsFontSizeToFitWidth = YES;
    titlePrompt.text = [PrivacyUtils localizedStringForKey:@"privacyDes"
                                             defaultString:@"Please provide your age,we will be able to better adjust game preference for you."];
    [ageView addSubview:titlePrompt];
    [titlePrompt makeLayout:^(YD1MakeLayout *make) {
        make.centerX.yd1_equalTo(ageView.yd1_centerX);
        make.top.yd1_equalTo(self->slider.yd1_bottom).offset(-5);
        make.width.yd1_equalTo(self->slider.yd1_width);
        make.height.yd1_equalTo(30);
    }];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[PrivacyUtils localizedStringForKey:@"privacyDes2"
                                                                                                                          defaultString:@"By clicking the \"I Agree\" button, you have read and agreed to our User Agreement."]];
    NSString* userAgreement = [PrivacyUtils localizedStringForKey:@"userAgreement"
                                                    defaultString:@"User Agreement"];
    [attributedString addAttribute:NSLinkAttributeName
                             value:self.userAgreementURL
                             range:[[attributedString string] rangeOfString:userAgreement]];
    
    NSString* privacyPolicy = [PrivacyUtils localizedStringForKey:@"privacyPolicy"
                                                    defaultString:@"Privacy Policy"];
    [attributedString addAttribute:NSLinkAttributeName
                             value:self.privacyPolicyURL
                             range:[[attributedString string] rangeOfString:privacyPolicy]];
    
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:20]
                             range:NSMakeRange(0, attributedString.length)];
    
    UITextView* privacyText = [UITextView new];
    privacyText.attributedText = attributedString;
    privacyText.dataDetectorTypes = UIDataDetectorTypeLink;
    privacyText.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor orangeColor],
                                       NSUnderlineColorAttributeName: [UIColor orangeColor],
                                       NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
    };
    
    privacyText.backgroundColor = [UIColor clearColor];
    privacyText.font = [UIFont systemFontOfSize:16];
    privacyText.textColor = [UIColor blackColor];
    privacyText.textAlignment = NSTextAlignmentCenter;
    privacyText.editable = NO;
    [privacyText sizeToFit];
    [ageView addSubview:privacyText];
    
    [privacyText makeLayout:^(YD1MakeLayout *make) {
        make.width.yd1_equalTo(titlePrompt.yd1_width);
        make.height.yd1_equalTo(80);
        make.centerX.yd1_equalTo(ageView.yd1_centerX);
        make.top.yd1_equalTo(titlePrompt.yd1_bottom).offset(5);
    }];
    
    
    UIView* acceptBackground = [UIView new];
    acceptBackground.layer.cornerRadius = 5;
    acceptBackground.backgroundColor = UIColorFromRGB(0xff359ff2);
    [ageView addSubview:acceptBackground];
    [acceptBackground makeLayout:^(YD1MakeLayout *make) {
        make.centerX.yd1_equalTo(ageView.yd1_centerX);
        make.top.yd1_equalTo(privacyText.yd1_bottom).offset(15);
        make.size.yd1_equalTo(CGSizeMake(120, 30));
    }];
    
    UILabel* acceptLabel = [UILabel new];
    acceptLabel.text = [PrivacyUtils localizedStringForKey:@"privacyAgree"
                                             defaultString:@"I Agree"];
    acceptLabel.adjustsFontSizeToFitWidth = YES;
    acceptLabel.textColor = [UIColor whiteColor];
    acceptLabel.textAlignment = NSTextAlignmentCenter;
    [acceptBackground addSubview:acceptLabel];
    [acceptLabel makeLayout:^(YD1MakeLayout *make) {
        make.center.yd1_equalTo(acceptBackground.yd1_center);
        make.width.yd1_equalTo(acceptBackground.yd1_width);
        make.height.yd1_equalTo(acceptBackground.yd1_height);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [acceptBackground addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(acceptButton:)];
}

- (void)acceptButton:(id)sender {
    int age = slider.value;
    if (age == 0) {
        [self showMessage:[PrivacyUtils localizedStringForKey:@"privacyTips"
                                                defaultString:@"You have not set your age yet"]];
        return;
    }
    
    if (self.agePrivacyBlock) {
        BOOL child = false;
        if (age < self.childAgeLimit) {
            child = true;
        }
        self.agePrivacyBlock(YES,child,age);
    }
    if (self.superview) {
        [self removeFromSuperview];
    }else{
        YD1LOG(@"Error: [ YD1 age privacy is add to view ]");
    }
}

- (void)showMessage:(NSString *)message {
    float maxLabelWidth = [UIScreen mainScreen].bounds.size.width - 60;
    int labelFont = 17;
    float animationTime = 2.5;
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:labelFont], NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize LabelSize  = [message boundingRectWithSize:CGSizeMake(maxLabelWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:labelFont];
    label.numberOfLines = 0;
    [showview addSubview:label];
    
    showview.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - LabelSize.width - 20)/2, [UIScreen mainScreen].bounds.size.height - 60 - LabelSize.height - 10, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:animationTime animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}

/// slider变动时改变label值
- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self setNewSliderValue:slider andAccuracy:1];
}

- (void)setNewSliderValue:(UISlider *)slider andAccuracy:(float)accuracy {
    // 滑动条的 宽
    float width = 246;
    float slideWidth = width * accuracy/slider.maximumValue;
    float currentSlideWidth =  slider.value/accuracy * slideWidth;
    float newSlideWidth = currentSlideWidth + slideWidth;
    float value =  newSlideWidth/width*slider.maximumValue;
    // 取整
    int d = (int)(value/accuracy);
    if(d >2) {
        slider.value = d*accuracy;
    } else {
        if(d == 0 || slider.value == 0) {
            slider.value = 0;
        }
        else if(d == 1) {
            slider.value = accuracy;
        }
        else if(d == 2) {
            slider.value = 2*accuracy;
        }
    }
    titleAge.text = [self ageWithValue:[NSString stringWithFormat:@"%d",(int)slider.value]];
}

- (NSString*)ageWithValue:(NSString*)age {
    return [NSString stringWithFormat:[PrivacyUtils localizedStringForKey:@"privacyYearsOld"
                                                            defaultString:@"%@ year(s) old"],age];
}

@end

@implementation YD1AgePrivacyUpdateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self createUI];
}

- (void)createUI {
    self.backgroundColor = [UIColor clearColor];
    UIView* backgroundView = [UIView new];
    backgroundView.frame = self.frame;
    backgroundView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3f];
    [self addSubview:backgroundView];
    
    UIView* ageView = [UIView new];
    ageView.backgroundColor = UIColor.whiteColor;
    [self addSubview:ageView];
    [ageView makeLayout:^(YD1MakeLayout *make) {
        make.width.yd1_equalTo(315);
        make.height.yd1_equalTo(315);
        make.center.yd1_equalTo(self);
    }];
    
    UIView* titleBackground = [UIView new];
    titleBackground.backgroundColor = UIColorFromRGB(0xff359ff2);
    [ageView addSubview:titleBackground];
    [titleBackground makeLayout:^(YD1MakeLayout *make) {
        make.width.yd1_equalTo(ageView.yd1_width);
        make.height.yd1_equalTo(40);
    }];
    
    UILabel* title = [UILabel new];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 2;
    title.adjustsFontSizeToFitWidth = YES;
    title.text = [PrivacyUtils localizedStringForKey:@"updateUserAgreement"
                                       defaultString:@"Updated User Agreement"];
    [titleBackground addSubview:title];
    [title makeLayout:^(YD1MakeLayout *make) {
        make.center.yd1_equalTo(titleBackground.yd1_center);
        make.width.yd1_equalTo(titleBackground.yd1_width);
        make.height.yd1_equalTo(titleBackground.yd1_height);
    }];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[PrivacyUtils localizedStringForKey:@"userAgreementDes"
                                                                                                                          defaultString:@"Our User Agreement has been updated"]];
    [attributedString addAttribute:NSLinkAttributeName
                             value:self.privacyURL
                             range:[[attributedString string] rangeOfString:[PrivacyUtils localizedStringForKey:@"userAgreement"
                                                                                                  defaultString:@"User Agreement"]]];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:20]
                             range:NSMakeRange(0, attributedString.length)];
    
    UITextView* privacyText = [UITextView new];
    privacyText.attributedText = attributedString;
    privacyText.dataDetectorTypes = UIDataDetectorTypeLink;
    privacyText.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor],
                                       NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                       NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)
    };
    privacyText.backgroundColor = [UIColor clearColor];
    privacyText.font = [UIFont systemFontOfSize:16];
    privacyText.textColor = [UIColor blackColor];
    privacyText.textAlignment = NSTextAlignmentCenter;
    privacyText.editable = NO;
    [privacyText sizeToFit];
    [ageView addSubview:privacyText];
    
    [privacyText makeLayout:^(YD1MakeLayout *make) {
        make.top.yd1_equalTo(titleBackground.yd1_bottom);
        make.width.yd1_equalTo(ageView.yd1_width);
        make.height.yd1_equalTo(140);
        make.centerX.yd1_equalTo(ageView.yd1_centerX);
    }];
    
    UIView* acceptBackground = [UIView new];
    acceptBackground.layer.cornerRadius = 5;
    acceptBackground.backgroundColor = UIColorFromRGB(0xff359ff2);
    [ageView addSubview:acceptBackground];
    [acceptBackground makeLayout:^(YD1MakeLayout *make) {
        make.centerX.yd1_equalTo(ageView.yd1_centerX);
        make.size.yd1_equalTo(CGSizeMake(120, 30));
        make.top.yd1_equalTo(privacyText.yd1_bottom).offset(90);
    }];
    
    UILabel* acceptLabel = [UILabel new];
    acceptLabel.text = [PrivacyUtils localizedStringForKey:@"privacyAgree"
                                             defaultString:@"I Agree"];
    acceptLabel.textColor = [UIColor whiteColor];
    acceptLabel.textAlignment = NSTextAlignmentCenter;
    acceptLabel.adjustsFontSizeToFitWidth = YES;
    [acceptBackground addSubview:acceptLabel];
    [acceptLabel makeLayout:^(YD1MakeLayout *make) {
        make.center.yd1_equalTo(acceptBackground.yd1_center);
        make.width.yd1_equalTo(acceptBackground.yd1_width);
        make.height.yd1_equalTo(acceptBackground.yd1_height);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [acceptBackground addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(acceptButton:)];
}

- (void)acceptButton:(id)sender {
    if (self.agePrivacyUpdateBlock) {
        self.agePrivacyUpdateBlock(YES);
    }
    
    if (self.superview) {
        [self removeFromSuperview];
    }else{
        YD1LOG(@"Error: [ YD1 age privacy is add to view ]");
    }
}


@end

@implementation YD1UISlider

- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, 0,246,5);
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 12 ;
    rect.size.width = rect.size.width +20;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}

@end

@implementation PrivacyUtils

+ (void)selectLocalLanguage:(NSString*)language
        isSectlocalLanguage:(BOOL)isSelected {
    isSelectLanguage = isSelected;
    yd1SpecifiedLanguage = language;
    yd1Bundle = nil;
}

+ (NSString *)preferredLanguage {
    NSString* lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSArray * langArrayWord = [lang componentsSeparatedByString:@"-"];
    NSString* langString = [langArrayWord objectAtIndex:0];
    if (langArrayWord.count >= 3) {
        langString = [NSString stringWithFormat:@"%@-%@",
                      [langArrayWord objectAtIndex:0],
                      [langArrayWord objectAtIndex:1]];
    }
    return langString;
}

+ (NSString *)localizedStringForKey:(NSString *)key
                      defaultString:(NSString *)defaultString {
    NSString* selectString = @"";
    if (isSelectLanguage) {
        selectString = [PrivacyUtils localizedStringForKey:key
                                         specifiedLanguage:yd1SpecifiedLanguage withDefault:defaultString];
    }else{
        selectString = [PrivacyUtils localizedStringForKey:key
                                         specifiedLanguage:@"default"
                                               withDefault:defaultString];
    }
    return selectString;
}

+ (NSString *)localizedStringForKey:(NSString *)key
                  specifiedLanguage:(NSString *)specifiedLanguage
                        withDefault:(NSString *)defaultString {
    
    if (yd1Bundle == nil) {
        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"PrivacyStrings" ofType:@"bundle"];
        if (bundlePath == nil) {
            bundlePath = [NSBundle.mainBundle pathForResource:@"PrivacyStrings" ofType:@"bundle"];
        }
        yd1Bundle = [NSBundle bundleWithPath:bundlePath];
        if ([specifiedLanguage isEqualToString:@"zh-hant"]) {//繁体----与约定保持一致
            specifiedLanguage = @"zh-Hant";
        }else if ([specifiedLanguage isEqualToString:@"pt"]){//葡头牙----与约定保持一致
            specifiedLanguage = @"pt-BR";
        }else if ([specifiedLanguage isEqualToString:@"zh"]){//简体----与约定保持一致
            specifiedLanguage = @"zh-Hans";
        }
        //1.优先级指定语言
        if ([[yd1Bundle localizations] containsObject:specifiedLanguage]) {
            bundlePath = [yd1Bundle pathForResource:specifiedLanguage ofType:@"lproj"];
        } else {
            //2.运行时APP内选定语言
            NSString *language = [NSBundle mainBundle].preferredLocalizations.firstObject;
            if ([[yd1Bundle localizations] containsObject:language]) {
                bundlePath = [yd1Bundle pathForResource:language ofType:@"lproj"];
            } else {
                //3.系统设置语言
                language = [PrivacyUtils preferredLanguage];
                if ([[yd1Bundle localizations] containsObject:language]) {
                    bundlePath = [yd1Bundle pathForResource:language ofType:@"lproj"];
                }else{
                    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    language = @"en";//默认英文
                    if ([[infoDictionary allKeys] containsObject:@"CFBundleDevelopmentRegion"]) {
                        language = [infoDictionary objectForKey:@"CFBundleDevelopmentRegion"];
                    }
                    if ([language isEqualToString:@"zh_CN"]) {
                        language = @"zh-Hans";//中文
                    }
                    bundlePath = [yd1Bundle pathForResource:language ofType:@"lproj"];
                }
            }
        }
        yd1Bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [yd1Bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

@end


@implementation YD1PrivacyViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setFrame:[UIScreen mainScreen].bounds];
    self.isAccept = NO;
    [self createUI];
}

//- (UIModalPresentationStyle)modalPresentationStyle {
//    return UIModalPresentationa;
//}

- (BOOL)isLandscape {
    UIDeviceOrientation screenOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    return UIDeviceOrientationIsLandscape(screenOrientation);
}

- (void)createUI {
    self.view.backgroundColor = [UIColor clearColor];
    UIView* backgroundView = [UIView new];
    backgroundView.frame = self.view.frame;
    backgroundView.backgroundColor = [UIColor colorWithRed:0.5
                                                     green:0.5
                                                      blue:0.5
                                                     alpha:0.3f];
    [self.view addSubview:backgroundView];
    
    int ageW = 315;
    int ageH = 360;
    if ([self isLandscape]) {
        ageW = 420;
        ageH = 315;
    }
    
    UIView* ageView = [UIView new];
    ageView.backgroundColor = UIColor.whiteColor;
    [backgroundView addSubview:ageView];
    [ageView makeLayout:^(YD1MakeLayout *make) {
        make.width.yd1_equalTo(ageW);
        make.height.yd1_equalTo(ageH);
        make.center.yd1_equalTo(self.view);
    }];
    
    UIView* titleBackground = [UIView new];
    titleBackground.backgroundColor = UIColorFromRGB(0xff359ff2);
    [ageView addSubview:titleBackground];
    [titleBackground makeLayout:^(YD1MakeLayout *make) {
        make.width.yd1_equalTo(ageView.yd1_width);
        make.height.yd1_equalTo(40);
    }];
    
    UILabel* title = [UILabel new];
    [titleBackground addSubview:title];
    title.text = @"温馨提示";
    title.adjustsFontSizeToFitWidth = YES;
    title.textAlignment = NSTextAlignmentCenter;
    
    [title makeLayout:^(YD1MakeLayout *make) {
        make.center.yd1_equalTo(titleBackground.yd1_center);
        make.width.yd1_equalTo(titleBackground.yd1_width);
        make.height.yd1_equalTo(titleBackground.yd1_height);
    }];
    
    NSString* des = @"感谢您对本游戏的喜爱， 在使用前请您仔细阅读《隐私政策》，《用户协议》(点击查看最新内容)。我们将严格遵守相关法律法规收集使用您的个人信息，以便为您提供更好的服务。同时我们将严格保护您的个人信息。为了给您更好的游戏体验我们会读取相关权限例如：\n- 存储权限：支持游戏存档功能和其他缓存以加速游戏运行；\n- 电话：获取设备唯一标识进行防沉迷系统和其他功能的标识；\n运营商将严格保护您的个人信息，确保信息安全。同意协议前务必审慎阅读。如果您拒绝此协议程序将会关闭。";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:des];
    NSString* userAgreement = @"《隐私政策》";
    [attributedString addAttribute:NSLinkAttributeName
                             value:self.userAgreementURL
                             range:[[attributedString string] rangeOfString:userAgreement]];
    
    NSString* privacyPolicy = @"《用户协议》";
    [attributedString addAttribute:NSLinkAttributeName
                             value:self.privacyPolicyURL
                             range:[[attributedString string] rangeOfString:privacyPolicy]];
    
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:20]
                             range:NSMakeRange(0, attributedString.length)];
    
    UITextView* privacyText = [UITextView new];
    privacyText.attributedText = attributedString;
    privacyText.dataDetectorTypes = UIDataDetectorTypeLink;
    privacyText.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor orangeColor],
                                       NSUnderlineColorAttributeName: [UIColor orangeColor],
                                       NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
    };
    
    privacyText.backgroundColor = [UIColor clearColor];
    privacyText.font = [UIFont systemFontOfSize:14];
    privacyText.textColor = [UIColor blackColor];
    privacyText.textAlignment = NSTextAlignmentLeft;
    privacyText.editable = NO;
    [privacyText sizeToFit];
    [ageView addSubview:privacyText];
    
    int privacyH = 260;
    if ([self isLandscape]) {
        privacyH = 200;
    }
    [privacyText makeLayout:^(YD1MakeLayout *make) {
        make.width.yd1_equalTo(title.yd1_width);
        make.height.yd1_equalTo(privacyH);
        make.centerX.yd1_equalTo(ageView.yd1_centerX);
        make.top.yd1_equalTo(title.yd1_bottom).offset(5);
    }];
    
    UIButton* acceptBt = [UIButton buttonWithType:UIButtonTypeSystem];
    acceptBt.tag = 1020;
    [acceptBt setTitle:@"同意" forState:UIControlStateNormal];
    [ageView addSubview:acceptBt];
    [acceptBt addTarget:self
                 action:@selector(acceptButton:)
       forControlEvents:UIControlEventTouchUpInside];
    [acceptBt makeLayout:^(YD1MakeLayout *make) {
        make.right.yd1_equalTo(-5);
        make.size.yd1_equalTo(CGSizeMake(60, 30));
        make.top.yd1_equalTo(privacyText.yd1_bottom).offset(15);
    }];
    
    UIButton* noAcceptBt = [UIButton buttonWithType:UIButtonTypeSystem];
    noAcceptBt.tag = 1021;
    [noAcceptBt setTitle:@"不同意" forState:UIControlStateNormal];
    [ageView addSubview:noAcceptBt];
    [noAcceptBt addTarget:self
                   action:@selector(acceptButton:)
         forControlEvents:UIControlEventTouchUpInside];
    [noAcceptBt makeLayout:^(YD1MakeLayout *make) {
        make.left.yd1_equalTo(10);
        make.size.yd1_equalTo(CGSizeMake(60, 30));
        make.top.yd1_equalTo(privacyText.yd1_bottom).offset(15);
    }];
}

- (void)acceptButton:(id)sender {
    UIButton* bt = (UIButton*)sender;
    if (bt.tag == 1020) {
        YD1LOG(@"agree.");
        self.isAccept = true;
    }else if (bt.tag == 1021){
        YD1LOG(@"disagree.");
        self.isAccept = false;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.privacyBlock) {
        self.privacyBlock(self.isAccept);
    }
}

@end
