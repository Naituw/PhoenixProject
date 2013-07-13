//
//  WTUserViewController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTMasterViewController.h"
#import "WeiboConstants.h"
#import "WTUITabBar.h"
#import "WMUserFollowActionView.h"

@class WeiboAccount, WeiboUser, WTStatusStreamViewController, WTUserToolbarView;
@class TUIImageView, TUIActivityIndicatorView, WTUITabBar, WTActionWebImageView;
@class WeiboStream;
@class WTUserProfileViewController;

@interface WTUserViewController : WTMasterViewController 
<WTUITabBarDelegate, WMUserFollowActionViewDelegate> {
    WeiboAccount * account;
    NSString * username;
    WeiboUserID userID;
    
    WTUserToolbarView * toolBar;
    TUIActivityIndicatorView * spinner;
    WMUserFollowActionView * followAction;
    WTUITabBar * tabBar;
        
    WTUIViewController *subViewController;
    BOOL iFollowThem;
    BOOL theyFollowMe;
    struct {
        unsigned int loading:1;
        unsigned int loadingFollowStatus:1;
        unsigned int didLoadFollowStatus:1;
        unsigned int errorLoadingFollowStatus:1;
        unsigned int errorLoading:1;
        unsigned int isProcessingFollowAction:1;
    } _flags;
}

@property (retain, nonatomic) WeiboAccount * account;
@property (retain, nonatomic) WeiboUser * user;
@property (retain, nonatomic) NSString * username;
@property (assign, nonatomic) WeiboUserID userID;
@property (readonly, nonatomic) BOOL theyFollowMe;
@property (readonly, nonatomic) BOOL iFollowThem;
@property(readonly, nonatomic) BOOL didLoadFollowStatus;
@property (assign, nonatomic) NSInteger initialTabIndex;

#pragma mark - Lift Cycle
- (id)initWithUsername:(NSString *)screenname;
- (id)initWithUser:(WeiboUser *)user;
- (id)initialFirstResponder;

#pragma mark - View Layout
- (CGRect)subViewControllerRect;

#pragma mark - SubView Control
- (NSArray *)makeSubViewControllers;
- (void)_goTabIndex:(NSUInteger)index;
- (void)nextTab:(id)sender;
- (void)previousTab:(id)sender;
- (void)_firstTab;
- (void)setSubViewController:(WTUIViewController *)newController animated:(BOOL)animated;

#pragma mark - User
- (WeiboStream *)streamForTabIndex:(NSUInteger)index;
- (BOOL)userIsLoaded;
- (void)_loadUser;
- (void)userResponse:(id)response info:(id)info;
- (BOOL)isMe;
- (BOOL)shouldEnableTabAtIndex:(NSUInteger)index;

#pragma mark - User Action
- (void)_loadFollowState;
- (void)_updateFollowButton;
- (void)followStatus:(id)response info:(id)info;
- (NSMenu *)_actionsMenu;
- (void)toggleFollow;
- (void)follow:(id)sender;
- (void)unfollow:(id)sender;
- (void)unfollowAlertDidEnd:(id)arg1 returnCode:(long long)arg2 contextInfo:(void *)arg3;
- (void)viewOnWeb:(id)sender;


@end
