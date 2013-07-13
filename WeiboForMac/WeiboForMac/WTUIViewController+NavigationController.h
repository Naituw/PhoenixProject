//
//  WTUIViewController+NavigationController.h
//  WeiboForMac
//
//  Created by 吴 天 on 12-10-6.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUIViewController.h"

@class WMColumnViewController;

@interface WTUIViewController (NavigationController)

@property (nonatomic, readonly) WMColumnViewController * columnViewController;

- (void)popBack;
- (BOOL)isRootViewController;

@end
