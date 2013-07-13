//
//  WTButtonCell.h
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface WTComposeButtonCell : NSButtonCell {
    BOOL shouldInset;
}

@property(readwrite) BOOL shouldInset;

- (NSRect)buttonRectByCellRect:(NSRect) rect;

@end
