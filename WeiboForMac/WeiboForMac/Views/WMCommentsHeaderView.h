//
//  WMCommentsHeaderView.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-13.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"

@class WTHeadImageView;

@interface WMCommentsHeaderView : WUIView {
    WTHeadImageView * avatar;
    TUITextRenderer * content;
}

@property (readonly, nonatomic) WTHeadImageView * avatar;
@property (readonly, nonatomic) TUITextRenderer * content;

@end
