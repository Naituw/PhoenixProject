//
//  WMUserFollowersViewController.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-19.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMUserFollowersViewController.h"
#import "WeiboUserFollowersList.h"

@implementation WMUserFollowersViewController

- (NSString *)title
{
    return NSLocalizedString(@"user_followers_title_key", nil);
}

- (WeiboUserList *)_userList
{
    if (self.user && self.account)
    {
        WeiboUserFollowersList * list = [[WeiboUserFollowersList alloc] init];
        list.account = self.account;
        list.user = self.user;
        
        return [list autorelease];
    }
    return nil;
}

@end
