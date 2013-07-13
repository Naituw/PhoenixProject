//
//  WTTitleView.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-9-1.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIView.h"

@class TUIButton;

@interface WTTitleView : WUIView {
    BOOL drawsAsMainWindow;
    
    NSPoint initialLocation;
    
    BOOL isExpanded;
    
}

@property (readwrite , assign) BOOL isExpanded;

- (void)redrawWithActive:(BOOL)active;

@end
