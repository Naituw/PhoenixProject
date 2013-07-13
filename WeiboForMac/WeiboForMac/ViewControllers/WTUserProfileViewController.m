//
//  WTUserProfileViewController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-1.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUserProfileViewController.h"
#import "WMUserProfileViewCell.h"
#import "WTUserViewController.h"
#import "WeiboUser.h"
#import "TUIStringDrawing.h"
#import "TUIFont.h"
#import "WTEventHandler.h"
#import "WMUserProfileTableHeaderView.h"
#import "WTUIViewController+NavigationController.h"
#import "WMColumnViewController+CommonPush.h"

@implementation WTUserProfileViewController

@synthesize user = _user, userViewController = _userViewController;

- (void)dealloc{
    [_user release];
    [super dealloc];
}

- (Class)cellClass{
    return [WMUserProfileViewCell class];
}

- (void)setUser:(WeiboUser *)user
{
    [user retain];
    [_user release];
    _user = user;
    
    CGFloat currentScaleFactor = TUICurrentContextScaleFactor();
    
    NSString * avatarURLString = (currentScaleFactor > 1) ? user.profileLargeImageUrl : user.profileImageUrl;
    
    WMUserProfileTableHeaderView * headerView = [[WMUserProfileTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65)];
    [headerView setName:user.screenName];
    [headerView setLocation:user.location];
    [headerView setUserID:[NSString stringWithFormat:@"%lld",user.userID]];
    [headerView setAvatarURL:avatarURLString];
    [headerView setUserViewController:self.userViewController];
    [self.tableView setHeaderView:headerView];
    [headerView release];
    
    if (!self.userViewController.isMe)
    {
        TUIButton * actionButton = [TUIButton buttonWithType:TUIButtonTypeCustom];
        [actionButton setImage:[TUIImage imageNamed:@"action.png"] forState:TUIControlStateNormal];
        [actionButton setPopUpMenu:[self.userViewController _actionsMenu]];
        [headerView addSubview:actionButton];
        actionButton.backgroundColor = [TUIColor colorWithWhite:0.97 alpha:1.0];
        actionButton.layer.borderColor = [TUIColor colorWithWhite:0.82 alpha:1.0].CGColor;
        actionButton.layer.borderWidth = 1;
        actionButton.layer.cornerRadius = 4;
        actionButton.layer.shadowColor = [TUIColor whiteColor].CGColor;
        actionButton.layer.shadowOffset = CGSizeMake(0, -1);
        actionButton.layer.shadowOpacity = 1.0;
        actionButton.layer.shadowRadius = 0.0;
        actionButton.size = CGSizeMake(34, 31);
        actionButton.right = headerView.width - 12;
        actionButton.bottom = 5;
        actionButton.autoresizingMask = TUIViewAutoresizingFlexibleTopMargin | TUIViewAutoresizingFlexibleLeftMargin;
    }
}

- (NSString *)titleAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            return NSLocalizedString(@"bio", nil);
        }
        else if (indexPath.row == 1)
        {
            return NSLocalizedString(@"location", nil);
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            return NSLocalizedString(@"following", nil);
        }
        else if (indexPath.row == 1)
        {
            return NSLocalizedString(@"followers", nil);
        }
        else if (indexPath.row == 2)
        {
            return NSLocalizedString(@"weibos", nil);
        }
        else if (indexPath.row == 3)
        {
            return NSLocalizedString(@"favorites", nil);
        }
    }
    return @"";
}
- (NSString *)textAtIndexPath:(TUIFastIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [self.user.description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }else if (indexPath.row == 1) {
            return self.user.location;
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return [NSString stringWithFormat:@"%d",self.user.friendsCount];
        }else if (indexPath.row == 1) {
            return [NSString stringWithFormat:@"%d",self.user.followersCount];
        }else if (indexPath.row == 2) {
            return [NSString stringWithFormat:@"%d",self.user.statusesCount];
        }else if (indexPath.row == 3) {
            return [NSString stringWithFormat:@"%d",self.user.favouritesCount];
        }
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(TUITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if (section == 1) {
        return 4;
    }
    return 0;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    NSString * text = [self textAtIndexPath:indexPath];
    CGFloat textAreaWidth = tableView.bounds.size.width - 2*self.paddingLeftRight - 100;
    NSAttributedString * s = [[NSAttributedString alloc] initWithString:text attributes:[NSDictionary dictionaryWithObject:[NSFont fontWithName:@"HelveticaNeue" size:12] forKey:NSFontAttributeName]];
    CGFloat textHeight = [s ab_sizeConstrainedToWidth:textAreaWidth].height;
    [s release];
    CGFloat minHeight = textHeight + 2 * 14;
    if (minHeight < 40) {
        minHeight = 40;
    }
    return minHeight;
}


- (void)configureCell:(WMGroupedCell *)groupedCell atIndexPath:(TUIFastIndexPath *)indexPath{
    WMUserProfileViewCell * cell = (WMUserProfileViewCell *)groupedCell;
    cell.title = [self titleAtIndexPath:indexPath];
    cell.text = [self textAtIndexPath:indexPath];
}


- (BOOL)canPerformActionByRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2)
        {
            return YES;
        }
        
        if (indexPath.row == 3 && self.userViewController.isMe)
        {
            return YES;
        }
    }
    return NO;
}
- (void)performActionForRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    if (indexPath.row == 0)
    {
        if (self.userViewController.isMe)
        {
            [self.columnViewController pushUserFollowingListControllerWithUser:self.user account:self.userViewController.account];
        }
        else
        {
            [self.userViewController _goTabIndex:2];
        }
    }
    else if (indexPath.row == 1)
    {
        if (self.userViewController.isMe)
        {
            [self.columnViewController pushUserFollowerListControllerWithUser:self.user account:self.userViewController.account];
        }
        else
        {
            [self.userViewController _goTabIndex:1];
        }
    }
    else if (indexPath.row == 2)
    {
        [self.userViewController _firstTab];
    }
    else if (indexPath.row == 3)
    {
        if (self.userViewController.isMe)
        {
            [self.userViewController _goTabIndex:2];
        }
    }
}

@end
