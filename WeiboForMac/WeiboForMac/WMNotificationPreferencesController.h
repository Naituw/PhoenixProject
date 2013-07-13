//
//  WMNotificationPreferencesController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-2.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "WeiboConstants.h"

@class WeiboAccount;

@interface WMNotificationPreferencesController : NSViewController 
<MASPreferencesViewController> {
    WeiboAccount * selectedAccount;
    IBOutlet NSPopUpButton *accountChooser;
    IBOutlet NSPopUpButton *newTweetsOptions;
    IBOutlet NSPopUpButton *newMentionsOptions;
    IBOutlet NSPopUpButton *newCommentsOptions;
    IBOutlet NSPopUpButton *newMessagesOptions;
    IBOutlet NSPopUpButton *newFollowersOptions;
}

- (IBAction)chooseAccount:(id)sender;
- (IBAction)chooseOption:(id)sender;
- (int)shiftForMenuItem:(NSMenuItem *)item;
//- (NSUInteger)optionsBitForMenuItem:(NSMenuItem *)item;

@end
