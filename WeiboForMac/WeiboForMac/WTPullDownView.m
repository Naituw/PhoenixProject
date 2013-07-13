//
//  WTPullDownView.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-1.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTPullDownView.h"

@interface WTPullDownView (Private)
- (void)setState:(PullState)state_;
@end

@implementation WTPullDownView

@synthesize scrollView, delegate;

- (id)initWithScrollView:(TUIScrollView *)scroll
{
    CGRect frame = [self frameWithScrollView:scroll];
    if ((self = [super initWithFrame:frame])) {
        scrollView = scroll;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
        //arrow image init
        arrowImage = [[CALayer alloc] init];
        arrowImage.frame = CGRectMake(frame.size.width/2-11, 5+6, 23, 53);
        arrowImage.autoresizingMask = TUIViewAutoresizingFlexibleLeftMargin | TUIViewAutoresizingFlexibleRightMargin;
        arrowImage.contentsGravity = kCAGravityResizeAspect;
        arrowImage.contents = (id) [TUIImage imageNamed:@"pull-to-refresh-arrow.png" cache:YES].CGImage;
        [self.layer addSublayer:arrowImage];
        
        //refresh image init
        refreshImage = [[CALayer alloc] init];
        refreshImage.frame = CGRectMake(frame.size.width/2-24, 5+11, 48, 38);
        refreshImage.autoresizingMask = TUIViewAutoresizingFlexibleLeftMargin | TUIViewAutoresizingFlexibleRightMargin;
        refreshImage.contentsGravity = kCAGravityResizeAspect;
        refreshImage.contents = (id) [TUIImage imageNamed:@"release-to-refresh.png" cache:YES].CGImage;
        refreshImage.opacity = 0.0;
        [self.layer addSublayer:refreshImage];
        
        // activityView
        activityView = [[TUIActivityIndicatorView alloc] initWithActivityIndicatorStyle:TUIActivityIndicatorViewStyleGray];
        activityView.autoresizingMask = TUIViewAutoresizingFlexibleWidth;
    
		[self addSubview:activityView];
		[self setState:PullStateNormal];

    }
    return self;
}

- (CGRect)frameWithScrollView:(TUIScrollView *)aScrollView
{
    return CGRectMake(0.0f, aScrollView.contentSize.height, aScrollView.bounds.size.width, aScrollView.bounds.size.height);
}

- (void)updateFrame
{
    self.frame = [self frameWithScrollView:self.scrollView];
}

- (void)drawRect:(CGRect)rect{
	CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, .941, .941, .941, 1);
    CGContextFillRect(ctx, b);
    CGContextSetRGBFillColor(ctx, .768, .768, .768, 1); // bottom line
    CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
}

- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
    if (shouldShow) {
        [activityView startAnimating];
        activityView.frame = CGRectMake([self frame].size.width/2-10, 5+10+11, 20.0f, 20.0f);
        activityView.alpha = 1.0;
    }
    else {
        activityView.alpha = 0.0;
        [activityView stopAnimating];
    }
    
    [TUIView beginAnimations:nil context:nil];
    [TUIView setAnimationDuration:(animated ? 0.1f : 0.0)];
    arrowImage.opacity = (shouldShow ? 0.0 : 1.0);
    refreshImage.opacity = (shouldShow ? 0.0 : 1.0);
    [TUIView commitAnimations];
}

- (void)setImageFlipped:(BOOL)flipped finishing:(BOOL)finishing {
    [TUIView beginAnimations:nil context:NULL];
    [TUIView setAnimationDuration:0.1f];
    arrowImage.transform = (flipped ? CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) : CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f));
    arrowImage.opacity = (flipped ? 0.0:1.0);
    
    refreshImage.opacity = (flipped ? 1.0:0.0);
    refreshImage.transform = (flipped ? CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) : CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f));
    [TUIView commitAnimations];
}

- (void)setState:(PullState)state_ {
    state = state_;
	switch (state) {
		case PullStateReady:
			[self showActivity:NO animated:NO];
            [self setImageFlipped:YES finishing:NO];
            scrollView.contentInset = TUIEdgeInsetsZero;
			break;
            
		case PullStateNormal:
			[self showActivity:NO animated:NO];
            [self setImageFlipped:NO finishing:NO];
            scrollView.contentInset = TUIEdgeInsetsZero;
			break;
            
		case PullStateLoading:
			[self showActivity:YES animated:YES];
            [self setImageFlipped:NO finishing:YES];
            arrowImage.opacity = 0.0;
            scrollView.contentInset = TUIEdgeInsetsMake(70.0f, 0.0f, 0.0f, 0.0f);
			break;
            
		default:
			break;
	}
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat offset = scrollView.contentSize.height-scrollView.bounds.size.height+scrollView.contentOffset.y;
        if (scrollView.isDragging) {
            if (state == PullStateReady) {
                if (offset > -80.0f && offset < 0.0f){
                    [self setState:PullStateNormal];
                }
            } else if (state == PullStateNormal) {
                if (offset < -80.0f){
                    [self setState:PullStateReady];
                }
            } else if (state == PullStateLoading) {
                if (offset >= 0){
                    scrollView.contentInset = TUIEdgeInsetsZero;
                }
                else
                    scrollView.contentInset = TUIEdgeInsetsMake(MIN(-offset, 70.0f), 0, 0, 0);
            }
        } else {
            if (state == PullStateReady) {
                [TUIView beginAnimations:nil context:NULL];
                [TUIView setAnimationDuration:0.2f];
                [self setState:PullStateLoading];
                [TUIView commitAnimations];
                
                if ([delegate respondsToSelector:@selector(pullToRefreshViewShouldRefresh:)])
                    [delegate pullToRefreshViewShouldRefresh:self];
            }
        }
    }
}

- (void)finishedLoading {
    if (state == PullStateLoading) {
        [TUIView beginAnimations:nil context:NULL];
        [TUIView setAnimationDuration:0.3f];
        [self setState:PullStateNormal];
        [TUIView commitAnimations];
    }
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {

    [arrowImage removeFromSuperlayer];
    [arrowImage release];
    [refreshImage removeFromSuperlayer];
    [refreshImage release];
    [activityView release];
    
    [super dealloc];
}


@end
