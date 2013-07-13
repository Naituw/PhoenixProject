//
//  WTStatusStreamViewController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-20.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTStatusListViewController.h"
#import "WeiboConcreteStatusesStream.h"

@interface WTStatusStreamViewController : WTStatusListViewController
{
    WeiboStream * statusStream;
}

@property(assign, nonatomic) WeiboStatusID viewedMostRecentID;

- (void)setStatusStream:(WeiboStream *)newStream;
- (WeiboStream *)statusStream;
- (void)saveScrollPosition;

@end
