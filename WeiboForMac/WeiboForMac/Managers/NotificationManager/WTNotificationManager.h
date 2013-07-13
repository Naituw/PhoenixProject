//
//  WTNotificationManager.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-1.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeiboAccount, WMRootViewController, WMMenu;

enum {
    WMStatusItemStateOff,
    WMStatusItemStateHalf,
    WMStatusItemStateOn,
};
typedef NSInteger WMStatusItemState;

@interface WTNotificationManager : NSObject <NSMenuDelegate> {
    NSStatusItem * statusItem;
    NSSound * alertSound;
    NSDate * lastNotificationDate;
    NSUInteger animationState;
    NSTimer * animationTimer;
    WMRootViewController * targetController;
    WMMenu * statusMenu;
}

@property (retain, nonatomic) NSTimer * animationTimer;
@property (assign, nonatomic) NSUInteger animationState;
@property (retain, nonatomic) NSDate * lastNotificationDate;
@property (assign, nonatomic) WMStatusItemState statusItemState;
@property (retain, nonatomic) NSStatusItem * statusItem;
@property (retain, nonatomic) NSSound * alertSound;

+ (id)sharedNotificationManager;
- (void)playAlertSound;
- (void)setDockIconWithCount:(NSUInteger)count;
- (void)showStatusMenu;
- (NSMenu *)menuForActiveAccounts;
- (void)showStatusItem;
- (void)updateForAccount:(WeiboAccount *)account;
- (void)updateStatusItemWithCurrentState;
- (void)setShowDockBadge:(BOOL)show;
- (void)updateBehavior;

@end
