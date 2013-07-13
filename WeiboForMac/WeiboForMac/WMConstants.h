//
//  WMConstants.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-1.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#define kStreamViewDidReachTopNotification @"StreamViewDidReachTopNotification"
#define kWindowSheetPositionRect @"kWindowSheetPositionRect"

typedef enum {
    WTSideBarNot = (int)-1,
    WTSideBarFriends = (int)0,
    WTSideBarMention = (int)1,
    WTSideBarComment = (int)2,
    WTSideBarMessage = (int)3,
    WTSideBarProfile = (int)4,
    WTSideBarSearch  = (int)5,
} WTSideBarItem;