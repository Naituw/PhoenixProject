//
//  WMGroupedTableViewController.h
//  Example
//
//  Created by Wu Tian on 12-4-30.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUIViewController.h"
#import "WMGroupedTableView.h"

@class WMGroupedCell;

@interface WMGroupedTableViewController : WTUIViewController
<TUITableViewDelegate, TUITableViewDataSource> {
    
}

@property (nonatomic, retain) TUIView * containerView;
@property (nonatomic, retain) WMGroupedTableView * tableView;
@property (nonatomic, readwrite) CGFloat paddingLeftRight;

- (Class)cellClass;
- (BOOL)canPerformActionByRowAtIndexPath:(TUIFastIndexPath *)indexPath;
- (void)performActionForRowAtIndexPath:(TUIFastIndexPath *)indexPath;
- (void)configureCell:(WMGroupedCell *)cell atIndexPath:(TUIFastIndexPath *)indexPath;

@end
