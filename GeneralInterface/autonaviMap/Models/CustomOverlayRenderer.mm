//
//  CustomOverlayRenderer.m
//  DevDemo2D
//
//  Created by 刘博 on 14-1-16.
//  Copyright (c) 2014年 xiaoming han. All rights reserved.
//

#if defined(TARGET_OS_IPHONE) && defined(ENABLE_AMAP)

#import "CustomOverlayRenderer.h"
#import "CustomOverlay.h"

@implementation CustomOverlayRenderer

- (void)drawMapRect:(MAMapRect)mapRect zoomScale:(MAZoomScale)zoomScale inContext:(CGContextRef)context
{
    CustomOverlay *overlay = (CustomOverlay *)self.overlay;
    
    if (overlay == nil)
    {
        NSLog(@"overlay is nil");
        return;
    }
    
    MAMapRect theMapRect    = [self.overlay boundingMapRect];
    CGRect theRect          = [self rectForMapRect:theMapRect];
    double width            = theRect.size.width;
    
    // 绘制image
    UIGraphicsPushContext(context);
    
    UIImage *image = [UIImage imageNamed:@"point.png"];
//    [image drawInRect:theRect blendMode:kCGBlendModeOverlay alpha:0.8];
    [image drawInRect:theRect];
    
    // 绘制文字
    NSString *legendString = @"顶点软件";
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [legendString drawAtPoint:CGPointMake(width * 0.3, width * 0.45) withFont:[UIFont systemFontOfSize:20.0 / zoomScale]];
    
    UIGraphicsPopContext();
    
    //绘制path
//    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
//    CGContextSetRGBFillColor(context, 0.1, 0.1, 0.9, 0.4);
//	CGContextSetLineWidth(context, 4.0 / zoomScale);
//    
//    CGContextMoveToPoint(context, width * 0.1, width * 0.1);
//    CGContextAddLineToPoint(context, width * 0.9, width / 2.0);
//	CGContextAddLineToPoint(context, width * 0.1, width * 0.9);
//    CGContextAddLineToPoint(context, width / 4.0, width / 2.0);
//    CGContextClosePath(context);
//    CGContextDrawPath(context, kCGPathFillStroke);
    
}

@end


#endif