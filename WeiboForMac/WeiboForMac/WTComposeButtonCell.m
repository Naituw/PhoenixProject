//
//  WTButtonCell.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTComposeButtonCell.h"
#import "WTComposerButton.h"
#import "TUIKit.h"
#import "NSImage+EtchedDrawing.h"

@implementation WTComposeButtonCell
@synthesize shouldInset;

- (NSRect)buttonRectByCellRect:(NSRect) rect{
    CGFloat insetLength = shouldInset?5.0:1.0;
    return NSInsetRect(rect, insetLength, insetLength);
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)cellFrame inView:(NSView*)controlView
{

}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    return frame;
}

- (void)drawFocusRingMaskWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
    //NSRect frame = [self buttonRectByCellRect:cellFrame];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect frame = [self buttonRectByCellRect:cellFrame];
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    
    CGFloat roundedRadius = 3.0f;
    
    WTComposerButton * button = (WTComposerButton *)self.controlView;
    BOOL pressed = [self isHighlighted];
    BOOL isDefaultButton = ([[controlView window] defaultButtonCell] == self);
    BOOL enabled = [self isEnabled];
    BOOL blue = isDefaultButton && enabled;
    
    if (button.pressedDown) {
        pressed = YES;
    }
    
    if (!pressed || blue || !enabled) {
        [ctx saveGraphicsState];
        NSRect buttonRect = NSInsetRect(frame, 1.0f, 1.0f);
        buttonRect.size.height -= 1;
        buttonRect.origin.y += 1;
        NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:buttonRect xRadius:4.0 yRadius:4.0];
        
        NSShadow * buttonShadow = [[NSShadow alloc] init];
        NSColor * toplineColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.2];
        if (blue) {
            toplineColor = [NSColor colorWithDeviceRed:111.0/255.0 green:197.0/255.0 blue:253.0/255.0 alpha:1.0];
        }
        [buttonShadow setShadowColor:toplineColor];
        [buttonShadow setShadowBlurRadius:0.0];
        [buttonShadow setShadowOffset:NSMakeSize(0, 1)];
        [buttonShadow set];
        [backgroundPath fill];
        [buttonShadow release];
        
        [ctx restoreGraphicsState];

        
        
        
        [ctx saveGraphicsState];
        backgroundPath = [NSBezierPath bezierPathWithRoundedRect:buttonRect xRadius:roundedRadius yRadius:roundedRadius];
        [backgroundPath setClip];
        
        NSColor * topColor = [NSColor colorWithDeviceWhite:58.0/255.0 alpha:1.0f];
        NSColor * bottomColor = [NSColor colorWithDeviceWhite:36.0/255.0 alpha:1.0f];
        if (blue) {
            if (pressed) {
                topColor = [NSColor colorWithDeviceRed:20.0/255.0 green:182.0/255.0 blue:1 alpha:1];
                bottomColor = [NSColor colorWithDeviceRed:20.0/255.0 green:96.0/255.0 blue:1 alpha:1];
            }else{
                topColor = [NSColor colorWithDeviceRed:0 green:153.0/255.0 blue:1 alpha:1];
                bottomColor = [NSColor colorWithDeviceRed:0 green:76.0/255.0 blue:1 alpha:1];
            }
        }
        NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:topColor endingColor:bottomColor];

        [backgroundGradient drawInRect:[backgroundPath bounds] angle:90.0f];
        [backgroundGradient release];
        
        [ctx restoreGraphicsState];
    }
    
    if(![self image] && [self title]){
        NSString * title = [self title];
        NSColor * fontColor = [NSColor colorWithDeviceWhite:0.92 alpha:1.0];
        if (!enabled) {
            fontColor = [NSColor colorWithDeviceWhite:0.4 alpha:1.0];
        }
        NSShadow * fontShadow = [[NSShadow alloc] init];
        [fontShadow setShadowColor:[NSColor colorWithDeviceWhite:0 alpha:0.3]];
        [fontShadow setShadowBlurRadius:1.0];
        [fontShadow setShadowOffset:NSMakeSize(0, 1)];
        
        NSMutableParagraphStyle * fontPara = [[NSMutableParagraphStyle alloc] init];
        [fontPara setAlignment:NSCenterTextAlignment];
        
        NSDictionary * atts = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSFont fontWithName:@"HelveticaNeue-Bold" size:13.0],NSFontAttributeName, 
                               fontColor,NSForegroundColorAttributeName,
                               fontShadow,NSShadowAttributeName,
                               fontPara,NSParagraphStyleAttributeName,
                               nil];
        [title drawInRect:frame withAttributes:atts];
        [fontShadow release];
        [fontPara release];
    }else if([self image]){
        NSImage * image = [self image];
        [image setFlipped:YES];
        NSSize imageSize = [image size];
        CGFloat inset = shouldInset?5.0:1.0;
        NSRect imageRect = NSMakeRect((frame.size.width - imageSize.width)/2 + inset,
                                      (frame.size.height - imageSize.height)/2 + inset, 
                                      imageSize.width, imageSize.height);
        [image drawEtchedInRect:imageRect];
    }
}

- (void)drawBezelWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{     NSRect frame = [self buttonRectByCellRect:cellFrame];
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    
    CGFloat roundedRadius = 4.0f;
    
    BOOL isDefaultButton = ([[controlView window] defaultButtonCell] == self);
    BOOL shadow = isDefaultButton && [self isEnabled];

    
    {
        [ctx saveGraphicsState];
        NSBezierPath *shadowPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, -5.0f, -5.0f) xRadius:0 yRadius:0];
        [shadowPath setClip];
        
        NSBezierPath *fillPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:roundedRadius yRadius:roundedRadius];
        
        NSShadow * outerShadow = [[NSShadow alloc] init];
        NSColor * shadowColor = shadow?[NSColor colorWithDeviceRed:0.0/255.0 
                                                             green:153.0/255.0 
                                                              blue:255.0/255.0 
                                                             alpha:0.8]:
                                        [NSColor colorWithDeviceWhite:1.0 alpha:0.1];
        [outerShadow setShadowColor:shadowColor];
        [outerShadow setShadowBlurRadius:shadow?5.0:0.0];
        [outerShadow setShadowOffset:shadow?NSZeroSize:NSMakeSize(0, -1)];
        [outerShadow set];
        
        NSColor * bgColor = shadow?[NSColor colorWithDeviceRed:0.0/255.0 green:43.0/255.0 blue:145.0/255.0 alpha:1.0]:[NSColor colorWithDeviceWhite:0.1 alpha:1.0];
        [bgColor set];
        [fillPath fill];
        
        [outerShadow release];
        [ctx restoreGraphicsState];
        
        
        
        [ctx saveGraphicsState];
        [fillPath setClip];
        
        NSColor * topColor = [NSColor colorWithDeviceWhite:24.0/255.0 alpha:1.0f];
        NSColor * bottomColor = [NSColor colorWithDeviceWhite:20.0/255.0 alpha:1.0f];
        if (shadow) {
            topColor = [NSColor colorWithDeviceRed:22.0/255.0 green:57.0/255.0 blue:123.0/255.0 alpha:1];
            bottomColor = [NSColor colorWithDeviceRed:0 green:43.0/255.0 blue:146.0/255.0 alpha:1];
        }
        NSGradient *backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                          topColor, 0.0f, 
                                          bottomColor, 1.0f, 
                                          nil];
        [backgroundGradient drawInRect:[fillPath bounds] angle:90.0f];
        [backgroundGradient release];
        
        [ctx restoreGraphicsState];
    }
}

@end
