//
//  Yodo1LocalNotification.h
//  Yodo1LocalNotification
//
//  Created by zhaojun on 16/3/18.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Yodo1LocalNotification : NSObject

/**
 *  注册本地推送通知
 *
 *  @param notificationKey 通知的Key
 *  @param notificationId   通知的Id
 *  @param alertTime              通知时间(单位：秒)
 *  @param title                       通知对话框标题
 *  @param msg                           通知描述
 */
+ (void)registerLocalNotification:(NSString* __nullable)notificationKey
                   notificationId:(NSInteger)notificationId
                        alertTime:(NSInteger)alertTime
                            title:(NSString* __nullable)title
                              msg:(NSString* __nullable)msg;
/**
 *  取消本地推送通知
 *
 *  @param notificationKey 通知的Key
 *  @param notificationId   通知的Id
 */
+ (void)cancelLocalNotificationWithKey:(NSString* __nullable)notificationKey
                        notificationId:(NSInteger)notificationId;

@end
