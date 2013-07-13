//
//  WMUserProfileTableHeaderView.h
//  WeiboForMac
//
//  Created by 吴 天 on 12-8-26.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"
#import "WTUserViewController.h"

@interface WMUserProfileTableHeaderView : WUIView

@property (nonatomic, assign) WTUserViewController * userViewController;

- (void)setName:(NSString *)name;
- (void)setUserID:(NSString *)uid;
- (void)setLocation:(NSString *)location;
- (void)setAvatarURL:(NSString *)url;

@end
