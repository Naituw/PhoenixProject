//
//  WTUIViewController.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIViewController.h"

@class WTUINavigationItem, WTUINavigationController;

@interface WTUIViewController : TUIViewController <NSCoding> {
    NSString *_title;
    WTUINavigationItem *_navigationItem;
    NSArray *_toolbarItems;
    CGSize _contentSizeForViewInPopover;
}

@property (nonatomic, copy) NSString *title;
@property(readonly, retain, nonatomic) WTUINavigationItem *navigationItem;
@property (nonatomic, readonly, retain) WTUINavigationController *navigationController;
@property (nonatomic, retain) NSArray *toolbarItems;
@property (nonatomic, readwrite) CGSize contentSizeForViewInPopover;

@property (nonatomic, assign) CGRect initialBounds;
@property (nonatomic, retain) NSString * windowIdentifier;

- (void)setNeedsRelayout;
- (void)relayout;
- (void)relayoutIfNeeded;

/**
 * @note append a column shadow to the right edge of controller view.
 */
- (void)appendBoxShadow;
/**
 * @note remove the shadow on the right edge of controller view if exist.
 */
- (void)removeBoxShadow;
- (BOOL)boxShadowAppended;

@end
