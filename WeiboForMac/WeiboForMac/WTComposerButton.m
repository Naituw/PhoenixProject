//
//  WTComposeButton.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-26.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTComposerButton.h"
#import "WTComposeButtonCell.h"

@implementation WTComposerButton
@synthesize pressedDown = _pressedDown;

- (id)initWithFrame:(NSRect)frameRect{
    NSRect buttonRect = NSInsetRect(frameRect, -1.0, -1.0);
    if ((self = [super initWithFrame:buttonRect])) {
        
    }
    return self;
}

+ (Class)cellClass{
    return [WTComposeButtonCell class];
}

- (void)setShouldInset:(BOOL)inset{
    WTComposeButtonCell * cell = [self cell];
    if (cell.shouldInset == inset) {
        return;
    }
    if (inset) {
        [self setFrame:NSInsetRect(self.frame, -4.0, -4.0)];
    }else{
        [self setFrame:NSInsetRect(self.frame, 4.0, 4.0)];
    }
    cell.shouldInset = inset;
}

@end
