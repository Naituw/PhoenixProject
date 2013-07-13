//
//  TUIImage+WMUI.m
//  new-window
//
//  Created by Wu Tian on 12-7-13.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIImage+WMUI.h"
#import "TUIKit.h"

@implementation TUIImage (WMUI)

- (TUIImage *)sideBarButtonStyleImage{
    CGRect imageRect = CGRectZero;
    imageRect.size = self.size;
    return [TUIImage imageWithSize:imageRect.size drawing:^(CGContextRef ctx) {
        CGRect r = CGRectZero;
        r.size = imageRect.size;
        TUIColor * emboseColor = [TUIColor colorWithWhite:1 alpha:0.3];
        
        CGFloat alpha = 1.0;
        
        CGContextClipToMask(ctx, r, self.CGImage);
        
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = { 
            75.0/255.0,79.0/255.0,84.0/255.0,alpha,
            45.0/255.0,48.0/255.0,51.0/255.0,alpha,
            62.0/255.0,63.0/255.0,65.0/255.0,alpha };
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, NULL, 3);
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, r.size.height), CGPointZero, 0);
        CGColorSpaceRelease(colorspace);
        CGGradientRelease(gradient);
        
        TUIImage *innerShadow = [self innerShadowWithOffset:CGSizeMake(0, -1) radius:1 color:emboseColor backgroundColor:[TUIColor colorWithRed:75.0/255.0 green:79.0/255.0 blue:84.0/255.0 alpha:1.0]];
        CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
        CGContextDrawImage(ctx, r, innerShadow.CGImage);
    }];
}

@end
