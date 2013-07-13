//
//  WMFollowUserCell.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-18.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMFollowUserCell.h"
#import "WMUserListFollowButton.h"
#import "TUIView+ViewController.h"

@interface WMFollowUserCell ()

@property (nonatomic, retain) WMUserListFollowButton * followButton;

@end

@implementation WMFollowUserCell

- (void)dealloc
{
    [_followButton release], _followButton = nil;
    [super dealloc];
}

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.followButton = [WMUserListFollowButton buttonWithType:TUIButtonTypeCustom];
        [self.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:TUIControlEventTouchUpInside];

        [self addSubview:self.followButton];
    }
    return self;
}

- (CGFloat)accessoryViewWidth
{
    return self.isMe? 0 : 70;
}

- (void)setUser:(WeiboUser *)user
{
    [super setUser:user];
    
    WMFollowButtonState state = WMFollowButtonStateNotfollowed;
    if (user.following)
    {
        state = user.followMe ? WMFollowButtonStateFollowedEachother : WMFollowButtonStateFollowing;
    }
    [self.followButton setFollowState:state];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.followButton.hidden = self.isMe;
    
    if (!self.isMe)
    {
        CGSize buttonSize = CGSizeMake(60, 24);
        CGRect buttonRect = CGRectGetCenterRect(self.bounds, buttonSize);
        self.followButton.frame = buttonRect;
        self.followButton.right = self.width - 11;
    }
}

- (void)followButtonPressed:(id)sender
{
    TUIViewController * controller = [self firstAvailableViewController];
    
    if ([controller respondsToSelector:@selector(userCell:didPressFollowButton:)])
    {
        [controller performSelector:@selector(userCell:didPressFollowButton:) withObject:self withObject:sender];
    }
}

@end
