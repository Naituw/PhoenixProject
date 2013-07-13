//
//  WTUserViewController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUserViewController.h"
#import "WTUserToolbarView.h"
#import "WTStatusStreamViewController.h"
#import "WTUserProfileViewController.h"
#import "WMUserFollowersViewController.h"
#import "WMUserFollowingViewController.h"
#import "WTUITabBar.h"
#import "WTUITabBarItemView.h"
#import "WTWebImageView.h"
#import "WMFollowButton.h"
#import "WTActionWebImageView.h"
#import "WTCallback.h"
#import "WTEventHandler.h"
#import "WTImageViewer.h"
#import "WTCGAdditions.h"
#import "WeiboAPI+UserMethods.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"
#import "WeiboStream.h"
#import "WeiboUserTimelineStream.h"
#import "WeiboRequestError.h"

#import "LocalAutocompleteDB.h"

#import "TUIKit.h"
#import "TUIImage+UIDrawing.h"
#import "TUIView+Sizes.h"
#import "WTUIViewController+NavigationController.h"
#import "NSDictionary+WeiboAdditions.h"

#define kUserToolbarViewHeight 70.0
#define kUserBottomBarHeight   32.0

@interface WTUserViewController ()
@property (nonatomic, retain) TUIView * bottomBar;
@property (nonatomic, retain) TUIButton * backButton;
@property (nonatomic, retain) WMFollowButton * followButton;
@property (nonatomic, retain) NSArray * subViewControllers;
@end

@implementation WTUserViewController
@synthesize account, userID, username, theyFollowMe, iFollowThem;
@synthesize user = _user;
@synthesize bottomBar = _bottomBar;
@synthesize backButton = _backButton;

- (void)dealloc{
    [account release], account = nil;
    [_user release], _user = nil;
    [_bottomBar release], _bottomBar = nil;
    [_backButton release], _backButton = nil;
    [_followButton release], _followButton = nil;
    [_subViewControllers release], _subViewControllers = nil;
    [username release], username = nil;
    [subViewController release];
    [super dealloc];
}

#pragma mark - Lift Cycle

- (id)init{
    if (self = [super init])
    {
    }
    return self;
}
- (id)initWithUsername:(NSString *)screenname
{
    if (self = [self init])
    {
        self.username = screenname;
        self.title = screenname;
    }
    return self;
}
- (id)initWithUser:(WeiboUser *)aUser
{
    if (self = [self initWithUsername:aUser.screenName])
    {
        self.user = aUser;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    WTUserViewController * result = [super copyWithZone:zone];
    
    result.username = self.username;
    result.user = self.user;
    result.account = self.account;
    result.initialTabIndex = tabBar.selectedIndex;
    
    if ([subViewController respondsToSelector:@selector(saveScrollPosition)])
    {
        [subViewController performSelector:@selector(saveScrollPosition)];
    }
    
    return result;
}

- (id)initialFirstResponder
{
    return nil;
}

- (NSArray *)makeSubViewControllers
{
    WTStatusStreamViewController * timeline = [[[WTStatusStreamViewController alloc] init] autorelease];
    timeline.title = NSLocalizedString(@"timeline", nil);
    timeline.statusStream = [account timelineStreamForUser:self.user];
    timeline.account = self.account;
    
    WMUserFollowersViewController * followers = [[[WMUserFollowersViewController alloc] init] autorelease];
    followers.title = NSLocalizedString(@"followers", nil);
    followers.account = self.account;
    followers.user = self.user;
    
    WMUserFollowingViewController * following = [[[WMUserFollowingViewController alloc] init] autorelease];
    following.title = NSLocalizedString(@"following", nil);
    following.account = self.account;
    following.user = self.user;

    WTUserProfileViewController * profile = [[[WTUserProfileViewController alloc] init] autorelease];
    profile.title = NSLocalizedString(@"profile", nil);
    profile.userViewController = self;
    profile.user = self.user;
    
    return @[timeline, followers, following, profile];
}

#pragma mark - View Layout
- (CGRect)subViewControllerRect{
    CGRect bounds = [self.view bounds];
    bounds.size.height -= kUserToolbarViewHeight;
    
    if (!self.isMe)
    {
        bounds.size.height -= kUserBottomBarHeight;
        bounds.origin.y += kUserBottomBarHeight;
    }
    
    return bounds;
}

#pragma mark - SubView Control

- (void)_goTabIndex:(NSUInteger)index
{
    WTUIViewController * subVC = self.subViewControllers[index];
    [self setSubViewController:subVC animated:YES];
    [tabBar setSelectedIndex:index];
}
- (void)nextTab:(id)sender{
    
}
- (void)previousTab:(id)sender{
    
}
- (void)_firstTab{
    [self _goTabIndex:0];
}
- (void)setSubViewController:(WTUIViewController *)newController animated:(BOOL)animated{
    
    [newController retain];
    [subViewController viewWillDisappear:animated];
    [subViewController.view removeFromSuperview];
    [subViewController viewDidDisappear:animated];
    [subViewController release];
    subViewController = newController;
    if (newController)
    {
        [newController setParentViewController:self];
        [newController viewWillAppear:animated];
        [newController.view setClipsToBounds:YES];

        [self.view addSubview:newController.view];
        [self.view.nsWindow makeFirstResponder:newController];
        
        __block typeof(self) SELF = self;
        [newController.view setLayout:^(TUIView *v){
            return [SELF subViewControllerRect];
        }];

        if (viewDidAlreadyAppear) {
            // subview should NOT be appear when user view is pushing.
            [newController viewDidAppear:animated];
        }
    }
    
    if ([self boxShadowAppended])
    {
        [self removeBoxShadow];
        [self appendBoxShadow];
    }
}


#pragma mark - User

- (WeiboStream *)streamForTabIndex:(NSUInteger)index{
    return [account timelineStreamForUser:self.user];
}
- (BOOL)userIsLoaded{
    return self.user?YES:NO;
}
- (void)_userDidLoad
{
    
    [followAction setHidden:![self canMakeActions]];
    [spinner stopAnimating];
    [spinner setHidden:YES];
    [toolBar setName:self.user.screenName];
    [toolBar setAvatarImageURL:self.user.profileImageUrl];
    [toolBar redraw];
    
    
    [self _loadFollowState];
    
    self.subViewControllers = [self makeSubViewControllers];
    
    
    for (NSInteger index = tabBar.tabViews.count - 1; index >= 0; index--)
    {
        WTUITabBarItemView * itemView = tabBar.tabViews[index];
        itemView.toolTip = [self.subViewControllers[index] title];
    }
    
    [tabBar setHidden:NO];
    
    [self _goTabIndex:self.initialTabIndex];
}

- (void)_loadUser
{
    [spinner setHidden:NO];
    [spinner startAnimating];
    WTCallback * callback = WTCallbackMake(self, @selector(userResponse:info:), nil);
    [account userWithUsername:username callback:callback];
}
- (void)userResponse:(id)response info:(id)info
{
    if ([response isKindOfClass:[WeiboRequestError class]]) {
        return;
    }
    WeiboUser * newUser = (WeiboUser *)response;
    self.user = newUser;
    [[LocalAutocompleteDB sharedAutocompleteDB] addUser:newUser];
    [self _userDidLoad];
}
- (BOOL)isMe
{
    NSString * screenName = self.user.screenName;
    if (!screenName) screenName = self.username;
    
    return [account.user.screenName.lowercaseString isEqualToString:screenName.lowercaseString];
}
- (BOOL)shouldEnableTabAtIndex:(NSUInteger)index{
    if (index == 0 || index == 3) {
        return YES;
    }else {
        return [self isMe];
    }
}

#pragma mark - User Action
- (BOOL)canMakeActions{
    return ![self isMe];
}
- (BOOL)didLoadFollowStatus{
    return _flags.didLoadFollowStatus;
}
- (void)_loadFollowState{
    _flags.loadingFollowStatus = YES;
    WTCallback * callback = WTCallbackMake(self, @selector(followStatus:info:), nil);
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api lookupRelationships:self.user.userID];//    [self followStatus:nil info:nil];
}
- (void)_updateFollowButton{
    NSString * toolTip = [NSString stringWithFormat:@"%@ %@",self.user.screenName,theyFollowMe?NSLocalizedString(@"is following you", nil):NSLocalizedString(@"does not follow you", nil)];
    [self.followButton setToolTip:toolTip];
    [self.followButton setToolTipDelay:0.5];
    WMFollowButtonState state = WMFollowButtonStateUnknow;
    if (self.didLoadFollowStatus)
    {
        state = iFollowThem ? WMFollowButtonStateFollowing : WMFollowButtonStateNotfollowed;
    }
    [self.followButton setFollowState:state];
}
- (void)followStatus:(id)response info:(id)info{
    _flags.isProcessingFollowAction = NO;
    _flags.loadingFollowStatus = NO;
    
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        return;
    }
    
    _flags.didLoadFollowStatus = YES;
    
    iFollowThem = [response boolForKey:@"followed_by" defaultValue:NO];
    theyFollowMe = [response boolForKey:@"following" defaultValue:NO];
    
    //iFollowThem = [response boolValue];
    [self _updateFollowButton];
}
- (NSMenu *)_actionsMenu{
    NSMenu * menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:NSLocalizedString(@"View on Weibo.com", nil) action:@selector(viewOnWeb:) keyEquivalent:@""];
    [menu setAutoenablesItems:YES];
    [[menu.itemArray objectAtIndex:0] setTarget:self];
    return [menu autorelease];
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    return YES;
}
- (void)toggleFollow{
    if (_flags.isProcessingFollowAction)
    {
        return;
    }
    _flags.isProcessingFollowAction = YES;
    if (iFollowThem) {
        [self unfollow:nil];
    }else {
        [self follow:nil];
    }
    iFollowThem = !iFollowThem;
    [self _updateFollowButton];
}
- (BOOL)isProcessingFollowAction{
    return _flags.isProcessingFollowAction;
}
- (void)followActionResponse:(id)response info:(id)info{
    if ([response isKindOfClass:[WeiboRequestError class]]) {
        iFollowThem = !iFollowThem;
        [self _updateFollowButton];
    }else {
        
    }
    _flags.isProcessingFollowAction = NO;
}
- (void)follow:(id)sender{
    WTCallback * callback = WTCallbackMake(self, @selector(followActionResponse:info:), nil);
    WeiboAPI * api = [account authenticatedRequest:callback];
    [api followUserID:self.user.userID];
}
- (void)unfollow:(id)sender{
    NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Unfollow?", nil) defaultButton:NSLocalizedString(@"Unfollow", nil)
                                    alternateButton:NSLocalizedString(@"No", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Are you sure you want to unfollow %@?", nil),self.user.screenName];
    [alert beginSheetModalForWindow:self.view.nsWindow modalDelegate:self didEndSelector:@selector(unfollowAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}
- (void)unfollowAlertDidEnd:(NSAlert *)alert returnCode:(long long)returnCode contextInfo:(void *)contextInfo{
    if (returnCode == NSAlertDefaultReturn) {
        WTCallback * callback = WTCallbackMake(self, @selector(followActionResponse:info:), nil);
        WeiboAPI * api = [account authenticatedRequest:callback];
        [api unfollowUserID:self.user.userID];
    }else {
        iFollowThem = !iFollowThem;
        [self _updateFollowButton];
        _flags.isProcessingFollowAction = NO;
    }
}
- (void)viewOnWeb:(id)sender{
    NSString * url = [NSString stringWithFormat:@"http://weibo.com/%lld",self.user.userID];
    [WTEventHandler openURL:url];
}
- (void)viewAvatar:(id)sender
{
    NSString * urlString = self.user.profileLargeImageUrl;
    
    [WTImageViewer viewImageWithImageURL:urlString];
}

#pragma mark - View Controller Methods

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[TUIColor colorWithWhite:247.0/255.0 alpha:1.0]];
    
    CGRect toolbarRect = self.view.bounds;
    toolbarRect.origin.y = toolbarRect.size.height - kUserToolbarViewHeight;
    toolbarRect.size.height = kUserToolbarViewHeight;
    toolBar = [[WTUserToolbarView alloc] initWithFrame:toolbarRect];
    toolBar.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:toolBar];
    [toolBar release];
    
    TUIButton * backButton = [TUIButton buttonWithType:TUIButtonTypeCustom];
    [backButton setImage:[TUIImage imageNamed:@"toolbar-back-arrow.png" cache:YES] forState:TUIControlStateNormal];
    [backButton addTarget:self action:@selector(popBack) forControlEvents:TUIControlEventTouchUpInside];
    [toolBar addSubview:backButton];
    [backButton setFrame:CGRectMake(10, toolBar.bounds.size.height - 10 - 19, 14, 19)];
    [backButton setAutoresizingMask:TUIViewAutoresizingFlexibleBottomMargin];
    [backButton setMoveWindowByDragging:YES];
    self.backButton = backButton;
    
    spinner = [[TUIActivityIndicatorView alloc] initWithActivityIndicatorStyle:TUIActivityIndicatorViewStyleGray];
    [spinner setHidden:YES];
    [toolBar addSubview:spinner];
    spinner.layout = ^(TUIView *v) {
        CGRect b = v.superview.bounds;
        CGFloat length = 20.0;
        return CGRectMake((b.size.width - length)/2,b.size.height - 45,length,length);
    };
    spinner.center = toolBar.center;
    [spinner release];
    
    tabBar = [[WTUITabBar alloc] initWithNumberOfTabs:4];
    [tabBar setLayout:^(TUIView * v){
        CGRect b = v.superview.bounds;
        return CGRectMake(15, 1, b.size.width - 30, 40);
    }];
    tabBar.delegate = self;
    [toolBar addSubview:tabBar];
    [tabBar setHidden:YES];
    [tabBar release];
    
    if ([self userIsLoaded]) {
        [self _userDidLoad];
    }else{
        [self _loadUser];
    }

    
    if (!self.isMe)
    {
        self.bottomBar = [[[TUIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kUserBottomBarHeight)] autorelease];
        self.bottomBar.autoresizingMask = TUIViewAutoresizingFlexibleTopMargin | TUIViewAutoresizingFlexibleWidth;
        self.bottomBar.moveWindowByDragging = YES;
        self.bottomBar.drawRect = ^(TUIView * v,CGRect rect){
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            BOOL keyWindow = [v.nsWindow isKeyWindow];
            
            CGFloat topColor = keyWindow?0.80:0.89, bottomColor = keyWindow?0.61:0.78;
            CGFloat top[] = {topColor,topColor,topColor,1.0};
            CGFloat bottom[] = {bottomColor,bottomColor,bottomColor,1.0};
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointZero, bottom, CGPointMake(0, v.height), top);
            
            CGFloat topDark = keyWindow?0.5:0.52;
            CGContextSetRGBFillColor(ctx, topDark, topDark, topDark, 1.0);
            CGContextFillRect(ctx, CGRectMake(0, v.height - 1, v.width, 1));
            
            CGFloat topLight = keyWindow?0.95:0.98;
            CGContextSetRGBFillColor(ctx, topLight, topLight, topLight, 1.0);
            CGContextFillRect(ctx, CGRectMake(0, v.height - 2, v.width, 1));
            
        };
        
        self.followButton = [WMFollowButton buttonWithType:TUIButtonTypeCustom];
        [self.followButton setFrame:CGRectMake(9, 4, 100, 24)];
        [self.followButton setDimsInBackground:YES];
        [self.followButton addTarget:self action:@selector(toggleFollow) forControlEvents:TUIControlEventTouchUpInside];
        [self.bottomBar addSubview:self.followButton];
            
        [self.view addSubview:self.bottomBar];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    self.user.cacheTime = [NSDate timeIntervalSinceReferenceDate];
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.backButton.hidden = [self isRootViewController];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (subViewController)
    {
        [self.view.nsWindow makeFirstResponder:subViewController];
    }
}
- (NSArray *)visibleViewControllers{
    if (subViewController) {
        return [NSArray arrayWithObject:subViewController];
    }
    return nil;
}

- (void)tabBar:(WTUITabBar *)tabBar didSelectTab:(NSInteger)index{
    [self _goTabIndex:index];
}
- (NSString *)tabBar:(WTUITabBar *)tabBar imageNameForTabAtIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return @"clock.png";
        case 1:
            return @"followers.png";
        case 2:
            return @"following.png";
        case 3:
            return @"person.png";
        default:
            return nil;
    }
}

- (id)retain{
    
    return [super retain];
}

- (BOOL)performKeyAction:(NSEvent *)event{
    if (subViewController) {
        return [subViewController performKeyAction:event];
    }
    return NO;
}

@end
