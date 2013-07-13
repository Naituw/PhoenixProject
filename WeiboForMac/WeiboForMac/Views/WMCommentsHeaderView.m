//
//  WMCommentsHeaderView.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-13.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMCommentsHeaderView.h"
#import "WTHeadImageView.h"
#import "TUITextRenderer.h"
#import "TUIKit.h"

@implementation WMCommentsHeaderView
@synthesize avatar, content;

- (void)dealloc{
    [avatar release];
    [content release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        avatar = [[WTHeadImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        avatar.autoresizingMask = TUIViewAutoresizingFlexibleBottomMargin;
        avatar.clipsToBounds = YES;
        avatar.backgroundColor = [TUIColor clearColor];
        avatar.layer.cornerRadius = 4.0;
        [self addSubview:avatar];
        
        content = [[TUITextRenderer alloc] init];
        self.textRenderers = [NSArray arrayWithObject:content];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGFloat colorA[] = { 255.0/255.0, 254.0/255.0, 235.0/255.0, 1.0 };
    CGFloat colorB[] = { 246.0/255.0, 246.0/255.0, 221.0/255.0, 1.0 };
    CGContextDrawLinearGradientBetweenPoints(ctx, 
                                             CGPointMake(0, b.size.height)  , colorA, 
                                             CGPointMake(0, 0), colorB);
    CGContextSetRGBFillColor(ctx, 200.0/255.0, 200.0/255.0, 200.0/255.0, 0.8); // dark at the bottom
    CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
    
    CGRect contentRect = CGRectMake(70, 10, b.size.width - 70 - 10, b.size.height - 23);
    content.frame = contentRect;
    [content draw];
}

@end
