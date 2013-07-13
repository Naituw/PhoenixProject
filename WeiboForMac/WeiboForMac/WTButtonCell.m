//
//  WTButtonCell.m
//  WTTabbarController
//
//  Created by Wu Tian on 11-8-20.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTButtonCell.h"

@implementation WTButtonCell
@synthesize lighted;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (NSArray *)icons{
    return [NSArray arrayWithObjects:
            @"tweet.png",@"at.png",@"comment.png",
            @"messages.png",@"person.png",@"magnifying-glass.png",nil];
}

- (void)mouseUp:(NSEvent *)theEvent{
    [TUIView animateWithDuration:0.2 animations:^{
        [self redraw];
    }];
    [super mouseUp:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
    [[self superview] mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    isDragging = YES;
    [[self superview] mouseDragged:theEvent];
    if (isTracking) {
        [TUIView animateWithDuration:0.2 animations:^{
            [self redraw];
        }];
        isTracking = NO;
    }
    isDragging = NO;
}

- (void)drawRect:(CGRect)rect
{
	CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, .13, .13, .13, 1);
    CGContextFillRect(ctx, b);
    
    self.backgroundColor = [TUIColor clearColor]; // will also set opaque=NO
    
    NSString * iconName = [[self icons] objectAtIndex:[self indexPath].row];
    TUIImage *image = [TUIImage imageNamed:iconName cache:YES];
    TUIImage * bg = [TUIImage imageNamed:@"TabBarItemSelectedBackground.png" cache:YES];
    CGRect imageRect = ABIntegralRectWithSizeCenteredInRect([image size], b);
    
    image = [TUIImage imageWithSize:imageRect.size scale:image.scale drawing:^(CGContextRef ctx) {
        CGRect r;
        r.origin = CGPointZero;
        r.size = imageRect.size;
        CGContextClipToMask(ctx, r, image.CGImage);
        
        TUIColor * emboseColor = [TUIColor colorWithWhite:0.9 alpha:1];
        
        
        if ([self.nsView isTrackingSubviewOfView:self] & !isDragging || [self lighted]) {
            CGRect bgRect = CGRectMake(rect.origin.x + rect.size.width/2,
                                       rect.origin.y + rect.size.height/2 -19, 
                                       bg.size.width, 
                                       bg.size.height);
            CGContextDrawImage(ctx, bgRect, bg.CGImage);
        }
        else if(!self.lighted){
            emboseColor = [TUIColor colorWithWhite:1 alpha:0.6];
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, r.size.height), (CGFloat[]){0.4,0.4,0.4,1}, CGPointZero, (CGFloat[]){0.3,0.3,0.3,1});
        }
        
        TUIImage *innerShadow = [image innerShadowWithOffset:CGSizeMake(0, -1) radius:1.0 color:emboseColor backgroundColor:emboseColor];
        CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
        CGContextDrawImage(ctx, r, innerShadow.CGImage);
        
    }];
    
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, image.size.width + 10, image.size.height + 10, CGImageGetBitsPerComponent(image.CGImage), 0, 
                                                           colourSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    TUIColor * shadowColor = [TUIColor blackColor];
    if ([self.nsView isTrackingSubviewOfView:self] & !isDragging) {
        shadowColor = [TUIColor colorWithRed:77.0/255.0 
                                       green:194.0/255.0 
                                        blue:255.0/255.0 
                                       alpha:1.0];
        isTracking = YES;
    }
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(0, 0), 5, 
                                shadowColor.CGColor); 

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
    
    if (shouldShowGlow) {
        TUIImage * glow = [TUIImage imageNamed:@"TabBarGlow.png"];
        CGRect glowRect = CGRectMake(70 - 15, (38 - 16)/2, 15, 16);
        [glow drawInRect:glowRect];
    }
}

- (void) setShouldShowGlow:(BOOL) show{
    shouldShowGlow = show;
    [self redraw];
}

@end
