//
//  Yodo1Tool+LoginParameters.m
//  Yodo1UCenterSDK
//
//  Created by yixian huang on 2020/5/6.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import "Yodo1Tool+LoginParameters.h"

#define __PRODUCT_EVN__  0

@implementation Yodo1Tool (LoginParameters)

- (NSString *)ucapDomain {
#if __PRODUCT_EVN__ == 1 //测试环境
    return @"https://api-ucap-test.yodo1.com/uc_ap";
#elif __PRODUCT_EVN__ == 2 //准生产
    return @"https://uc-ap-stg.yodo1api.com/uc_ap";
#else
    return @"https://uc-ap.yodo1api.com/uc_ap";
#endif
}

- (NSString *)deviceLoginURL {
    return @"channel/device/login";
}

@end
