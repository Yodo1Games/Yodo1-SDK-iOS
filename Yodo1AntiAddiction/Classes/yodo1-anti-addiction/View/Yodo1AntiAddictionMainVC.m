//
//  Yodo1AntiAddictionMainVC.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/3.
//

#import "Yodo1AntiAddictionMainVC.h"
#import "Yodo1AntiAddictionInputVC.h"
#import "Yodo1AntiAddictionHelpVC.h"
#import "Yodo1AntiAddictionMinorVC.h"
#import "Yodo1AntiAddictionAdultVC.h"
#import "Yodo1AntiAddictionDialogVC.h"
#import "Yodo1AntiAddictionUserManager.h"

@interface Yodo1AntiAddictionMainVC ()<Yodo1AntiAddictionInputDelegate>

@property (weak, nonatomic) IBOutlet UIView *effectView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) Yodo1AntiAddictionInputVC *inputVC;

@end

@implementation Yodo1AntiAddictionMainVC

- (void)didInitialize {
    [super didInitialize];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor colorWithRed:243.0 / 255 green:243.0 / 255 blue:243.0 / 255 alpha:1];
    [_effectView addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_effectView);
        make.trailing.equalTo(_effectView);
        make.bottom.equalTo(_effectView);
    }];
    
    _inputVC = [Yodo1AntiAddictionInputVC loadFromStoryboard];
    _inputVC.delegate = self;
    _inputVC.hideGuest = self.hideGuest;
    [self replaceContent:_inputVC animated:NO];
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = 47.0;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.backgroundColor = [UIColor whiteColor];
    [_effectView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(94);
        make.trailing.equalTo(_contentView).offset(-26);
        make.centerY.equalTo(_contentView.mas_top);
    }];
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSArray *iconsArr = infoDict[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"];
    NSString *iconLastName = [iconsArr lastObject];
    if (iconLastName) {
        [_avatarView setImage:[UIImage imageNamed:iconLastName]];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        [_avatarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_contentView).offset(-26 - _contentView.safeAreaInsets.right);
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addRadius];
}

- (void)replaceContent: (Yodo1AntiAddictionBaseVC *) vc animated:(BOOL)animated {
    if (self.childViewControllers.lastObject == vc) {
        return;
    }
    for (UIView *view in _contentView.subviews) {
        [view removeFromSuperview];
    }
    for (UIViewController *vc in self.childViewControllers) {
        [vc removeFromParentViewController];
    }
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    [vc.view willMoveToSuperview:_contentView];
    [_contentView addSubview:vc.view];
    [vc.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentView);
        make.leading.equalTo(_contentView);
        make.trailing.equalTo(_contentView);
        make.bottom.equalTo(_contentView.mas_bottom);
    }];
    _contentView.backgroundColor = vc.view.backgroundColor;
    if (animated) {
        _contentView.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.alpha = 1;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self addRadius];
        }];
    } else {
        [self.view layoutIfNeeded];
        [self addRadius];
    }
}

- (void)addRadius {
    CGSize size = [_contentView systemLayoutSizeFittingSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width, 1000)];
    size.width = UIScreen.mainScreen.bounds.size.width;
    if (@available(iOS 11.0, *)) {
        size.height += _contentView.safeAreaInsets.bottom;
    }
    
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight; // 圆角位置，
    CGFloat radius = 20; // 圆角大小
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path = path.CGPath;
    maskLayer.fillColor = _contentView.backgroundColor.CGColor;
    _contentView.layer.mask = maskLayer;
}

#pragma mark - Yodo1AntiAddictionInputDelegate
- (void)didUnableClicked {
    __weak __typeof(self)weakSelf = self;
    Yodo1AntiAddictionHelpVC *vc = [Yodo1AntiAddictionHelpVC loadFromStoryboard];
    vc.onBackClicked = ^{
        [weakSelf replaceContent:weakSelf.inputVC animated:YES];
    };
    [self replaceContent:vc animated:YES];
}

- (void)didInfoChecked:(id)info {
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    if (user.certificationStatus == UserCertificationStatusNot) {
        Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
        event.eventCode = Yodo1AntiAddictionEventCodeNone;
        event.action = Yodo1AntiAddictionActionResumeGame;
        [[Yodo1AntiAddictionHelper shared] successful: event];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (user.certificationStatus == UserCertificationStatusAault) {
        Yodo1AntiAddictionAdultVC *vc = [Yodo1AntiAddictionAdultVC loadFromStoryboard];
        [self replaceContent:vc animated:YES];
    } else {
        Yodo1AntiAddictionMinorVC *vc = [Yodo1AntiAddictionMinorVC loadFromStoryboard];
        [self replaceContent:vc animated:YES];
    }
}

@end
