//
//  CaptureVideoPreviewLayer.m
//  VideoDemo
//
//  Created by 钟文成(外包) on 16/6/22.
//  Copyright © 2016年 钟文成(外包). All rights reserved.
//

#import "CaptureVideoPreviewLayer.h"

@implementation CaptureVideoPreviewLayer


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    UIColor *aColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0];
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1.0);
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGPoint aPoints[3];
    aPoints[0] =CGPointMake(100, 60);
    aPoints[1] =CGPointMake(60, 60);
    aPoints[2] =CGPointMake(60, 100);
    CGContextAddLines(context, aPoints, 3);
    CGContextDrawPath(context, kCGPathStroke);
    
    
}


@end
