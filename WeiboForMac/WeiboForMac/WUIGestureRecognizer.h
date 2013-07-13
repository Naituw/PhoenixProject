//
//  WUIGestureRecognizer.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-12.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUIAction.h"

@class WUIView;

typedef enum {
    WUIGestureRecognizerStatePossible,
    WUIGestureRecognizerStateBegan,
    WUIGestureRecognizerStateChanged,
    WUIGestureRecognizerStateEnded,
    WUIGestureRecognizerStateCancelled,
    WUIGestureRecognizerStateFailed,
    WUIGestureRecognizerStateRecognized = WUIGestureRecognizerStateEnded
} WUIGestureRecognizerState;

@class WUIGestureRecognizer;

@protocol WUIGestureRecognizerDelegate <NSObject>

- (BOOL)gestureRecognizerShouldBegin:(WUIGestureRecognizer *)r;

@end

@interface WUIGestureRecognizer : NSObject
{
    NSMutableArray * _registeredActions;
    WUIGestureRecognizerState _state;
}

- (id)initWithTarget:(id)target action:(SEL)action;

- (void)addTarget:(id)target action:(SEL)action;
- (void)removeTarget:(id)target action:(SEL)action;

@property (nonatomic, assign) BOOL cancelsEvent;
@property (nonatomic, assign) WUIView * view;
@property (nonatomic, assign, readonly) WUIGestureRecognizerState state;
@property (nonatomic, assign) id<WUIGestureRecognizerDelegate> delegate;

@end
