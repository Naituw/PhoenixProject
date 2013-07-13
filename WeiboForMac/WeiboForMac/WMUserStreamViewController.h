//
//  WMUserStreamViewController.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-18.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMUserListViewController.h"
#import "WeiboUserList.h"
#import "WeiboUser.h"

@interface WMUserStreamViewController : WMUserListViewController

@property (nonatomic, retain) WeiboUser * user;

- (void)loadNewer:(id)sender;
- (void)loadOlder:(id)sender;

@end
