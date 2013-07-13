//
//  WMRootViewController.h
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUIViewController.h"
#import "WMSideBarView.h"
#import "WeiboAccount.h"

@class TUIFastIndexPath, WMColumnViewController;
@class WeiboUser;

@interface WMRootViewController : WTUIViewController <WMSidebarViewDelegate, WeiboAccountDelegate>

@property (nonatomic, retain) TUIFastIndexPath * selectedIndexPath;
@property (nonatomic, assign) WeiboUserID currentAccountUserID;

- (WMSideBarView *)sideBar;
- (WMColumnViewController *)columnViewController;

- (IBAction)accountTimeline:(id)sender;
- (IBAction)accountMentions:(id)sender;
- (IBAction)accountComments:(id)sender;
- (IBAction)accountMessages:(id)sender;
- (IBAction)accountProfile:(id)sender;
- (IBAction)accountSearch:(id)sender;
- (NSInteger)selectedSectionInSidebarView;
- (NSInteger)selectedRowInSidebarView;
- (IBAction)nextSelection:(id)sender;
- (IBAction)previousSelection:(id)sender;
- (IBAction)selectNextAccount:(id)sender;
- (IBAction)selectPreviousAccount:(id)sender;

- (WeiboAccount *)selectedAccount;

- (void)setSelectedIndexPathForSideBar:(TUIFastIndexPath *)indexPath;
- (void)accountFollowersForAccount:(WeiboAccount *)account;

- (void)compose:(id)sender;


@end
