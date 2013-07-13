//
//  WTDragableTableView.h
//  WTTabbarController
//
//  Created by Wu Tian on 11-8-21.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"

@interface WTDragableTableView : TUITableView {
    NSPoint initialLocation;
}

- (NSUInteger) selectedRow;
- (TUIFastIndexPath *)selectedIndexPath;
@end
