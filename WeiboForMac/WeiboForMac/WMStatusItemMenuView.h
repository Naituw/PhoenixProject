//
//  WMStatusItemMenuView.h
//  WeiboForMac
//
//  Created by 吴 天 on 12-9-2.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TUITableView.h"

@class WeiboAccount;

@protocol WMStatusItemMenuViewDelegate;

@interface WMStatusItemMenuView : NSView <TUITableViewDataSource, TUITableViewDelegate>

@property (nonatomic, assign) id<WMStatusItemMenuViewDelegate> delegate;

+ (CGFloat)defaultWidth;
- (CGFloat)contentHeight;

- (void)reloadData;
- (void)sizeToFit;

@end

@protocol WMStatusItemMenuViewDelegate <NSObject>

- (BOOL)menuView:(WMStatusItemMenuView *)menuView shouldHighlightImageAtIndex:(NSInteger)index forAccount:(WeiboAccount *)account;
- (void)menuView:(WMStatusItemMenuView *)menuView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath
;

@end