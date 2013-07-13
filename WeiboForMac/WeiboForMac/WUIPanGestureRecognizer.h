//
//  WUIPanGestureRecognizer.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-12.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WUIGestureRecognizer.h"

typedef enum {
    WUIPanGestureRecognizerDirectionRight = 1 << 0,
    WUIPanGestureRecognizerDirectionLeft  = 1 << 1,
    WUIPanGestureRecognizerDirectionUp    = 1 << 2,
    WUIPanGestureRecognizerDirectionDown  = 1 << 3
} WUIPanGestureRecognizerDirection;

@interface WUIPanGestureRecognizer : WUIGestureRecognizer

@property (nonatomic, assign) WUIPanGestureRecognizerDirection direction;
@property (nonatomic, assign) CGPoint lastDeltaOffset;
@property (nonatomic, assign) CGPoint offset;

@end
