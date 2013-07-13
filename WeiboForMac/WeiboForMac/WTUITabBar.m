//
//  WTUITabBar.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUITabBar.h"
#import "WTUITabBarItemView.h"
#import "TUIKit.h"

@implementation WTUITabBar
@synthesize selectedIndex, delegate = _delegate, tabViews;

- (id)initWithNumberOfTabs:(NSUInteger)nTabs{
    if (self = [super initWithFrame:CGRectZero]) {
        NSMutableArray *_tabViews = [NSMutableArray arrayWithCapacity:nTabs];
        for(int i = 0; i < nTabs; ++i) {
			WTUITabBarItemView *t = [[WTUITabBarItemView alloc] initWithFrame:CGRectZero];
			t.tag = i;
			t.layout = ^(TUIView *v) { 
				CGRect b = v.superview.bounds; 
				float width = b.size.width / nTabs;
				float x = i * width;
				return CGRectMake(roundf(x), 0, roundf(width), b.size.height);
			};
            if (i == 0) {
                [t setHighlighted:YES];
            }
			[self addSubview:t];
			[_tabViews addObject:t];
            [t release];
            
		}
		tabViews = [[NSArray alloc] initWithArray:_tabViews];
        self.backgroundColor = [TUIColor clearColor];
        self.moveWindowByDragging = YES;
    }
    return self;
}

- (void)dealloc{
    for (WTUITabBarItemView * t in tabViews)
    {
        [t removeFromSuperview];
    }
    [tabViews release];
    [super dealloc];
}


- (void)drawRect:(CGRect)rect
{
    /*
	// draw tab bar background
	
	CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
	
    
	// gray gradient
	CGFloat colorA[] = { 231.0/255.0, 231.0/255.0, 231.0/255.0, 1.0 };
	CGFloat colorB[] = { 219.0/255.0, 219.0/255.0, 219.0/255.0, 1.0 };
	CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height), colorA, CGPointMake(0, 0), colorB);
     */
}
 

- (void)setSelectedIndex:(NSInteger)newIndex{
    WTUITabBarItemView * oldItem = [tabViews objectAtIndex:selectedIndex];
    WTUITabBarItemView * newItem = [tabViews objectAtIndex:newIndex];
    
    if (!newItem.enabled)
    {
        return;
    }
    selectedIndex = newIndex;
    [oldItem setHighlighted:NO];
    [newItem setHighlighted:YES];
}

- (void)mouseUpInTabAtIndex:(NSUInteger)index{
    if (selectedIndex == index) {
        return;
    }
    WTUITabBarItemView * newItem = [tabViews objectAtIndex:index];
    if (!newItem.enabled)
    {
        return;
    }
    [self setSelectedIndex:index];
    [_delegate tabBar:self didSelectTab:index];
}

@end
