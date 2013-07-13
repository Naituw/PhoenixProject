//
//  WTHUDActivityIndicatorView.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-9-1.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTHUDActivityIndicatorView.h"

@implementation WTHUDActivityIndicatorView

- (id)initWithActivityIndicatorStyle:(TUIActivityIndicatorViewStyle)style
{
	if((self = [super initWithFrame:CGRectMake(0, 0, 30, 30)]))
	{
		_activityIndicatorViewStyle = style;
		
		spinner = [[TUIView alloc] initWithFrame:self.bounds];
		spinner.backgroundColor = [TUIColor whiteColor];
		spinner.alpha = 1.0;
		spinner.layer.cornerRadius = 15.0;
		[self addSubview:spinner];
		[spinner release];
	}
	return self;
}

- (void)startAnimating
{
	if(!_animating) {
		CGFloat duration = 1.0;
		
		{
			CABasicAnimation *animation = [CABasicAnimation animation];
			animation.repeatCount = INT_MAX;
			animation.duration = duration;
			animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 0.1)];
			animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
			[spinner.layer addAnimation:animation forKey:@"transform"];
		}
		
		{
			CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
			animation.values = [NSArray arrayWithObjects:
								[NSNumber numberWithFloat:0.0],
								[NSNumber numberWithFloat:1.0],
								[NSNumber numberWithFloat:0.0],
								nil];
			animation.repeatCount = INT_MAX;
			animation.duration = duration;
			[spinner.layer addAnimation:animation forKey:@"opacity"];
		}
		
		_animating = YES;
	}
}


@end
