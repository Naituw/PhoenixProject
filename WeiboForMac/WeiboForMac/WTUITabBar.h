//
//  WTUITabBar.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"

@protocol WTUITabBarDelegate, WTUITabBarItem;

@interface WTUITabBar : WUIView {
    NSArray * tabViews;
    NSInteger selectedIndex;
    id <WTUITabBarDelegate> _delegate;
}

@property (assign, nonatomic) NSInteger selectedIndex;
@property (nonatomic, readonly) NSArray *tabViews;
@property (assign, nonatomic) id <WTUITabBarDelegate> delegate;

- (id)initWithNumberOfTabs:(NSUInteger)nTabs;
- (void)mouseUpInTabAtIndex:(NSUInteger)index;
@end

@protocol WTUITabBarDelegate <NSObject>
- (void)tabBar:(WTUITabBar *)tabBar didSelectTab:(NSInteger)index;
- (NSString *)tabBar:(WTUITabBar *)tabBar imageNameForTabAtIndex:(NSInteger)index;
@end
