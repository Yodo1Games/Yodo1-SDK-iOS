//
//  Yodo1ShareWeChatHelper.h
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "qrencode.h"

@interface Yodo1ShareWeChatHelper : NSObject

/**
 *  生成中间带logo图
 *
 *  @param string 二维码文本或是url字符串
 *  @param size   二维码图片大小
 *  @param topimg 二维码中间logo图片
 *
 *  @return 二维码图片
 */
+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)size
                       Topimg:(UIImage *)topimg;

+ (void)drawQRCode:(QRcode *)code
           context:(CGContextRef)ctx
              size:(CGFloat)size;

+ (UIImage *)addImage:(UIImage *)imageSmall
              toImage:(UIImage *)imageBig
            shareLogo:(UIImage *)shareLogo
               qrText:(NSString*)qrText
       whiteBackgroud:(BOOL)bWhiteBackgroud
            optionDic:(NSDictionary*)optionDic;

+ (UIImage*)yodo1ResizedImageToSize:(CGSize)dstSize
                        sourceImage:(UIImage*)sourceImage;

@end
