//
//  WTTabViewController.h
//  WTTabbarController
//
//  Created by Wu Tian on 11-8-20.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"
#import "WTDragableTableView.h"
#import "WTSectionAvatarView.h"
#import "WMConstants.h"
#import "EGOImageLoader.h"


@protocol WTTabViewDelegate;

@interface WTTabViewController : WUIView
<TUITableViewDelegate, TUITableViewDataSource, EGOImageLoaderObserver>{
    WTDragableTableView * tabView;
    NSUInteger selectedTab;
    
    TUIImage * avatarImage;
    WTSectionAvatarView * sectionView;
    
    TUIButton * composeButton;
    TUIButton * dropdownButton;
    
    NSURL * profileImageURL;
    
    id <WTTabViewDelegate> _delegate;
    struct {
        BOOL didChangeSelect : 1;
        BOOL didClickSelected : 1;
        BOOL shouldSelectTab : 1;
        BOOL didClickShouldNotSelect: 1;
    } _delegateHas;
}

@property (nonatomic , assign) TUIImage * avatarImage;
@property (nonatomic , assign) id <WTTabViewDelegate> delegate;
@property (nonatomic , assign) NSUInteger selectedTab;
@property (nonatomic , readonly) TUIButton * dropdownButton;

- (void) setTabAtIndex:(NSUInteger)index shouldShowGlow:(BOOL) show;
- (void) clickTabAtIndex:(NSUInteger)index;
- (TUIFastIndexPath *)selectedIndexPath;
- (void)compose:(id)sender;

@end


@protocol WTTabViewDelegate <NSObject>
@required
- (void) sideBar:(WTTabViewController *)sideBar didChangeSelectionToTab:(WTSideBarItem)tab;
- (void) sideBar:(WTTabViewController *)sideBar didClickSelectedTab:(WTSideBarItem)tab;
- (void) sideBar:(WTTabViewController *)sideBar didClickOnShouldNotSelectTab:(WTSideBarItem)tab;
- (BOOL) sideBar:(WTTabViewController *)sideBar shouldSelectTab:(WTSideBarItem)tab;

@end