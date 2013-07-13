//
//  WTControlPanel.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-8.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTControlPanel.h"

@implementation WTControlPanel
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        
        
        replyButton = [[TUIImageView alloc] init];
        retweetButton = [[TUIImageView alloc] init];
        TUIImageView * picButton = [[TUIImageView alloc] init];
        
        replyButton.backgroundColor = [TUIColor clearColor];
        retweetButton.backgroundColor = [TUIColor clearColor];
        picButton.backgroundColor = [TUIColor clearColor];
        
        replyButton.image = [TUIImage imageNamed:@"reply.png" cache:YES];
        retweetButton.image = [TUIImage imageNamed:@"retweet.png" cache:YES];
        picButton.image = [TUIImage imageNamed:@"pic.png" cache:YES];
        
        replyButton.frame = CGRectMake(0, 0, 22, 14);
        retweetButton.frame = CGRectMake(25, 2, 20, 11);
        picButton.frame = CGRectMake(50, 0, 22, 14);
        
        replyButton.alpha = 0.3;
        retweetButton.alpha = 0.3;
        picButton.alpha = 0.3;
        
        
        [self addSubview:replyButton];
        [self addSubview:retweetButton];
        [self addSubview:picButton];
        [picButton release];
        //self.viewDelegate = self;
        //replyButton.viewDelegate = self;
        //retweetButton.viewDelegate = self;
    }
    
    return self;
}

- (void)mouseEntered:(NSEvent *)event onSubview:(TUIView *)subview{
    if (!isMouseInSubView) {
        isMouseInSubView = YES;
    }
    if (!isMouseInside) {
        isMouseInside = YES;
    }
    [TUIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.5;
        subview.alpha = 0.8;
        [delegate mouseEnteredControlPanel:self];
    }];
}

- (void)mouseExited:(NSEvent *)event fromSubview:(TUIView *)subview{
    if (isMouseInSubView) {
        isMouseInSubView = NO;
        [TUIView animateWithDuration:0.2 animations:^{
            subview.alpha = 0.3;
        }];
        
        [TUIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0;
        }];
        if (![self eventInside:event]) {
            
            [delegate mouseExitedControlPanel:self];
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent{
    [super mouseEntered:theEvent];
    if (!isMouseInside) {
        isMouseInside = YES;
    }
    if (!isMouseInSubView) {
        [TUIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0;
        }];
    }
}

- (void)mouseExited:(NSEvent *)theEvent{
    [super mouseExited:theEvent];
    if (![self eventInside:theEvent] && isMouseInside) {
        [TUIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0;
        }];
        [delegate mouseExitedControlPanel:self];
    }
}

- (void)mouseDown:(NSEvent *)event onSubview:(TUIView *)subview{
    subview.alpha = 0.6;
}

- (void)mouseUp:(NSEvent *)event fromSubview:(TUIView *)subview{
    subview.alpha = 0.8;
}

@end
