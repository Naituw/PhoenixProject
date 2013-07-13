//
//  WTTextRenderer.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-7.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTTextRenderer.h"
#import "WTEventHandler.h"
#import "ABActiveRange.h"
#import "WMRootViewController.h"
#import "WeiboForMacAppDelegate.h"

@implementation WTTextRenderer

- (void)mouseUp:(NSEvent *)event
{
    [super mouseUp:event];
    
    if (self.hitRange && [self.clickDelegate respondsToSelector:@selector(textRenderer:didClickActiveRange:)])
    {
        [self.clickDelegate textRenderer:self didClickActiveRange:self.hitRange];
    }

    self.hitRange = nil;
    [self.view redraw];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    self.hitRange = nil;

    [super mouseDragged:theEvent];
}

@end
