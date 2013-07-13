//
//  WMSideBarItemView.m
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMSideBarItemView.h"
#import "TUIKit.h"
#import "WMSideBarView.h"

@interface WMSideBarItemView (){
    struct {
        unsigned int mouseDown:1;
    } _flags;
}
@property (nonatomic) BOOL overLight;
@property (nonatomic, retain) TUIView * tooltip;
@property (nonatomic, retain) TUIAttributedString * tooltipString;
@property (nonatomic) BOOL didDrag;
@end

@implementation WMSideBarItemView
@synthesize delegate = _delegate, section = _section, indexPath = _indexPath;
@synthesize badge = _badge, highlight = _highlight, imageName = _imageName;
@synthesize overLight = _overLight, sectionHeading = _sectionHeading;
@synthesize image= _image, tooltip = _tooltip, tooltipString = _tooltipString;
@synthesize didDrag = _didDrag, sectionHeadingSelected = _sectionHeadingSelected;

- (void)dealloc{
    [_indexPath release];
    [_imageName release];
    [_image release];
    [_tooltip release];
    [_tooltipString release];
    [super dealloc];
}

+ (void)initialize{
    
}
- (CGRect)tooltipRect{
    CGRect rect = CGRectZero;
    rect.size = [self.tooltipString ab_sizeConstrainedToWidth:400.0];
    rect.size.height = 26;
    rect.size.width += 18;
    return rect;
}
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.moveWindowByDragging = YES;
        
        self.tooltip = [[[TUIView alloc] initWithFrame:CGRectZero] autorelease];
        self.tooltip.opaque = NO;
        
        __block typeof(self) blockSelf = self;
        self.tooltip.drawRect = ^(TUIView * v, CGRect rect){
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            CGContextClearRect(ctx, rect);
            CGContextSetGrayFillColor(ctx, 0.0, 0.3);
            CGContextFillRect(ctx, rect);
            CGContextSetShadowWithColor(ctx, CGSizeMake(0, -2), 5, [TUIColor blackColor].CGColor);
            TUIAttributedString * s = blockSelf.tooltipString;
            CGFloat textHeight = [s ab_size].height;
            CGRect textRect = CGRectInset(rect, 0, (rect.size.height - textHeight)/2 - 1);
            [s ab_drawInRect:textRect];
        };
        self.tooltip.clipsToBounds = YES;

    }
    return self;
}
- (WMSideBarView *)sidebarView{
    return (WMSideBarView *)self.superview;
}
- (void)drawRect:(CGRect)rect{
    CGRect b = self.bounds;
    
    CGFloat scale = self.layer.contentsScale;
    
    TUIImage *image = self.image?self.image:[TUIImage imageNamed:self.imageName cache:YES];
    if (!image) {
        return;
    }
    if (self.sectionHeading) {
        image = [image scale:CGSizeMake(48 * scale, 48 * scale)];
        image = [image roundImage:4 * scale];
        [image __setScale:scale];
    }

    CGRect imageRect = ABIntegralRectWithSizeCenteredInRect([image size], b);
    TUIImage * bgImage = [TUIImage imageNamed:@"TabBarItemSelectedBackground.png" cache:YES];
    
    
    image = [TUIImage imageWithSize:imageRect.size scale:image.scale drawing:^(CGContextRef ctx) {
        CGRect r = CGRectZero;
        r.size = imageRect.size;
        TUIColor * emboseColor = [TUIColor colorWithWhite:1.0 alpha:1];
        
        // section avatar drawing below
        if (self.sectionHeading) {
            CGFloat alpha = 1.0;
            if (!self.sectionHeadingSelected) {
                alpha *= 0.6;
            }
            if ([self.nsView isTrackingSubviewOfView:self] & !self.didDrag) {
                alpha *= 0.8;
            }
            emboseColor = [TUIColor colorWithWhite:1.0 alpha:0.4];
            [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:alpha];
        }
        // item drawing below
        else {
            CGContextClipToMask(ctx, r, image.CGImage);
            
            // Mouse Tracking Button.
            if ([self.nsView isTrackingSubviewOfView:self] & !self.didDrag || self.highlight) {
                CGRect bgRect = ABIntegralRectWithSizeCenteredInRect(bgImage.size, r);
                bgRect.origin.y = 0; // little fix
                CGContextDrawImage(ctx, bgRect, bgImage.CGImage);
            }
            // Normal State.
            else if(!self.highlight){
                emboseColor = [TUIColor colorWithWhite:1 alpha:0.8];
                CGFloat alpha = 1.0;

                CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
                CGFloat components[] = { 
                    75.0/255.0,79.0/255.0,84.0/255.0,alpha,
                    45.0/255.0,48.0/255.0,51.0/255.0,alpha,
                    62.0/255.0,63.0/255.0,65.0/255.0,alpha };
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, NULL, 3);
                CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, r.size.height), CGPointZero, 0);
                CGColorSpaceRelease(colorspace);
                CGGradientRelease(gradient);
            }
        }
        
        // Draw Embose.
        
        CGFloat shadowAlpha = 1.0;
        
        TUIImage *innerShadow = nil;
        
        if (self.sectionHeading)
        {
            if (!self.sectionHeadingSelected)
            {
                shadowAlpha = 0.5;
            }
            
            innerShadow = [image innerShadowWithOffset:CGSizeMake(0, -1) radius:1 color:emboseColor backgroundColor:[TUIColor colorWithWhite:0.0 alpha:shadowAlpha]];
        }
        else
        {
            innerShadow = [image innerShadowWithOffset:CGSizeMake(0, -1) radius:1 color:emboseColor backgroundColor:[TUIColor colorWithRed:0.77 green:0.85 blue:0.96 alpha:shadowAlpha]];
        }
        
        CGRect shadowRect = r;

        CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
        CGContextDrawImage(ctx, shadowRect, innerShadow.CGImage);
    }];
    
    CGFloat sizeMultiplier = image.size.width / imageRect.size.width;
    
    // Draw Under Shadow
    
    image = [TUIImage imageWithSize:CGSizeMake(image.size.width + 10 * sizeMultiplier, image.size.height + 10 * sizeMultiplier) scale:image.scale drawing:^(CGContextRef ctx) {
        
        TUIColor * shadowColor = [TUIColor blackColor];
        CGFloat shadowBlur = 6 * sizeMultiplier;
        CGSize shadowOffset = CGSizeMake(0, 0);
        if ([self.nsView isTrackingSubviewOfView:self] & !self.didDrag) {
            shadowColor = [TUIColor colorWithRed:81.0/255.0
                                           green:216.0/255.0
                                            blue:251.0/255.0
                                           alpha:1.0];
            self.overLight = YES;
        }else {
            shadowOffset = CGSizeMake(0, -1);
            shadowBlur = 4;
            self.overLight = NO;
        }
        if (self.highlight && !self.sectionHeading && !self.overLight) {
            shadowColor = [TUIColor colorWithRed:81.0/255.0
                                           green:216.0/255.0
                                            blue:251.0/255.0
                                           alpha:0.4];
            shadowBlur = 8;
            shadowOffset = CGSizeMake(0, 0);
        }
        CGContextSetShadowWithColor(ctx, shadowOffset, shadowBlur,
                                    shadowColor.CGColor);
        
        CGContextDrawImage(ctx, CGRectMake(5 * sizeMultiplier, 5 * sizeMultiplier, image.size.width, image.size.height), image.CGImage);
    }];
    
    imageRect = CGRectInset(imageRect, -5, -5);
    
    CGFloat alpha = self.nsWindow.isKeyWindow || self.sectionHeading || self.highlight?1.0:0.8;
    [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:alpha];
    
    if (self.badge > 0) {
        
        TUIImage * glow = [TUIImage imageNamed:@"TabBarGlow.png" cache:YES];
        
        if (!self.sectionHeading)
        {
            CGSize s = glow.size;
            CGRect glowRect = CGRectMake(b.size.width - s.width, (b.size.height - s.height)/2,
                                         s.width, s.height);
            [glow drawInRect:glowRect blendMode:kCGBlendModeDestinationAtop alpha:1.0];
        }
        else if (!self.sectionHeadingSelected)
        {
            CGFloat baseY = (b.size.height - 12 * 4) / 2;
            
            for (NSInteger index = 0; index < 4; index++)
            {
                BOOL light = self.badge & (1 << index);
                
                if (light)
                {
                    CGRect glowRect = CGRectMake(b.size.width - 10, b.size.height - 12 * (index + 1) - baseY, 10, 12);
                    [glow drawInRect:glowRect blendMode:kCGBlendModeDestinationAtop alpha:1.0];
                }
            }
        }
    }
}
- (void)mouseDown:(NSEvent *)event{
    [self redraw];
    if (self.tooltip.alpha > 0) {
        CGRect rect = [self tooltipRect];
        rect.origin.x += 10;
        rect = ABRectCenteredInRect(rect, self.bounds);
        rect.origin.x = self.bounds.size.width + 5;
        self.tooltip.frame = rect;
    }
    self.overLight = YES;
    [super mouseDown:event];
}
- (void)mouseDragged:(NSEvent *)event{
    self.didDrag = YES;
    if (self.overLight) {
        [TUIView animateWithDuration:0.3 animations:^{
            [self redraw];
        }];
        self.overLight = NO;
    }
    [super mouseDragged:event];
    if (self.tooltip.alpha > 0){
        [TUIView animateWithDuration:0.2 animations:^{
            self.tooltip.alpha = 0;
        }completion:^(BOOL finished) {
            [self.tooltip removeFromSuperview];
        }];
    }
}
- (void)mouseUp:(NSEvent *)theEvent{
    [self redraw];
    if (self.tooltip.alpha > 0) {
        CGRect frame = self.tooltip.frame;
        frame.origin.x += 100;
        [TUIView animateWithDuration:0.2 
                               delay:0.1 
                               curve:TUIViewAnimationCurveEaseInOut
                          animations:^{
            self.tooltip.frame = frame;
            self.tooltip.alpha = 0;
        } completion:^(BOOL finished) {
            [self.tooltip removeFromSuperview]; 
        }];
    }
    [super mouseUp:theEvent];

    if (self.didDrag) {
        self.didDrag = NO;
    }else {
        if (self.sectionHeading) {
            if (theEvent.clickCount == 2) {
                if ([self.delegate respondsToSelector:@selector(sidebarView:doubleClickedSection:)]) {
                    [self.delegate sidebarView:nil doubleClickedSection:self.section];
                }
            }else {
                if ([self.delegate respondsToSelector:@selector(sidebarView:didSelectSection:)]) {
                    [self.delegate sidebarView:nil didSelectSection:self.section];
                }
            }
            self.indexPath = [TUIFastIndexPath indexPathForRow:0 
                                                     inSection:self.section];
        }else {
            BOOL shouldSelect = YES;
            if ([self.delegate respondsToSelector:@selector(sidebarView:shouldSelectRow:)]) {
                shouldSelect = [self.delegate sidebarView:nil shouldSelectRow:self.indexPath.row];
            }
            
            if (!shouldSelect) {
                if ([self.delegate respondsToSelector:@selector(sidebarView:didClickShouldNotSelectRow:)]) {
                    [self.delegate sidebarView:nil didClickShouldNotSelectRow:self.indexPath.row];
                }
            }else if (self.highlight) {
                if ([self.delegate respondsToSelector:@selector(sidebarView:doubleClickedRow:)]) {
                    [self.delegate sidebarView:nil doubleClickedRow:self.indexPath.row];
                }
            }else {
                if ([self.delegate respondsToSelector:@selector(sidebarView:didSelectRow:)]) {
                    [self.delegate sidebarView:nil didSelectRow:self.indexPath.row];
                }
            }
        }
    }
}
- (void)mouseEntered:(NSEvent *)theEvent{
    CGRect tooltipRect = [self tooltipRect];
    [self drawTooltip:tooltipRect];
    tooltipRect = ABRectCenteredInRect(tooltipRect, self.bounds);
    tooltipRect.origin.x = self.bounds.size.width - 10;
    [CATransaction begin];
    self.tooltip.frame = tooltipRect;
    self.tooltip.alpha = 0;
    [self addSubview:self.tooltip];
    [CATransaction commit];
    [CATransaction flush];
    [TUIView animateWithDuration:0.2 delay:0.38 curve:TUIViewAnimationCurveEaseInOut animations:^{
        self.tooltip.alpha = 1;
        CGRect toRect = tooltipRect;
        toRect.origin.x += 20;
        self.tooltip.frame = toRect;
    } completion:NULL];
}
- (void)mouseExited:(NSEvent *)theEvent{
    CGRect tooltipRect = [self tooltipRect];
    tooltipRect = ABRectCenteredInRect(tooltipRect, self.bounds);
    tooltipRect.origin.x = self.bounds.size.width - 10;
    [TUIView animateWithDuration:0.3 animations:^{
        self.tooltip.alpha = 0;
        self.tooltip.frame = tooltipRect;
    } completion:^(BOOL finished) {
        [self.tooltip removeFromSuperview];
    }];
}
- (void)drawTooltip:(CGRect)bounds{
    self.tooltip.frame = bounds;
    self.tooltip.layer.cornerRadius = bounds.size.height / 2;
}
- (void)setToolTip:(NSString *)toolTipString{
    TUIAttributedString * s = [TUIAttributedString stringWithString:toolTipString];
    s.font = [TUIFont fontWithName:@"HelveticaNeue" size:16];
    s.color = [TUIColor whiteColor];
    s.alignment = TUITextAlignmentCenter;
    self.tooltipString = s;
}
- (NSString *)toolTip{
    return nil;
}

@end
