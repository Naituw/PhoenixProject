//
//  WTMasterViewController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTMasterViewController.h"

@implementation WTMasterViewController

- (NSArray *)visibleViewControllers{
    return nil;
}
- (void)viewDidLoad{
    
}
- (void)viewDidUnload{
    
}
- (void)viewWillAppear:(BOOL)animated{
    for (WTUIViewController * v in [self visibleViewControllers]) {
        [v viewWillAppear:animated];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    viewDidAlreadyAppear = YES;
    for (WTUIViewController * v in [self visibleViewControllers]) {
        [v viewDidAppear:animated];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    for (WTUIViewController * controller in [self visibleViewControllers]) {
        [controller viewWillDisappear:animated];
    }
}
- (void)viewDidDisappear:(BOOL)arg1{
    
}

- (void)relayout
{
    for (WTUIViewController * controller in [self visibleViewControllers])
    {
        [controller relayout];
    }
}

@end
