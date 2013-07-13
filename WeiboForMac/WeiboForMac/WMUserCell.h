//
//  WMUserCell.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-18.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "TUITableViewCell.h"
#import "WeiboUser.h"

@interface WMUserCell : TUITableViewCell

@property (nonatomic, retain) WeiboUser * user;

@property (nonatomic, assign) BOOL isMe;

- (CGFloat)accessoryViewWidth;

@end
