//
//  Yodo1ShareWeChatHelper.m
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "Yodo1ShareWeChatHelper.h"

int wechat_qr_margin = 3;

@implementation Yodo1ShareWeChatHelper

+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)size
                       Topimg:(UIImage *)topimg {
    
    if (![string length]) {
        return nil;
    }
    
    QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
    if (!code) {
        return nil;
    }
    
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
    CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
    
    // draw QR on this context
    [Yodo1ShareWeChatHelper drawQRCode:code context:ctx size:size];
    
    // get image
    CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
    UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
    
    
    if(topimg)
    {
        UIGraphicsBeginImageContext(qrImage.size);
        
        //Draw image2
        [qrImage drawInRect:CGRectMake(0, 0, qrImage.size.width, qrImage.size.height)];
        
        //Draw image1
        float r=qrImage.size.width*35*1.1/240;
        [topimg drawInRect:CGRectMake((qrImage.size.width-r)/2, (qrImage.size.height-r)/2 ,r, r)];
        qrImage=UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    
    // some releases
    CGContextRelease(ctx);
    CGImageRelease(qrCGImage);
    CGColorSpaceRelease(colorSpace);
    QRcode_free(code);
    
    return qrImage;
}

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size {
    unsigned char *data = 0;
    int width;
    data = code->data;
    width = code->width;
    float zoom = (double)size / (code->width + 2.0 * wechat_qr_margin);
    CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
    
    // draw
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin = CGPointMake((j + wechat_qr_margin) * zoom,(i + wechat_qr_margin) * zoom);
                CGContextAddRect(ctx, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(ctx);
}

+ (UIImage *)addImage:(UIImage *)imageSmall
              toImage:(UIImage *)imageBig
            shareLogo:(UIImage *)shareLogo
               qrText:(NSString*)qrText
       whiteBackgroud:(BOOL)bWhiteBackgroud
            optionDic:(NSDictionary*)optionDic {
    
    float shareLogoX = [[optionDic objectForKey:@"gameLogoX"]floatValue];
    float qrTextX = [[optionDic objectForKey:@"qrTextX"]floatValue];
    float qrImageX = [[optionDic objectForKey:@"qrImageX"]floatValue];
    
    UIColor* bgColor = bWhiteBackgroud?[UIColor whiteColor]:[UIColor blackColor];
    
    float bgOutline = 40;
    
    CGSize bgSize = CGSizeMake(imageBig.size.width + 2*bgOutline,
                               imageBig.size.height + imageSmall.size.height + 3*bgOutline);
    
    UIGraphicsBeginImageContext(bgSize);
    //Draw background 大图片背景
    CGContextRef contextBig = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(contextBig, bgColor.CGColor);
    CGContextSetFillColorWithColor(contextBig, bgColor.CGColor);
    CGRect bgRectBig = CGRectMake(0, 0, bgSize.width, bgSize.height);
    CGContextAddRect(contextBig, bgRectBig);
    CGContextDrawPath(contextBig, kCGPathFillStroke);
    
    //Draw imageBig
    [imageBig drawInRect:CGRectMake(bgOutline,bgOutline, imageBig.size.width, imageBig.size.height)];
    
    //draw shareLogo
    if (shareLogo) {
        [shareLogo drawInRect:CGRectMake(bgOutline + shareLogoX,imageBig.size.height + 2*bgOutline,
                                         shareLogo.size.width, shareLogo.size.height)];
    }
    
    //Draw background 二维码背景
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (bWhiteBackgroud) {
        CGContextSetStrokeColorWithColor(context, bgColor.CGColor);
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
    }else{
        CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    
    CGRect bgRect = CGRectMake(bgSize.width/2,imageBig.size.height + 2*bgOutline,
                               imageSmall.size.width, imageSmall.size.height);
    CGContextAddRect(context, bgRect);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //Draw imageSmall 二维码logo
    [imageSmall drawInRect:CGRectMake(bgSize.width/2 + qrImageX,imageBig.size.height + 2*bgOutline,
                                      imageSmall.size.width, imageSmall.size.height)];
    //绘制文本
    NSString* _qrText = @"长按识别二维码\n求挑战！求带走！";
    if (qrText && [qrText length] > 0) {
        _qrText = qrText;
    }
    NSString *subString = @"\n";
    NSArray *array = [_qrText componentsSeparatedByString:subString];
    NSInteger count = [array count] - 1;
    
    UILabel* desLabel1 = [[UILabel alloc] init];
    UIColor* color = [UIColor redColor];
    desLabel1.text = _qrText;
    desLabel1.textColor = color;
    desLabel1.font = [UIFont boldSystemFontOfSize:40];
    [desLabel1 sizeToFit];
    desLabel1.numberOfLines = count + 1;
    desLabel1.adjustsFontSizeToFitWidth = YES;
    desLabel1.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    NSLog(@"w:%f,%ld",(imageBig.size.width/2 - imageSmall.size.width),(long)count);
    
    [desLabel1 drawTextInRect:CGRectMake(bgSize.width/2 + imageSmall.size.width + 10 + qrTextX,imageBig.size.height + 2*bgOutline,
                                         imageBig.size.width/2 - imageSmall.size.width, imageSmall.size.height)];
    
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

+ (UIImage*)yodo1ResizedImageToSize:(CGSize)dstSize sourceImage:(UIImage*)sourceImage
{
    if (sourceImage == nil) {
        return nil;
    }
    
    CGImageRef imgRef = sourceImage.CGImage;
    // the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
    CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
    
    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(srcSize, dstSize)) {
        return sourceImage;
    }
    
    CGFloat scaleRatio = dstSize.width / srcSize.width;
    UIImageOrientation orient = sourceImage.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    /////////////////////////////////////////////////////////////////////////////
    // The actual resize: draw the image on a new context, applying a transform matrix
    UIGraphicsBeginImageContextWithOptions(dstSize, NO, sourceImage.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) {
        return nil;
    }
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -srcSize.height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -srcSize.height);
    }
    
    CGContextConcatCTM(context, transform);
    
    // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end
