//
//  WTPullToRefreshTableView.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "TUITableView.h"
#import "WTPullDownView.h"

@interface WTPullToRefreshTableView : TUITableView
{
    WTPullDownView * pullView;
}

- (void)setPullDownViewDelegate:(id<WTPullDownViewDelegate>)delegate;
- (void)finishedLoadingNewer;

@end
