//
//  WTImageAttachmentCell.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-27.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTImageAttachmentCell.h"

@implementation WTImageAttachmentCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
    NSRect frame = [self buttonRectByCellRect:cellFrame];
    NSImage * image = [self image];
    if (image) {
        NSSize imageSize = [image size];
        BOOL isWidthBigger = YES;
        if (imageSize.height > imageSize.width) {
            isWidthBigger = NO;
        }
        
        NSRect fromRect;
        if (isWidthBigger) {
            fromRect = NSMakeRect((imageSize.width - imageSize.height)/2,
                                  0, imageSize.height, imageSize.height);
        }else{
            fromRect = NSMakeRect(0, (imageSize.height - imageSize.width)/2, imageSize.width, imageSize.width);
        }
        
        NSGraphicsContext * ctx = [NSGraphicsContext currentContext];
        [ctx saveGraphicsState];
        frame = NSInsetRect(frame, 1.0, 1.0);
        NSBezierPath * imagePath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:4.0 yRadius:4.0
                                    ];
        [imagePath setClip];
        [image setFlipped:YES];
        [image drawInRect:frame fromRect:fromRect operation:NSCompositeCopy fraction:1.0];
        [image setFlipped:NO];
        [ctx restoreGraphicsState];
    }
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView{
    if ([self image]) {
        [super drawBezelWithFrame:frame inView:controlView];
    }
}

@end
