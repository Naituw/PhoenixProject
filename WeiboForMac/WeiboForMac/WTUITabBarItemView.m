//
//  WTUITabBarItemView.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUITabBarItemView.h"
#import "WTUITabBar.h"
#import "TUIKit.h"

@interface WTUITabBarItemView ()

@property (nonatomic, assign) BOOL didDrag;

@end

@implementation WTUITabBarItemView
@synthesize highlighted, enabled = _enabled;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:[TUIColor clearColor]];
        [self setMoveWindowByDragging:YES];
        [self setEnabled:YES];
    }
    return self;
}

- (void)redrawAnimated{
    [TUIView animateWithDuration:0.2 animations:^{
        [self redraw]; 
    }];
}

- (void)setHighlighted:(BOOL)highlight{
    highlighted = highlight;
    [self redrawAnimated];
}

- (void)drawRect:(CGRect)rect{
    CGRect b = self.bounds;
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    NSString * imageName = [[self tabBar].delegate tabBar:[self tabBar] 
                                   imageNameForTabAtIndex:self.tag];
    TUIImage *image = [TUIImage imageNamed:imageName cache:YES];
    CGRect imageRect = ABIntegralRectWithSizeCenteredInRect([image size], b);
    
    // first draw a slight white emboss below
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, CGRectOffset(imageRect, 0, -1), image.CGImage);
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.5);
    CGContextFillRect(ctx, b);
    CGContextRestoreGState(ctx);
    
    BOOL isKeyWindow = self.nsWindow.isKeyWindow;
    self.alpha = (isKeyWindow || highlighted)?1.0:0.6;
    
    // replace image with a dynamically generated fancy inset image
    // 1. use the image as a mask to draw a blue gradient
    // 2. generate an inner shadow image based on the mask, then overlay that on top
    image = [TUIImage imageWithSize:imageRect.size scale:image.scale drawing:^(CGContextRef ctx) {
        CGRect r;
        r.origin = CGPointZero;
        r.size = imageRect.size;
        
        CGContextClipToMask(ctx, r, image.CGImage);
        if (highlighted) {
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, r.size.height), (CGFloat[]){0.2,0.55,0.93,1}, CGPointZero, (CGFloat[]){0.23,0.64,0.98,1});
        }
        else if([self.nsView isTrackingSubviewOfView:self] && self.enabled && !self.didDrag) {
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, r.size.height), (CGFloat[]){0.35,0.35,0.35,1}, CGPointZero, (CGFloat[]){0.45,0.45,0.45,1});
        }else {
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, r.size.height), (CGFloat[]){0.55,0.55,0.55,1}, CGPointZero, (CGFloat[]){0.65,0.65,0.65,1});
        }
        
        TUIImage *innerShadow = [image innerShadowWithOffset:CGSizeMake(0, -1) radius:3.0 color:[TUIColor blackColor] backgroundColor:[TUIColor grayColor]];
        CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
        CGContextDrawImage(ctx, r, innerShadow.CGImage);
    }];
    
    CGContextSaveGState(ctx);
    if (highlighted) {
        CGContextSetShadowWithColor(ctx, CGSizeZero, 5.0, [TUIColor colorWithRed:0.33 green:0.74 blue:1 alpha:0.7].CGColor);
    }
    
    self.alpha = self.enabled?1.0:0.5;
    
    [image drawInRect:imageRect]; // draw 'image' (might be the regular one, or the dynamically generated one)
    CGContextRestoreGState(ctx);
}


- (WTUITabBar *)tabBar
{
	return (WTUITabBar *)self.superview;
}

- (void)mouseDown:(NSEvent *)event
{
	[super mouseDown:event];
	[self setNeedsDisplay];
}

- (void)mouseDragged:(NSEvent *)event{
    self.didDrag = YES;
    [super mouseDragged:event];
}

- (void)mouseUp:(NSEvent *)event
{
	[super mouseUp:event];
	[TUIView animateWithDuration:0.5 animations:^{
		[self redraw];
	}];
	
    if (self.didDrag)
    {
        self.didDrag = NO;
    }
	else if([self eventInside:event]) {
		[[self tabBar] mouseUpInTabAtIndex:self.tag];
	}
}

- (void)setEnabled:(BOOL)enabled{
    _enabled = enabled;
    self.alpha = enabled?1.0:0.4;
}


@end
