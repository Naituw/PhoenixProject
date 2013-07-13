//
//  WTStatusCell.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-1.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"
#import "WTHeadImageView.h"
#import "WTThumbPicView.h"
#import "WTTextRenderer.h"
#import "WTControlPanel.h"
#import "WMStatusImageContentView.h"

@class WeiboBaseStatus, WTStatusListViewController;

@interface WTStatusCell : TUITableViewCell <TUIViewDelegate, TUITextRendererDelegate, WTTextRendererClickDelegate>
{
    WTHeadImageView * avatar;
    TUITextRenderer * name;
    WTTextRenderer * content;
    
    TUITextRenderer * time;
    WTControlPanel * panel;
    
    TUIView * controls;
    TUIButton *reply;
    TUIButton *retweet;
    TUIButton *viewPic;
    TUIButton *viewComment;
    
    WeiboBaseStatus * status;
    
    WTStatusListViewController * _controller;
    
    struct {
		unsigned int isMouseInside:1;
        unsigned int isMouseInSubView:1;
        unsigned int superBlue:1;
        unsigned int isRightMouseDown:1;
        unsigned int drawInBackgroundNextTime:1;
	} _cellFlags;
}

@property (retain) WTHeadImageView  * avatar;
@property (nonatomic , retain) TUITextRenderer * name;
@property (nonatomic , retain) WTTextRenderer  * content;
@property (nonatomic , retain) WTTextRenderer  * quotedContent;
@property (nonatomic , retain) WMStatusImageContentView * imageContentView;
@property (nonatomic , retain) TUITextRenderer * time;
@property (nonatomic , retain) WeiboBaseStatus * status;
@property (nonatomic , assign) WTStatusListViewController * controller;

- (void)forceToTakeMouseOut;
- (void)setWasSeened;

- (IBAction)viewWeiboSourceApp:(id)sender;
- (IBAction)deleteWeibo:(id)sender;
- (IBAction)viewPhoto:(id)sender;
- (IBAction)viewReplies:(id)sender;
- (IBAction)reply:(id)sender;
- (IBAction)repost:(id)sender;
- (IBAction)viewUserDetails:(id)sender;
- (IBAction)viewOnWebPage:(id)sender;
- (IBAction)viewActiveRange:(id)sender;

@end
