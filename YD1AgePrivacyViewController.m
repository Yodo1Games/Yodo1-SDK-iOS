//
//  ViewController.m
//  gdpr_demo
//
//  Created by yixian huang on 2019/8/26.
//  Copyright © 2019 yixian huang. All rights reserved.
//

#import "YD1AgePrivacyViewController.h"
#import "YD1AgePrivacyView.h"

@interface YD1AgePrivacyViewController (){
    
}

@property(nonatomic,strong)YD1AgePrivacyView* privacyView;

@end

@implementation YD1AgePrivacyViewController

- (YD1AgePrivacyView *)privacyView {
    if (_privacyView == nil) {
        _privacyView = [[YD1AgePrivacyView alloc]init];
    }
    return _privacyView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.privacyView.frame = self.view.frame;
    [self.view addSubview:self.privacyView];
    __strong YD1AgePrivacyViewController* controller = self;
    
    [self.privacyView setAgePrivacyBlock:^(BOOL accept, BOOL adults, int age) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
  
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
  
}

@end
