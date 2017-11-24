//
//  UIImage+UIImage_custom_.m
//  ApexiPhoneOpenAccount
//
//  Created by mac  on 14-3-6.
//  Copyright (c) 2014年 mac . All rights reserved.
//


#import "UIKit+custom_.h"

@implementation UIPopoverController (iPhone)
+ (BOOL)_popoversDisabled {
    return NO;
}
@end


@implementation UIImage (custom_)

- (UIImage *)fixOrientation {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
//    if (self.imageOrientation == UIImageOrientationUp) return self;
//    
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
//    [self drawInRect:(CGRect){0, 0, self.size}];
//    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return normalizedImage;
}

- (UIImage *)createGrayImage{
    int BLUE = 1;
    int GREEN = 2;
    int RED = 3;
    
    UIImage* imgGray = nil;
    
    @autoreleasepool {
        CGSize size = self.size;
        int width = size.width;
        int height = size.height;
        
        uint32_t* pixels = (uint32_t*) malloc (width * height * sizeof (uint32_t));
        memset (pixels, 0, width * height * sizeof (uint32_t));
        
        // 新建一个context，并将图片绘制到context中
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB ();
        CGContextRef context = CGBitmapContextCreate (pixels, width, height, 8, \
                                                      width * sizeof (uint32_t), colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast);
        CGContextDrawImage (context, CGRectMake (0, 0, width, height),self.CGImage);
        
        // 将图片像素灰化
        for (int y = 0; y < height; ++ y)
        {
            for (int x = 0; x < width; ++ x)
            {
                uint8_t* rgbaPixel = (uint8_t *) (pixels + (y * (int) width + x));
                uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
                rgbaPixel[RED] = rgbaPixel[GREEN] = rgbaPixel[BLUE] = gray;
            }
        }
        
        // 根据context创建CGImageRef
        CGImageRef imageRef = CGBitmapContextCreateImage (context);
        
        // 释放资源
        CGContextRelease (context);
        CGColorSpaceRelease (colorSpace);
        free (pixels);
        
        // 将灰化后的图片保存为文件
        imgGray = [UIImage imageWithCGImage: imageRef];
        CGImageRelease (imageRef);
    }
    return imgGray;
}

- (UIImage *)imageByResizingToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, .0);
    [self drawInRect:CGRectMake(.0, .0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, .0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color set];
    CGContextFillRect(context, CGRectMake(.0, .0, size.width, size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)clearImage {
    static UIImage *image = nil;
    if (image == nil) {
        image = [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1.0, 1.0)];
    }
    return image;
}

- (UIImage *) ImageTintColor:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, .0);
    [color set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = CGRectZero;
    bounds.size = self.size;
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, bounds, self.CGImage);
    CGContextFillRect(context, bounds);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)clipImagefromRect:(CGRect)rect{
    CGImageRef imageref=CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *img=[UIImage imageWithCGImage:imageref];
    CGImageRelease(imageref);
    return img;
}


+ (UIImage *)imageWithBezierPath:(UIBezierPath *)path color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
    UIGraphicsBeginImageContextWithOptions((CGSizeMake(path.bounds.origin.x * 2 + path.bounds.size.width, path.bounds.origin.y * 2 + path.bounds.size.height)), NO, .0);
    
    if (backgroundColor) {
        [backgroundColor set];
        [path fill];
    }
    if (color) {
        [color set];
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
