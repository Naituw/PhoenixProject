//
//  WTStatusTableView.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-23.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTStatusTableView.h"
#import "WTStatusListViewController.h"
#import "WTStatusCell.h"
#import "TUITableView+WTAddition.h"

@implementation WTStatusTableView

- (void)dealloc
{
    [_textRenderer release], _textRenderer = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame style:(TUITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        self.textRenderer = [[TUITextRenderer new] autorelease];
    }
    return self;
}

- (void)mouseExited:(NSEvent *)event fromSubview:(TUIView *)subview{
    BOOL isMouseInside = YES;
    CGPoint locationInWindow = [event locationInWindow];
    CGSize windowSize = [event window].frame.size;
    if (locationInWindow.x > windowSize.width - 10 || locationInWindow.x < 70 ||
        locationInWindow.y < 0 || locationInWindow.y > windowSize.height) {
        isMouseInside = NO;
    }
    if (!isMouseInside) {
        for (WTStatusCell * cell in [self visibleCells]) {
            if ([cell respondsToSelector:@selector(forceToTakeMouseOut)]) {
                [cell forceToTakeMouseOut];
            }
        }
    }
}

@end
