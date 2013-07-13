//
//  TUITableView+WTAddition.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-5.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"

@interface TUITableView (WTAddition)

- (void) pushNewRowsWithCount:(NSUInteger) count;
- (void) appendNewRows;
- (void) reloadAndKeepInTop;

- (TUIFastIndexPath *)indexPathForVisibleRow;
- (double) relativeOffset;

@end
