//
//  WTTitleView.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-9-1.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTTitleView.h"
#import "TUIKit.h"

@implementation WTTitleView

@synthesize isExpanded;

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    /*
    CGRect b = self.bounds;
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGFloat lineColor;
    
    if (AtLeastLion) {
        CGFloat aa = drawsAsMainWindow ? 0.686 : 0.878;
        CGFloat bb = drawsAsMainWindow ? 0.906 : 0.976;
        CGFloat colorA[] = {aa,aa,aa,1.0};
        CGFloat colorB[] = {bb,bb,bb,1.0};
        CGContextDrawLinearGradientBetweenPoints(ctx, 
                                                 CGPointMake(0, 0), colorA, 
                                                 CGPointMake(0, b.size.height)            , colorB);
        lineColor = drawsAsMainWindow ? 0.408 : 0.655;
    }
    else{
        CGFloat aa = drawsAsMainWindow ? 0.659 : 0.851;
        CGFloat bb = drawsAsMainWindow ? 0.812 : 0.929;
        CGFloat colorA[] = {aa,aa,aa,1.0};
        CGFloat colorB[] = {bb,bb,bb,1.0};
        CGContextDrawLinearGradientBetweenPoints(ctx, 
                                                 CGPointMake(0, 0), colorA, 
                                                 CGPointMake(0, b.size.height)            , colorB);
        lineColor = drawsAsMainWindow ? 0.318 : 0.600;
    }
    CGContextSetRGBFillColor(ctx, lineColor, lineColor, lineColor, 1.0); // light at the top
    CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
    */
    //CGRect actionRect = CGRectMake(b.size.width - 60, 6, 24, 24);
}

- (void)redrawWithActive:(BOOL)active{
    drawsAsMainWindow = active;
    [self redraw];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    NSRect  windowFrame = [[self nsWindow] frame];
    
    initialLocation = [NSEvent mouseLocation];
    
    initialLocation.x -= windowFrame.origin.x;
    initialLocation.y -= windowFrame.origin.y;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event{
    return YES;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
  NSPoint currentLocation;
    NSPoint newOrigin;
    
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    //go ahead and move the window to the new location
    [[self nsWindow] setFrameOrigin:newOrigin];
}

@end
