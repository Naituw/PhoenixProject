//
//  WMSideBarView.m
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMSideBarView.h"
#import "TUIKit.h"
#import "TUIImage+WMUI.h"
#import "WindowTrafficLightsView.h"

#import "WMSideBarItemView.h"

#define SECTION_ITEM_HEIGHT 68.0
#define ROW_ITEM_HEIGHT 42.0

@interface WMSideBarView () <WindowTrafficLightsViewDelegate>
@property (nonatomic, retain) NSMutableArray *sectionViews;
@property (nonatomic, retain) NSMutableArray *itemViews;
@property (nonatomic, retain) NSMutableArray *oldItemViews;
@end

@implementation WMSideBarView
@synthesize delegate = _delegate;
@synthesize sectionViews = _sectionViews, itemViews = _itemViews;
@synthesize oldItemViews = _oldItemViews;

- (void)dealloc{
    [_sectionViews release];
    [_itemViews release];
    [_oldItemViews release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.sectionViews = [NSMutableArray array];
        self.itemViews = [NSMutableArray array];
        self.oldItemViews = [NSMutableArray array];
        
        [self setMoveWindowByDragging:YES];
        
        
        scrollView = [[[TUIScrollView alloc] initWithFrame:CGRectZero] autorelease];
        scrollView.moveWindowByDragging = YES;
        scrollView.verticalScrollIndicatorVisibility = TUIScrollViewIndicatorVisibleNever;
        scrollView.horizontalScrollIndicatorVisibility = TUIScrollViewIndicatorVisibleNever;
        scrollView.layout = ^(TUIView * v){
            CGRect frame = v.superview.bounds;
            frame.size.width = 68;
            return frame;
        };
        [scrollView setAlwaysBounceVertical:YES];
        [self addSubview:scrollView];
                
        TUIView * topView = [[[TUIView alloc] init] autorelease];
        topView.moveWindowByDragging = YES;
        topView.layout = ^(TUIView * v){
            CGRect frame = v.superview.bounds;
            CGFloat height = 23;
            frame.origin.y = frame.size.height - height;
            frame.size.height = height;
            return frame;
        };
        topView.drawRect = ^(TUIView *v, CGRect rect) {
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            CGContextClearRect(ctx, rect);
            TUIImage * bg = [TUIImage imageNamed:@"sidebar-top.png"];
            [bg drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
        };
        topView.opaque = NO;
        [self addSubview:topView];
        
        WindowTrafficLightsView * trafficView = [[[WindowTrafficLightsView alloc] initWithFrame:CGRectZero] autorelease];
        trafficView.layout = ^(TUIView * v){
            CGRect frame = v.superview.bounds;
            frame.size.height = 23;
            frame.size.width = 68;
            return frame;
        };
        trafficView.delegate = self;
        [topView addSubview:trafficView];
        
        TUIView * bottomView = [[[TUIView alloc] init] autorelease];
        bottomView.moveWindowByDragging = YES;
        bottomView.layout = ^(TUIView * v){
            CGRect frame = v.superview.bounds;
            CGFloat height = 23;
            frame.size.height = height;
            return frame;
        };
        bottomView.drawRect = ^(TUIView *v, CGRect rect) {
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            CGContextClearRect(ctx, rect);
            TUIImage * bg = [TUIImage imageNamed:@"sidebar-bottom.png"];
            [bg drawInRect:rect];
        };
        bottomView.opaque = NO;
        [self addSubview:bottomView];
        
        composeButton = [TUIButton button];
        composeButton.alpha = 1.0;
        composeButton.dimsInBackground = YES;
        [composeButton setImage:[TUIImage imageNamed:@"sidebar-compose.png"] forState:TUIControlStateNormal];
        composeButton.frame = CGRectMake(5, 1, 29, 23);
        [composeButton addTarget:self action:@selector(compose:) forControlEvents:TUIControlEventTouchUpInside];
        [bottomView addSubview:composeButton];
        
        menuButton = [TUIButton button];
        menuButton.alpha = 1.0;
        menuButton.dimsInBackground = YES;
        [menuButton setImage:[TUIImage imageNamed:@"sidebar-dropdown.png"] forState:TUIControlStateNormal];
        menuButton.frame = CGRectMake(34, 0, 29, 23);
        [menuButton addTarget:self action:@selector(menu:) forControlEvents:TUIControlEventTouchUpInside];
        [bottomView addSubview:menuButton];
    }
    return self;
}

- (void)trafficClose:(id)sender{
    [self.nsWindow performClose:sender];
}
- (void)trafficMinimize:(id)sender{
    [self.nsWindow performMiniaturize:sender];
}
- (void)trafficZoom:(id)sender{
    [self.nsWindow performZoom:sender];
}

- (void)reset{
    // make sure delegate is avaliable
    if (!self.delegate || ![self.delegate conformsToProtocol:@protocol(WMSidebarViewDelegate)]) {
        return;
    }
    NSInteger sectionCount = [self.delegate numberOfSectionsInSidebarView:self];
    if (sectionCount <= 0) return;
    
    [self.sectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.sectionViews removeAllObjects];
    [self.itemViews removeAllObjects];
    [self.oldItemViews removeAllObjects];
    
    for (int section = 0; section < sectionCount; section++) {
        WMSideBarItemView * sectionItem = [[WMSideBarItemView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, SECTION_ITEM_HEIGHT)];
        sectionItem.sectionHeading = YES;
        sectionItem.section = section;        
        
        [self.sectionViews addObject:sectionItem];
        [scrollView addSubview:sectionItem];
        [sectionItem release];
    }
    
    
    [self.delegate selectedRowInSidebarView:self];
    NSInteger initialSelectedSection = 0;
    WMSideBarItemView * selectedSectionView = [self.sectionViews objectAtIndex:initialSelectedSection];
    selectedSectionView.sectionHeadingSelected = YES;
    
    
    NSInteger rowCount = [self.delegate sideBarView:self numberOfItemsInSection:initialSelectedSection];
    for (int row = 0; row < rowCount; row++) {
        {
            WMSideBarItemView * rowItem = [[WMSideBarItemView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, ROW_ITEM_HEIGHT)];
            rowItem.section = initialSelectedSection;
            rowItem.delegate = self.delegate;
            rowItem.imageName = [self.delegate sidebarView:self imageNameForRow:row];
            rowItem.toolTip = [self.delegate sidebarView:self titleForRow:row];
            
            [self.itemViews addObject:rowItem];
            [scrollView addSubview:rowItem];
            [rowItem release];
        }
        {
            WMSideBarItemView * rowItem = [[WMSideBarItemView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, ROW_ITEM_HEIGHT)];
            rowItem.section = initialSelectedSection;
            rowItem.delegate = self.delegate;
            rowItem.imageName = [self.delegate sidebarView:self imageNameForRow:row];
            rowItem.toolTip = [self.delegate sidebarView:self titleForRow:row];
            rowItem.alpha = 0;
            
            [self.oldItemViews addObject:rowItem];
            [scrollView addSubview:rowItem];
            [rowItem release];
        }
        
    }
    
    [self reloadData];
}
- (void)reloadData{
    // make sure delegate is avaliable
    if (!self.delegate || ![self.delegate conformsToProtocol:@protocol(WMSidebarViewDelegate)]) {
        return;
    }
    
    CGFloat animationDuration = 0.3;
    
    __block CGFloat itemTopPosition = 23, contentHeight = 23 * 2; // padding for sidebar top & bottom.
    CGFloat sectionItemHeight = SECTION_ITEM_HEIGHT, rowItemHeight = ROW_ITEM_HEIGHT;
    
    TUIFastIndexPath * selectedIndexPath = [self.delegate selectedRowInSidebarView:self];
    NSInteger previousSection = [(WMSideBarItemView *)[self.itemViews lastObject] section];
    BOOL sectionChanged = selectedIndexPath.section != previousSection;
    
    // Calculate Content Height
    contentHeight += self.sectionViews.count * sectionItemHeight;
    contentHeight += [self.itemViews count] * rowItemHeight;
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, contentHeight);
    
    if (sectionChanged) {
        NSMutableArray * tempForSwap = [self.itemViews retain];
        self.itemViews = self.oldItemViews;
        self.oldItemViews = tempForSwap;
        [tempForSwap release];
    }
        
    CGRect oldSectionFrame;
    NSInteger section = 0;
    for (WMSideBarItemView * sectionItem in self.sectionViews) {
        sectionItem.image = [self.delegate sidebarView:self imageForSection:section];
        sectionItem.toolTip = [self.delegate sidebarView:self titleForSection:section];
        sectionItem.badge = [self.delegate sideBarView:self badgeForSection:section];
        sectionItem.delegate = self.delegate;

        CGRect sectionFrom = sectionItem.frame;
        CGRect sectionTo = CGRectMake(0, contentHeight - itemTopPosition - sectionItemHeight, 
                                        scrollView.bounds.size.width, sectionItemHeight);
        itemTopPosition += sectionItemHeight;
        
        if (selectedIndexPath.section != section && sectionItem.sectionHeadingSelected) {
            oldSectionFrame = sectionTo;
        }
        sectionItem.sectionHeadingSelected = (selectedIndexPath.section == section);

        if (sectionItem.sectionHeadingSelected) {
            
            NSInteger row = 0;
            for (WMSideBarItemView * rowItem in self.itemViews) {
                rowItem.section = section;
                rowItem.highlight = (selectedIndexPath.row == row);
                rowItem.badge = [self.delegate sideBarView:self badgeForRow:row];
                rowItem.indexPath = [TUIFastIndexPath indexPathForRow:row inSection:section];
                                
                CGRect rowRect = CGRectMake(0, contentHeight - itemTopPosition - rowItemHeight, 
                                            scrollView.bounds.size.width, rowItemHeight);
                itemTopPosition += rowItemHeight;
                
                [rowItem redraw];
                
                if (sectionChanged) {
                    rowItem.alpha = 0;
                    CGRect startFrame = sectionFrom;
                    startFrame.size.height = ROW_ITEM_HEIGHT;
                    [CATransaction begin];
                    rowItem.frame = startFrame;
                    [CATransaction flush];
                    [CATransaction commit];
                    [TUIView animateWithDuration:animationDuration animations:^{
                        rowItem.frame = rowRect;
                        rowItem.alpha = 1;
                    }];
                }else {
                    rowItem.frame = rowRect;
                }                
                row++;
            }
            
            // Scroll hole section to visible.
            {
                CGRect sectionRect = sectionTo;
                CGFloat itemsHeight = [self.itemViews count] * ROW_ITEM_HEIGHT;
                sectionRect.origin.y -= itemsHeight;
                sectionRect.size.height += itemsHeight;
                // padding fo sidebar top & bottom.
                sectionRect.origin.y -= 23;
                sectionRect.size.height += 2 * 23;
                CGRect visible = scrollView.visibleRect;
                [scrollView setContentOffset:CGPointMake(0, -sectionRect.origin.y + visible.size.height - sectionRect.size.height) animated:YES];
            }
        }
        
        [TUIView animateWithDuration:animationDuration animations:^{
            sectionItem.frame = sectionTo;
            [sectionItem redraw];
        }];
        
        section++;
    }
    if (sectionChanged) {
        CGRect toFrame = oldSectionFrame;
        toFrame.size.height = ROW_ITEM_HEIGHT;
        [TUIView animateWithDuration:animationDuration animations:^{
            for (WMSideBarItemView * item in self.oldItemViews) {
                item.alpha = 0;
                item.frame = toFrame;
            }
        }];
    }    
}

- (TUIFastIndexPath *)selectedIndexPath{
    return [self.delegate selectedRowInSidebarView:self];
}

#pragma mark - Actions

- (void)compose:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sidebarView:didClickComposeButton:)])
    {
        [self.delegate sidebarView:self didClickComposeButton:sender];
    }
}

- (void)menu:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sidebarView:didClickMenuButton:)])
    {
        [self.delegate sidebarView:self didClickMenuButton:sender];
    }
}

@end
