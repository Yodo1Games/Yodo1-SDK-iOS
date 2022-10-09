//
//  Yodo1ShareUI.m
//  ShareManager
//
//  Created by Jerry on 12/31/14.
//  Copyright (c) 2014 Jerry. All rights reserved.
//

#import "Yodo1ShareUI.h"


@interface Yodo1ShareUI ()
{
     BOOL isUIInitialized;
}

@property (nonatomic, weak) UIView *shareWindowBackView;
@property (nonatomic, weak) UIView *shareWindow;
@property (nonatomic, weak) UIView *shareWindowArea;
@property (nonatomic, assign) int shareWindowHeight;
@property (nonatomic, assign) float screenWith;
@property (nonatomic, assign) float screenHeight;
@property (nonatomic, strong) Yodo1ShareUIBlock shareBlock;
@property (nonatomic, strong) NSMutableArray *shareType;

- (void)drawYodo1ShareUI;

- (void)cancelAction;

- (void)dismissShareUI;

- (UIColor*)colorWithHex:(long)hexColor;

- (UIImage*)loadImage:(NSString*)imageName;

- (NSString*)localizedString:(NSString*)key;

- (NSString*)snsImageNameWithType:(Yodo1ShareType)platform;

- (NSString*)snsTitleNameWithType:(Yodo1ShareType)platform;

@end

@implementation Yodo1ShareUI
@synthesize isLandscapeOrPortrait;

static Yodo1ShareUI   *sharedInstance;
+ (Yodo1ShareUI *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1ShareUI alloc] init];
    });
    return sharedInstance;
}

- (void)showShareWithTypes:(NSArray *)shareTypes
                     block:(Yodo1ShareUIBlock)bock
{
    if (self.isLandscapeOrPortrait) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(adjustScreenOrientation:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    
    isUIInitialized = NO;
    self.shareBlock = bock;
    self.shareType = [NSMutableArray arrayWithArray:shareTypes];
    [self drawYodo1ShareUI];
}

- (void)adjustScreenOrientation:(NSNotification*)notofication
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if(orientation == UIDeviceOrientationFaceDown ||  orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationUnknown){
        return;
    }
    if (isUIInitialized) {
        if (_shareWindowBackView) {
            [_shareWindowBackView removeFromSuperview];
        }
        isUIInitialized = NO;
        [self drawYodo1ShareUI];
    }
}

- (void)drawYodo1ShareUI
{
    if(isUIInitialized)
        return;
    isUIInitialized = YES;
    self.screenWith = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if ([self.shareType count] > 3) {
        self.shareWindowHeight = 295;
    }
    else {
        self.shareWindowHeight = 195;
    }
    
    UIView *shareWindowBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWith,self.screenHeight)];
    _shareWindowBackView = shareWindowBackView;
    _shareWindowBackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.2];
    [[UIApplication sharedApplication].keyWindow addSubview:_shareWindowBackView];
    
    UIView *shareWindow = [[UIView alloc] initWithFrame:CGRectMake(5, self.screenHeight, self.screenWith - 10, self.shareWindowHeight)];
    _shareWindow = shareWindow;
    _shareWindow.backgroundColor = [UIColor clearColor];
    [_shareWindowBackView addSubview:_shareWindow];
    
    UIView *shareWindowArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([_shareWindow frame]), CGRectGetHeight([_shareWindow frame])-50)];
    _shareWindowArea = shareWindowArea;
    _shareWindowArea.backgroundColor = [UIColor whiteColor];
    _shareWindowArea.layer.cornerRadius = 5;
    [_shareWindow addSubview:_shareWindowArea];
    
    UILabel *shareTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth([_shareWindow frame]), 20)];
    shareTitleLbl.text = [self localizedString:@"sm.select.platform"];
    
    shareTitleLbl.textColor = [self colorWithHex:0x8f8f8f];
    
    shareTitleLbl.textAlignment = NSTextAlignmentCenter;
    shareTitleLbl.font = [UIFont systemFontOfSize:17];
    [_shareWindowArea addSubview:shareTitleLbl];
    
    if (self.shareType.count <= 0) {
        CGFloat shareHeight = (CGRectGetHeight([shareWindowArea frame]) - CGRectGetMaxY([shareTitleLbl frame]))/2 + CGRectGetMaxY([shareTitleLbl frame]);
        
        UILabel *shareNoPlatformLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,shareHeight - 15, CGRectGetWidth([_shareWindow frame]), 20)];
        shareNoPlatformLbl.text = [self localizedString:@"sm.select.noplatform"];
        
        shareNoPlatformLbl.textColor = [UIColor blackColor];
        
        shareNoPlatformLbl.textAlignment = NSTextAlignmentCenter;
        shareNoPlatformLbl.font = [UIFont systemFontOfSize:17];
        [_shareWindowArea addSubview:shareNoPlatformLbl];

    }
    UIScrollView * scrollView = [[UIScrollView alloc]init];
    scrollView.frame = CGRectMake(0, 40, _shareWindowArea.frame.size.width, self.shareWindowHeight - 90);
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(_shareWindowArea.frame.size.width,self.shareWindowHeight);
    
    int row = 0;
    for (int i=0; i<self.shareType.count; i++) {
        if (i % 3 == 0) {
            row++;
        }
        Yodo1ShareType platform = (Yodo1ShareType)[self.shareType[i]integerValue];
        UIView *icon = [[UIView alloc]init];
        UIImageView *iconImageView = [[UIImageView alloc] init];
        iconImageView.frame = CGRectMake(0, 0, 58, 58);
        UIImage* shareIcon = [self loadImage:[self snsImageNameWithType:platform]];
        UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [iconButton setImage:shareIcon forState:UIControlStateNormal];
        [iconButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        iconButton.tag = platform;
        iconButton.frame = CGRectMake(0, 0, 58, 58);
        [iconImageView addSubview:iconButton];
        
        iconImageView.backgroundColor = [UIColor clearColor];
        iconImageView.userInteractionEnabled = YES;
        [icon addSubview:iconImageView];
        
        UILabel *_iconLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([iconImageView frame]) + 5, CGRectGetWidth([iconImageView frame]), 20)];
        _iconLbl.text = [self snsTitleNameWithType:platform];
        _iconLbl.textColor = [UIColor blackColor];
        _iconLbl.font = [UIFont systemFontOfSize:10];
        _iconLbl.textAlignment = NSTextAlignmentCenter;
        _iconLbl.backgroundColor = [UIColor clearColor];
        _iconLbl.userInteractionEnabled = NO;
        [icon addSubview:_iconLbl];
        
        
        icon.backgroundColor = [UIColor clearColor];
        if (i % 3 == 0) {
            icon.frame = CGRectMake((CGRectGetWidth([scrollView frame])/3-58)/2, 10+(row-1)*88, 58, 83);
        } else if (i % 3 == 1) {
            icon.frame = CGRectMake((CGRectGetWidth([scrollView frame])-58)/2, 10+(row-1)*88, 58, 83);
        }else if (i % 3 == 2) {
            icon.frame = CGRectMake(5*CGRectGetWidth([scrollView frame])/6-58/2, 10+(row-1)*88, 58, 83);
        }
        [scrollView addSubview:icon];
    }
    [_shareWindowArea addSubview: scrollView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, CGRectGetHeight([_shareWindow frame]) - 45, CGRectGetWidth([_shareWindow frame]), 40);
    [cancelBtn setTitle:[self localizedString:@"sm.general.cancel"] forState:UIControlStateNormal];
    
    [cancelBtn setTitleColor:[self colorWithHex:0x007aff] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.layer.cornerRadius = 5;
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_shareWindow addSubview:cancelBtn];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.shareWindow.frame = CGRectMake(5, weakSelf.screenHeight - weakSelf.shareWindowHeight-5, weakSelf.screenWith - 10, weakSelf.shareWindowHeight + 5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.shareWindow.frame = CGRectMake(5, weakSelf.screenHeight - weakSelf.shareWindowHeight, weakSelf.screenWith - 10, weakSelf.shareWindowHeight);
        }];
    }];
}

- (NSString*)snsImageNameWithType:(Yodo1ShareType)platform
{
    switch (platform) {
        case Yodo1ShareTypeTencentQQ:
            return @"sns_qzone";
        case Yodo1ShareTypeWeixinMoments:
            return @"sns_weixin_moments";
        case Yodo1ShareTypeWeixinContacts:
            return @"sns_weixin_contacts";
        case Yodo1ShareTypeSinaWeibo:
            return @"sns_weibo";
        case Yodo1ShareTypeFacebook:
            return @"sns_facebook";
        case Yodo1ShareTypeNone:
            return @"None";
        case Yodo1ShareTypeAll:
            return @"All";
    }
    return @"";
}

- (NSString*)snsTitleNameWithType:(Yodo1ShareType)platform
{
    switch (platform) {
        case Yodo1ShareTypeTencentQQ:
            return [self localizedString:@"sm.qzone"];
        case Yodo1ShareTypeWeixinMoments:
            return [self localizedString:@"sm.weixin.moments"];
        case Yodo1ShareTypeWeixinContacts:
            return [self localizedString:@"sm.weixin.contacts"];
        case Yodo1ShareTypeSinaWeibo:
            return [self localizedString:@"sm.weibo"];
        case Yodo1ShareTypeFacebook:
            return [self localizedString:@"sm.facebook"];
        case Yodo1ShareTypeNone:
            return @"None";
        case Yodo1ShareTypeAll:
            return @"All";
    }
    return @"";
}

- (void)cancelAction
{
    [self dismissShareUI];
    if (self.shareBlock) {
        self.shareBlock(Yodo1ShareTypeNone);
    }
}

- (void)dismissShareUI
{
    if (self.isLandscapeOrPortrait) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    self.shareWindowBackView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.2 animations:^{
        self.shareWindowBackView.frame = CGRectMake(15, self.screenHeight, self.screenWith - 30, self.shareWindowHeight);
    } completion:^(BOOL finished) {
        [self.shareWindowBackView removeFromSuperview];
    }];
}

- (void)shareAction:(UIButton*)sender
{
    [self dismissShareUI];
    if (self.shareBlock) {
        Yodo1ShareType form = (Yodo1ShareType)sender.tag;
        self.shareBlock(form);
    }
}

- (UIColor*)colorWithHex:(long)hexColor
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (UIImage *)loadImage:(NSString *)imageName
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"Yodo1Share.bundle/images/%@",imageName]];
}

- (NSString *)localizedString:(NSString *)key
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Yodo1Share.bundle"];
    NSBundle* bulde = [NSBundle bundleWithPath:path];
    return NSLocalizedStringFromTableInBundle(key, @"Root", bulde, nil);
}

@end
