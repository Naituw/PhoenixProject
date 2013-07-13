//
//  WTUINavigationBar+UIPrivate.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUINavigationBar.h"

@interface WTUINavigationBar (UIPrivate)
- (void)_updateNavigationItem:(WTUINavigationItem *)item animated:(BOOL)animated;
@end