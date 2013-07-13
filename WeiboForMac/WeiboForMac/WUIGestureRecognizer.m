//
//  WUIGestureRecognizer.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-12.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WUIGestureRecognizer.h"

@interface WUIGestureRecognizer ()

@property (nonatomic, assign) WUIGestureRecognizerState state;

@end

@implementation WUIGestureRecognizer

- (void)dealloc
{
    [_registeredActions release], _registeredActions = nil;
    [super dealloc];
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    if (self = [super init])
    {
        _state = WUIGestureRecognizerStatePossible;
        _registeredActions = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self addTarget:target action:action];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    NSAssert(target != nil, @"target must not be nil");
    NSAssert(action != NULL, @"action must not be NULL");
    
    WUIAction *actionRecord = [[WUIAction alloc] init];
    actionRecord.target = target;
    actionRecord.action = action;
    [_registeredActions addObject:actionRecord];
    [actionRecord release];
}

- (void)removeTarget:(id)target action:(SEL)action
{
    WUIAction *actionRecord = [[WUIAction alloc] init];
    actionRecord.target = target;
    actionRecord.action = action;
    [_registeredActions removeObject:actionRecord];
    [actionRecord release];
}

@end
