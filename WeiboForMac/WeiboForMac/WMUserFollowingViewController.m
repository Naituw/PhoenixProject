//
//  WMUserFollowingViewController.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-19.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMUserFollowingViewController.h"
#import "WeiboUserFollowingList.h"

@implementation WMUserFollowingViewController

- (NSString *)title
{
    return NSLocalizedString(@"user_following_title_key", nil);
}

- (WeiboUserList *)_userList
{
    if (self.user && self.account)
    {
        WeiboUserFollowingList * list = [[WeiboUserFollowingList alloc] init];
        list.account = self.account;
        list.user = self.user;
        
        return [list autorelease];
    }
    return nil;
}

@end
