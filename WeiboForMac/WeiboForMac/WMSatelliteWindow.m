//
//  WMSatelliteWindow.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMSatelliteWindow.h"
#import "NSWindow+WMAdditions.h"

@interface WMSatelliteWindow ()

@property (nonatomic, retain) WUIView * rootView;

@end

@implementation WMSatelliteWindow

- (void)dealloc
{
    [_rootView release], _rootView = nil;
    [_columnViewController release], _columnViewController = nil;
    [super dealloc];
}

- (id)initWithViewController:(WTUIViewController *)viewController oldFrameOnScreen:(CGRect)oldFrame
{
    if (self = [super init])
    {
        [self setFrame:oldFrame display:YES];
        [self setReleasedWhenClosed:YES];
        [self setMinSize:NSMakeSize(self.minSize.width - 70, self.minSize.height)];
        
        self.rootView = [[[WUIView alloc] initWithFrame:CGRectZero] autorelease];
        [self.nsView setRootView:self.rootView];
        
        self.columnViewController = [[[WMColumnViewController alloc] init] autorelease];
        self.columnViewController.windowIdentifier = self.uniqueIdentifier;
        [self.rootView addSubview:self.columnViewController.view];
        
        self.columnViewController.view.frame = self.rootView.bounds;
        self.columnViewController.view.autoresizingMask = TUIViewAutoresizingFlexibleSize;
        
        [self.columnViewController setRootViewController:viewController animated:NO];
        [self _jumpOut];
    }
    return self;
}

- (void)_jumpOut
{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"frameOrigin"];
    
    NSRect frame = self.frame;
    NSPoint start = frame.origin;
    NSPoint end = NSMakePoint(start.x + 10 + frame.size.width, start.y);
    NSPoint middle = NSMakePoint((start.x + end.x) / 2, start.y + 40);

    if (![self isOnLeftSideOfScreen])
    {
        end = NSMakePoint(start.x + 20, start.y - 20);
        middle = NSMakePoint((start.x + end.x) / 2, start.y + 20);
    }
    
    CGMutablePathRef jumpPath = CGPathCreateMutable();
    CGPathMoveToPoint(jumpPath, NULL, start.x, start.y);
    
    CGPathAddCurveToPoint(jumpPath, NULL, middle.x, middle.y, middle.x, middle.y, end.x, end.y);
    
    animation.path = jumpPath;
    animation.duration = 0.25;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CGPathRelease(jumpPath);
    
    [self setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frameOrigin"]];
	[[self animator] setFrameOrigin:end];
}

- (void)drawBackground:(CGRect)rect
{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    CGFloat columnBGWhite = 245.0/255.0;
    
    NSShadow * shadow = [NSShadow shadowWithRadius:20 offset:CGSizeZero color:[TUIColor blackColor]];
    [shadow set];
    
    CGContextClipToRoundRect(ctx, rect, WeiboMac2WindowCornerRadius);
    CGContextSetRGBFillColor(ctx, columnBGWhite, columnBGWhite, columnBGWhite, 1.0);
    CGContextFillRect(ctx, rect);
}

@end
