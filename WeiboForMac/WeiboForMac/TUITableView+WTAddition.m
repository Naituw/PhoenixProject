//
//  TUITableView+WTAddition.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-5.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUITableView+WTAddition.h"

@implementation TUITableView (WTAddition)


- (TUIFastIndexPath *)indexPathForVisibleRow{
    TUIFastIndexPath *firstIndexPath = nil;
	for(TUIFastIndexPath *indexPath in _visibleItems) {
		if(firstIndexPath == nil || [indexPath compare:firstIndexPath] == NSOrderedAscending) {
			firstIndexPath = indexPath;
		}
	}
	return firstIndexPath;
}

- (double) relativeOffset{
    TUIFastIndexPath * index = [self indexPathForVisibleRow];
    CGRect rect = [self rectForRowAtIndexPath:index];
    CGFloat offset = rect.size.height + (self.contentOffset.y - self.bounds.size.height + rect.origin.y);
    return offset;
}

- (void) pushNewRowsWithCount:(NSUInteger) count{
    
    TUIFastIndexPath * index = [self indexPathForVisibleRow];
    TUIFastIndexPath * selected = nil;
    if (_selectedIndexPath) {
        selected = [TUIFastIndexPath indexPathForRow:_selectedIndexPath.row+count inSection:0];
        
        if (count > 0) {
            // Selected row must changed
            [self deselectRowAtIndexPath:_selectedIndexPath animated:NO];
        }
    }
    
    CGRect rect = [self rectForRowAtIndexPath:index];
    
    // calculate relative offset
    CGFloat offset = rect.size.height + (self.contentOffset.y - self.bounds.size.height + rect.origin.y);
    // keep the top row position.
    if (index.row == 0 && index.section == 1) {
        // if first load , keep in top.
        index = [TUIFastIndexPath indexPathForRow:0 inSection:0];
    }
    else{
        index = [TUIFastIndexPath indexPathForRow:index.row+count inSection:index.section];
    }
    // Set content inset to zero , otherwise may occure inset calculate problem after reload.
    [self setContentInset:TUIEdgeInsetsZero];
    [self reloadDataMaintainingVisibleIndexPath:index relativeOffset:-offset];
    // if there are selected row before, reselect it.
    if (selected) {
        [self selectRowAtIndexPath:selected animated:NO scrollPosition:TUITableViewScrollPositionNone];
    }
}

- (void) appendNewRows{
    TUIFastIndexPath * selected = nil;
    NSUInteger beforeCount = [self numberOfRowsInSection:0];
    if (_selectedIndexPath) {
        if (_selectedIndexPath.section == 1) {
            selected = [TUIFastIndexPath indexPathForRow:beforeCount-1 inSection:0];
        }else {
            selected = [TUIFastIndexPath indexPathForRow:_selectedIndexPath.row inSection:0];
        }
    }
    
    TUIFastIndexPath * index = [self indexPathForVisibleRow];
    CGRect rect = [self rectForRowAtIndexPath:index];
    CGFloat offset = rect.size.height + (self.contentOffset.y - self.bounds.size.height + rect.origin.y);
    // keep the top row position.
    [self reloadDataMaintainingVisibleIndexPath:[TUIFastIndexPath indexPathForRow:index.row inSection:0] relativeOffset:-offset];
    
    if (selected) {
        if (([self numberOfRowsInSection:0] > selected.row + 1) &&
            (selected.row == beforeCount - 1)) {
            selected = [TUIFastIndexPath indexPathForRow:selected.row+1 inSection:selected.section];
        }
        [self selectRowAtIndexPath:selected animated:NO scrollPosition:TUITableViewScrollPositionNone];
    }
}

- (void) reloadAndKeepInTop{
    TUIFastIndexPath * index = [TUIFastIndexPath indexPathForRow:0 inSection:0];
    [self reloadDataMaintainingVisibleIndexPath:index relativeOffset:0];
}

@end
