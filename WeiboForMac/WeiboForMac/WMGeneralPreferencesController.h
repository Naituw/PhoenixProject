//
//  WMGeneralPreferencesController.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-2.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "SRRecorderControl.h"

@class DDHotKeyCenter;

@interface WMGeneralPreferencesController : NSViewController 
<MASPreferencesViewController> {
    IBOutlet SRRecorderControl *showAppRecorder;
    IBOutlet SRRecorderControl *newWeiboRecorder;
    IBOutlet NSPopUpButton *menuBehaviorChooser;
}

- (void)restoreKeyCombos;
- (IBAction)updateStatusBarItemBehavior:(id)sender;

@end
