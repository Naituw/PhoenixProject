//
//  WindowTrafficLightsView.m
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WindowTrafficLightsView.h"
#import "TUIImage.h"
#import "TUIButton.h"
#import "TUINSView.h"

@interface WindowTrafficLightsView ()
@property (nonatomic, retain) TUIButton * close;
@property (nonatomic, retain) TUIButton * minimize;
@property (nonatomic, retain) TUIButton * zoom;
@end

@implementation WindowTrafficLightsView
@synthesize close = _close, minimize = _minimize, zoom = _zoom;
@synthesize delegate = _delegate;

- (void)dealloc{
    [_close release];
    [_minimize release];
    [_zoom release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.moveWindowByDragging = YES;
        
        self.close = [TUIButton button];
        self.minimize = [TUIButton button];
        self.zoom = [TUIButton button];
                
        self.close.moveWindowByDragging = YES;
        self.minimize.moveWindowByDragging = YES;
        self.zoom.moveWindowByDragging = YES;
        
        [self.close addTarget:self action:@selector(close:) forControlEvents:TUIControlEventTouchUpInside];
        [self.minimize addTarget:self action:@selector(minimize:) forControlEvents:TUIControlEventTouchUpInside];
        [self.zoom addTarget:self action:@selector(zoom:) forControlEvents:TUIControlEventTouchUpInside];
        
        self.close.layout = ^(TUIView * v){
            CGRect frame = v.superview.bounds;
            frame.size.height -= 1;
            frame.origin.x += 5;
            frame.size.width = 19;
            return frame;
        };
        self.minimize.layout = ^(TUIView * v){
            CGRect frame = v.superview.bounds;
            frame.size.height -= 1;
            frame.origin.x += 5;
            frame.size.width = 19;
            frame.origin.x += 19;
            return frame;
        };
        self.zoom.layout = ^(TUIView * v){
            CGRect frame = v.superview.bounds;
            frame.size.height -= 1;
            frame.origin.x += 5;
            frame.size.width = 19;
            frame.origin.x += 38;
            return frame;
        };
        
        self.close.viewDelegate = self;
        self.minimize.viewDelegate = self;
        self.zoom.viewDelegate = self;
        
        [self addSubview:self.close];
        [self addSubview:self.minimize];
        [self addSubview:self.zoom];
        
        [self _update:NO];
    }
    return self;
}

- (void)_update:(BOOL)mouseInside{
    TUIImage * defaultImage = [TUIImage imageNamed:@"traffic-normal.png" cache:YES];
    TUIImage * closeImage = mouseInside?[TUIImage imageNamed:@"traffic-close.png" cache:YES]:defaultImage;
    TUIImage * minimizeImage = mouseInside?[TUIImage imageNamed:@"traffic-minimize.png" cache:YES]:defaultImage;
    TUIImage * zoomImage = mouseInside?[TUIImage imageNamed:@"traffic-zoom.png" cache:YES]:defaultImage;
    
    [TUIView animateWithDuration:mouseInside?0:0.25 animations:^{
        [self.close setImage:closeImage forState:TUIControlStateNormal];
        [self.close redraw];
        [self.minimize setImage:minimizeImage forState:TUIControlStateNormal];
        [self.minimize redraw];
        [self.zoom setImage:zoomImage forState:TUIControlStateNormal];
        [self.zoom redraw];
    }];
}

- (void)view:(TUIView *)v mouseEntered:(NSEvent *)event{
    [self _update:YES];
}
- (void)view:(TUIView *)v mouseExited:(NSEvent *)event{
    if (![self.close eventInside:event] && ![self.minimize eventInside:event] && ![self.zoom eventInside:event]) {
        [self _update:NO];
    }
}

- (void)close:(id)sender
{
    [self.nsView invalidateHoverForView:self.close];
    if([_delegate respondsToSelector:@selector(trafficClose:)])
        [_delegate performSelector:@selector(trafficClose:) withObject:self.close];
}
- (void)minimize:(id)sender{
    [self.nsView invalidateHoverForView:self.minimize];
    if([_delegate respondsToSelector:@selector(trafficMinimize:)])
        [_delegate performSelector:@selector(trafficMinimize:) withObject:self.minimize];
}
- (void)zoom:(id)sender{
    [self.nsView invalidateHoverForView:self.zoom];
    if([_delegate respondsToSelector:@selector(trafficZoom:)])
        [_delegate performSelector:@selector(trafficZoom:) withObject:self.zoom];
}

@end
