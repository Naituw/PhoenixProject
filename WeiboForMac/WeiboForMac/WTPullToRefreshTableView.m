//
//  WTPullToRefreshTableView.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WTPullToRefreshTableView.h"
#import "TUITableView+WTAddition.h"
#import <Carbon/Carbon.h>

@implementation WTPullToRefreshTableView

- (void)dealloc
{
    if (pullView)
    {
        [self removeObserver:pullView forKeyPath:@"contentOffset"];
        [pullView release];
    }
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame style:(TUITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        self.autoresizingMask = TUIViewAutoresizingFlexibleSize;
        self.backgroundColor = [TUIColor colorWithWhite:245.0/255.0 alpha:1.0];
        self.alwaysBounceVertical = YES;
        self.animateSelectionChanges = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (pullView)
    {
        [pullView updateFrame];
    }
}

- (void)finishedLoadingNewer
{
    [pullView finishedLoading];
}


- (void)setPullDownViewDelegate:(id<WTPullDownViewDelegate>)delegate
{
    if (delegate)
    {
        if (!pullView)
        {
            pullView = [[WTPullDownView alloc] initWithScrollView:self];
            self.pullDownView = pullView;
        }
        pullView.delegate = delegate;
    }
    else
    {
        [pullView release], pullView = nil;
        self.pullDownView = nil;
    }
}

- (BOOL)performKeyAction:(NSEvent *)event
{
    self.animateSelectionChanges = YES;
    BOOL accepted = YES;
    
    unichar keyCode = [[event charactersIgnoringModifiers] characterAtIndex:0];
    
    if (keyCode == 'k')
    {
        [self selectPreviousRow:event];
    }
    else if (keyCode == 'j')
    {
        [self selectNextRow:event];
    }
    else
    {
        accepted = [super performKeyAction:event];
    }
    
    self.animateSelectionChanges = NO;
    return accepted;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if (![self recognizeEvent:theEvent withSelector:@selector(scrollWheel:)])
    {
        [super scrollWheel:theEvent];
    }
}


@end
