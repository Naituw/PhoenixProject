//
//  WMGroupedTableViewController.m
//  Example
//
//  Created by Wu Tian on 12-4-30.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMGroupedTableViewController.h"
#import "WMGroupedCell.h"
#import "WMGroupedHeaderView.h"
#import "TUITableView+Additions.h"

@implementation WMGroupedTableViewController 

@synthesize containerView = _containerView;
@synthesize tableView = _tableView, paddingLeftRight = _paddingLeftRight;

- (id)init{
    if (self = [super init]) {
        self.paddingLeftRight = 12.0;
    }
    return self;
}
- (void)dealloc{
    [_containerView release];
    [_tableView release];
    [super dealloc];
}

- (void)loadView{
    WMGroupedTableView * t = [[WMGroupedTableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.tableView = t;
    [t release];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.verticalScrollIndicatorVisibility = TUIScrollViewIndicatorVisibleNever;
    self.tableView.backgroundColor = [TUIColor colorWithWhite:245.0/255.0 alpha:1];
    self.tableView.layout = ^(TUIView * v){
        return v.superview.bounds;
    };
    self.tableView.clipsToBounds = YES;
    WUIView * containerView = [[WUIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.containerView = containerView;
    self.view = self.containerView;
    [containerView addSubview:self.tableView];
    [containerView release];
}

- (Class)cellClass{
    return [WMGroupedCell class];
}

- (NSInteger)numberOfSectionsInTableView:(TUITableView *)tableView{
	return 2;
}
- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section{
    return 5;
}
- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    return 40;
}
- (void)configureCell:(WMGroupedCell *)cell atIndexPath:(TUIFastIndexPath *)indexPath{
    
}
- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    // else is a status cell
    WMGroupedCell * cell = (WMGroupedCell *)[tableView ab_reusableCellOfClass:[self cellClass] identifier:NSStringFromClass([self cellClass]) initializationBlock:nil];
    cell.backgroundColor = self.tableView.backgroundColor;
    cell.opaque = YES;
    cell.paddingLeftRight = self.paddingLeftRight;
    cell.canPerformAction = [self canPerformActionByRowAtIndexPath:indexPath];
    
    NSInteger allRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    cell.allRows = allRows;
    cell.rowIndex = indexPath.row;
    
    NSInteger sectionCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row == 0) {
        cell.isFirstRow = YES;
    }
    if (indexPath.row == sectionCount - 1) {
        cell.isLastRow = YES;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (TUIView *)tableView:(TUITableView *)tableView headerViewForSection:(NSInteger)section{
    CGRect b = tableView.bounds;
    WMGroupedHeaderView * headerView = [[WMGroupedHeaderView alloc] initWithFrame:CGRectMake(0, 0, b.size.width, section?15:self.paddingLeftRight)];
    headerView.alpha = 0.0;
    return [headerView autorelease];
}

- (void)performActionForRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    
}
- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event{
    if ([self canPerformActionByRowAtIndexPath:indexPath]) {
        [self performActionForRowAtIndexPath:indexPath];
    }
}
- (BOOL)canPerformActionByRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    return YES;
}

@end
