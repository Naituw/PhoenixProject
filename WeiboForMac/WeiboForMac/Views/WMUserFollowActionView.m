//
//  WMUserFollowActionView.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-4.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMUserFollowActionView.h"
#import "TUIKit.h"
#import "WTCGAdditions.h"

@implementation WMUserFollowActionView
@synthesize menuButton, followButton, delegate = _delegate;

+ (id)font{
    return [TUIFont fontWithName:@"HelveticaNeue" size:12.0];
}
+ (CGFloat)expectedWidth{
    return 100;
}
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [TUIColor clearColor];
        followButton = [[TUIButton buttonWithType:TUIButtonTypeCustom] retain];
        menuButton = [[TUIButton buttonWithType:TUIButtonTypeCustom] retain];
        followButton.layout = ^(TUIView * v){
            WMUserFollowActionView * SELF = (WMUserFollowActionView *)v.superview;
            return [SELF leftRect];
        };
        followButton.drawRect = ^(TUIView *v, CGRect rect) {
            CGRect b = v.bounds;
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            
            CGContextSaveGState(ctx);
            CGMutablePathRef tempPath = createLeftRightRoundedPathForRect(rect, 3, 0);
            CGContextAddPath(ctx, tempPath);
            CGContextClip(ctx);
            CGContextSetRGBFillColor(ctx, 0.64, 0.64, 0.64, 1.0);
            CGContextFillRect(ctx, b);
            CGContextSetRGBFillColor(ctx, 0.79, 0.79, 0.79, 1.0);
            CGContextFillRect(ctx, CGRectMake(b.size.width - 1, 1, 1, b.size.height - 2));
            CGPathRelease(tempPath);
            
            tempPath = createLeftRightRoundedPathForRect(CGRectInset(rect, 1.0, 1.0), 3, 0);
            CGContextAddPath(ctx, tempPath);
            CGContextClip(ctx);
            if ([v.nsView isTrackingSubviewOfView:v]) {
                WTCGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, 24), 0.73, CGPointMake(0, 0), 0.86, 1.0);
            }else {
                WTCGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, 24), 0.96, CGPointMake(0, 0), 0.85, 1.0);
            }
            CGPathRelease(tempPath);
            CGContextRestoreGState(ctx);
            NSDictionary * textAttrs = [(WMUserFollowActionView *)v.superview textAttributes];
            WMUserFollowActionView * SELF = (WMUserFollowActionView *)v.superview;
            NSString * buttonString = [SELF.delegate iFollowThem]?@"取消关注":@"关注";
            NSAttributedString * string = [[NSAttributedString alloc] initWithString: buttonString
                                                                          attributes:textAttrs];
            CGRect textRect = b;
            textRect.size.height -= 4;
            [string drawInRect:textRect];
            [string release];
        };
        [followButton addTarget:self action:@selector(followAction:) forControlEvents:TUIControlEventTouchUpInside];
        menuButton.layout = ^(TUIView * v){
            WMUserFollowActionView * SELF = (WMUserFollowActionView *)v.superview;
            return [SELF rightRect];
        };
        menuButton.drawRect = ^(TUIView *v, CGRect rect) {
            CGRect b = v.bounds;
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            WMUserFollowActionView * SELF = (WMUserFollowActionView *)v.superview;
            
            CGFloat loadedFollowStatus = [SELF.delegate didLoadFollowStatus];
            CGContextSaveGState(ctx);
            CGMutablePathRef tempPath = createLeftRightRoundedPathForRect(rect, loadedFollowStatus?0:3, 3);
            CGContextAddPath(ctx, tempPath);
            CGContextClip(ctx);
            CGContextSetRGBFillColor(ctx, 0.64, 0.64, 0.64, 1.0);
            CGContextFillRect(ctx, b);
            if (loadedFollowStatus) {
                CGContextSetRGBFillColor(ctx, 0.91, 0.91, 0.91, 1.0);
                CGContextFillRect(ctx, CGRectMake(0, 1, 1, b.size.height - 2));
            }
            CGPathRelease(tempPath);
            
            tempPath = createLeftRightRoundedPathForRect(CGRectInset(rect, 1.0, 1.0), loadedFollowStatus?0:3, 3);
            CGContextAddPath(ctx, tempPath);
            CGContextClip(ctx);
            if ([v.nsView isTrackingSubviewOfView:v]) {
                WTCGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, 24), 0.73, CGPointMake(0, 0), 0.86, 1.0);
            }else {
                WTCGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, 24), 0.96, CGPointMake(0, 0), 0.85, 1.0);
            }
            CGContextRestoreGState(ctx);
            CGPathRelease(tempPath);
            
            TUIImage * image = [TUIImage imageNamed:@"profile-dropdown.png" cache:YES];
            [image drawInRect:CGRectMake(6, 6, 21, 13)];
        };
        
        [self addSubview:followButton];
        [self addSubview:menuButton];
    }
    return self;
}
- (void)dealloc{
    [followButton release]; followButton = nil;
    [menuButton release]; menuButton = nil;
    [super dealloc];
}
- (CGRect)leftRect{
    return CGRectMake(0, 0, 68, 24);
}
- (CGRect)rightRect{
    return CGRectMake(68, 0, 32, 24);
}
- (NSDictionary *)textAttributes{
    NSShadow * textShadow = [[NSShadow alloc] init];
    [textShadow setShadowBlurRadius:0.0];
    [textShadow setShadowColor:[NSColor colorWithDeviceWhite:0.9 alpha:1.0]];
    [textShadow setShadowOffset:NSMakeSize(0, -1)];
    NSMutableParagraphStyle * textStyle = [[NSMutableParagraphStyle alloc] init];
    [textStyle setAlignment:NSCenterTextAlignment];
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSColor colorWithDeviceWhite:0.3 alpha:1.0], NSForegroundColorAttributeName, 
                                 textShadow,NSShadowAttributeName,
                                 textStyle, 
                                 NSParagraphStyleAttributeName, nil];
    [textStyle release];
    [textShadow release];
    return attributes;
}
- (void)layoutSubviews{
    [self update];
}
- (void)drawRect:(CGRect)rect{
}
- (void)_needsDisplayAnimated{
}
- (void)viewWillDisplayLayer:(TUIView *)v{
    
}
- (void)followAction:(id)sender{
    [_delegate toggleFollow];
}
- (void)update{
    if ([_delegate didLoadFollowStatus]) {
        [menuButton redraw];
        [followButton setHidden:NO];
        [followButton redraw];
    }else {
        [followButton setHidden:YES];
        [menuButton redraw];
        [followButton redraw];
    }
}

@end
