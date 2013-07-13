//
//  WMColumnViewController.h
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUIViewController.h"

@interface WMColumnViewController : WTUIViewController

@property(readonly, nonatomic) WTUIViewController * topViewController;

- (NSArray *)viewControllers;
- (BOOL)isRoot:(WTUIViewController *)controller;

- (void)setRootViewController:(WTUIViewController *)viewController animated:(BOOL)animated;
- (void)pushViewController:(WTUIViewController *)newController
       afterViewController:(WTUIViewController *)afterController animated:(BOOL)animate;
- (void)pushViewController:(WTUIViewController *)viewController animated:(BOOL)animated;
- (BOOL)popViewControllerAnimated:(BOOL)animated;
- (void)popToViewController:(WTUIViewController *)viewController animated:(BOOL)animated;
- (BOOL)popToRootViewControllerAnimated:(BOOL)animated;

- (IBAction)openCurrentViewControllerInSatelliteWindow:(id)sender;

@end
