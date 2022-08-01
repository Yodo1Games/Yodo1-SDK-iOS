//
//  Yodo1AntiAddictionDialogVC.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/3.
//

#import "Yodo1AntiAddictionDialogVC.h"
#import "Yodo1AntiAddictionUtils.h"
#import "Yodo1AntiAddictionUserManager.h"
#import "Yodo1AntiAddictionRulesManager.h"
#import "Yodo1AntiAddictionTimeManager.h"

@interface Yodo1AntiAddictionDialogVC ()

@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@end

@implementation Yodo1AntiAddictionDialogVC

+ (void)showDialog:(Yodo1AntiAddictionDialogStyle)style error:(NSString * _Nullable)error {
    UIViewController *topVC = [Yodo1AntiAddictionUtils getTopViewController];
    Yodo1AntiAddictionDialogVC *vc = [Yodo1AntiAddictionDialogVC loadFromStoryboard];
    vc.style = style;
    vc.msg = error;
    YMCardPresentationController *presentation = [[YMCardPresentationController alloc] initWithPresentedViewController:vc presentingViewController:topVC];
    vc.transitioningDelegate = presentation;
    [topVC presentViewController:vc animated:YES completion:nil];
}

- (void)didInitialize {
    [super didInitialize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Yodo1AntiAddictionRules *rules = [Yodo1AntiAddictionRulesManager manager].currentRules;
    Yodo1AntiAddictionUser *user = [Yodo1AntiAddictionUserManager manager].currentUser;
    
    switch (_style) {
        case Yodo1AntiAddictionDialogStyleBuyOverstep: {
            // 超出购买额度
            _iconView.image = [UIImage imageNamed:@"error"];
            _titleLabel.text = @"额度不够";
            _contentLabel.text = @"根据国家规定：单笔金额不可超过%@元，每月累计不可超过%@元。您今日已消费%@元，本月已消费%@元，无法继续交易。";
            _checkButton.hidden = YES;
            [_exitButton setTitle:@"→ 知道了" forState:UIControlStateNormal];
            break;
        }
        case Yodo1AntiAddictionDialogStyleTimeDisable: {
            // 禁玩时段
            // 接口给出的可玩时间段，需要手动计算，且给出是多个时段，但这里只展示了一个时段
            
//            NSString *timeRange = @"08:00-22:00";
//            for (GroupAntiPlayingTimeRange *range in rules.groupAntiPlayingTimeRangeList) {
//                if ([Yodo1AntiAddictionUtils age:user.age inRange:range.ageRange]) {
//                    timeRange = range.antiPlayingTimeRange.firstObject;
//                    break;
//                }
//            }
//            NSArray *ranges = [timeRange componentsSeparatedByString:@"-"];
            
            _iconView.image = [UIImage imageNamed:@"error"];
            _titleLabel.text = @"当前为禁玩时间，无法继续游戏";
//            _contentLabel.text = [NSString stringWithFormat:@"根据国家规定，未成年人禁玩时间段为%@请合理安排游戏时间", [NSString stringWithFormat:@"%@-%@", ranges[0], ranges[1]]];
            _contentLabel.text = rules.antiPlayingTimeMsg.message ?:@"根据《国家新闻出版署通知》，非周五、周六、周日和法定节假日20时至21时的时段，未成年人账号，不得进行游戏。";
            _checkButton.hidden = YES;
            [_exitButton setTitle:@"→ 退出游戏" forState:UIControlStateNormal];
            break;
        }
        case Yodo1AntiAddictionDialogStyleTimeOverstep: { // 时间超出
//            Yodo1AntiAddictionRecord *record = [Yodo1AntiAddictionTimeManager manager].record;
//            float regularTime = 5400; // 工作日可玩时长
//            float holidayTime = 10800; // 假日可玩时长
//            for (GroupPlayingTime *range in rules.groupPlayingTimeList) {
//                if ([Yodo1AntiAddictionUtils age:user.age inRange:range.ageRange]) {
//                    regularTime = range.regularTime;
//                    holidayTime = range.holidayTime;
//                    break;
//                }
//            }
            _iconView.image = [UIImage imageNamed:@"error"];
            _titleLabel.text = @"无可继续游戏时间";
//            _contentLabel.text = [NSString stringWithFormat:@"根据国家规定\n工作日：每天最多可玩%@分钟\n节假日：每天最多可玩%@分钟\n您今天已游戏了%@分钟，无法继续游戏", @((NSInteger)regularTime / 60), @((NSInteger)holidayTime / 60), @((NSInteger)record.playingTime / 60)];
            _contentLabel.text = rules.playingTimeMsg.message;
            _checkButton.hidden = YES;
            [_exitButton setTitle:@"→ 退出游戏" forState:UIControlStateNormal];
            break;
        }
        case Yodo1AntiAddictionDialogStyleBuyDisable: {
            // 禁止购买
            _iconView.image = [UIImage imageNamed:@"error"];
            _titleLabel.text = @"无法购买";
            _contentLabel.text = @"根据国家规定：游客体验模式无法购买物品。";
            _checkButton.hidden = YES;
            [_exitButton setTitle:@"→ 知道了" forState:UIControlStateNormal];
            break;
        }
        case Yodo1AntiAddictionDialogStyleVisitorOver: {
            // 游客模式结束
            [Yodo1AntiAddiction.shared offline:^(BOOL result, NSString * _Nonnull content) {
                NSLog(@"游客体验结束，下线！");
            }];
            _iconView.image = [UIImage imageNamed:@"error"];
            _titleLabel.text = @"游客体验模式已结束";
            _contentLabel.text = rules.guestModeMsg.message?:@"游戏时长已耗尽，请合理安排游戏时间。";
//            _contentLabel.text = [NSString stringWithFormat:@"尊敬的玩家您好，您当前处于试玩模式 每%@天能试玩%@分钟，当前已无可继续游戏的时间，为了获得更好的游戏体验，请完成实名认证。", @(rules.guestModeConfig.effectiveDay), @(rules.guestModeConfig.playingTime / 60)];
            [_exitButton setTitle:@"→ 退出游戏" forState:UIControlStateNormal];
            break;
        }
        case Yodo1AntiAddictionDialogStyleNetError: {
            // 网络错误
            _iconView.image = [UIImage imageNamed:@"unlink"];
            _topView.backgroundColor = [UIColor colorWithRed:227 / 255.0 green:116 / 255.0 blue:0 alpha:1];
            _titleLabel.text = @"您当前网络状态不佳，无法完成验证";
            _contentLabel.text = @"请保证网络畅通后完成重试。";
            _checkButton.hidden = YES;
            [_exitButton setTitle:@"→ 知道了" forState:UIControlStateNormal];
            break;
        }
        case Yodo1AntiAddictionDialogStyleCheckDisable: {
            // 验证次数用完
            _iconView.image = [UIImage imageNamed:@"stop"];
            _topView.backgroundColor = [UIColor colorWithRed:227 / 255.0 green:116 / 255.0 blue:0 alpha:1];
            _titleLabel.text = @"无法继续验证";
            _contentLabel.text = @"抱歉！已达到今日可尝试验证的最高次数，请24小时后重试。如果您确保姓名和身份证号正确，您可以尝试回到认证界面，点击“无法通过实名验证”来获得更多帮助。";
            _checkButton.hidden = YES;
            [_exitButton setTitle:@"→ 知道了" forState:UIControlStateNormal];
            break;
        }
        case Yodo1AntiAddictionDialogStyleCheckUnable: {
            // 无法通过审核
            _iconView.image = [UIImage imageNamed:@"error"];
            _titleLabel.text = @"无法通过公安部网络身份系统核查";
            _contentLabel.text = @"请核对您的身份证是否输入正确或姓名和身份证是否匹配，然后重试。\n今日还剩有 3  次核查机会。";
            _checkButton.hidden = YES;
            [_exitButton setTitle:@"→ 知道了" forState:UIControlStateNormal];
            break;
        }
        default: {
            _iconView.image = [UIImage imageNamed:@"error"];
            _titleLabel.text = @"发生错误了";
            _contentLabel.text = _msg;
            _checkButton.hidden = YES;
            [_exitButton setTitle:@"→ 知道了" forState:UIControlStateNormal];
            break;
        }
            
    }
    
    if (_msg != nil) {
        _contentLabel.text = _msg;
    }
    _titleLabel.textColor = _topView.backgroundColor;
}

#pragma mark - Event
// 去验证
- (IBAction)onCkeckClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [Yodo1AntiAddictionUtils showVerifyUI: YES];
    }];
}

// 退出游戏
- (IBAction)onQuitClicked:(id)sender {
    switch (_style) {
        case Yodo1AntiAddictionDialogStyleTimeDisable: // 禁玩时段
        case Yodo1AntiAddictionDialogStyleTimeOverstep: // 时间超出
        case Yodo1AntiAddictionDialogStyleVisitorOver: // 游客模式结束
            // 退出游戏
            exit(0);
            break;
        default:
            // 知道了
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

@end


@interface YMCardPresentationController () <UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIView *dismissView;
@property (nonatomic, strong) UIView *replacePresentView;

@end

@implementation YMCardPresentationController
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(nullable UIViewController *)presentingViewController{
    
    self =[super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        // 自定义modalPresentationStyle
        presentedViewController.modalPresentationStyle= UIModalPresentationCustom;
        
    }
    return self;
}

/**
 present将要执行
 */
- (void)presentationTransitionWillBegin {
    self.replacePresentView = [[UIView alloc] initWithFrame:[self frameOfPresentedViewInContainerView]];
    self.replacePresentView.layer.cornerRadius = 16;
    self.replacePresentView.layer.shadowOpacity = 0.44f;
    self.replacePresentView.layer.shadowRadius = 13.f;
    self.replacePresentView.layer.shadowOffset = CGSizeMake(0, -6.f);
    UIView *presentedView = [super presentedView];
    presentedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.replacePresentView addSubview:presentedView];
    
    UIView *dismissView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    [self.containerView addSubview:dismissView];
    self.dismissView = dismissView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture_dismiss)];
    [self.dismissView addGestureRecognizer:tap];
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    self.dismissView.alpha = 0.f;
    self.dismissView.backgroundColor = [UIColor blackColor];
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        self.dismissView.alpha = 0.5f;
        
    } completion:NULL];
    
}
/**
 present执行结束
 */
- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        self.dismissView = nil;
    }
}
/**
 dismiss将要执行
 */
- (void)dismissalTransitionWillBegin {
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        self.dismissView.alpha = 0.f;
        
    } completion:NULL];
}
/**
 dismiss执行结束
 */
- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed == YES)
    {
        self.dismissView = nil;
    }
}
- (UIView *)presentedView {
    return self.replacePresentView;
}
- (void)gesture_dismiss {
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [containerView addSubview:toView];
    BOOL present = (toVc.presentingViewController == fromVc) ? YES : NO;
    CGFloat height = 300;
    if (present) {
        toView.frame = CGRectMake(0, containerView.bounds.size.height, containerView.bounds.size.width, height);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.frame = CGRectMake(0, containerView.bounds.size.height - height, containerView.bounds.size.width, height);
        } completion:^(BOOL finished) {
            BOOL cancel = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancel];
        }];
    } else {
        fromView.frame = CGRectMake(0, containerView.bounds.size.height - height, containerView.bounds.size.width, height);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.frame = CGRectMake(0, containerView.bounds.size.height, containerView.bounds.size.width, height);
        } completion:^(BOOL finished) {
            BOOL cancel = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancel];
        }];
    }
}
#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    NSAssert(self.presentedViewController == presented, @"You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.",
             self, presented, self.presentedViewController);
    return self;
}

@end
