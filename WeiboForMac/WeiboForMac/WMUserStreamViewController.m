//
//  WMUserStreamViewController.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-18.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMUserStreamViewController.h"
#import "WeiboUserUserList.h"
#import "WMUserCell.h"
#import "WUITableViewEndCell.h"
#import "WMColumnViewController+CommonPush.h"

@interface WMUserStreamViewController ()

@property (nonatomic, retain) WeiboUserList * userList;

@end

@implementation WMUserStreamViewController

- (void)dealloc
{
    [self unregisterNotifications];
    [_user release], _user = nil;
    [_userList release], _userList = nil;
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    WMUserStreamViewController * result = [super copyWithZone:zone];
    
    result.user = self.user;
    result.account = self.account;
    result.userList = self.userList;
    
    return result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForNotifications];
    
    if (toolbar && self.user.profileImageUrl)
    {
        NSURL * url = [NSURL URLWithString:self.user.profileImageUrl];
        [toolbar.imageView setImageWithURL:url];
    }
}

- (WeiboUserList *)_userList
{
    return nil;
}

- (WeiboUserList *)userList
{
    if (!_userList)
    {
        _userList = [[self _userList] retain];
    }
    return _userList;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.users.count)
    {
        [self.userList loadNewer];
    }
}

- (void)registerForNotifications
{
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(userListDidAddUserNotification:) name:WeiboUserUserListDidAddUsersNotification object:nil];
    [nc addObserver:self selector:@selector(userListDidReciveRequestErrorNotification:) name:WeiboUserUserListDidReceiveRequestErrorNotification object:nil];
}
- (void)unregisterNotifications
{
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:WeiboUserUserListDidAddUsersNotification object:nil];
    [nc removeObserver:self name:WeiboUserUserListDidReceiveRequestErrorNotification object:nil];
}

- (BOOL)isEnded
{
    return self.userList.isEnded;
}

- (NSArray *)users
{
    return self.userList.users;
}

- (WeiboUserUserList *)userUserList
{
    if ([self.userList isKindOfClass:[WeiboUserUserList class]])
    {
        return (WeiboUserUserList *)self.userList;
    }
    return nil;
}

- (void)loadNewer:(id)sender
{
    [self.userList loadNewer];
}
- (void)loadOlder:(id)sender
{
    [self.userList loadOlder];
}

- (void)userListDidAddUserNotification:(NSNotification *)notification
{
    if (notification.object != self.userList)
    {
        return;
    }
    
    NSArray * array = notification.userInfo[WeiboUserUserListDidAddUserNotificationUsersKey];
    BOOL prepend = [notification.userInfo[WeiboUserUserListDidAddUserNotificationPrependKey] boolValue];
    
    
    if (prepend)
    {
        if (!_flags.findMode && array.count)
        {
            [self.tableView pushNewRowsWithCount:array.count];
        }
        [self.tableView performSelector:@selector(finishedLoadingNewer) withObject:nil afterDelay:0.1];
    }
    else
    {
        [self.tableView appendNewRows];
    }
}

- (void)userListDidReciveRequestErrorNotification:(NSNotification *)notification
{
    if (notification.object != self.userList)
    {
        return;
    }
    
    [self.tableView appendNewRows];
}

- (void)pullToRefreshViewShouldRefresh:(WTPullDownView *)view
{
    [self loadNewer:self];
}

- (WeiboRequestError *)loadingError
{
    WeiboRequestError * loadOlderError = [[self userList] loadOlderError];
    if (loadOlderError)
    {
        return loadOlderError;
    }
    else if (!self.userList.users.count)
    {
        return [[self userList] loadNewerError];
    }
    return nil;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return [self loadingError] ? 80 : 40;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    TUITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1 && [cell isKindOfClass:[WUITableViewEndCell class]])
    {
        WUITableViewEndCell * endCell = (WUITableViewEndCell *)cell;
        
        endCell.isEnded = self.userList.isEnded;
        endCell.loading = !endCell.isEnded;
        endCell.error = [self loadingError];
    }
    return cell;
}

- (void)tableView:(TUITableView *)aTableView willDisplayCell:(TUITableViewCell *)cell forRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (!self.userList.isEnded && self.users.count)
        {
            [self.userList loadOlder];
        }
    }
}

- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event
{
    if (event.clickCount == 2)
    {
        if (indexPath.section == 1 && self.userList.isEnded)
        {
            [self.userList retryLoadOlder];
            [self.tableView reloadData];
        }
    }
    else
    {
        [super tableView:tableView didClickRowAtIndexPath:indexPath withEvent:event];
    }
}


@end
