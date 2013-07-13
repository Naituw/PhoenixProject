//
//  TUIImage+UIDrawing.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-6-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIImage+UIDrawing.h"
#import "TUIKit.h"

@implementation TUIImage (UIDrawing)

+ (TUIImage *)macAvatarFromImage:(TUIImage *)image contentScale:(CGFloat)scale
{
    CGSize imageSize = CGSizeMake(50 * scale, 50 * scale);
    
    return [TUIImage imageWithSize:imageSize scale:1 drawing:^(CGContextRef ctx) {
        CGRect r = CGRectZero;
        r.size = imageSize;
        r.size.height -= 1 * scale;
                
        TUIImage * i = [image thumbnail:imageSize];
        i = [i roundImage:3.0 * scale];
        
        CGContextDrawImage(ctx, r, i.CGImage);
        
        CGContextClipToRoundRect(ctx, r, 3.0 * scale);
        
        
        TUIImage *innerShadow = [i innerShadowWithOffset:CGSizeMake(0, -1 * scale) radius:2.0 * scale color:[TUIColor blackColor] backgroundColor:[TUIColor whiteColor]];
        CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
        CGContextDrawImage(ctx, r, innerShadow.CGImage);
        
        innerShadow = [i innerShadowWithOffset:CGSizeMake(0, -1 * scale) radius:2.0 * scale color:[TUIColor colorWithWhite:0 alpha:0.2] backgroundColor:[TUIColor whiteColor]];
        CGContextSetBlendMode(ctx, kCGBlendModeSourceAtop);
        CGContextDrawImage(ctx, r, innerShadow.CGImage);
    }];
}

+ (TUIImage *)macThumbFromNSImage:(NSImage *)image{
    CGFloat width = 52, height = 51, padding = 4;
    CGRect thumbRect = CGRectZero;
    thumbRect.size.width = width + 2*padding;
    thumbRect.size.height = (height + 1) + 2*padding;

    return [TUIImage imageWithSize:thumbRect.size drawing:^(CGContextRef ctx) {
        
        CGRect rect = thumbRect;
        rect.origin.y += 1;
        rect.size.height -= 1;
        
        // Get pixel width and height from image representations instead of image.size,
        // since image.size may went wrong.
        
        NSArray * imageReps = [image representations];
        
        NSInteger imageWidth = 0;
        NSInteger imageHeight = 0;
        
        for (NSImageRep * imageRep in imageReps)
        {
            if ([imageRep pixelsWide] > imageWidth) imageWidth = [imageRep pixelsWide];
            if ([imageRep pixelsHigh] > imageHeight) imageHeight = [imageRep pixelsHigh];
        }
        
        CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
        CGContextSetRGBFillColor(ctx, 187.0/255.0,192.0/255.0,195.0/255.0, 1.0);
        CGContextFillRect(ctx, CGRectInset(rect, 1.0, 1.0));
        CGContextSetRGBFillColor(ctx, 1,1,1, 1.0);
        CGContextFillRect(ctx, CGRectInset(rect, 2.0, 2.0));
        
        CGRect fromRect = CGRectZero;
        
        BOOL needResize = imageSize.width > width && imageSize.height > width;
        BOOL isWidthBigger = imageSize.width > imageSize.height;
        
        if (isWidthBigger) {
            CGFloat delta = needResize?imageSize.height:height;
            fromRect = CGRectMake((imageSize.width - delta)/2, 
                                  0, delta, imageSize.height);
        } else {
            CGFloat delta = needResize?imageSize.width:width;
            fromRect = CGRectMake(0, (imageSize.height - delta)/2, 
                                  imageSize.width, delta);
        }
        
        CGRect toRect = CGRectInset(rect, padding, padding);
        if (!needResize) {
            if (isWidthBigger) {
                toRect = CGRectMake(toRect.origin.x, (toRect.size.width - imageSize.height)/2 + toRect.origin.y, toRect.size.width, imageSize.height);
            }else{
                toRect = CGRectMake((toRect.size.width - imageSize.width)/2 + toRect.origin.x, toRect.origin.y, imageSize.width, toRect.size.height);
            }
        }
        
        TUIImage * i = [TUIImage imageWithNSImage:image];
        fromRect.size.width = MIN(fromRect.size.width, i.size.width);
        fromRect.size.height = MIN(fromRect.size.height, i.size.height);
        
        i = [i crop:fromRect];
        CGContextDrawImage(ctx, toRect, i.CGImage);
        
        CGContextSetRGBFillColor(ctx, 221.0/255.0, 224.0/255.0, 225.0/255.0, 1.0);
        CGContextFillRect(ctx, CGRectMake(2, 1, rect.size.width - 4, 1));
        
        /*
        TUIImage *innerShadow = [i innerShadowWithOffset:CGSizeMake(0, -1) radius:3.0 color:[TUIColor blackColor] backgroundColor:[TUIColor blackColor]];
        CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
        CGContextDrawImage(ctx, toRect, innerShadow.CGImage);
        
        innerShadow = [i innerShadowWithOffset:CGSizeMake(0, -1) radius:3.0 color:[TUIColor colorWithWhite:0 alpha:0.2] backgroundColor:[TUIColor blackColor]];
        CGContextSetBlendMode(ctx, kCGBlendModeSourceAtop);
        CGContextDrawImage(ctx, toRect, innerShadow.CGImage);
         */
    }];
}


@end
