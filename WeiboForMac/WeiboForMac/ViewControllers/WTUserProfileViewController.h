//
//  WTUserProfileViewController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-1.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMGroupedTableViewController.h"

@class WeiboUser, WTUserViewController;

@interface WTUserProfileViewController : WMGroupedTableViewController

@property (nonatomic, assign) WTUserViewController * userViewController;
@property (nonatomic, retain) WeiboUser * user;

@end
