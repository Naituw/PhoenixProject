//
//  WTStatusTableView.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-23.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIKit.h"
#import "WTPullToRefreshTableView.h"

@class WTStatusListViewController, TUITextRenderer;

@interface WTStatusTableView : WTPullToRefreshTableView

@property (nonatomic, retain) TUITextRenderer * textRenderer;

@end
