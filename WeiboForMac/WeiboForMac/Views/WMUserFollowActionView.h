//
//  WMUserFollowActionView.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-4.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"

@class WeiboUser, TUIButton;

@protocol WMUserFollowActionViewDelegate <NSObject>
- (void)toggleFollow;
@property (readonly, nonatomic) BOOL isProcessingFollowAction;
@property (readonly, nonatomic) BOOL theyFollowMe;
@property (readonly, nonatomic) BOOL iFollowThem;
@property (readonly, nonatomic) BOOL didLoadFollowStatus;
@property (readonly, retain, nonatomic) WeiboUser * user;
@end

@interface WMUserFollowActionView : WUIView <TUIViewDelegate> {
    id <WMUserFollowActionViewDelegate> _delegate;
    TUIButton * followButton;
    TUIButton * menuButton;
}

@property (readonly, nonatomic) TUIButton * menuButton;
@property (readonly, nonatomic) TUIButton * followButton;
@property (assign, nonatomic) id <WMUserFollowActionViewDelegate> delegate;

+ (id)font;
+ (CGFloat)expectedWidth;
- (CGRect)leftRect;
- (CGRect)rightRect;
- (void)followAction:(id)sender;
- (void)update;
- (NSDictionary *)textAttributes;

@end
