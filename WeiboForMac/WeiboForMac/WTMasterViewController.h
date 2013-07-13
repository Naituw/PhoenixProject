//
//  WTMasterViewController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUIViewController.h"

@interface WTMasterViewController : WTUIViewController {
    BOOL viewDidAlreadyAppear;
}

- (NSArray *)visibleViewControllers;

@end
