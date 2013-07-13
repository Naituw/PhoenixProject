//
//  WTNotificationManager.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-1.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTNotificationManager.h"
#import "WMRootViewController.h"
#import "WMMenu.h"
#import "Weibo.h"
#import "WeiboUser.h"
#import "WeiboForMacAppDelegate.h"
#import "WMStatusItemMenuView.h"
#import "WMColumnViewController+CommonPush.h"

@interface WTNotificationManager () <WMStatusItemMenuViewDelegate>
@property (nonatomic,retain) WMStatusItemMenuView * menuView;
@property (nonatomic,retain) NSMenu * statusItemMenu;
@end

@implementation WTNotificationManager
@synthesize animationState, animationTimer, alertSound;
@synthesize statusItem, lastNotificationDate;
@synthesize menuView = _menuView;
@synthesize statusItemMenu = _statusItemMenu;

static WTNotificationManager * shared = nil;
+ (id)sharedNotificationManager
{
    if (!shared) {
        shared = [[[self class] alloc] init];
    }
    return shared;
}

- (id)init{
    if (self = [super init])
    {
        targetController = [(WeiboForMacAppDelegate *)[NSApp delegate] rootViewController];
        
        self.menuView = [[[WMStatusItemMenuView alloc] initWithFrame:NSZeroRect] autorelease];
        self.menuView.delegate = self;
        
        NSMenu * menu = [[NSMenu alloc] init];
        [menu setDelegate:self];
        [menu setAutoenablesItems:NO];        
        self.statusItemMenu = [menu autorelease];
    }
    return self;
}
- (void)dealloc{
    self.statusItem = nil;
    self.animationTimer = nil;
    self.lastNotificationDate = nil;
    self.alertSound = nil;
    [_statusItemMenu release], _statusItemMenu = nil;
    [_menuView release], _menuView = nil;
    [super dealloc];
}
- (void)playAlertSound{
    
}
- (void)setDockIconWithCount:(NSUInteger)count
{
    
}
- (void)showStatusMenu
{
    
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self.menuView reloadData];
    [self.menuView sizeToFit];
    [menu removeAllItems];
    NSMenuItem * item = [[NSMenuItem alloc] init];
    [item setView:self.menuView];
    [menu addItem:item];
    [item release];
}

- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu
{
    return 1;
}

- (NSMenu *)menuForActiveAccounts
{
    return self.statusItemMenu;
}

- (void)didSelectNewTweetFromStatusMenuItem:(id)sender{
    [targetController compose:self];
}
- (void)showStatusItem
{
    if (!statusItem)
    {
        self.statusItem = [[NSStatusBar systemStatusBar]
                           statusItemWithLength:NSVariableStatusItemLength];
        [statusItem setAlternateImage:[NSImage imageNamed:@"statusbar_alt"]];
        [statusItem setHighlightMode:YES];
        [statusItem setMenu:[self menuForActiveAccounts]];
    }
    self.statusItemState = WMStatusItemStateOff;
}
- (void)updateBehavior
{
    id behaviorObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"MenuItemBehavior"];
    NSInteger behavior = behaviorObject?[behaviorObject integerValue]:0;
    switch (behavior) {
        case 0:
            [self showStatusItem];
            [statusItem setMenu:[self menuForActiveAccounts]];
            break;
        case 1:{
            [self showStatusItem];
            [statusItem setMenu:nil];
            [statusItem setTarget:[NSApp delegate]];
            [statusItem setAction:@selector(toggleMainWindow:)];
            break;
        }
        case 2:{
            if (statusItem) {
                [statusItem setMenu:nil];
                [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
                statusItem = nil;
            }
            break;
        }
        default:
            break;
    }
}
- (void)updateForAccount:(WeiboAccount *)account
{
    
}

- (void)updateStatusItemWithCurrentState
{
    NSMutableString * imageName = [NSMutableString stringWithString:@"statusbar_"];
    if (self.statusItemState == WMStatusItemStateHalf)
    {
        [imageName appendString:@"half"];
    }
    else if (self.statusItemState == WMStatusItemStateOff)
    {
        [imageName appendString:@"off"];
    }
    else
    {
        [imageName appendString:@"on"];
    }
    [statusItem setImage:[NSImage imageNamed:imageName]];
}

- (void)setStatusItemState:(WMStatusItemState)statusItemState
{
    _statusItemState = statusItemState;
    
    [self updateStatusItemWithCurrentState];
}
- (void)setShowDockBadge:(BOOL)show{
    NSDockTile * tile = [NSApp dockTile];
    [tile setBadgeLabel:show?@"★":nil];
}

#pragma mark - Menu View Delegate

- (BOOL)menuView:(WMStatusItemMenuView *)menuView shouldHighlightImageAtIndex:(NSInteger)index forAccount:(WeiboAccount *)account
{
    switch (index) {
        case 0:return [account hasFreshTweets];
        case 1:return [account hasFreshMentions];
        case 2:return [account hasFreshComments];
        case 3:return [account hasFreshDirectMessages];
        case 4:return [account hasNewFollowers];
        default:
            break;
    }
    return NO;
}

- (void)menuView:(WMStatusItemMenuView *)menuView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    [self.statusItemMenu cancelTracking];
    
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    if (indexPath.section >= accounts.count)
    {
        [targetController compose:self];
    }
    else if (indexPath.row == 4)
    {
        WeiboAccount * account = accounts[indexPath.section];
        
        [targetController accountFollowersForAccount:account];
    }
    else
    {
        [targetController setSelectedIndexPathForSideBar:indexPath];
    }
}

@end
