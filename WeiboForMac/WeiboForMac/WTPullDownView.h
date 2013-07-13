//
//  WTPullDownView.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-1.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"

typedef enum {
    PullStateNormal = 0,
	PullStateReady,
	PullStateLoading
} PullState;

@protocol WTPullDownViewDelegate;

@interface WTPullDownView : WUIView{
    id<WTPullDownViewDelegate> delegate;
    TUIScrollView *scrollView;
	PullState state;
    
    CALayer * arrowImage;
    CALayer * refreshImage;
    TUIActivityIndicatorView *activityView;
}

@property (nonatomic, readonly) TUIScrollView *scrollView;
@property (nonatomic, assign) id<WTPullDownViewDelegate> delegate;

- (void)updateFrame;

- (void)finishedLoading;
- (id)initWithScrollView:(TUIScrollView *) scroll;

@end

@protocol WTPullDownViewDelegate <NSObject>
@optional
- (void)pullToRefreshViewShouldRefresh:(WTPullDownView *)view;
@end

