//
//  WTUINavigationBar.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUIToolBar.h"
#import "TUIView.h"

@class TUIColor, WTUINavigationItem, WTUINavigationBar;

@protocol WTUINavigationBarDelegate <NSObject>
@optional
- (BOOL)navigationBar:(WTUINavigationBar *)navigationBar shouldPushItem:(WTUINavigationItem *)item;
- (void)navigationBar:(WTUINavigationBar *)navigationBar didPushItem:(WTUINavigationItem *)item;
- (BOOL)navigationBar:(WTUINavigationBar *)navigationBar shouldPopItem:(WTUINavigationItem *)item;
- (void)navigationBar:(WTUINavigationBar *)navigationBar didPopItem:(WTUINavigationItem *)item;
@end

@interface WTUINavigationBar : WUIView {
@private
    NSMutableArray *_navStack;
    TUIColor *_tintColor;
    __unsafe_unretained id _delegate;
    
    TUIView *_leftView;
    TUIView *_centerView;
    TUIView *_rightView;
    
    struct {
        BOOL shouldPushItem : 1;
        BOOL didPushItem : 1;
        BOOL shouldPopItem : 1;
        BOOL didPopItem : 1;
    } _delegateHas;
    
    // ideally this should share the same memory as the above flags structure...
    struct {
        unsigned reloadItem : 1;
        unsigned __RESERVED__ : 31;
    } _navigationBarFlags;
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated;
- (void)setItemWithFade:(WTUINavigationItem *)item;
- (void)pushNavigationItem:(WTUINavigationItem *)item animated:(BOOL)animated;
- (WTUINavigationItem *)popNavigationItemAnimated:(BOOL)animated;

@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, retain) TUIColor *tintColor;
@property (nonatomic, readonly, retain) WTUINavigationItem *topItem;
@property (nonatomic, readonly, retain) WTUINavigationItem *backItem;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, assign) id delegate;

@end
