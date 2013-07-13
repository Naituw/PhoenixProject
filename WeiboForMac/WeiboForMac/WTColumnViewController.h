//
//  WTColumnViewController.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-8.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUINavigationController.h"
#import "WTUINavigationBar.h"

@interface WTColumnViewController : WTUINavigationController <NSWindowDelegate, WTUINavigationBarDelegate> {
}


- (BOOL)isRoot:(WTUIViewController *)controller;

@end
