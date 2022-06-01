//
//  Yodo1Secret.h
//  Yodo1SDK
//
//  Created by yanpeng on 2020/9/4.
//  该文件用于存储各类安全密钥，使用C语言编写提高被hock成本，相较Object-C更安全
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct _secret {
    NSString * _Nullable (* _Nonnull secretRewardGame)(void);
} Yodo1Secret_t ;
 
#define Yodo1Secret ([_Yodo1Secret shared])
 
@interface _Yodo1Secret : NSObject
+(Yodo1Secret_t *)shared;
@end

NS_ASSUME_NONNULL_END
