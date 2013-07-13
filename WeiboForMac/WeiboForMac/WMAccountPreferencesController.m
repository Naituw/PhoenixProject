//
//  WMAccountPreferencesController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-2.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMAccountPreferencesController.h"
#import "WeiboForMacAppDelegate.h"
#import "Weibo.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"
#import "WeiboRequestError.h"
#import "WTCallback.h"
#import "EGOImageLoader.h"

#define kAccountTableViewDataType @"AccountTableViewDataType"

@interface WMAccountPreferencesController ()<WMOAuthResponder>

@end

@implementation WMAccountPreferencesController

- (id)init
{
    if (self = [super initWithNibName:@"WMAccountPreferencesView" bundle:nil])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountAvatarUpdated:) name:kWeiboAccountAvatarDidUpdateNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)awakeFromNib
{
    [accountsTableView registerForDraggedTypes:[NSArray arrayWithObjects:kAccountTableViewDataType, nil]];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"AccountPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameUserAccounts];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Account", @"Toolbar item name for the Account preference pane");
}

#pragma mark -
#pragma mark Account TableView Delegate & Datasource

- (void)accountAvatarUpdated:(NSNotification *)notification
{
    [accountsTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    return [[[Weibo sharedWeibo] accounts] count];
}
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    WeiboAccount * account = [[[Weibo sharedWeibo] accounts] objectAtIndex:rowIndex];
    if ([[aTableColumn identifier] isEqualToString:@"avatar"]) {
        return account.profileImage;
    }else {
        return [[account user] screenName];
    }
}
- (BOOL)tableView:(NSTableView *)tableView shouldReorderColumn:(NSInteger)columnIndex toColumn:(NSInteger)newColumnIndex
{
    return NO;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn
{
    return NO;
}
// drag operation stuff
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard*)pboard {
    // Copy the row numbers to the pasteboard.
    NSData *zNSIndexSetData =
    [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:kAccountTableViewDataType]
                   owner:self];
    [pboard setData:zNSIndexSetData forType:kAccountTableViewDataType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv
                validateDrop:(id )info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)op {
    // Add code here to validate the drop
    if (op == NSTableViewDropOn)
    {
        return NSDragOperationNone;
    }
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView
       acceptDrop:(id )info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation {
    
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:kAccountTableViewDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger dragRow = [rowIndexes firstIndex];
    
    if (dragRow < row)
    {
        row--;
    }
    
    [[Weibo sharedWeibo] reorderAccountFromIndex:dragRow toIndex:row];
    [accountsTableView reloadData];
    
    return YES;
}


#pragma mark -
#pragma mark Accounts Management

- (void)removeAlertDidEnd:(NSAlert *)alert returnCode:(NSUInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn) {
        NSInteger index = [accountsTableView selectedRow];
        WeiboAccount * account = [[[Weibo sharedWeibo] accounts] objectAtIndex:index];
        [[Weibo sharedWeibo] removeAccount:account];
        [accountsTableView reloadData];
    }
}

- (IBAction)removeAccount:(id)sender
{
    NSInteger index = [accountsTableView selectedRow];
    if (index >= 0) {
        WeiboAccount * account = [[[Weibo sharedWeibo] accounts] objectAtIndex:index];
        
        NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Remove Account", nil) defaultButton:NSLocalizedString(@"Remove", nil) alternateButton:NSLocalizedString(@"Cancel", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Are you sure you want to remove \"%@\"?", nil),account.user.screenName];
        NSURL * imageURL = [NSURL URLWithString:account.user.profileImageUrl];
        NSImage* anImage = [[EGOImageLoader sharedImageLoader] imageForURL:imageURL shouldLoadWithObserver:nil];
        [alert setIcon:anImage];

        NSWindow * window = [self.view window];
        [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(removeAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
}

#pragma mark - Add Account

- (IBAction)addAccount:(id)sender
{
    self.addAccountPanel.defaultButtonCell = [self.addAccountButton cell];
    
    NSWindow * window = [self.view window];
    
    [NSApp beginSheet:self.addAccountPanel modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)cancelAddAccount:(id)sender
{
    [[NSApp delegate] endOAuthSession];
    [NSApp endSheet:self.addAccountPanel];
    [self.addAccountPanel orderOut:sender];
}

- (IBAction)loginButtonPressed:(id)sender
{
    [[NSApp delegate] startOAuthSessionWithResponder:self];
}

#pragma mark - OAuth Responder

- (NSWindow *)windowForOAuthModalAlert
{
    return self.addAccountPanel;
}

- (BOOL)shouldAddAccountWithAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID
{
    WeiboAccount * existAccount = [[Weibo sharedWeibo] accountWithUserID:userID];
    
    if (existAccount)
    {
        NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Account Exists", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"You cannot add the same account twice.", nil),existAccount.user.screenName];
        [alert runModal];
        return NO;
    }
    
    return YES;
}

- (void)willVerifyAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID
{
    [self.progressIndicator startAnimation:self];
    [self.addAccountButton setEnabled:NO];
    [self.cancelAccountAddButton setEnabled:NO];
}
- (void)finishedVerifingAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID error:(NSError *)error
{
    [self.progressIndicator stopAnimation:nil];
    [self.addAccountButton setEnabled:YES];
    [self.cancelAccountAddButton setEnabled:YES];
    
    if (error)
    {
        
    }
    else
    {
        [NSApp endSheet:self.addAccountPanel];
        [self.addAccountPanel orderOut:nil];
        [accountsTableView reloadData];
    }
}

@end
