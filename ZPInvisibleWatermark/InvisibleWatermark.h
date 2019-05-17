//
//  InvisibleWatermark.h
//  ZPInvisibleWatermark
//
//  Created by Justin on 2019/5/17.
//  Copyright © 2019 Justin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InvisibleWatermark : NSObject
// 添加水印照片
+ (UIImage *)visibleWatermark:(UIImage *)image;
// 添加水印文字照片
+ (UIImage *)addWatermark:(UIImage *)image
                     text:(NSString *)text;
// 异步添加水印文字照片
+ (void)addWatermark:(UIImage *)image
                text:(NSString *)text
          completion:(void (^ __nullable)(UIImage *))completion;
// 最小水
+ (int)mixedCalculation:(int)originValue;

@end

NS_ASSUME_NONNULL_END
