//
//  WMMediaViewerWindow.m
//  WeiboForMac
//
//  Created by Wutian on 13-6-1.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMMediaViewerWindow.h"

@implementation WMMediaViewerWindow

+ (NSArray *)mediaViewerWindows
{
    NSArray * allWindows = [NSApp windows];
    NSMutableArray * viewerWindows = [NSMutableArray array];
    
    for (NSWindow * window in allWindows)
    {
        if ([window isKindOfClass:[WMMediaViewerWindow class]])
        {
            [viewerWindows addObject:window];
        }
    }
    return viewerWindows;
}

- (void)performClose:(id)sender
{
    [self.viewerController makeNextViewerKeyWindow];
    [self.viewerController close];
}

- (void)keyDown:(NSEvent *)theEvent
{    
    if (theEvent.keyCode == 49)
    {
        // Space Key
        
        [self setAnimationBehavior:NSWindowAnimationBehaviorUtilityWindow];
        [self orderOut:nil];
        [self setOrderingOut:YES];
        [self.viewerController makeNextViewerKeyWindow];

        [self.viewerController performSelector:@selector(close) withObject:nil afterDelay:0.4];
    }
    else
    {
        [super keyDown:theEvent];
    }
}

@end
