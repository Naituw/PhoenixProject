//
//  WMUserListViewController.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMSearchableTableViewController.h"
#import "WMUserTableView.h"
#import "WeiboAccount.h"

@class WMUserCell, WMUserListFollowButton;

@interface WMUserListViewController : WMSearchableTableViewController

@property (nonatomic, retain) WeiboAccount * account;

- (NSArray *)users;

- (BOOL)isEnded;

@end
