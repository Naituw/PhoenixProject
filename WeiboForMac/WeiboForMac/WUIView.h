//
//  WUIView.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-12.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "TUIView.h"

@class WUIGestureRecognizer;

@interface WUIView : TUIView

@property (nonatomic,copy) NSArray *gestureRecognizers;

- (void)addGestureRecognizer:(WUIGestureRecognizer *)gestureRecognizer;
- (void)removeGestureRecognizer:(WUIGestureRecognizer *)gestureRecognizer;

@end

@interface TUIView (WUIAdditions)

- (BOOL)recognizeEvent:(NSEvent *)event withSelector:(SEL)selector;
@property (nonatomic, retain) NSString * windowIdentifier;

@end