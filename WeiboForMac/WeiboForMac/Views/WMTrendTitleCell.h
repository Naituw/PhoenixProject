//
//  WMTrendTitleCell.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMGroupedCell.h"

@interface WMTrendTitleCell : WMGroupedCell {
    TUITextRenderer * textRenderer;
}

@property (nonatomic, assign) NSString * text;
@property (nonatomic, assign) BOOL loading;

@end
