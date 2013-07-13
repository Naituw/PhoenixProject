//
//  WMFollowButton.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-14.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "TUIButton.h"

typedef enum {
    WMFollowButtonStateUnknow,
    WMFollowButtonStateFollowing,
    WMFollowButtonStateNotfollowed,
    WMFollowButtonStateFollowedEachother,
} WMFollowButtonState;

@interface WMFollowButton : TUIButton
{
    struct {
        unsigned int hovering:1;
    } _flags;
}

@property (nonatomic, assign) WMFollowButtonState followState;

@end
