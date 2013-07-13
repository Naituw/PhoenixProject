//
//  WTTokenRefreshPanel.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WeiboAccount;

@interface WTTokenRefreshPanel : NSWindowController {
    IBOutlet NSTextField * username;
    IBOutlet NSTextField * userID;
    
    IBOutlet NSImageView * avatar;
    IBOutlet NSButton * refreshButton;
    IBOutlet NSButton * removeButton;
    IBOutlet NSProgressIndicator * spinner;
}

@property(retain, nonatomic) WeiboAccount * account;

- (id)init;

- (IBAction)removeAccount:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)viewHelp:(id)sender;

@end
