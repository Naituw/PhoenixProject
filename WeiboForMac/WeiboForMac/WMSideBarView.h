//
//  WMSideBarView.h
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"

@protocol WMSidebarViewDelegate;

@class TUIFastIndexPath, TUIScrollView, TUIButton;

@interface WMSideBarView : WUIView
{
    TUIScrollView *scrollView;
    TUIButton *composeButton;
    TUIButton *menuButton;
}

@property (nonatomic, assign) id <WMSidebarViewDelegate> delegate;
@property (nonatomic, readonly) TUIFastIndexPath * selectedIndexPath;

/**
 * @brief Generate item views 
 * Alloc section views and item views, set it's initial frame
 * and attributes (imageName, tooltip, etc..)
 * will call reloadData once.
 * @return none
 */
- (void)reset;

/**
 * @brief Reloading sort of attributes 
 * reload badge, and animate items to new position if needed.
 * @return none
 */
- (void)reloadData;

@end

@protocol WMSidebarViewDelegate <NSObject>
@required
- (TUIImage *)sidebarView:(WMSideBarView *)sideBar imageForSection:(NSInteger)section;
- (TUIImage *)sidebarView:(WMSideBarView *)sideBar imageForRow:(NSInteger)row;
- (NSString *)sidebarView:(WMSideBarView *)sideBar imageNameForRow:(NSInteger)row;
- (NSString *)sidebarView:(WMSideBarView *)sideBar titleForRow:(NSInteger)row;
- (NSString *)sidebarView:(WMSideBarView *)sideBar titleForSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInSidebarView:(WMSideBarView *)sideBar;
- (NSInteger)sideBarView:(WMSideBarView *)sideBar numberOfItemsInSection:(NSInteger)section;
- (NSInteger)sideBarView:(WMSideBarView *)sideBar badgeForSection:(NSUInteger)section;
- (NSInteger)sideBarView:(WMSideBarView *)sideBar badgeForRow:(NSInteger)row;
- (TUIFastIndexPath *)selectedRowInSidebarView:(WMSideBarView *)sideBar;
@optional
- (BOOL)sidebarView:(WMSideBarView *)sideBar shouldSelectRow:(NSInteger)row;
- (void)sidebarView:(WMSideBarView *)sideBar didSelectSection:(NSInteger)section;
- (void)sidebarView:(WMSideBarView *)sideBar didSelectRow:(NSInteger)row;
- (void)sidebarView:(WMSideBarView *)sideBar didClickShouldNotSelectRow:(NSInteger)row;
- (void)sidebarView:(WMSideBarView *)sideBar doubleClickedRow:(NSInteger)row;
- (void)sidebarView:(WMSideBarView *)sideBar doubleClickedSection:(NSInteger)section;

- (void)sidebarView:(WMSideBarView *)sideBar didClickComposeButton:(TUIButton *)button;
- (void)sidebarView:(WMSideBarView *)sideBar didClickMenuButton:(TUIButton *)button;

@end
