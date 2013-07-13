//
//  WeiboMac2Window.m
//  new-window
//
//  Created by Wu Tian on 12-7-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboMac2Window.h"
#import "WeiboConstants.h"
#import "TUINSWindow.h"
#import "NSWindow+WMAdditions.h"
#import "WTComposeWindow.h"

@implementation TUINSWindow (UniqueIdentifier)

- (NSString *)uniqueIdentifier
{
    return nil;
}

@end

@interface WeiboMac2Window ()
{
    NSString * _uniqueIndetifier;
}

@end

@implementation WeiboMac2Window

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WeiboObjectWithIdentifierWillDeallocNotification object:self userInfo:@{WeiboObjectUserInfoUniqueIdentifierKey : self.uniqueIdentifier}];
    
    [_uniqueIndetifier release], _uniqueIndetifier = nil;
    [super dealloc];
}

- (CGRect)defaultFrame
{
    CGRect screenFrame = [[NSScreen mainScreen] visibleFrame];
    CGFloat width = 380, height = MIN(645, screenFrame.size.height);
    CGRect defaultFrame = CGRectMake(135, (screenFrame.size.height - height)/2,
                                     width, height);
    return defaultFrame;
}

- (id)init
{
    if (self = [super initWithContentRect:[self initialFrame]])
    {        
        [self setMinSize:NSMakeSize(310, 380)];
        [self setMaxSize:NSMakeSize(610, 2000)];
        [self setMovableByWindowBackground:YES];
        [self setReleasedWhenClosed:NO];
        [nsView ab_setIsOpaque:NO];
        
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        _uniqueIndetifier = (NSString *)uuidStringRef;
        
        
    }
    return self;
}

- (BOOL)canBecomeKeyWindow{
    return YES;
}
- (BOOL)canBecomeMainWindow{
    return YES;
}
- (BOOL)useCustomContentView{
    return YES;
}

- (void)drawBackground:(CGRect)rect{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGFloat columnBGWhite = 245.0/255.0;
    
    CGRect sideBarRect = rect;
    sideBarRect.size.width = WeiboMac2WindowSideBarWidth;
    TUIImage * sideBarImage = [TUIImage imageNamed:@"sidebar.png"];
    sideBarImage = [sideBarImage stretchableImageWithLeftCapWidth:0 topCapHeight:29];
    [sideBarImage drawInRect:sideBarRect blendMode:kCGBlendModeNormal alpha:0.92];
    
    CGRect columnBGRect = CGRectMake(WeiboMac2WindowSideBarWidth - WeiboMac2WindowCornerRadius, 0, rect.size.width - (WeiboMac2WindowSideBarWidth - WeiboMac2WindowCornerRadius), rect.size.height);
    CGContextClipToRoundRect(ctx, columnBGRect, WeiboMac2WindowCornerRadius);
    CGContextSetGrayFillColor(ctx, columnBGWhite, 1.0);
    CGContextFillRect(ctx, columnBGRect);
}

- (BOOL)presentingSheet
{
    return (self.attachedSheet != nil);
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(performClose:) ||
        menuItem.action == @selector(openCurrentViewControllerInSatelliteWindow) ||
        menuItem.action == @selector(performMiniaturize:) ||
        menuItem.action == @selector(performZoom:))
    {
        return ![self presentingSheet];
    }
    else if (menuItem.action == @selector(toggleKeepsOnTop:))
    {
        menuItem.state = (self.level == NSNormalWindowLevel) ? NSOffState : NSOnState;
        return YES;
    }

    return [super validateMenuItem:menuItem];
}
- (void)performZoom:(id)sender
{
    if ([self presentingSheet])
    {
        return;
    }
    
    NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame]; 
    //CGFloat topPosition = 
    windowFrame.size = [self maxSize];
    windowFrame.size.height = MIN(windowFrame.size.height, screenFrame.size.height);
    windowFrame.size.width = MIN(windowFrame.size.width, screenFrame.size.width);
    
    windowFrame = ABClampProposedRectToScreen(windowFrame);
    
    if (CGRectEqualToRect(self.frame, windowFrame))
    {
        // Already maximized, bring back to default size.
        
        CGFloat targetX = windowFrame.origin.x;
        
        windowFrame = [self defaultFrame];
        windowFrame.origin.x = targetX;
    }
    
    [self setFrame:windowFrame display:YES animate:YES];
}
- (void)performMiniaturize:(id)sender
{
    if ([self presentingSheet])
    {
        return;
    }
    
    [self miniaturize:sender];
}
- (void)performClose:(id)sender
{
    if ([self presentingSheet])
    {
        return;
    }
    
    [self close];
}

- (NSString *)uniqueIdentifier
{
    return _uniqueIndetifier;
}

- (void)toggleKeepsOnTop:(id)sender
{
    NSMenuItem * item = sender;
    NSInteger currentLevel = self.level;
    
    if (currentLevel == NSNormalWindowLevel)
    {
        self.level = NSFloatingWindowLevel;
        item.state = NSOnState;
    }
    else
    {
        self.level = NSNormalWindowLevel;
        item.state = NSOffState;
    }
}

- (void)windowWillStartLiveDrag
{
    [WTComposeWindow dissociateAllNipples];
}

- (void)resignKeyWindow
{
    [self.nsView invalidateHoverForView:self.nsView.rootView];
    
    [super resignKeyWindow];
}

#define kWeiboMac2WindowFrameAutoSaveName @"WeiboMac2WindowFrameAutoSave"
- (CGRect)initialFrame
{
    NSString * autosaved = [[NSUserDefaults standardUserDefaults] stringForKey:kWeiboMac2WindowFrameAutoSaveName];
    
    if (autosaved)
    {
        return NSRectFromString(autosaved);
    }
    
    return [self defaultFrame];
}
- (void)updateAutoSavedFrame
{
    CGRect defaultFrame = [self defaultFrame];
    CGRect currentFrame = [self frame];
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    if (CGRectEqualToRect(defaultFrame, currentFrame))
    {
        [ud removeObjectForKey:kWeiboMac2WindowFrameAutoSaveName];
    }
    else
    {
        [ud setObject:NSStringFromRect(currentFrame) forKey:kWeiboMac2WindowFrameAutoSaveName];
    }
}

@end
