//
//  WMUserListViewController.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMUserListViewController.h"
#import "WMFollowUserCell.h"
#import "WUITableViewEndCell.h"
#import "WMColumnViewController+CommonPush.h"
#import "WMUserListFollowButton.h"
#import "WeiboRequestError.h"
#import "WTCallback.h"
#import "WeiboAPI+UserMethods.h"
#import "WMConstants.h"

@interface WMUserListViewController ()

@property (nonatomic, retain) NSMutableArray * filteredUsers;

@end

@implementation WMUserListViewController

- (void)dealloc
{
    [_account release], _account = nil;
    [_filteredUsers release], _filteredUsers = nil;
    [super dealloc];
}

- (NSArray *)users
{
    return nil;
}

- (NSArray *)userDatasource
{
    if (_flags.findMode)
    {
        return _filteredUsers;
    }
    return self.users;
}

- (BOOL)isEnded
{
    return NO;
}

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 1; // Loading Cell
    }
    
    return [self userDatasource].count;
}

- (NSInteger)numberOfSectionsInTableView:(TUITableView *)tableView
{
    if (_flags.findMode)
    {
        return 1;
    }
    return 2;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return 40.0;
    }
    return 70.0;
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        WUITableViewEndCell *cell = reusableTableCellOfClass(tableView, WUITableViewEndCell);
        return cell;
    }
    
    WMFollowUserCell * cell = reusableTableCellOfClass(tableView, WMFollowUserCell);
    cell.backgroundColor = [TUIColor blueColor];
    cell.user = [self userDatasource][indexPath.row];
    
    cell.isMe = [cell.user isEqual:self.account.user];
    
    return cell;
}

- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event
{
    if (indexPath.section == 0 && self.account)
    {
        WeiboUser * user = [self userDatasource][indexPath.row];
        
        [self.columnViewController pushUserViewControllerWithUser:user account:self.account];
    }
}

- (void)userCell:(WMUserCell *)cell didPressFollowButton:(WMUserListFollowButton *)button
{
    WeiboUser * user = cell.user;
    
    if (user.following)
    {
        [self unfollowUser:user];
    }
    else
    {
        [self followUser:user];
    }
    
    cell.user = user;
}

- (WMUserCell *)cellForUser:(WeiboUser *)user
{
    for (WMUserCell * cell in self.tableView.visibleCells)
    {
        if ([cell isKindOfClass:[WMUserCell class]])
        {
            if ([cell.user isEqual:user])
            {
                return cell;
            }
        }
    }
    return nil;
}

- (void)updateCellForUser:(WeiboUser *)user
{
    WMUserCell * cell = [self cellForUser:user];
    
    if (cell)
    {
        cell.user = user;
    }
}

- (void)followUser:(WeiboUser *)user
{
    user.following = YES;
    
    WTCallback * callback = WTCallbackMake(self, @selector(followActionResponse:info:), user);
    WeiboAPI * api = [self.account authenticatedRequest:callback];
    [api followUserID:user.userID];
}

- (void)unfollowUser:(WeiboUser *)user
{
    user.following = NO;
    
    WMUserCell * cell = [self cellForUser:user];
    
    NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Unfollow?", nil) defaultButton:NSLocalizedString(@"Unfollow", nil)
                                    alternateButton:NSLocalizedString(@"No", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Are you sure you want to unfollow %@?", nil),user.screenName];
    
    CGRect cellRect = [cell frameInNSView];
    cellRect.origin.y += cellRect.size.height;
    cellRect.size.height = 0;

    if (cell)
    {
        NSValue * rect = [NSValue valueWithRect:cellRect];
        
        [alert.window setObject:rect forAssociatedKey:kWindowSheetPositionRect retained:YES];
    }
    
    [alert beginSheetModalForWindow:self.view.nsWindow modalDelegate:self didEndSelector:@selector(unfollowAlertDidEnd:returnCode:contextInfo:) contextInfo:user];
}

- (void)unfollowAlertDidEnd:(NSAlert *)alert returnCode:(long long)returnCode contextInfo:(void *)contextInfo
{
    WeiboUser * user = contextInfo;
    if (returnCode == NSAlertDefaultReturn)
    {
        WTCallback * callback = WTCallbackMake(self, @selector(followActionResponse:info:), user);
        WeiboAPI * api = [self.account authenticatedRequest:callback];
        [api unfollowUserID:user.userID];
    }
    else
    {
        user.following = !user.following;
        [self updateCellForUser:user];
    }
}


- (void)followActionResponse:(id)response info:(id)info
{
    WeiboUser * user = info;
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        user.following = !user.following;
        [self updateCellForUser:user];
    }
}

- (void)filterItemsWithQuery:(NSString *)query
{
    NSMutableArray * filtered = [NSMutableArray array];
    
    for (WeiboUser * user in self.users)
    {
        if ([user.screenName rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [user.description rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [filtered addObject:user];
        }
    }
    
    self.filteredUsers = filtered;
}


@end
