//
//  WMMediaLoaderView.m
//  WeiboForMac
//
//  Created by 吴 天 on 12-11-25.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMMediaLoaderView.h"
#import "TUIKit.h"
#import <QuartzCore/QuartzCore.h>

@interface WMMediaLoaderView ()

@end

@implementation WMMediaLoaderView
@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.progress = 0.0;
        self.opaque = NO;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [TUIColor clearColor];
        self.layer.shadowColor = [TUIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.4;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeZero;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    if (_progress != progress)
    {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = TUIGraphicsGetCurrentContext();
    CGRect b = self.bounds;
    
    CGFloat borderWidth = 3;
    
    CGRect circleRect = CGRectInset(b, .0, .0);
    
    [[TUIColor colorWithWhite:0.0 alpha:0.1] setFill];
    CGContextFillEllipseInRect(context, circleRect);
    
    circleRect = CGRectInset(b, 1.0, 1.0);
    [[TUIColor colorWithWhite:1.0 alpha:1.0] setFill];
    CGContextFillEllipseInRect(context, circleRect);
    
    circleRect = CGRectInset(circleRect, borderWidth, borderWidth);
    [[TUIColor colorWithWhite:0.6 alpha:1.0] setFill];
    CGContextFillEllipseInRect(context, circleRect);
    
    circleRect = CGRectInset(circleRect, 1, 1);
    [TUIRGBColor(189, 222, 244) setFill];
    CGContextFillEllipseInRect(context, circleRect);

    // Draw progress
    CGPoint center = CGPointMake(b.size.width / 2, b.size.height / 2);
    CGFloat radius = (circleRect.size.width) / 2;
    CGFloat startAngle = ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = startAngle - (self.progress * 2 * (float)M_PI);
    
    [TUIRGBColor(44, 102, 175) setFill];
    
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end
