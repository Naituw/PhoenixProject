//
//  WTUINavigationItem.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTUIBarButtonItem, TUIView, WTUINavigationBar;

@interface WTUINavigationItem : NSObject {
@private
    NSString *_title;
    NSString *_prompt;
    WTUIBarButtonItem *_backBarButtonItem;
    WTUIBarButtonItem *_leftBarButtonItem;
    WTUIBarButtonItem *_rightBarButtonItem;
    TUIView *_titleView;
    BOOL _hidesBackButton;
    WTUINavigationBar *_navigationBar;
}

- (id)initWithTitle:(NSString *)title;
- (void)setLeftBarButtonItem:(WTUIBarButtonItem *)item animated:(BOOL)animated;
- (void)setRightBarButtonItem:(WTUIBarButtonItem *)item animated:(BOOL)animated;
- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, retain) WTUIBarButtonItem *backBarButtonItem;
@property (nonatomic, retain) WTUIBarButtonItem *leftBarButtonItem;
@property (nonatomic, retain) WTUIBarButtonItem *rightBarButtonItem;
@property (nonatomic, retain) TUIView *titleView;
@property (nonatomic, assign) BOOL hidesBackButton;

@end
