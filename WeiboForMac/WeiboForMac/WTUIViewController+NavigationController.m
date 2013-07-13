//
//  WTUIViewController+NavigationController.m
//  WeiboForMac
//
//  Created by 吴 天 on 12-10-6.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUIViewController+NavigationController.h"
#import "WMColumnViewController.h"

@interface WTUIViewController ()
- (id)_nearestParentViewControllerThatIsKindOf:(Class)c;
@end

@implementation WTUIViewController (NavigationController)

- (WMColumnViewController *)columnViewController
{
    return [self _nearestParentViewControllerThatIsKindOf:[WMColumnViewController class]];
}

- (void)popBack
{
    WMColumnViewController * columnViewController = [self columnViewController];
    [columnViewController popViewControllerAnimated:YES];
}

- (BOOL)isRootViewController
{
    return [[self columnViewController] isRoot:self];
}

@end
