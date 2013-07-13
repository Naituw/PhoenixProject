//
//  WMNotificationPreferencesController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-2.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMNotificationPreferencesController.h"
#import "Weibo.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"
#import "EGOImageLoader.h"

#define kNotificationOptionIndexOfItemAll 4
#define kNotificationOptionIndexOfItemNone 5

@implementation WMNotificationPreferencesController

- (id)init
{
    return [super initWithNibName:@"WMNotificationPreferencesView" bundle:nil];
}

- (void)_updateDropdown:(NSPopUpButton *)dropdown opts:(WeiboNotificationOptions)options{
    NSMenu * dropdownMenu = [dropdown menu];
    NSArray * itemArray = [dropdownMenu itemArray];
    NSMenuItem * firstItem = [itemArray objectAtIndex:1];
    NSMenuItem * secondItem = [itemArray objectAtIndex:2];
    NSMenuItem * allItem = [itemArray objectAtIndex:kNotificationOptionIndexOfItemAll];
    NSMenuItem * noneItem = [itemArray objectAtIndex:kNotificationOptionIndexOfItemNone];
    int shift = [self shiftForMenuItem:firstItem];
    
    NSString *title;
    [firstItem setState:(options & (1 << shift))?NSOnState:NSOffState];
    [secondItem setState:(options & (1 << (shift + 1)))?NSOnState:NSOffState];

    if (firstItem.state + secondItem.state == 2*NSOnState) {
        [allItem setState:NSOnState];
        [noneItem setState:NSOffState];
        title = NSLocalizedString(@"Status Bar, Dock", nil);
    }else if (firstItem.state + secondItem.state == 2*NSOffState) {
        [noneItem setState:NSOnState];
        [allItem setState:NSOffState];
        title = NSLocalizedString(@"None", nil);
    }else {
        [allItem setState:NSOffState];
        [noneItem setState:NSOffState];
        if (firstItem.state == NSOnState) {
            title = NSLocalizedString(@"Status Bar", nil);
        }else {
            title = @"Dock";
        }
    }
    [dropdown setTitle:title];
}
- (void)updateDropdowns{
    WeiboNotificationOptions options = [selectedAccount notificationOptions];
    [self _updateDropdown:newTweetsOptions opts:options];
    [self _updateDropdown:newMentionsOptions opts:options];
    [self _updateDropdown:newCommentsOptions opts:options];
    [self _updateDropdown:newMessagesOptions opts:options];
    [self _updateDropdown:newFollowersOptions opts:options];
}
- (IBAction)chooseAccount:(id)sender{
    NSInteger index = [accountChooser indexOfSelectedItem];
    if (index < [[[Weibo sharedWeibo] accounts] count]) {
        selectedAccount = [[[Weibo sharedWeibo] accounts] objectAtIndex:index];
        [self updateDropdowns];
    }
}
- (IBAction)chooseOption:(id)sender{
    NSPopUpButton * button = sender;
    NSMenuItem * selectedItem = [button selectedItem];
    NSInteger selectedIndex = [selectedItem.menu indexOfItem:selectedItem];
    int shift = [self shiftForMenuItem:selectedItem];
    WeiboNotificationOptions options = [selectedAccount notificationOptions];
    if (selectedIndex == kNotificationOptionIndexOfItemAll) {
        // Set all bit in group.
        options |= 1 << shift;
        options |= 1 << (shift + 1);
    } else if (selectedIndex == kNotificationOptionIndexOfItemNone) {
        // Clear all bit in group.
        options &= ~(1 << shift);
        options &= ~(1 << (shift + 1));
    } else {
        // Toggle selected bit.
        options ^= 1 << shift;
    }
    [selectedAccount setNotificationOptions:options];
    [self _updateDropdown:button opts:options];
}


- (int)shiftForMenuItem:(NSMenuItem *)item{
    NSInteger popupIndex = item.tag;
    NSInteger itemIndex = [item.menu indexOfItem:item] - 1;
    if (itemIndex != 1) {
        itemIndex = 0;
    }
    return (int)(2*popupIndex + itemIndex);
}

/*
- (NSUInteger)optionsBitForMenuItem:(NSMenuItem *)item{
    NSInteger itemIndex = [item.menu indexOfItem:item];
    int shift = [self shiftForMenuItem:item];
    if (itemIndex == kNotificationOptionIndexOfItemAll) {
        // Selected All.
        return (1 << shift) || (1 << (shift + 1));
    }else if (itemIndex == kNotificationOptionIndexOfItemNone) {
        // Selected None.
        return 0;
    }else {
        // Other
        return (1 << shift);
    }
}*/

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"NotificationPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"NotificationPrefs"];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Notification", @"Toolbar item name for the Notification preference pane");
}

#pragma mark - 
#pragma mark NSViewController
- (void)viewWillAppear{
    [accountChooser removeAllItems];
    
    for (WeiboAccount * account in [[Weibo sharedWeibo] accounts]) {
        [accountChooser addItemWithTitle:account.user.screenName];
        NSMenuItem * item = [[accountChooser itemArray] lastObject];
        NSURL * imageURL = [NSURL URLWithString:account.user.profileImageUrl];
        NSImage* anImage = [[EGOImageLoader sharedImageLoader] imageForURL:imageURL shouldLoadWithObserver:nil];
        
        CGFloat resizeWidth = 15.0, resizeHeight = 15.0;
        NSImage *sourceImage = anImage;
        NSImage *resizedImage = [[NSImage alloc] initWithSize: NSMakeSize(resizeWidth, resizeHeight)];
        NSSize originalSize = [sourceImage size];
        [resizedImage lockFocus];
        [sourceImage drawInRect: NSMakeRect(0, 0, resizeWidth, resizeHeight) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
        [resizedImage unlockFocus];
        if (anImage) {
            [item setImage:resizedImage];
        }
        [resizedImage release];
    }
    
    if (!selectedAccount) {
        [self chooseAccount:[[Weibo sharedWeibo] defaultAccount]];
    }
}


@end
