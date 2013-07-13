//
//  WMAccountPreferencesController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-2.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface WMAccountPreferencesController : NSViewController 
<MASPreferencesViewController, NSTableViewDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView * accountsTableView;
}

@property (assign) IBOutlet NSPanel *addAccountPanel;
@property (assign) IBOutlet NSButton *addAccountButton;
@property (assign) IBOutlet NSButton *cancelAccountAddButton;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)removeAccount:(id)sender;
- (IBAction)addAccount:(id)sender;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)cancelAddAccount:(id)sender;

@end
