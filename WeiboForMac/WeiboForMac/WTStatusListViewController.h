//
//  WTStatusListViewController.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-23.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WMSearchableTableViewController.h"
#import "WTStatusTableView.h"
#import "WeiboConstants.h"
#import "WeiboBaseStatus.h"

@class WTStatusCell, WeiboBaseStatus, WMToolbarView, WeiboUser, WeiboAccount;

@interface WTStatusListViewController : WMSearchableTableViewController
{
    NSArray * statuses;
    struct {
        double relativeOffset;
        WeiboStatusID statusID;
        NSUInteger possibleRow;
    } saveScrollPosition;
}

@property (nonatomic, retain) NSArray * filteredStatus;
@property (nonatomic, retain) WeiboAccount * account;

- (WeiboStatusID)newestStatusID;

- (void)loadNewer:(id)sender;
- (void)loadOlder:(id)sender;
- (void)scrollToTop:(id)sender;

- (void)setUpStatusCell:(WTStatusCell *)cell withBaseStatus:(WeiboBaseStatus*)status;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (CGFloat)tableView:(TUITableView *)tableView heightForBaseStatus:(WeiboBaseStatus *)status;
- (CGFloat)tableView:(TUITableView *)tableView heightForSectionAtIndex:(NSUInteger)index;

- (NSMenuItem *)menuItemWithTitle:(NSString *)title action:(SEL)action;
- (void)addMenuItemsForStatus:(WeiboBaseStatus *)status toMenu:(NSMenu *)menu;

- (void)textRenderer:(TUITextRenderer *)r didClickActiveRange:(ABFlavoredRange *)range;
- (BOOL)statusCell:(WTStatusCell *)cell didPressAvatarWithUser:(WeiboUser *)user;

- (IBAction)deleteWeibo:(id)sender;
- (IBAction)viewPhoto:(id)sender;
- (IBAction)viewReplies:(id)sender;
- (IBAction)reply:(id)sender;
- (IBAction)repost:(id)sender;
- (IBAction)viewUserDetails:(id)sender;
- (IBAction)viewOnWebPage:(id)sender;
- (IBAction)viewActiveRange:(id)sender;

- (BOOL)validateMenuItemWithAction:(SEL)action cell:(WTStatusCell *)cell;

@end
