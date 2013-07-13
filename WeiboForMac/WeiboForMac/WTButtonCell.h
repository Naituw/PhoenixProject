//
//  WTButtonCell.h
//  WTTabbarController
//
//  Created by Wu Tian on 11-8-20.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"

@interface WTButtonCell : TUITableViewCell {
    BOOL lighted;
    BOOL isDragging;
    BOOL isTracking;
    
    BOOL shouldShowGlow;
}

@property (assign) BOOL lighted;

- (void) setShouldShowGlow:(BOOL) show;

@end
