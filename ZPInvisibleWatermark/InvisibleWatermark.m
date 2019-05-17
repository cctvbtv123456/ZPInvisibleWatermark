//
//  InvisibleWatermark.m
//  ZPInvisibleWatermark
//
//  Created by Justin on 2019/5/17.
//  Copyright © 2019 Justin. All rights reserved.
//


#define Mask8(x)  ( (x) & 0xFF )
#define R(x)      ( Mask8(x) )
#define G(x)      ( Mask8(x >> 8) )
#define B(x)      ( Mask8(x >> 16) )
#define A(x)      ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a)  ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24)

#import "InvisibleWatermark.h"

@implementation InvisibleWatermark
// 添加水印照片
+ (UIImage *)visibleWatermark:(UIImage *)image {
    // 定义 32位整形指针 *inputPixels
    UInt32 *inputPixels;
    
    // 转换图片为CGImageRef,获取参数，每个像素的字节数（4），每个R的比特数
    CGImageRef inputCGImage = [image CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    // 每行字节数
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    // 开辟内存区域， 指向首像素地址
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    // 根据指针，前面的参数，创建像素层
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight, bitsPerComponent, inputBytesPerRow, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // 根据目前像素在界面绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    // 像素处理
    for (int j = 0; j < inputHeight; j++) {
        for (int i = 0; i < inputWidth; i++) {
            @autoreleasepool {
                UInt32 *currentPixel = inputPixels + (j * inputWidth) + i;
                UInt32 color = *currentPixel;
                UInt32 thisR,thisG,thisB,thisA;
                // 这里直接移位获得RGBA的值，以及输出写的非常好
                thisR = R(color);
                thisG = R(color);
                thisB = R(color);
                thisA = R(color);
                
                UInt32 newR,newG,newB;
                newR = [self mixedCalculation:thisR];
                newG = [self mixedCalculation:thisG];
                newB = [self mixedCalculation:thisB];
                
                *currentPixel = RGBAMake(newR, newG, newB, thisA);
            }
        }
    }
    
    // 创建新图
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage *processdImage = [UIImage imageWithCGImage:newCGImage];
    
    // 释放
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    
    return processdImage;
}
// 添加水印文字照片
+ (UIImage *)addWatermark:(UIImage *)image
                     text:(NSString *)text{
    UIFont *font = [UIFont systemFontOfSize:20];
    NSDictionary *attributes = @{NSFontAttributeName : font,
                                 NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.01]
                                 };
    UIImage *newImage = [image copy];
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat idx0 = 0;
    CGFloat idy0 = 0;
    CGSize textSize = [text sizeWithAttributes:attributes];
    while (y < image.size.height) {
        y = (textSize.height * 2) * idy0;
        while (x < image.size.width) {
            @autoreleasepool {
                x = (textSize.width * 1.5) * idx0;
                newImage = [self addWatermark:newImage text:text textPoint:CGPointMake(x, y) attributedString:attributes];
            }
            idx0 ++;
        }
        
        x = 0;
        idx0 = 0;
        idy0 ++;
    }
    
    return newImage;;
}
// 异步添加水印文字照片
+ (void)addWatermark:(UIImage *)image
                text:(NSString *)text
          completion:(void (^ __nullable)(UIImage *))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *result = [self addWatermark:image text:text];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    });
}


+ (UIImage *)addWatermark:(UIImage *)image
                     text:(NSString *)text
                textPoint:(CGPoint)point
         attributedString:(NSDictionary *)attributes{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    CGSize textSize = [text sizeWithAttributes:attributes];
    [text drawInRect:CGRectMake(point.x, point.y, textSize.width, textSize.height) withAttributes:attributes];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// 最小盘算值
+ (int)mixedCalculation:(int)originValue{
    // 结果色 = 基色 - （基色反相 x 混合色反相）/ 混合色
    int mixValue = 1;
    int resultValue = 0;
    if (mixValue == 0) {
        resultValue = 0;
    }else{
        resultValue = originValue - (255 - originValue);
    }
    if (resultValue < 0) {
        resultValue = 0;
    }
    return resultValue;
}

@end
