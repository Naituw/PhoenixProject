//
//  WMFollowButton.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMFollowButton.h"

@interface WMFollowButton ()

@end

@implementation WMFollowButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clearsContextBeforeDrawing = YES;
        self.alpha = 0.0;
    }
    return self;
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    if (!_flags.hovering)
    {
        _flags.hovering = YES;
        
        [TUIView animateWithDuration:0.3 animations:^{
            [self redraw];
        }];
    }
    [super mouseEntered:theEvent];
}
- (void)mouseExited:(NSEvent *)theEvent
{
    if (_flags.hovering)
    {
        _flags.hovering = NO;
        
        [TUIView animateWithDuration:0.3 animations:^{
            [self redraw];
        }];
    }
    [super mouseExited:theEvent];
}
- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
}

- (NSTimeInterval)toolTipDelay
{
    return 0.3;
}

- (void)setFollowState:(WMFollowButtonState)followState
{
    if (_followState != followState)
    {
        _followState = followState;
        
        [TUIView animateWithDuration:0.3 animations:^{
            if (followState == WMFollowButtonStateUnknow && self.alpha > 0)
            {
                self.alpha = 0;
            }
            else if (followState != WMFollowButtonStateUnknow && self.alpha <= 0)
            {
                self.alpha = 1;
            }
            [self redraw];
        }];
    }
}

- (NSString *)backgroundImageName
{
    NSString * imageName = @"toolbar-button-normal";
    if (self.tracking)
    {
        imageName = @"toolbar-button-highlighted";
    }
    else if (_flags.hovering)
    {
        imageName = @"toolbar-button-hover";
    }
    else if (self.followState == WMFollowButtonStateFollowing ||
             self.followState == WMFollowButtonStateFollowedEachother)
    {
        imageName = @"toolbar-button-selected";
    }

    return imageName;
}

- (BOOL)whiteTextColor
{
    return ((self.followState == WMFollowButtonStateFollowing || self.followState == WMFollowButtonStateFollowedEachother) && !_flags.hovering) ||
    (self.tracking);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx, rect);
    
    CGFloat alpha = 1.0;

    if (self.dimsInBackground && self.nsWindow && !self.nsWindow.isKeyWindow)
    {
        alpha = 0.5;
    }
    
    NSString * imageName = [self backgroundImageName];
    
    TUIImage * bg = [[TUIImage imageNamed:[NSString stringWithFormat:@"%@.png",imageName]] stretchableImageWithLeftCapWidth:6 topCapHeight:12];
    [bg drawInRect:rect blendMode:kCGBlendModeNormal alpha:alpha];
    
    NSString * title = NSLocalizedString(@"Follow", nil);
    
    
    BOOL whiteText = [self whiteTextColor];
    
    if (self.followState == WMFollowButtonStateFollowing ||
        self.followState == WMFollowButtonStateFollowedEachother)
    {
        if (_flags.hovering)
        {
            title = NSLocalizedString(@"Unfollow", nil);
        }
        else if (self.followState == WMFollowButtonStateFollowedEachother)
        {
            title = NSLocalizedString(@"Mutual", nil);
        }
        else
        {
            title = NSLocalizedString(@"Following", nil);
        }
    }
    
    alpha = MAX(0.9, alpha);
    
    TUIColor * textColor = whiteText ? [TUIColor colorWithWhite:1.0 alpha:alpha] : [TUIColor colorWithWhite:0.2 alpha:alpha];
    TUIColor * shadowColor = whiteText ? [TUIColor colorWithWhite:0.0 alpha:alpha] : [TUIColor whiteColor];
    CGSize shadowOffset = CGSizeMake(0, whiteText ? 1 : -1);
    
    TUIFont * font = [TUIFont boldDefaultFontOfSize:11];
    
    CGSize size = [title ab_sizeWithFont:font];
    CGContextSaveGState(ctx);
    CGContextSetShadowWithColor(ctx, shadowOffset, 0, shadowColor.CGColor);
    
    [title ab_drawInRect:CGRectGetCenterRect(rect, size) color:textColor font:font];
    CGContextRestoreGState(ctx);
}

@end
