//
//  WTControlPanel.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-8.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"

@protocol WTControlPanelDelegate;

@interface WTControlPanel : WUIView{
    TUITextRenderer * name;
    TUITextRenderer * text;
    
    TUIImageView * replyButton;
    TUIImageView * retweetButton;
    
    id<WTControlPanelDelegate> delegate;
    
    BOOL isMouseInSubView;
    BOOL isMouseInside;
}

@property (nonatomic, assign) id<WTControlPanelDelegate> delegate;

@end

@protocol WTControlPanelDelegate <NSObject>
@required
- (void)mouseEnteredControlPanel:(WTControlPanel *)panel;
- (void)mouseExitedControlPanel:(WTControlPanel *)panel;
@end
