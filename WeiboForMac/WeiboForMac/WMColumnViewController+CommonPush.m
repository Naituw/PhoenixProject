//
//  WMColumnViewController+CommonPush.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-15.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMColumnViewController+CommonPush.h"
#import "WeiboTrendStatusesStream.h"
#import "WeiboUserFollowersList.h"
#import "WeiboUserFollowingList.h"
#import "WeiboUser.h"
#import "WTAccountUserViewController.h"
#import "WTTrendStatusStreamViewController.h"
#import "WMUserStreamViewController.h"
#import "WMUserFollowersViewController.h"
#import "WMUserFollowingViewController.h"

@implementation WMColumnViewController (CommonPush)

- (BOOL)pushUserViewControllerWithUsername:(NSString *)name account:(WeiboAccount *)account
{
    if (![self.topViewController.title isEqualToString:name])
    {
        WTUserViewController * controller = nil;
        if ([account.user.screenName.lowercaseString isEqualToString:name.lowercaseString])
        {
            controller = [[[WTAccountUserViewController alloc] initWithAccount:account] autorelease];
        }
        else
        {
            controller = [[[WTUserViewController alloc] initWithUsername:name] autorelease];
            [controller setAccount:account];
        }
        [self pushViewController:controller animated:YES];
        return YES;
    }
    return NO;
}
- (BOOL)pushUserViewControllerWithUser:(WeiboUser *)user account:(WeiboAccount *)account
{
    NSString * currentTitle = self.topViewController.title;
    if (![currentTitle isEqualToString:user.screenName])
    {
        if ([self.topViewController isKindOfClass:[WTAccountUserViewController class]])
        {
            
        }
        else if ([user.screenName.lowercaseString isEqualToString:account.user.screenName.lowercaseString])
        {
            return [self pushUserViewControllerWithUsername:user.screenName account:account];
        }
        else
        {
            WTUserViewController * controller = [[WTUserViewController alloc] initWithUser:user];
            [controller setAccount:account];
            [self pushViewController:controller animated:YES];
            [controller release];
            return YES;
        }
    }
    return NO;
}
- (BOOL)pushTrendViewControllerWithTrendName:(NSString *)name account:(WeiboAccount *)account
{
    NSString * currentTitle = self.topViewController.title;
    if (![currentTitle isEqualToString:name]) {
        WeiboTrendStatusesStream * stream = [[WeiboTrendStatusesStream alloc] init];
        [stream setAccount:account];
        [stream setTrendName:name];
        WTTrendStatusStreamViewController * controller = [[WTTrendStatusStreamViewController alloc] init];
        [controller setStatusStream:stream];
        [controller setTitle:name];
        [controller setAccount:account];
        [self pushViewController:controller animated:YES];
        [stream release];
        [controller release];
        return YES;
    }
    return NO;
}

- (BOOL)pushUserFollowerListControllerWithUser:(WeiboUser *)user account:(WeiboAccount *)account
{
    WMUserFollowersViewController * controller = [[WMUserFollowersViewController alloc] init];
    controller.showsToolbar = YES;
    controller.user = user;
    controller.account = account;
    
    [self pushViewController:controller animated:YES];
    
    [controller release];
    
    return YES;
}
- (BOOL)pushUserFollowingListControllerWithUser:(WeiboUser *)user account:(WeiboAccount *)account
{
    WMUserFollowingViewController * controller = [[WMUserFollowingViewController alloc] init];
    controller.showsToolbar = YES;
    controller.user = user;
    controller.account = account;
    
    [self pushViewController:controller animated:YES];
    
    [controller release];
    
    return YES;
}

@end
