//
//  WUIView.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-12.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WUIView.h"
#import "WUIGestureRecognizer.h"
#import "WTUIViewController.h"

@implementation TUIView (WUIAdditions)

- (NSArray *)responderGestureRecognizers
{
    NSMutableArray * recognizers = [NSMutableArray array];
    
    TUIView * view = self;
    
    while (view)
    {
        if (![view isKindOfClass:[WUIView class]])
        {
            view = view.superview;
            continue;
        }
        [recognizers addObjectsFromArray:[(WUIView *)view gestureRecognizers]];
        view = (WUIView *)view.superview;
    }
    
    return recognizers;
}


- (BOOL)recognizeEvent:(NSEvent *)event withSelector:(SEL)selector
{
    BOOL cancelsEvent = NO;
    for (WUIGestureRecognizer * r in [self responderGestureRecognizers])
    {
        if ([r respondsToSelector:selector])
        {
            id obj = [r performSelector:selector withObject:event];
            BOOL recognizing = (r.state == WUIGestureRecognizerStateBegan || r.state == WUIGestureRecognizerStateChanged);
            if ((r.cancelsEvent && obj) || recognizing)
            {
                cancelsEvent = YES;
            }
        }
    }
    return cancelsEvent;
}

- (void)swipeWithEvent:(NSEvent *)event
{
    if (![self recognizeEvent:event withSelector:@selector(swipeWithEvent:)])
    {
        [self.superview swipeWithEvent:event];
    }
}

- (NSString *)windowIdentifier
{
    NSString * identifier = [self objectWithAssociatedKey:@"wui_window_identifier"];
    if (!identifier)
    {
        WTUIViewController * controller = (WTUIViewController *)self.firstAvailableViewController;
        if ([controller isKindOfClass:[WTUIViewController class]])
        {
            identifier = controller.windowIdentifier;
            [self setWindowIdentifier:identifier];
        }
    }
    return identifier;
}
- (void)setWindowIdentifier:(NSString *)windowIdentifier
{
    [self setObject:windowIdentifier forAssociatedKey:@"wui_window_identifier" retained:YES];
}

@end

@interface WUIView ()
{
    NSMutableSet * _gestureRecognizers;
}

@end

@implementation WUIView

- (void)dealloc
{
    [_gestureRecognizers release], _gestureRecognizers = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _gestureRecognizers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addGestureRecognizer:(WUIGestureRecognizer *)gestureRecognizer
{
    if (![_gestureRecognizers containsObject:gestureRecognizer]) {
        [gestureRecognizer.view removeGestureRecognizer:gestureRecognizer];
        [_gestureRecognizers addObject:gestureRecognizer];
        [gestureRecognizer setView:self];
    }
}

- (void)removeGestureRecognizer:(WUIGestureRecognizer *)gestureRecognizer
{
    if ([_gestureRecognizers containsObject:gestureRecognizer]) {
        [gestureRecognizer setView:nil];
        [_gestureRecognizers removeObject:gestureRecognizer];
    }
}

- (void)setGestureRecognizers:(NSArray *)newRecognizers
{
    for (WUIGestureRecognizer *gesture in [_gestureRecognizers allObjects]) {
        [self removeGestureRecognizer:gesture];
    }
    
    for (WUIGestureRecognizer *gesture in newRecognizers) {
        [self addGestureRecognizer:gesture];
    }
}

- (NSArray *)gestureRecognizers
{
    return [_gestureRecognizers allObjects];
}

- (void)beginGestureWithEvent:(NSEvent *)event
{
    if (![self recognizeEvent:event withSelector:@selector(beginGestureWithEvent:)])
    {
        [self.superview beginGestureWithEvent:event];
    }
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if (![self recognizeEvent:theEvent withSelector:@selector(scrollWheel:)])
    {
        [self.superview scrollWheel:theEvent];
    }
}

@end