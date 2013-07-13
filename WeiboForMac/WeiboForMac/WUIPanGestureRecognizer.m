//
//  WUIPanGestureRecognizer.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-12.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WUIPanGestureRecognizer.h"

@implementation WUIPanGestureRecognizer

- (WUIPanGestureRecognizerDirection)directionForEvent:(NSEvent *)event
{
    CGFloat x = event.deltaX, y = event.deltaY;
    if (ABS(x) > ABS(y))
    {
        if (x > 0)
        {
            return WUIPanGestureRecognizerDirectionRight;
        }
        return WUIPanGestureRecognizerDirectionLeft;
    }
    else
    {
        if (y > 0)
        {
            return WUIPanGestureRecognizerDirectionUp;
        }
        return WUIPanGestureRecognizerDirectionDown;
    }
}

- (BOOL)scrollWheel:(NSEvent *)event
{
    if (!self.view.nsWindow.isKeyWindow)
    {
        return NO;
    }
    
    BOOL recognized = YES;
    BOOL clearsOffset = NO;
    BOOL clearsDeltaOffset = NO;
    BOOL recognizeStarted =
        _state == WUIGestureRecognizerStateBegan ||
        _state == WUIGestureRecognizerStateChanged;
    
    WUIPanGestureRecognizerDirection direction = [self directionForEvent:event];
    
    switch (event.phase)
    {
        case NSEventPhaseMayBegin:
        {
            recognized = NO;
            _state = WUIGestureRecognizerStatePossible;
            break;
        }
        case NSEventPhaseBegan:
        {
            BOOL shouldBegin = YES;
            
            if ([self.delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)])
            {
                shouldBegin = [self.delegate gestureRecognizerShouldBegin:self];
            }
            
            if ((self.direction & direction) && shouldBegin)
            {
                _state = WUIGestureRecognizerStateBegan;
                clearsOffset = YES;
            }
            else
            {
                recognized = NO;
            }
            break;
        }
        case NSEventPhaseChanged:
        {
            recognized = NO;
            if (recognizeStarted &&
                (event.deltaX || event.deltaY))
            {
                _state = WUIGestureRecognizerStateChanged;
                _offset = CGPointMake(_offset.x + event.deltaX, _offset.y + event.deltaY);
                recognized = YES;
            }
            break;
        }
        case NSEventPhaseEnded:
        {
            if (recognizeStarted)
            {
                _state = WUIGestureRecognizerStateEnded;
                clearsOffset = YES;
            }
            else
            {
                recognized = NO;
            }
            clearsDeltaOffset = YES;
            break;
        }
        case NSEventPhaseCancelled:
        {
            _state = WUIGestureRecognizerStateCancelled;
            clearsOffset = YES;
            clearsDeltaOffset = YES;
            break;
        }
        default:
        {
            _state = WUIGestureRecognizerStatePossible;
            recognized = NO;
            break;
        }
    }
    
    if (event.deltaX || event.deltaY)
    {
        self.lastDeltaOffset = CGPointMake(event.deltaX, event.deltaY);
    }
    
    if (recognized)
    {
        for (WUIAction *actionRecord in _registeredActions)
        {
            [actionRecord.target performSelector:actionRecord.action withObject:self withObject:event];
        }
    }
    
    if (clearsOffset)
    {
        _offset = CGPointZero;
    }
    
    if (clearsDeltaOffset)
    {
        self.lastDeltaOffset = CGPointZero;
    }
    
    return recognized;
}

@end
