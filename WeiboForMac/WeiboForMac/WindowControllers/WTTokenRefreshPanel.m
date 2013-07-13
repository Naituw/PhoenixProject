//
//  WTTokenRefreshPanel.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTTokenRefreshPanel.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"
#import "TUIImage.h"
#import "EGOImageLoader.h"
#import "WTEventHandler.h"
#import "WTCallback.h"
#import "Weibo.h"
#import "WeiboRequestError.h"
#import "WeiboForMacAppDelegate.h"

@interface WTTokenRefreshPanel ()<WMOAuthResponder>

@end

@implementation WTTokenRefreshPanel
@synthesize account = _account;

- (void)dealloc{
    [_account release];
    [super dealloc];
}
- (id)init
{
    if (self = [super initWithWindowNibName:@"WTTokenRefreshPanel"])
    {
        [self.window setDefaultButtonCell:[refreshButton cell]];
    }
    return self;
}
- (void)setAccount:(WeiboAccount *)account{
    [account retain];
    [_account release];
    _account = account;
    
    if (account) {
        NSURL * imageURL = [NSURL URLWithString:account.user.profileImageUrl];
        /*
        NSImage* anImage = [[EGOImageLoader sharedImageLoader] imageForURL:imageURL shouldLoadWithObserver:nil];
        [avatar setImage:anImage];
         */
        [[EGOImageLoader sharedImageLoader] loadImageForURL:imageURL completion:^(NSData *imageData, NSURL *imageURL, NSError *error) {
            [avatar setImage:[[[NSImage alloc] initWithData:imageData] autorelease]];
        }];
        
        username.stringValue = self.account.user.screenName;
        userID.stringValue = [NSString stringWithFormat:@"%lld",self.account.user.userID];
    }
}


- (IBAction)removeAccount:(id)sender
{
    [[NSApp delegate] endOAuthSession];
    
    [[Weibo sharedWeibo] removeAccount:self.account];
    self.account = nil;
    [NSApp endSheet:self.window returnCode:0];
}
- (IBAction)refresh:(id)sender
{
    [[NSApp delegate] startOAuthSessionWithResponder:self];
}

- (IBAction)viewHelp:(id)sender
{
    [WTEventHandler openURL:@"http://open.weibo.com/wiki/Oauth2#.E8.BF.87.E6.9C.9F.E6.97.B6.E9.97.B4"];
}

#pragma mark - OAuth Responder

- (NSWindow *)windowForOAuthModalAlert
{
    return self.window;
}

- (BOOL)shouldAddAccountWithAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)aUserID
{
    if (aUserID != self.account.user.userID)
    {
        NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Wrong Account", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Please sign in the account waiting for renew.", nil)];
        [alert runModal];
        
        return NO;
    }
    
    return YES;
}

- (void)willVerifyAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID
{
    [spinner startAnimation:self];
    [removeButton setEnabled:NO];
    [refreshButton setEnabled:NO];
}
- (void)finishedVerifingAccessToken:(NSString *)accessToken forUserID:(WeiboUserID)userID error:(NSError *)error
{
    [refreshButton setEnabled:YES];
    [removeButton setEnabled:YES];
    [spinner stopAnimation:self];
    
    if (error)
    {
        
    }
    else
    {
        [NSApp endSheet:self.window returnCode:1];
    }
}

@end
