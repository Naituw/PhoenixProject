//
//  WTTabViewController.m
//  WTTabbarController
//
//  Created by Wu Tian on 11-8-20.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTTabViewController.h"
#import "WTButtonCell.h"
#import "WTComposeWindowController.h"
#import "Weibo.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"

@implementation WTTabViewController
@synthesize avatarImage , delegate = _delegate, selectedTab, dropdownButton;

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
        CGRect tabViewRect = frame;
        tabViewRect.origin.y += 24;
        tabViewRect.size.height -= 24;
        tabView = [[WTDragableTableView alloc] initWithFrame:tabViewRect style:TUITableViewStylePlain];
        tabView.autoresizingMask = (TUIViewAutoresizingFlexibleHeight);
        tabView.alwaysBounceVertical = YES;
        tabView.delegate = self;
        tabView.dataSource = self;
        tabView.scrollEnabled = YES;
        tabView.drawRect = ^(TUIView *v, CGRect rect) {
            CGRect b = self.bounds;
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            CGContextSetRGBFillColor(ctx, .13, .13, .13, 13);
            CGContextFillRect(ctx, b);
        };
        [self addSubview:tabView];
        selectedTab = -1;
        
        composeButton = [[TUIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 24)];
        dropdownButton = [[TUIButton alloc] initWithFrame:CGRectMake(35, 0, 35, 24)];
        
        [composeButton setImage:[TUIImage imageNamed:@"sidebar-compose.png"] forState:TUIControlStateNormal];
        [dropdownButton setImage:[TUIImage imageNamed:@"sidebar-dropdown.png"] forState:TUIControlStateNormal];
        
        [composeButton setDimsInBackground:NO];
        [dropdownButton setDimsInBackground:NO];
        [composeButton addTarget:self action:@selector(compose:) forControlEvents:TUIControlEventTouchUpInside];

        [self addSubview:composeButton];
        [self addSubview:dropdownButton];
        
        NSString * profileImageUrlString = [[NSApp delegate] selectedAccount].user.profileImageUrl;
        if (profileImageUrlString) {
            profileImageURL = [[NSURL URLWithString:profileImageUrlString] retain];
            
            /*
             [[EGOImageLoader sharedImageLoader] removeObserver:self];
             UIImage* nsImage = [[EGOImageLoader sharedImageLoader] imageForURL:profileImageURL shouldLoadWithObserver:self];
             TUIImage* anImage = [TUIImage imageWithNSImage:nsImage];
             if(anImage) {
             [self setAvatarImage:anImage];
             }
             */
            [[EGOImageLoader sharedImageLoader] loadImageForURL:profileImageURL completion:^(NSData *imageData, NSURL *imageURL, NSError *error) {
                [self setAvatarImage:[TUIImage imageWithData:imageData]];
            }];
        }
    }
    return self;
}
- (void)imageLoaderDidLoad:(NSNotification*)notification {
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:profileImageURL]) return;
    
	UIImage* nsImage = [[notification userInfo] objectForKey:@"image"];
    TUIImage* anImage = [TUIImage imageWithNSImage:nsImage];
	[self setAvatarImage:anImage];
}


- (void)dealloc
{
    [profileImageURL release];
	[tabView release];
    [composeButton release];
    [dropdownButton release];
	[super dealloc];
}

- (void)setDelegate:(id<WTTabViewDelegate>)newDelegate{
    _delegate = newDelegate;
    _delegateHas.didChangeSelect = [_delegate respondsToSelector:@selector(sideBar:didChangeSelectionToTab:)];
    _delegateHas.didClickSelected = [_delegate respondsToSelector:@selector(sideBar:didClickSelectedTab:)];
    _delegateHas.shouldSelectTab = [_delegate respondsToSelector:@selector(sideBar:shouldSelectTab:)];
    _delegateHas.didClickShouldNotSelect = [_delegate respondsToSelector:@selector(sideBar:didClickOnShouldNotSelectTab:)];
}

/**
 *  tableViewDelegate
 *  tableViewDatasource
 */

- (NSInteger)numberOfSectionsInTableView:(TUITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 6;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
	return 38.0;
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath{
    WTButtonCell * cell = reusableTableCellOfClass(tabView, WTButtonCell);
    
    // init select first tab
    if (selectedTab == -1 && indexPath.row == 0) {
        cell.lighted = YES;
        selectedTab = 0;
    }
    return cell;
}

- (TUIView *)tableView:(TUITableView *)tableView headerViewForSection:(NSInteger)section{
    if (!sectionView) {
        sectionView = [[WTSectionAvatarView alloc] initWithAvatar:avatarImage];
    }
    return sectionView;
}


- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event
{
	if([event clickCount] == 1) {
        [self clickTabAtIndex:indexPath.row];
	}
}

- (void) setTabAtIndex:(NSUInteger)index shouldShowGlow:(BOOL) show{
    if ([[tabView visibleCells] count] <= index) {
        return;
    }
    WTButtonCell * theCell = [[tabView visibleCells] objectAtIndex:index];
    [theCell setShouldShowGlow:show];
}

- (void) clickTabAtIndex:(NSUInteger)index{
    WTButtonCell * theCell = [[tabView visibleCells] objectAtIndex:index];
    WTButtonCell * preCell = [[tabView visibleCells] objectAtIndex:selectedTab];
    BOOL shouldSelect = YES;
    if (_delegateHas.shouldSelectTab) {
        shouldSelect = [_delegate sideBar:self shouldSelectTab:(int)index];
    }
    
    if (shouldSelect) {
        preCell.lighted = NO;
        theCell.lighted = YES;
        [TUIView animateWithDuration:0.2 animations:^{
            [theCell redraw];
            [preCell redraw];
        }];
        if (index != selectedTab && _delegateHas.didChangeSelect) {
            [_delegate sideBar:self didChangeSelectionToTab:(int)index];
        }
        else if(_delegateHas.didClickSelected){
            [_delegate sideBar:self didClickSelectedTab:(int)index];
        }
        selectedTab = index;
    }
    else{
        theCell.lighted = NO;
        [TUIView animateWithDuration:0.2 animations:^{
            [theCell redraw];
        }];
        if (_delegateHas.didClickShouldNotSelect) {
            [_delegate sideBar:self didClickOnShouldNotSelectTab:(int)index];
        }
    }
}


- (void)setAvatarImage:(TUIImage *)aImage{
    avatarImage = aImage;
    sectionView.avatar = aImage;
    [TUIView animateWithDuration:0.3 animations:^(void) {
        [sectionView redraw];
    }];
}
- (TUIFastIndexPath *)selectedIndexPath{
    return [tabView selectedIndexPath];
}

- (void)drawRect:(CGRect)rect{
    //CGRect b = self.bounds;
    //CGContextRef ctx = TUIGraphicsGetCurrentContext();
    TUIImage * bottomBG = [TUIImage imageNamed:@"sidebar-bottom.png"];
    [bottomBG drawInRect:CGRectMake(0, 0, 70, 24)];
}

- (void)compose:(id)sender
{
}

@end
