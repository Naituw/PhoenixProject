//
//  WMGroupedCell.h
//  Example
//
//  Created by Wu Tian on 12-4-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUITableViewCell.h"

@interface WMGroupedCell : TUITableViewCell

@property (nonatomic, readwrite) CGFloat paddingLeftRight;
@property (nonatomic, readwrite) BOOL isFirstRow;
@property (nonatomic, readwrite) BOOL isLastRow;
@property (nonatomic, readwrite) BOOL canPerformAction;

// a hacky way to implement
@property (nonatomic, readwrite) NSInteger allRows;
@property (nonatomic, readwrite) NSInteger rowIndex;

- (void)drawCellContent:(CGRect)b;

@end
