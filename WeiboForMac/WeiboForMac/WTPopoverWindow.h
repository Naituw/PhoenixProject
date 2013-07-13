//
//  WTPopoverWindow.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-13.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "SFBPopoverWindow.h"
#import <WebKit/WebKit.h>

@interface WTPopoverWindow : SFBPopoverWindow {
    WebView * webView;
    NSButton * saveButton;
}

@end
