//
//  WTSectionAvatarView.m
//  WTTabbarController
//
//  Created by Wu Tian on 11-8-21.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTSectionAvatarView.h"

@implementation WTSectionAvatarView
@synthesize avatar;

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
        
    }
    return self;
}

- (id)initWithAvatar:(TUIImage *)aAvatar
{
    CGRect rect = CGRectMake(0, 0, 70, 70);
    if ((self = [super initWithFrame:rect])) {
        self.avatar = aAvatar;
    }
    return self;
}

- (void)dealloc{
    [avatar release];
    [super dealloc];
}

- (void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
    [[self superview] mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    [[self superview] mouseDragged:theEvent];
}

- (void)drawRect:(CGRect)rect
{
    CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, .13, .13, .13, 1);
    CGContextFillRect(ctx, b);
    
    if (avatar) {
        TUIImage * image = [avatar roundImage:4.0];
        CGRect imageRect = ABIntegralRectWithSizeCenteredInRect([image size], b);
        
        image = [TUIImage imageWithSize:imageRect.size drawing:^(CGContextRef ctx) {
            CGRect r;
            r.origin = CGPointZero;
            r.size = imageRect.size;
            CGContextClipToMask(ctx, r, image.CGImage);
            
            TUIColor * emboseColor = [TUIColor colorWithWhite:0.8 alpha:0.6];
            TUIImage *innerShadow = [image innerShadowWithOffset:CGSizeMake(0, -1) radius:1.0 color:emboseColor backgroundColor:emboseColor];
            [image drawInRect:imageRect];
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextDrawImage(ctx, r, innerShadow.CGImage);
        }];
        
        
        CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef shadowContext = CGBitmapContextCreate(NULL, image.size.width + 10, image.size.height + 10, CGImageGetBitsPerComponent(image.CGImage), 0, 
                                                           colourSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colourSpace);
        
        CGContextSetShadowWithColor(shadowContext, CGSizeMake(0, 0), 5, 
                                    [TUIColor colorWithRed:0.0/255.0 
                                                     green:0.0/255.0 
                                                      blue:0.0/255.0 
                                                     alpha:1.0].CGColor); 
        
        CGContextDrawImage(shadowContext, CGRectMake(5, 5, image.size.width + 0, image.size.height + 0), image.CGImage);
        
        CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
        CGContextRelease(shadowContext);
        
        image = [TUIImage imageWithCGImage:shadowedCGImage];
        CGImageRelease(shadowedCGImage);
        
        imageRect.size.width += 10;
        imageRect.size.height += 10;
        imageRect.origin.x -= 5;
        imageRect.origin.y -= 5;
        
        [image drawInRect:imageRect];
    }
    
}

@end
