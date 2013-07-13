//
//  WTUserToolbarView.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-26.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"

@class TUITextRenderer, WTUserViewController;

@interface WTUserToolbarView : WUIView

- (void)setName:(NSString *)name;
- (void)setAvatarImageURL:(NSString *)url;

@end
