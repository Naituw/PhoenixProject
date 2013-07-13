//
//  WTPopoverWindow.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-13.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTPopoverWindow.h"

@implementation WTPopoverWindow

- (id)init
{
    self = [super init];
    NSRect windowRect = NSMakeRect(0, 0, 455, 325);
    if (self) {
        [self setFrame:windowRect display:NO];
        NSView * view = [[NSView alloc] initWithFrame:windowRect];
        [self setContentView:view];
        view.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
        [view release];
        
        NSRect buttonRect = NSMakeRect(352, 290, 92, 32);
        saveButton = [[NSButton alloc] initWithFrame:buttonRect];
        saveButton.title = @"Save Pic";
        [saveButton setButtonType:NSMomentaryPushButton];
        [saveButton setBezelStyle:NSRoundedBezelStyle];
        saveButton.autoresizingMask = (NSViewMaxXMargin | NSViewMaxYMargin);

        [[self contentView] addSubview:saveButton];
    }
    
    return self;
}

@end
