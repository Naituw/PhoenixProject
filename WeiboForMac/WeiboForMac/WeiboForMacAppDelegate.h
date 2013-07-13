//
//  WeiboForMacAppDelegate.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-7-31.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BWQuincyManager.h"

#import "TUIKit.h"
#import "WTPullDownView.h"
#import "WTLoginWindow.h"
#import "WeiboAccount.h"
#import "WMOAuthResponder.h"

@class DDHotKeyCenter, WTComposeWindowController;
@class WeiboMac2Window, WMRootViewController, MASPreferencesWindowController;

@interface WeiboForMacAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSControlTextEditingDelegate, NSComboBoxDelegate,BWQuincyManagerDelegate> {
    WTLoginWindow * loginWindowController;
    MASPreferencesWindowController *_preferencesWindowController;
    NSMenu * sidebarMenu;
    IBOutlet NSPanel *gotoUserPanel;
    IBOutlet NSComboBox *gotoUserField;
    IBOutlet NSButton *gotoUserButton;
    DDHotKeyCenter * hotKeyCenter;
    
    NSMutableArray * composers;
}

@property (nonatomic, readonly) MASPreferencesWindowController *preferencesWindowController;
@property (nonatomic, readonly) IBOutlet NSMenu * mainMenu;
@property (nonatomic, readonly) NSMenu *sidebarMenu;
@property (nonatomic, readonly) DDHotKeyCenter *hotKeyCenter;
@property (nonatomic, retain) NSDocumentController * documentController;

+ (WeiboForMacAppDelegate *)currentDelegate;
+ (BOOL)isUserLogined;

- (id)mainWindow;
- (WMRootViewController *)rootViewController;
- (WeiboAccount *)selectedAccount;

- (IBAction)showPreferenceWindow:(id) sender;
- (void)setShouldLogin;

- (void)saveState;

- (IBAction)emptyCache:(id)sender;

- (IBAction)compose:(id)sender;
- (void)showMainWindow;
- (IBAction)toggleMainWindow:(id)sender;
- (IBAction)viewWeiboHelpOnWeb:(id)sender;
- (void)updateMenuItemBehavior:(id)sender;
#pragma mark -
#pragma mark Goto User Sheet
- (IBAction)beginGoToUserSheet:(id)sender;
- (IBAction)gotoUserActive:(id)sender;
- (IBAction)cancelGoToUser:(id)sender;

#pragma mark - Status Item


#pragma mark - User Notification
- (void)updateNotifications;

#pragma mark - OAuth Handling
- (BOOL)canStartOAuthSession;
- (void)endOAuthSession;
- (void)startOAuthSessionWithResponder:(id<WMOAuthResponder>)responder;


#pragma mark - Utilities for debug.
- (IBAction)letMeCrash:(id)sender;
- (IBAction)expireCurrentAccount:(id)sender;

@end
