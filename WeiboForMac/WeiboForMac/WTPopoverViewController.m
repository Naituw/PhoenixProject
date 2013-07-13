//
//  WTPopoverViewController.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-12.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTPopoverViewController.h"
#import "WTPopoverWindow.h"

static WTPopoverViewController * sharedController = nil;

@implementation WTPopoverViewController
@synthesize webView;

+ (WTPopoverViewController *) shared{
    if (!sharedController) {
        WTPopoverWindow * popoverWindow = [[WTPopoverWindow alloc] init];
        sharedController = [[[self class] alloc] initWithWindow:popoverWindow];
        [popoverWindow release];
    }
    return sharedController;
}

- (id)initWithWindow:(NSWindow *)window{
    if ((self = [super initWithWindow:window])) {
        sharedController.animates = YES;
        sharedController.closesWhenPopoverResignsKey = YES;
        sharedController.closesWhenApplicationBecomesInactive = YES;
        //[sharedController closePopover:nil];
        sharedController.popoverWindow.popoverPosition = SFBPopoverPositionRight;
        sharedController.popoverWindow.popoverBackgroundColor = [NSColor colorWithDeviceWhite:0.95 alpha:0.95];
        sharedController.popoverWindow.borderColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.3];
        [sharedController.popoverWindow setFrame: NSMakeRect(0, 0, 475, 330) display:NO];
        sharedController.popoverWindow.borderWidth = 8.0;
        sharedController.popoverWindow.arrowWidth = 30.0;
        
        NSRect webRect = NSMakeRect(0, 0, 455, 290);
        webView = [[WebView alloc] initWithFrame:webRect];
        [webView setAutoresizingMask:(NSViewHeightSizable)];
        [webView setDrawsBackground:NO];
        [[[sharedController window] contentView] addSubview:sharedController.webView];
    }
    return self;
}

- (void)dealloc{
    [webView release];
    [super dealloc];
}

- (BOOL)showImageWithUrlString:(NSString *)urlString{
    NSURL * url = [NSURL URLWithString:urlString];
    [webView.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
    
    return YES;
}

@end