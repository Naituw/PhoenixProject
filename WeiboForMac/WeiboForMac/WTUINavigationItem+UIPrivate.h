//
//  WTUINavigationItem+UIPrivate.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUINavigationItem.h"

@class WTUINavigationBar;

@interface WTUINavigationItem (UIPrivate)
- (void)_setNavigationBar:(WTUINavigationBar *)navigationBar;
- (WTUINavigationBar *)_navigationBar;
@end
