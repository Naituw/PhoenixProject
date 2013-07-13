//
//  WTRepliesStreamViewController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-12.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTStatusStreamViewController.h"

@class WeiboRepliesStream;

@interface WTRepliesStreamViewController : WTStatusStreamViewController

@property (readonly, nonatomic) WeiboRepliesStream * repliesStream;

@end
