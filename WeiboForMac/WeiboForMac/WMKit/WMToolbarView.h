//
//  WMToolbarView.h
//  WeiboForMac
//
//  Created by 吴 天 on 12-11-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"
#import "WTWebImageView.h"

@interface WMToolbarView : WUIView

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain, readonly) WTWebImageView * imageView;
@property (nonatomic, assign) BOOL backButtonHidden;

- (void)setBackButtonTarget:(id)target action:(SEL)selector;

@end
