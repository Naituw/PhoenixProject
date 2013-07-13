//
//  WTAccountUserViewController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTAccountUserViewController.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"
#import "WeiboStream.h"
#import "WeiboTimelineStream.h"
#import "WeiboMentionsStream.h"
#import "WeiboFavoritesStream.h"
#import "WeiboUserTimelineStream.h"
#import "WTStatusStreamViewController.h"
#import "WTUserProfileViewController.h"

@implementation WTAccountUserViewController

- (id)initWithAccount:(WeiboAccount *)aAccount
{
    if (self = [super initWithUser:[aAccount user]])
    {
        self.account = aAccount;
        self.title = @"Profile";
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    WTAccountUserViewController * result = [super copyWithZone:zone];

    result = [result initWithAccount:self.account];
    
    return result;
}

- (NSArray *)makeSubViewControllers
{
    WTStatusStreamViewController * timeline = [[[WTStatusStreamViewController alloc] init] autorelease];
    timeline.title = NSLocalizedString(@"timeline", nil);
    timeline.statusStream = [self.account timelineStreamForUser:self.user];
    timeline.account = self.account;
    
    WTStatusStreamViewController * mentions = [[[WTStatusStreamViewController alloc] init] autorelease];
    mentions.title = NSLocalizedString(@"mentions", nil);
    mentions.statusStream = [self.account mentionsStream];
    mentions.account = self.account;
    
    WTStatusStreamViewController * favorites = [[[WTStatusStreamViewController alloc] init] autorelease];
    favorites.title = NSLocalizedString(@"favorites", nil);
    favorites.statusStream = [account favoritesStream];
    favorites.account = self.account;
    
    WTUserProfileViewController * profile = [[[WTUserProfileViewController alloc] init] autorelease];
    profile.title = NSLocalizedString(@"profile", nil);
    profile.userViewController = self;
    profile.user = self.user;
    
    return @[timeline, mentions, favorites, profile];
}

- (NSString *)tabBar:(WTUITabBar *)tabBar imageNameForTabAtIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return @"clock.png";
        case 1:
            return @"at.png";
        case 2:
            return @"startab.png";
        case 3:
            return @"person.png";
        default:
            return nil;
    }
}

@end
