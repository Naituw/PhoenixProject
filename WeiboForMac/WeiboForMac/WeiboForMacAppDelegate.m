//
//  WeiboForMacAppDelegate.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-7-31.
//  Copyright 2011年 Wutian. All rights reserved.
//


#import "WeiboForMacAppDelegate.h"
#import "WeiboForMacApp.h"
#import "WeiboMac2Window.h"
#import "WMRootViewController.h"
#import "WMColumnViewController+CommonPush.h"
#import "Weibo.h"
#import "WTCallback.h"
#import "INAppStoreWindow.h"

#import "WTStatusListViewController.h"
#import "WTNotificationManager.h"
#import "WeiboEmotionManager.h"
#import "WMAppVersionManager.h"
#import "WTEventHandler.h"
#import "WTComposeWindow.h"
#import "EGOCache.h"
#import "WeiboRequestError.h"

#import "LocalAutocompleteDB.h"
#import "ASIFormDataRequest.h"
#import "MASPreferencesWindowController.h"
#import "WMGeneralPreferencesController.h"
#import "WMAccountPreferencesController.h"
#import "WMNotificationPreferencesController.h"
#import "DDHotKeyCenter.h"
#import "WTStatusCell.h"
#import "WeiboStatus.h"
#import "WTTokenRefreshPanel.h"
#import "WMConstants.h"

@interface WeiboForMacAppDelegate ()
@property (nonatomic, retain) WeiboMac2Window * window;
@property (nonatomic, retain) WMRootViewController * rootViewController;
@property (nonatomic, retain) WTTokenRefreshPanel * tokenRefreshPanel;
@property (nonatomic, assign) BOOL showingTokenExpireSheet;

@property (nonatomic, assign) id<WMOAuthResponder> oauthResponder;
@property (nonatomic, assign, setter = setOAuthVerifing:) BOOL oauthVerifing;

@end

@implementation WeiboForMacAppDelegate
@synthesize window = _window;
@synthesize rootViewController = _rootViewController;
@synthesize sidebarMenu, hotKeyCenter, mainMenu;
@synthesize tokenRefreshPanel = _tokenRefreshPanel;

+ (WeiboForMacAppDelegate *)currentDelegate
{
    return [NSApp delegate];
}
+ (BOOL)isUserLogined
{
    return [[[Weibo sharedWeibo] accounts] count] > 0;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [sidebarMenu release];
    [_window release], _window = nil;
    [_preferencesWindowController release], _preferencesWindowController = nil;
    [_tokenRefreshPanel release], _tokenRefreshPanel = nil;
    [_documentController release], _documentController = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.documentController = [[[NSDocumentController alloc] init] autorelease];
    
    if ([[[Weibo sharedWeibo] accounts] count] > 0) {
        //[self showMainWindow];
        // Let QuinckKit do it.
        // see - (void) showMainApplicationWindow
    }
    else
    {
        [self setShouldLogin];
    }
    
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    hotKeyCenter = [[DDHotKeyCenter alloc] init];
    [self preferencesWindowController];
    [LocalAutocompleteDB verifyDatabase];
        
    [[BWQuincyManager sharedQuincyManager] setSubmissionURL:@"http://weiboformac.sinaapp.com/crashreport/crash_v200.php"];
    [[BWQuincyManager sharedQuincyManager] setCompanyName:@"Wutian"];
    [[BWQuincyManager sharedQuincyManager] setDelegate:self];
            
    [WeiboEmotionManager sharedManager];
    [[WMAppVersionManager defaultManager] configure];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenExpiredNotification:) name:kWeiboAccessTokenExpriedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSetChanged:) name:WeiboAccountSetDidChangeNotification object:nil];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [loginWindowController release];
    [self saveState];
    [[Weibo sharedWeibo] shutdown];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification{
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    [self showMainWindow];
    return YES;
}

-(void)setShouldLogin{
    [self.window close];
    [self.preferencesWindowController close];
    if (!loginWindowController) {
        loginWindowController = [[WTLoginWindow alloc] 
                                 initWithWindowNibName:@"WTLoginWindow"];
    }
    [loginWindowController.window display];
    [loginWindowController.window makeKeyAndOrderFront:self];
}
- (id)mainWindow{
    return self.window;
}
- (WeiboAccount *)selectedAccount{
    return self.rootViewController.selectedAccount;
}

- (IBAction) showPreferenceWindow:(id)sender
{
    if (!self.preferencesWindowController.window.isVisible)
    {
        [self.preferencesWindowController selectControllerAtIndex:0];
    }
    [self.preferencesWindowController showWindow:nil];
}
- (MASPreferencesWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        WMGeneralPreferencesController *generalViewController = [[WMGeneralPreferencesController alloc] init];
        NSViewController *accountViewController = [[WMAccountPreferencesController alloc] init];
        NSViewController *notificationViewController = [[WMNotificationPreferencesController alloc] init];
        NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, accountViewController,notificationViewController, nil];
        [generalViewController release];
        [accountViewController release];
        [notificationViewController release];
        
        [generalViewController restoreKeyCombos];
        
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
        _preferencesWindowController.window.delegate = self;
        [controllers release];
    }
    return _preferencesWindowController;
}

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect
{
    NSValue * rectValue = [sheet objectWithAssociatedKey:kWindowSheetPositionRect];
    if (rectValue) return [rectValue rectValue];
    
    return rect;
}

- (void)saveState
{
    [self.window updateAutoSavedFrame];
}

- (IBAction)emptyCache:(id)sender{
    [[EGOCache currentCache] clearCache];
}

- (void)doPost{
    
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (![[[Weibo sharedWeibo] accounts] count])
    {
        return NO;
    }
    
    if (menuItem.action == @selector(toggleMainWindow:))
    {
        return ![self.mainWindow presentingSheet];
    }
    
    return YES;
}
- (NSMenu *)sidebarMenu{
    if (!sidebarMenu) {
        sidebarMenu = [[NSMenu alloc] init];
        
        NSArray * itemArray = [[mainMenu.itemArray objectAtIndex:1] submenu].itemArray;
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
        NSArray * itemToAdd = [itemArray objectsAtIndexes:indexSet];
        for (NSMenuItem * item in itemToAdd) {
            NSMenuItem * copiedItem = [[item copy] autorelease];
            [sidebarMenu addItem:copiedItem];
            [copiedItem setTarget:self];
        }
    }
    return sidebarMenu;
}
- (IBAction)compose:(id)sender{
    [[self rootViewController] compose:sender];
}
- (void)showMainWindow
{
    if (![WeiboForMacAppDelegate isUserLogined]) return;
    
    if (!self.window)
    {
        self.window = [[[WeiboMac2Window alloc] init] autorelease];
        self.window.delegate = self;
        self.rootViewController = [[[WMRootViewController alloc] init] autorelease];
        self.rootViewController.windowIdentifier = self.window.uniqueIdentifier;
        [self.window.nsView setRootView:self.rootViewController.view];
        [self.rootViewController viewDidAppear:NO];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [self.window display];
    [self.window makeKeyAndOrderFront:nil];
}
- (IBAction)toggleMainWindow:(id)sender
{
    if ([self.window isVisible]) {
        [self.window performClose:sender];
    }else {
        [self showMainWindow];
    }
}
- (IBAction)viewWeiboHelpOnWeb:(id)sender{
    [WTEventHandler openURL:@"http://help.weibo.com/" inBackground:NO];
}
- (void)updateMenuItemBehavior:(id)sender{
    NSPopUpButton * button = sender;
    NSInteger index = 0;
    if (button) {
        index = [button indexOfSelectedItem];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:index]
                                              forKey:@"MenuItemBehavior"];
    [[WTNotificationManager sharedNotificationManager] updateBehavior];
    [self updateNotifications];
}

- (void)accountSetChanged:(NSNotification *)notification
{
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    if (accounts.count == 0)
    {
        // Relaunch Application
        NSApplication * app = [NSApplication sharedApplication];
        if ([app isKindOfClass:[WeiboForMacApp class]])
        {
            [(WeiboForMacApp *)app relaunchAfterDelay:0.0];
        }
    }
}

#pragma mark -
#pragma mark Goto User Sheet
- (IBAction)beginGoToUserSheet:(id)sender
{
    NSArray * items = [[LocalAutocompleteDB sharedAutocompleteDB] defaultResultsForType:WeiboAutocompleteTypeUser];
    for (WeiboAutocompleteResultItem * item in items) {
        [gotoUserField addItemWithObjectValue:item.autocompleteText];
    }
    [gotoUserField setStringValue:@""];
    [gotoUserButton setEnabled:NO];
    [gotoUserPanel setDefaultButtonCell:[gotoUserButton cell]];
    [NSApp beginSheet:gotoUserPanel modalForWindow:self.window modalDelegate:self didEndSelector:@selector(gotoUserSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}
- (void)gotoUserSheetDidEnd:(NSWindow *)sheet returnCode:(long long)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        NSString * name = [gotoUserField stringValue];
        WMColumnViewController * column = self.rootViewController.columnViewController;
        WeiboAccount * account = self.rootViewController.selectedAccount;
        [column pushUserViewControllerWithUsername:name account:account];
    }
    [sheet orderOut:self];
}
- (void)comboBoxWillDismiss:(NSNotification *)notification{
    [gotoUserButton setEnabled:[[gotoUserField objectValueOfSelectedItem] length] > 0];
}
- (void)controlTextDidChange:(NSNotification *)aNotification{
    if (aNotification.object == gotoUserField) {
        [gotoUserButton setEnabled:(gotoUserField.stringValue.length > 0)];
    }
}
- (IBAction)gotoUserActive:(id)sender{
    [NSApp endSheet:gotoUserPanel returnCode:NSOKButton];
}
- (IBAction)cancelGoToUser:(id)sender{
    [NSApp endSheet:gotoUserPanel returnCode:NSCancelButton];
}


#pragma mark - Status Item


#pragma mark - User Notification
- (void)updateNotifications
{
    BOOL highlightStatusItem = [[Weibo sharedWeibo] hasFreshAnythingApplicableToStatusItem];
    WMStatusItemState stautsItemState = WMStatusItemStateOff;
    
    if (highlightStatusItem)
    {
        stautsItemState = WMStatusItemStateHalf;
        
        for (WeiboAccount * account in [[Weibo sharedWeibo] accounts])
        {
            if (account.hasFreshComments ||
                account.hasFreshDirectMessages ||
                account.hasFreshMentions ||
                account.hasNewFollowers)
            {
                stautsItemState = WMStatusItemStateOn;
                break;
            }
        }
    }
    
    [[WTNotificationManager sharedNotificationManager] setStatusItemState:stautsItemState];
    [[WTNotificationManager sharedNotificationManager] setShowDockBadge:[[Weibo sharedWeibo] hasFreshAnythingApplicableToDockBadge]];
}

#pragma mark - Token Refreshing
- (WTTokenRefreshPanel *)tokenRefreshPanel{
    if (!_tokenRefreshPanel) {
        self.tokenRefreshPanel = [[[WTTokenRefreshPanel alloc] init] autorelease];
    }
    return _tokenRefreshPanel;
}

- (void)beginTokenExpiredSheet
{
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    
    for (WeiboAccount * account in accounts)
    {
        if (account.tokenExpired)
        {
            self.showingTokenExpireSheet = YES;
            
            WTTokenRefreshPanel * panel = self.tokenRefreshPanel;
            [panel setAccount: account];
            [NSApp beginSheet:panel.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(tokenRefreshDidEnd:returnCode:contextInfo:) contextInfo:nil];
             
            return;
        }
    }
}

- (void)tokenExpiredNotification:(NSNotification *)notification{
    if (!self.showingTokenExpireSheet && self.window)
    {
        [self beginTokenExpiredSheet];
    }
}
- (void)tokenRefreshDidEnd:(NSWindow *)window returnCode:(long long)returnCode contextInfo:(void *)contextInfo
{
    [window orderOut:self];
    if (returnCode == 1) {
        // refresh success
    }else if (returnCode == 0) {
        // request to remove account
        if ([[[Weibo sharedWeibo] accounts] count] == 0) {
            [[NSApplication sharedApplication] terminate:self];
        }
    }
    
    [self setShowingTokenExpireSheet:NO];
    
    [self performSelector:@selector(beginTokenExpiredSheet) withObject:nil afterDelay:0.5];
}

#pragma mark - QuincyKit Delegate
- (void)showMainApplicationWindow
{
    [self showMainWindow];
}



#pragma mark - OAuth Handling

- (BOOL)canStartOAuthSession
{
    return !self.oauthVerifing;
}

- (void)startOAuthSessionWithResponder:(id<WMOAuthResponder>)responder
{
    if (!self.canStartOAuthSession)
    {
        return;
    }
    
    self.oauthResponder = responder;
    
    NSURL * authURL = [NSURL URLWithString:@"http://weiboformac.sinaapp.com/_auth/new.php"];
    
    [[NSWorkspace sharedWorkspace] openURL:authURL];
}
- (void)endOAuthSession
{
    self.oauthVerifing = NO;
    self.oauthResponder = nil;
}

- (void)handleURLScheme:(NSString *)url
{
    if (!self.oauthResponder)
    {
        // Don't have any OAuth session started yet.
        return;
    }
    
    NSString * prefix = @"weibomac://done?";
    
    if (![url hasPrefix:prefix])
    {
        // Isn't an OAuth callback.
        return;
    }
    
    NSString * query = [url substringFromIndex:prefix.length];
    NSDictionary * authResult = [self _queryStringToDictionary:query];
    
    NSString * accessToken = authResult[@"access_token"];
    WeiboUserID userID = [authResult[@"uid"] longLongValue];
    NSTimeInterval expireTime = [authResult[@"expires_in"] doubleValue];
    
    if (!accessToken.length || !userID)
    {
        // Information is not complete
        return;
    }
    
    if (![self.oauthResponder shouldAddAccountWithAccessToken:accessToken forUserID:userID])
    {
        // Responder decide not to add this account.
        return;
    }
    
    [self.oauthResponder willVerifyAccessToken:accessToken forUserID:userID];
    [self setOAuthVerifing:YES];
    
    WTCallback * callback = WTCallbackMake(self, @selector(accessTokenSignInResponse:info:), authResult);
    
    [[Weibo sharedWeibo] signInWithAccessToken:accessToken tokenExpire:expireTime userID:userID callback:callback];
}

- (void)accessTokenSignInResponse:(id)responseValue info:(id)info
{
    NSString * accessToken = info[@"access_token"];
    WeiboUserID userID = [info[@"uid"] longLongValue];
    
    WeiboRequestError * error = nil;
    
    if ([responseValue isKindOfClass:[WeiboRequestError class]])
    {
        error = responseValue;
        
        [self accessTokenSignInFailedWithError:error];
    }
    
    [self.oauthResponder finishedVerifingAccessToken:accessToken forUserID:userID error:error];
    
    [self endOAuthSession];
}

- (void)accessTokenSignInFailedWithError:(WeiboRequestError *)error
{
    NSWindow * windowForModal = [self.oauthResponder windowForOAuthModalAlert];
    
    if (!windowForModal)
    {
        // Don't have an window for modal alert.
        return;
    }
    
    NSString * errorString = nil;
    int code = (int)[error code];
    switch (code)
    {
        case WeiboErrorCodeTokenInvalid:
            errorString = NSLocalizedString(@"Invalid authorize token", nil);
            break;
        case 403:
            errorString = NSLocalizedString(@"Unauthorized. Invalid user name or password.", nil);
            break;
        case 0:
        case 1:
            errorString = NSLocalizedString(@"No Internet connection.", nil);
            break;
        case 2:
            errorString = NSLocalizedString(@"Connection time out, please try again later.", nil);
            break;
        default:
        {
            if ([error errorStringInChinese])
            {
                errorString = [error errorStringInChinese];
            }
            else
            {
                errorString = [NSString stringWithFormat:NSLocalizedString(@"Signin failed, error code:%d", nil),code];
            }
            break;
        }
    }

    NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Signin failed", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",errorString];
    
    [alert beginSheetModalForWindow:windowForModal modalDelegate:self didEndSelector:nil contextInfo:NULL];
}

- (void)handleURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{    
    NSString * url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    
    [self handleURLScheme:url];
}

- (NSDictionary *)_queryStringToDictionary:(NSString *)string
{
    NSArray * components = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary * resultDictionary = [NSMutableDictionary dictionary];
    for (NSString * component in components)
    {
        if ([component length] == 0) continue;
        
        NSArray * keyAndValue = [component componentsSeparatedByString:@"="];
        if ([keyAndValue count] < 2) continue;
        
        NSString * value = [keyAndValue objectAtIndex:1];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        [resultDictionary setValue:value forKey:[keyAndValue objectAtIndex:0]];
    }
    return resultDictionary;
}

#pragma mark - Utilities for debug.


- (IBAction)letMeCrash:(id)sender{
    abort();
}
- (IBAction)expireCurrentAccount:(id)sender{
    WeiboAccount * account = [[Weibo sharedWeibo] defaultAccount];
    account.tokenExpired = YES;
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kWeiboAccessTokenExpriedNotification object:account];
}
- (void)simulateCrashWithDelay:(NSTimeInterval)delay{
    [self performSelector:@selector(letMeCrash:) withObject:self afterDelay:delay];
}


@end
