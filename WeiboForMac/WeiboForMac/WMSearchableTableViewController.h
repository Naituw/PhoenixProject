//
//  WMSearchableTableViewController.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WTUIViewController.h"
#import "WTPullToRefreshTableView.h"
#import "WMToolbarView.h"
#import "TUITableView+WTAddition.h"
#import "WTUIViewController+NavigationController.h"

@interface WMSearchableTableViewController : WTUIViewController
<TUITableViewDelegate , TUITableViewDataSource , WTPullDownViewDelegate,
TUITextFieldDelegate>
{
    WTPullToRefreshTableView * _tableView;
    TUIView * _findView;
    WMToolbarView * toolbar;
    TUITextField * textField;
    struct {
        unsigned int isLoadingNewer:1;
        unsigned int isLoadingOlder:1;
        unsigned int isReloading:1;
        unsigned int firstLoadWasDone:1;
        unsigned int findMode:1;
        unsigned int findViewVisible:1;
    } _flags;
}

- (Class)tableViewClass;

@property (assign, nonatomic) BOOL isReloading;
@property (readonly, nonatomic) WTPullToRefreshTableView * tableView;
@property (assign, nonatomic) BOOL showsToolbar;

- (void)setupToolBar;

- (BOOL)canPullToRefresh;

- (CGFloat)toolbarViewHeight;
- (TUITableViewStyle)tableViewStyle;

- (void)filterItemsWithQuery:(NSString *)query;
- (void)didExitFindMode;
- (void)didHitReturnButtonInFindMode;

@end
