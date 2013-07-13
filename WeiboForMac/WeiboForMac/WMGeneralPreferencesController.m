//
//  WMGeneralPreferencesController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-2.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMGeneralPreferencesController.h"
#import "WeiboForMacAppDelegate.h"
#import "WKHotKeyAssignment.h"
#import "DDHotKeyCenter.h"

#define kHotKeyDefaultsPrefix @"GlobalHotKey-"

@implementation WMGeneralPreferencesController

- (id)init
{
    return [super initWithNibName:@"WMGeneralPreferencesView" bundle:nil];
}
- (void)dealloc{
    [super dealloc];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (void)viewWillAppear{
    [self restoreKeyCombos];    
    id behaviorObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"MenuItemBehavior"];
    NSInteger behavior = behaviorObject?[behaviorObject integerValue]:0;
    [menuBehaviorChooser selectItemAtIndex:behavior];
}

- (void)saveKetCombo:(KeyCombo)newKeyCombo forHotKeyName:(NSString *)name{
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:newKeyCombo.flags],@"flags",[NSNumber numberWithInteger:newKeyCombo.code],@"code", nil];
    NSString * nameString = [NSString stringWithFormat:@"%@%@",kHotKeyDefaultsPrefix,name];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:nameString];
}
- (KeyCombo)restoreKeyComboWithHotKeyName:(NSString *)name{
    NSString * nameString = [NSString stringWithFormat:@"%@%@",kHotKeyDefaultsPrefix,name];
    NSDictionary * dic = [[NSUserDefaults standardUserDefaults] objectForKey:nameString];
    KeyCombo keyCombo;
    if (![dic isKindOfClass:[NSDictionary class]]) {
        keyCombo.code = -1;
        keyCombo.flags = 0;
        return keyCombo;
    }
    keyCombo.code = [[dic objectForKey:@"code"] integerValue];
    keyCombo.flags = [[dic objectForKey:@"flags"] longValue];
    return keyCombo;
}
- (void)restoreKeyCombos{
    [showAppRecorder setKeyCombo:[self restoreKeyComboWithHotKeyName:@"show-app-combo"]];
    [newWeiboRecorder setKeyCombo:[self restoreKeyComboWithHotKeyName:@"new-weibo-combo"]];
}

#pragma mark -
#pragma mark SRRecorder delegate methods

//- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
//{
////	return NO;
//}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
    WeiboForMacAppDelegate * target = [WeiboForMacAppDelegate currentDelegate];
    if (aRecorder == newWeiboRecorder) {
        [target.hotKeyCenter unregisterHotKeysWithTarget:target action:@selector(compose:)];
        [self saveKetCombo:newKeyCombo forHotKeyName:@"new-weibo-combo"];
        [target.hotKeyCenter registerHotKeyWithKeyCode:newKeyCombo.code modifierFlags:newKeyCombo.flags target:target action:@selector(compose:) object:nil];
    }else if (aRecorder == showAppRecorder) {
        [target.hotKeyCenter unregisterHotKeysWithTarget:target action:@selector(toggleMainWindow:)];
        [self saveKetCombo:newKeyCombo forHotKeyName:@"show-app-combo"];
        [target.hotKeyCenter registerHotKeyWithKeyCode:newKeyCombo.code modifierFlags:newKeyCombo.flags target:target action:@selector(toggleMainWindow:) object:nil];
    }
}


- (IBAction)updateStatusBarItemBehavior:(id)sender{
    [[WeiboForMacAppDelegate currentDelegate] updateMenuItemBehavior:sender];
}

@end
