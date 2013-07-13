//
//  WTButton.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTButton.h"
#import "WTComposeButtonCell.h"

@implementation WTButton

- (id)initWithFrame:(NSRect)frameRect{
    if((self = [super initWithFrame:frameRect])){
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([self action])
    {
        [super mouseDown:theEvent];
        return;
    }
    if ([self menu])
    {
        [[self menu] update];
        [NSMenu popUpContextMenu:[self menu] withEvent:theEvent forView:self];
    }
}

@end
