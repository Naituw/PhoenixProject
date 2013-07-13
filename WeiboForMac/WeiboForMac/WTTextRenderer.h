//
//  WTTextRenderer.h
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-7.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"

@class WTTextRenderer;

@protocol WTTextRendererClickDelegate <NSObject>

- (void)textRenderer:(WTTextRenderer *)renderer didClickActiveRange:(ABFlavoredRange *)activeRange;

@end

@interface WTTextRenderer : TUITextRenderer

@property (nonatomic, assign) id<WTTextRendererClickDelegate> clickDelegate;

@end