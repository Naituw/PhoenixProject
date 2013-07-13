//
//  WeiboForMacApp.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WeiboForMacApp : NSApplication

- (void)relaunchAfterDelay:(CGFloat)seconds;
- (IBAction)terminate:(id)sender;

@end
