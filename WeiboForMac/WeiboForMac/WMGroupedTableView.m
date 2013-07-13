//
//  WMGroupedTableView.m
//  Example
//
//  Created by Wu Tian on 12-4-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMGroupedTableView.h"

@implementation WMGroupedTableView

- (void)scrollWheel:(NSEvent *)theEvent
{
    if (![self recognizeEvent:theEvent withSelector:@selector(scrollWheel:)])
    {
        [super scrollWheel:theEvent];
    }
}

@end
