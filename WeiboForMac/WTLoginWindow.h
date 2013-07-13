//
//  WTLoginWindow.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-3.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WTLoginWindow : NSWindowController <NSWindowDelegate>{
    
    IBOutlet NSButton    * signInButton;
    
    IBOutlet NSProgressIndicator * spinner;
}

- (IBAction)didSignUp:(id)sender;
- (IBAction)signIn:(id)sender;

@end
