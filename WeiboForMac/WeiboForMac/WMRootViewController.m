//
//  WMRootViewController.m
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMRootViewController.h"
#import "WeiboForMacAppDelegate.h"
#import "WMSideBarView.h"
#import "TUIFastIndexPath.h"
#import "WeiboMac2Window.h"
#import "WMColumnViewController+CommonPush.h"
#import "WTComposeWindowController.h"
#import "WTNotificationManager.h"
#import "WTEventHandler.h"
#import "Weibo.h"
#import "WeiboUser.h"
#import "WeiboUnread.h"
#import "WeiboRequestError.h"
#import "WMConstants.h"
#import "WMComposition.h"
#import "NSWindow+WMAdditions.h"

#import "WTStatusStreamViewController.h"
#import "WTAccountUserViewController.h"
#import "WTSearchesViewController.h"
#import "WTTrendStatusStreamViewController.h"

#import "WeiboTimelineStream.h"
#import "WeiboMentionsStream.h"
#import "WeiboCommentsTimelineStream.h"
#import "WeiboTrendStatusesStream.h"
#import "WeiboUserUserList.h"

@interface WMRootViewController ()
@property (nonatomic, retain) WMSideBarView * sideBar;
@property (nonatomic, retain) WMColumnViewController * columnViewController;
@end

@implementation WMRootViewController
@synthesize sideBar = _sideBar;
@synthesize columnViewController = _columnViewController;
@synthesize selectedIndexPath = _selectedIndexPath;

#pragma mark - Object Life Cycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_sideBar release];
    [_columnViewController release];
    [_selectedIndexPath release];
    [super dealloc];
}
- (id)init{
    if (self = [super init]) {
        self.selectedIndexPath = [TUIFastIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

#pragma mark - View Controller Overrides

- (void)viewDidLoad
{
    
    [self.view setMoveWindowByDragging:YES];
    
    self.columnViewController = [[[WMColumnViewController alloc] init] autorelease];
    self.columnViewController.parentViewController = self;
    [self.view addSubview:self.columnViewController.view];
    self.columnViewController.view.layout = ^(TUIView * v){
        CGRect frame = v.superview.bounds;
        frame.origin.x += WeiboMac2WindowSideBarWidth - WeiboMac2WindowCornerRadius;
        frame.size.width -= frame.origin.x;
        return frame;
    };
    
    self.sideBar = [[[WMSideBarView alloc] initWithFrame:CGRectZero] autorelease];
    self.sideBar.layout = ^(TUIView * v){
        CGRect frame = v.superview.bounds;
        frame.size.width = WeiboMac2WindowSideBarWidth;
        return frame;
    };
    self.sideBar.delegate = self;
    
    [self.view addSubview:self.sideBar];
    [self.sideBar reset];

    
    
    [[WTNotificationManager sharedNotificationManager] updateBehavior];
    self.selectedIndexPath = [TUIFastIndexPath indexPathForRow:WTSideBarNot inSection:0];

    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(accountAvatarUpdated:) name:kWeiboAccountAvatarDidUpdateNotification object:nil];
    [nc addObserver:self selector:@selector(accountSetChanged:) name:WeiboAccountSetDidChangeNotification object:nil];
    [nc addObserver:self selector:@selector(streamStatusChanged:) name:kWeiboStreamStatusChangedNotification object:nil];
    [nc addObserver:self selector:@selector(streamViewDidReachTop:) name:kStreamViewDidReachTopNotification object:nil];
    [nc addObserver:self selector:@selector(userListDidAddUser:) name:WeiboUserUserListDidAddUsersNotification object:nil];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self accountTimeline:nil];
}

#pragma mark - Accessors
- (WeiboAccount *)selectedAccount{
    NSInteger index = self.selectedIndexPath.section;
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    if (accounts.count > index) {
        return [accounts objectAtIndex:index];
    }
    return nil;
}
- (NSInteger)selectedSectionInSidebarView{
    return self.selectedIndexPath.section;
}
- (NSInteger)selectedRowInSidebarView{
    return self.selectedIndexPath.row;
}

#pragma mark - Account Set Updated

- (void)accountAvatarUpdated:(NSNotification *)notification
{
    [self updateNotifications]; // this will update sidebar and statusitem menu
    
    
}

- (void)accountSetChanged:(NSNotification *)notification
{
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    
    NSInteger selectedIndex = self.selectedIndexPath.section;
    BOOL needReselect = YES;
    if (selectedIndex >= accounts.count)
    {
        self.selectedIndexPath = [TUIFastIndexPath indexPathForRow:0 inSection:0];
    }
    else if ([[(WeiboAccount *)[accounts objectAtIndex:selectedIndex] user] userID] != self.currentAccountUserID)
    {
        self.selectedIndexPath = [TUIFastIndexPath indexPathForRow:0 inSection:0];
    }
    else
    {
        needReselect = NO;
    }
    [self.sideBar reset];
    if (needReselect)
    {
        [self sidebarView:self.sideBar didSelectRow:self.selectedIndexPath.row];
    }
}

#pragma mark - Unread Management
- (void)updateNotifications
{
    [self.sideBar reloadData];
    [[NSApp delegate] updateNotifications];
}
- (void)streamStatusChanged:(NSNotification *)notification
{
    [self updateNotifications];
}
- (void)streamViewDidReachTop:(NSNotification *)notification
{
    [self updateNotifications];
}
- (void)userListDidAddUser:(NSNotification *)notification
{
    [self updateNotifications];
}

#pragma mark - Side Bar View Delegate
- (TUIImage *)sidebarView:(WMSideBarView *)sideBar imageForSection:(NSInteger)section
{
    WeiboAccount * account = [[[Weibo sharedWeibo] accounts] objectAtIndex:section];
    TUIImage * image = [TUIImage imageWithNSImage:account.profileImage];
    return image; // Profile Image for Account at index:section
}
- (TUIImage *)sidebarView:(WMSideBarView *)sideBar imageForRow:(NSInteger)row
{
    return nil;
}
- (NSString *)sidebarView:(WMSideBarView *)sideBar imageNameForRow:(NSInteger)row
{
    NSArray * nameArray = [NSArray arrayWithObjects:@"tweet.png",@"at.png",@"comment.png",@"messages.png",@"person.png",@"magnifying-glass.png", nil];
    return [nameArray objectAtIndex:row];
}
- (NSString *)sidebarView:(WMSideBarView *)sideBar titleForRow:(NSInteger)row
{
    return @[@"Timeline",
             @"Mentions",
             @"Comments",
             @"Messages",
             @"Profile",
             @"Search"][row];
}
- (NSString *)sidebarView:(WMSideBarView *)sideBar titleForSection:(NSInteger)section
{
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    if ([accounts count] <= section) return @""; // for debug
    WeiboAccount * account = [[[Weibo sharedWeibo] accounts] objectAtIndex:section];
    return account.user.screenName;
    // Screen name for Account at index:section.
}
- (NSInteger)numberOfSectionsInSidebarView:(WMSideBarView *)sideBar
{
    return [[[Weibo sharedWeibo] accounts] count]; // Account Number;
}
- (NSInteger)sideBarView:(WMSideBarView *)sideBar numberOfItemsInSection:(NSInteger)section
{
    return 6; // Current Has Six.
}
- (NSInteger)sideBarView:(WMSideBarView *)sideBar badgeForSection:(NSUInteger)section
{
    NSInteger badge = 0;
    
    WeiboAccount * account = [[Weibo sharedWeibo] accounts][section];
    
    badge |= [account hasFreshTweets] << 0;
    badge |= [account hasFreshMentions] << 1;
    badge |= [account hasFreshComments] << 2;
    badge |= [account hasFreshDirectMessages] << 3;
    
    return badge;
}
- (NSInteger)sideBarView:(WMSideBarView *)sideBar badgeForRow:(NSInteger)row
{
    WeiboAccount * account = self.selectedAccount;
    switch (row)
    {
        case WTSideBarFriends:return [account hasFreshTweets];
        case WTSideBarMention:return [account hasFreshMentions];
        case WTSideBarComment:return [account hasFreshComments];
        case WTSideBarMessage:return [account hasFreshDirectMessages];
        default:return 0;
    }
}
- (TUIFastIndexPath *)selectedRowInSidebarView:(WMSideBarView *)sideBar
{
    return self.selectedIndexPath;
}
- (void)sidebarView:(WMSideBarView *)sideBar didSelectSection:(NSInteger)section
{
    [self clickSideBarSection:section];
}
- (void)sidebarView:(WMSideBarView *)sideBar didSelectRow:(NSInteger)row
{
    self.selectedIndexPath = [TUIFastIndexPath indexPathForRow:row inSection:self.selectedIndexPath.section];
    [self.sideBar reloadData];
    [self updateCurrentAccountUserID];
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (row == WTSideBarProfile)
        {
            WTAccountUserViewController * accountViewController = [[WTAccountUserViewController alloc] initWithAccount:self.selectedAccount];
            [self.columnViewController setRootViewController:accountViewController animated:YES];
            [accountViewController release];
        }
        else if (row == WTSideBarSearch)
        {
            WTSearchesViewController * controller = [[WTSearchesViewController alloc] init];
            [controller setTitle:@"Search"];
            [controller setAccount:self.selectedAccount];
            [self.columnViewController setRootViewController:controller animated:YES];
            [controller release];
        }
        else
        {
            WTStatusStreamViewController * controller = [[WTStatusStreamViewController alloc] init];
            WeiboStream * stream = nil;
            WeiboAccount * account = self.selectedAccount;
            switch (row)
            {
                case WTSideBarFriends:
                    stream = [account timelineStream];
                    break;
                case WTSideBarMention:
                    stream = [account mentionsStream];
                    break;
                case WTSideBarComment:
                    stream = [account commentsTimelineStream];
                default:
                    break;
            }
            [controller setStatusStream:stream];
            [controller setAccount:account];
            
            [self.columnViewController setRootViewController:controller animated:YES];
            [controller release];
        }
    });
    
}
- (void)sidebarView:(WMSideBarView *)sideBar doubleClickedRow:(NSInteger)row
{
    if ([[self.columnViewController viewControllers] count] > 1)
    {
        [self.columnViewController popToRootViewControllerAnimated:YES];
    }
    else if([self.columnViewController.topViewController
             isKindOfClass:[WTStatusListViewController class]])
    {
        WTStatusListViewController * listViewController = (WTStatusListViewController *)self.columnViewController.topViewController;
        [listViewController scrollToTop:self];
    }
}
- (void)sidebarView:(WMSideBarView *)sideBar doubleClickedSection:(NSInteger)section
{
    [self clickSideBarRow:WTSideBarProfile];
}

- (BOOL)sidebarView:(WMSideBarView *)sideBar shouldSelectRow:(NSInteger)row
{
    return row != WTSideBarMessage;
}

- (void)sidebarView:(WMSideBarView *)sideBar didClickShouldNotSelectRow:(NSInteger)row
{
    WeiboAccount * account = self.selectedAccount;
    switch (row) {
        case WTSideBarMessage:
            [account resetUnreadCountWithType:WeiboUnreadCountTypeDirectMessage];
            [WTEventHandler openMessagePage];
            [[NSApp delegate] updateNotifications];
            break;
        default:
            break;
    }
}

- (void)updateCurrentAccountUserID
{
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    NSInteger index = self.selectedIndexPath.section;
    if (index < accounts.count)
    {
        self.currentAccountUserID = [[(WeiboAccount *)[accounts objectAtIndex:index] user] userID];
    }
}

- (void)sidebarView:(WMSideBarView *)sideBar didClickComposeButton:(TUIButton *)button
{
    [self compose:button];
}

- (void)sidebarView:(WMSideBarView *)sideBar didClickMenuButton:(TUIButton *)button
{
    NSMenu * menu = [[[NSMenu alloc] init] autorelease];
    
    {
        [menu addItemWithTitle:NSLocalizedString(@"Compose Weibo", nil) action:@selector(compose:) keyEquivalent:@"n"];
    }
    
    {
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    {
        [menu addItemWithTitle:NSLocalizedString(@"Go To User", nil) action:@selector(beginGoToUserSheet:) keyEquivalent:@"u"];
    }
    
    {
        [menu addItemWithTitle:NSLocalizedString(@"Open In New Window", nil) action:@selector(openCurrentViewControllerInSatelliteWindow:) keyEquivalent:@"T"];
    }
    
    {
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    {
        [menu addItemWithTitle:NSLocalizedString(@"Preference", nil) action:@selector(showPreferenceWindow:) keyEquivalent:@","];
    }
    
    NSPoint p = [button frameInNSView].origin;
    p.x += 6;
    p.y -= 2;
    [menu popUpMenuPositioningItem:nil atLocation:p inView:button.nsView];
}

#pragma mark - WeiboAccount Delegate Methods
- (void)account:(WeiboAccount *)account didFailToPost:(id<WeiboComposition>)composition errorMessage:(NSString *)message error:(WeiboRequestError *)error
{
    
}
- (void)account:(WeiboAccount *)account didCheckingUnreadCount:(id)info{
}
- (void)account:(WeiboAccount *)account finishCheckingUnreadCount:(WeiboUnread *)unread{
    if (unread.newMentions > 0) {
        //[sideBarController setTabAtIndex:WTSideBarMention shouldShowGlow:YES];
    }
    
    if (unread.newComments > 0) {
        //[sideBarController setTabAtIndex:WTSideBarComment shouldShowGlow:YES];
    }
    [[NSApp delegate] updateNotifications];
}

- (void)clickSideBarRow:(NSInteger)row
{
    if (![self sidebarView:self.sideBar shouldSelectRow:row]) {
        [self sidebarView:self.sideBar didClickShouldNotSelectRow:row];
    }else if (self.selectedIndexPath.row == row) {
        [self sidebarView:self.sideBar doubleClickedRow:row];
    }else {
        [self sidebarView:self.sideBar didSelectRow:row];
    }
}
- (void)clickSideBarSection:(NSInteger)section
{
    if (self.selectedIndexPath.section == section)
    {
        [self clickSideBarRow:0];
    }
    else
    {
        self.selectedIndexPath = [TUIFastIndexPath indexPathForRow:0 inSection:section];
        [self sidebarView:self.sideBar didSelectRow:0];
    }
}

- (void)setSelectedIndexPathForSideBar:(TUIFastIndexPath *)indexPath
{
    [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
    
    BOOL sectionChanged = NO;
    
    if (indexPath.section != self.selectedIndexPath.section)
    {
        sectionChanged = YES;
        [self clickSideBarSection:indexPath.section];
    }
    
    if (!sectionChanged || indexPath.row != self.selectedIndexPath.row)
    {
        [self clickSideBarRow:indexPath.row];
    }
}

- (void)accountFollowersForAccount:(WeiboAccount *)account
{
    [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
    
    [self.columnViewController pushUserFollowerListControllerWithUser:account.user account:account];
}


- (void)accountTimeline:(id)sender{
    [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
    [self clickSideBarRow:WTSideBarFriends];
}
- (void)accountMentions:(id)sender{
    [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
    [self clickSideBarRow:WTSideBarMention];
}
- (void)accountComments:(id)sender{
    [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
    [self clickSideBarRow:WTSideBarComment];
}
- (void)accountMessages:(id)sender{
    [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
    [self clickSideBarRow:WTSideBarMessage];
}
- (void)accountProfile:(id)sender{
    [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
    [self clickSideBarRow:WTSideBarProfile];
}
- (void)accountSearch:(id)sender{
    [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
    [self clickSideBarRow:WTSideBarSearch];
}
- (void)accountFollowers:(id)sender{
    [WTEventHandler openFollowserPageForUserID:[self selectedAccount].user.userID];
    [[self selectedAccount] resetUnreadCountWithType:WeiboUnreadCountTypeFollower];
    [self updateNotifications];
}
- (void)nextSelection:(id)sender
{
    NSInteger tabs = [self sideBarView:self.sideBar numberOfItemsInSection:self.selectedSectionInSidebarView];
    NSInteger nextIndex = ([self selectedRowInSidebarView]+1)%tabs;
    while (![self sidebarView:self.sideBar shouldSelectRow:nextIndex]) {
        nextIndex = (nextIndex+1)%tabs;
    }
    [self clickSideBarRow:nextIndex];
}
- (void)previousSelection:(id)sender
{
    NSInteger tabs = [self sideBarView:self.sideBar numberOfItemsInSection:self.selectedSectionInSidebarView];
    NSInteger preIndex = ([self selectedRowInSidebarView] - 1 + tabs)%tabs;
    while (![self sidebarView:self.sideBar shouldSelectRow:preIndex]) {
        preIndex = (preIndex - 1 + tabs)%tabs;
    }
    [self clickSideBarRow:preIndex];
}

- (void)selectNextAccount:(id)sender
{
    NSInteger count = [self numberOfSectionsInSidebarView:self.sideBar];
    
    NSInteger nextIndex = ([self selectedSectionInSidebarView] + 1) % count;
    
    [self clickSideBarSection:nextIndex];
}
- (void)selectPreviousAccount:(id)sender
{
    NSInteger count = [self numberOfSectionsInSidebarView:self.sideBar];
    
    NSInteger preIndex = ([self selectedSectionInSidebarView] - 1 + count) % count;

    [self clickSideBarSection:preIndex];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(selectNextAccount:) ||
        menuItem.action == @selector(selectPreviousAccount:))
    {
        return [[[Weibo sharedWeibo] accounts] count] > 1;
    }
    
    return YES;
}


- (void)compose:(id)sender
{    
    NSWindow * mainWindow = self.view.nsWindow;
    
    if ([sender isKindOfClass:[TUIView class]] &&
        !mainWindow.isKeyWindow)
    {
        return;
    }
    
    CGFloat windowSpacing = 50;
    
    CGPoint defaultOffset = CGPointMake(-42 - [WTComposeWindowController defaultWindowSize].width, 180);
    
    if (mainWindow.isOnLeftSideOfScreen)
    {
        defaultOffset = CGPointMake(mainWindow.frame.size.width + 42, 180);
    }
    
    CGPoint origin = CGPointMake(CGRectGetMinX(mainWindow.frame), CGRectGetMaxY(mainWindow.frame));
    origin.x += defaultOffset.x;
    origin.y -= defaultOffset.y;
    
    NSArray * windows = [WTComposeWindow composeWindows];
    NSInteger windowCount = windows.count;
    
    CGPoint desiredOrigin = CGPointMake(origin.x + windowCount * windowSpacing, origin.y - windowCount * windowSpacing);
    
    origin = desiredOrigin;
    
    BOOL overlay;
    
    do
    {
        overlay = NO;
        
        for (NSWindow * window in windows)
        {
            if (window.frame.origin.y == origin.y)
            {
                overlay = YES;
                break;
            }
        }
        
        if (overlay)
        {
            origin.x -= windowSpacing;
            origin.y -= windowSpacing;
        }
    }
    while (overlay);
    
    
    NSDocumentController * documentController = [NSDocumentController sharedDocumentController];
    NSDocument * document = [documentController openUntitledDocumentAndDisplay:YES error:nil];
    
    WTComposeWindowController * controller = document.windowControllers.lastObject;
    controller.account = self.selectedAccount;
    
    [controller.window setFrameOrigin:origin];
}

@end
