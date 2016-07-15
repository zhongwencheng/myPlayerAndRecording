//
//  CaptureVideoPreviewLayer.m
//  VideoDemo
//
//  Created by 钟文成(外包) on 16/6/22.
//  Copyright © 2016年 钟文成(外包). All rights reserved.
//  摄像头聚焦的时候那个动画的正方形

#import "Focus.h"

@implementation Focus


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//-(instancetype)initWithFrame:(CGRect)frame{
//    self=[super initWithFrame:frame];
//    if (self) {
//        self.drawImage=[self imageWithUIView:self];
//    }
//     return self;
//}
- (void)drawRect:(CGRect)rect {
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
    CGContextSetLineWidth(context, 2.0);
    CGContextAddRect(context, CGRectMake(2, 2, 96, 96));
    CGContextStrokePath(context);

}
- (UIImage*) imageWithUIView:(UIView*) view{
    
    /* 创建一个bitmap的context
     并把它设置成为当前正在使用的context*/
    //创建图形上下文
    UIGraphicsBeginImageContext(view.bounds.size);
    //创建画板上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    UIColor *aColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0];
    CGContextSetRGBStrokeColor(context, 0.1, 0.3, 0.4, 1.0);
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGPoint aPoints[3];
    aPoints[0] =CGPointMake(41, 1);
    aPoints[1] =CGPointMake(1, 1);
    aPoints[2] =CGPointMake(1, 41);
    CGContextAddLines(context, aPoints, 3);
    CGContextDrawPath(context, kCGPathStroke);
    [view.layer renderInContext:context];
    // 从当前context中创建一个改变大小后的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return image;
}

@end
