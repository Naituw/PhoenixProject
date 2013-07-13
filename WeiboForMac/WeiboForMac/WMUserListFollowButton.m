//
//  WMUserListFollowButton.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-18.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMUserListFollowButton.h"

@implementation WMUserListFollowButton

- (NSString *)backgroundImageName
{
    NSString * imageName = @"button-bar-button";
    if (self.tracking)
    {
        imageName = @"button-bar-button-active";
    }
    else if (_flags.hovering)
    {
        imageName = @"toolbar-button-hover";
    }
    else if (self.followState == WMFollowButtonStateFollowing ||
             self.followState == WMFollowButtonStateFollowedEachother)
    {
        imageName = @"button-bar-button-active";
    }
    
    return imageName;
}

- (BOOL)whiteTextColor
{
    return NO;
}

@end
