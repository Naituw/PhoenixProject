//
//  NSWindow+WMAdditions.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-24.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "NSWindow+WMAdditions.h"

@implementation NSWindow (WMAdditions)

- (BOOL)isOnLeftSideOfScreen
{
    NSRect windowFrame = [self frame];
    NSRect screenRect = [self.screen frame];
    return (windowFrame.origin.x + windowFrame.size.width/2) < screenRect.size.width/2;
}

@end
