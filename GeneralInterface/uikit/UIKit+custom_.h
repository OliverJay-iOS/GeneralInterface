//
//  UIImage+UIImage_custom_.h
//  ApexiPhoneOpenAccount
//
//  Created by mac  on 14-3-6.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPopoverController (iPhone)
+ (BOOL)_popoversDisabled;
@end

@interface UIImage (custom_)

- (UIImage *)fixOrientation;

- (UIImage *)createGrayImage;

//scale图片
- (UIImage *)imageByResizingToSize:(CGSize)size;

//用颜色生成指定size的图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//空白图片
+ (UIImage *)clearImage;

//暂时未用
//+ (UIImage *)imageWithBezierPath:(UIBezierPath *)path color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

//改变图片的颜色。如黑色bar变成白色bar
- (UIImage *)ImageTintColor:(UIColor *)color;

//截rect位置的图片
- (UIImage *)clipImagefromRect:(CGRect)rect;



@end
