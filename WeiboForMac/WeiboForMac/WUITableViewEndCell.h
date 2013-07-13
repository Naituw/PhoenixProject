//
//  WUITableViewEndCell.h
//  WeiboForMac
//
//  Created by Wutian on 13-5-30.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "TUITableViewCell.h"
#import "WeiboRequestError.h"

@interface WUITableViewEndCell : TUITableViewCell

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL isEnded;
@property (nonatomic, retain) WeiboRequestError * error;

@end
