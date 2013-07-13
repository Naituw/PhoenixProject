//
//  WTUINavigationController.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUIViewController.h"

@class WTUINavigationBar, WTUIToolbar, WTUIViewController;

@protocol WTUINavigationControllerDelegate <NSObject>
@optional
- (void)navigationController:(WTUINavigationController *)navigationController didShowViewController:(WTUIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(WTUINavigationController *)navigationController willShowViewController:(WTUIViewController *)viewController animated:(BOOL)animated;
@end

@interface WTUINavigationController : WTUIViewController {
@private
    WTUINavigationBar *_navigationBar;
    WTUIToolbar *_toolbar;
    NSMutableArray *_viewControllers;
    __unsafe_unretained id _delegate;
    BOOL _toolbarHidden;
    BOOL _navigationBarHidden;
    
    struct {
        BOOL didShowViewController : 1;
        BOOL willShowViewController : 1;
    } _delegateHas;
}

- (id)initWithRootViewController:(WTUIViewController *)rootViewController;

- (void)setViewControllers:(NSArray *)newViewControllers animated:(BOOL)animated;

- (void)pushViewController:(WTUIViewController *)viewController animated:(BOOL)animated;
- (WTUIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(WTUIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;
- (void)setRootViewController:(WTUIViewController *)viewController animated:(BOOL)animated;

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, readonly, retain) WTUIViewController *visibleViewController;
@property (nonatomic, readonly) WTUINavigationBar *navigationBar;
@property (nonatomic, readonly) WTUIToolbar *toolbar;
@property (nonatomic, assign) id<WTUINavigationControllerDelegate> delegate;
@property (nonatomic, readonly, retain) WTUIViewController *topViewController;
@property (nonatomic,getter=isNavigationBarHidden) BOOL navigationBarHidden;
@property (nonatomic,getter=isToolbarHidden) BOOL toolbarHidden;

@end