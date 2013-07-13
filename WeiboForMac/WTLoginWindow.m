//
//  WTLoginWindow.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-3.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTLoginWindow.h"
#import "WTCallback.h"
#import "ASIHTTPRequest.h"
#import "WeiboRequestError.h"
#import "Weibo.h"
#import "WeiboForMacAppDelegate.h"

@interface WTLoginWindow () <WMOAuthResponder>

@end

@implementation WTLoginWindow

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    if ((self = [super initWithWindowNibName:windowNibName]))
    {
        [[self window] setDefaultButtonCell:[signInButton cell]];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)signIn:(id)sender
{
    [[NSApp delegate] startOAuthSessionWithResponder:self];
}

- (IBAction)didSignUp:(id)sender
{
    NSURL * signUpUrl = [NSURL URLWithString:@"http://weibo.com/signup/signup.php"];
    [[NSWorkspace sharedWorkspace] openURL:signUpUrl];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (notification.object == self.window)
    {
        if (![WeiboForMacAppDelegate isUserLogined])
        {
            [[NSApplication sharedApplication] terminate:self];
        }
    }
}

#pragma mark - OAuth Responder

- (NSWindow *)windowForOAuthModalAlert
{
    return self.window;
}

- (BOOL)shouldAddAccountWithAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID
{
    WeiboAccount * existAccount = [[Weibo sharedWeibo] accountWithUserID:userID];
    
    if (existAccount)
    {
        // Account Existed, This should not happen.
        return NO;
    }
    
    return YES;
}

- (void)willVerifyAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID
{
    [signInButton setEnabled:NO];
    [spinner startAnimation:self];
}
- (void)finishedVerifingAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID error:(NSError *)error
{
    [signInButton setEnabled:YES];
    [spinner stopAnimation:self];
    
    if (error)
    {
        
    }
    else
    {
        [[self window] close];
        [[NSApp delegate] showMainWindow];
    }
}

@end
