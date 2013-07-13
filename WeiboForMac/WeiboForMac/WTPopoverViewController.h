//
//  WTPopoverViewController.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-12.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "SFBPopoverWindowController.h"
#import <WebKit/WebKit.h>

@interface WTPopoverViewController : SFBPopoverWindowController {
    WebView * webView;
}

@property (assign) WebView * webView;

+ (WTPopoverViewController *) shared;
- (BOOL)showImageWithUrlString:(NSString *)url;
@end
