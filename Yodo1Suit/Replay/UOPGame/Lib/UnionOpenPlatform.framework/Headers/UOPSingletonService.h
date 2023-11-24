//
//  UOPSingletonService.h
//  Aspects
//
//  Created by ByteDance on 2020/4/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UOPSingletonService <NSObject>

@optional
//退出登录后是否需要销毁，默认不销毁
- (BOOL)destroyAfterLogout;
//退出登录，需要清理数据
- (void)onLogout;
//登录成功
- (void)onLogin;


@end

NS_ASSUME_NONNULL_END
