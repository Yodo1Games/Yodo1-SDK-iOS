//
//  Yodo1AntiAddictionInputVC.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/3.
//

#import "Yodo1AntiAddictionInputVC.h"
#import "Yodo1AntiAddictionUserManager.h"
#import "Yodo1AntiAddictionDialogVC.h"
#import "Yodo1AntiAddictionUtils.h"

@interface Yodo1AntiAddictionInputVC ()<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *nameField; // 姓名
@property (weak, nonatomic) IBOutlet UILabel *nameHint;

@property (weak, nonatomic) IBOutlet UITextField *identifyField; // 身份证
@property (weak, nonatomic) IBOutlet UILabel *identifyHint;

@property (weak, nonatomic) IBOutlet UIButton *unableButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *experienceButton;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;

@end

@implementation Yodo1AntiAddictionInputVC

+ (NSString *)identifier {
    NSString *identifier = NSStringFromClass([self class]);
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return [NSString stringWithFormat:@"%@H", identifier];
    } else {
        return [NSString stringWithFormat:@"%@V", identifier];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameField.delegate = self;
    _identifyField.delegate = self;
    
    _nameHint.text = nil;
    _identifyHint.text = nil;
    _experienceButton.hidden = _hideGuest;
    _lineView.hidden = _hideGuest;
    
    [self setLoading:NO];
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    
    if ((_nameField.isEditing || _identifyField.isEditing) && isLandscape) {
        CGFloat height = UIScreen.mainScreen.bounds.size.height - 47;
        _contentHeight.constant = height;
    } else {
        CGFloat height = UIScreen.mainScreen.bounds.size.height / 3 * 2;
        CGFloat max = isLandscape ? 271 : 523;
        if (@available(iOS 11.0, *)) {
            max = max + self.view.safeAreaInsets.bottom;
        }
        _contentHeight.constant = height > max ? max : height;
    }
}

- (void)setLoading:(BOOL)loading {
    _nameField.enabled = !loading;
    _identifyField.enabled = !loading;
    _unableButton.enabled = !loading;
    _submitButton.enabled = !loading;
    _experienceButton.enabled = !loading;
    
    if (loading) {
        _submitButton.backgroundColor = [UIColor clearColor];
        [_submitButton setImage:nil forState:UIControlStateNormal];
        [_submitButton setTitle:@"正在核查 请稍后" forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        _submitButton.backgroundColor = [UIColor colorWithRed:63 / 255.0 green:143 / 255.0 blue:1 / 255.0 alpha:1];
        [_submitButton setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
        [_submitButton setTitle:@"提交验证" forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    _contentHeight.constant = UIScreen.mainScreen.bounds.size.height - 47;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    CGFloat height = 271;
    if (@available(iOS 11.0, *)) {
        height = height + self.view.safeAreaInsets.bottom;
    }
    _contentHeight.constant = height;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

#pragma mark - Event
// 无法通过验证？
- (IBAction)onUnableClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didUnableClicked)]) {
        [_delegate didUnableClicked];
    }
}

// 提交
- (IBAction)onSubmitClicked:(id)sender {
    [_nameField resignFirstResponder];
    [_identifyField resignFirstResponder];
    
    NSString *name = [_nameField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    if (![Yodo1AntiAddictionUtils isChineseName:name]) {
//        [self.view makeToast:@"请输入中文姓名"];
//        return;
//    }
    
    if (!name || name.length < 2) {
        [self.view makeToast:@"至少输入2个中文"];
        return;
    }
    
    if (name.length > 50) {
        [self.view makeToast:@"最多输入50个中文"];
        return;
    }
    
    NSString *identify = [_identifyField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![Yodo1AntiAddictionUtils isChineseId:identify]) {
        [self.view makeToast:@"请输入18位有效身份证"];
        return;
    }
    
    [self setLoading:YES];
    [[Yodo1AntiAddictionUserManager manager] post:name identify:identify success:^(id data) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didInfoChecked:)]) {
            NSInteger status = [data[@"status"] integerValue];
            if (status >= 0) {
                [self.delegate didInfoChecked:[Yodo1AntiAddictionUserManager manager].currentUser];
            } else {
                [self setLoading:NO];
                NSInteger retryTimes = [data[@"retryTimes"] integerValue];
                if (status == -1) {
                    NSString *msg = [NSString stringWithFormat:@"请核对您的身份证是否输入正确或姓名和身份证是否匹配，然后重试。\n今日还剩有 %@  次核查机会。", @(retryTimes)];
                    [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleCheckUnable error:msg];
                } else {
                    [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleCheckDisable error:nil];
                }
            }
        }
    } failure:^(NSError *error) {
        [self setLoading:NO];
        if ([Yodo1AntiAddictionUtils isNetError:error]) { // -1009 没有网络 -1001 超时
            [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleNetError error:nil];
        } else {
            [Yodo1AntiAddictionDialogVC showDialog:Yodo1AntiAddictionDialogStyleError error:error.localizedDescription];
        }
    }];
}

// 游客体验
- (IBAction)onExperienceClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
        event.eventCode = Yodo1AntiAddictionEventCodeNone;
        event.action = Yodo1AntiAddictionActionResumeGame;
        [[Yodo1AntiAddictionHelper shared] successful: event];
        
        if ([Yodo1AntiAddictionHelper shared].autoTimer) {
            [[Yodo1AntiAddictionHelper shared] startTimer];
        }
        [Yodo1AntiAddiction.shared online:^(BOOL result, NSString * _Nonnull content) {
                    
        }];
    }];
}

// 退出游戏
- (IBAction)onQuitClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    Yodo1AntiAddictionEvent *event = [[Yodo1AntiAddictionEvent alloc] init];
    event.eventCode = Yodo1AntiAddictionEventCodeNone;
    event.action = Yodo1AntiAddictionActionEndGame;
    if (![[Yodo1AntiAddictionHelper shared] successful: event]) {
        exit(0);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == _nameField) {
        if (newText.length > 0) {
            if ([Yodo1AntiAddictionUtils isChineseName:newText]) {
                if (newText.length < 2) {
                    _nameHint.text = @"至少2个中文";
                } else if (newText.length >= 50) {
                    _nameHint.text = @"最多输入50个中文";
                    return NO;
                } else {
                    _nameHint.text = nil;
                }
            }
//            else {
//                _nameHint.text = @"请输入中文";
//            }
        } else {
            _nameHint.text = nil;
        }
    } else {
        if (newText.length > 0) {
            if (![Yodo1AntiAddictionUtils isChineseId:newText]) {
                _identifyHint.text = @"请输入18位有效身份证";
            } else {
                _identifyHint.text = nil;
            }
        } else {
            _identifyHint.text = nil;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameField) {
        [_identifyField becomeFirstResponder];
    } else {
        [self onSubmitClicked:nil];
    }
    return YES;
}

@end
