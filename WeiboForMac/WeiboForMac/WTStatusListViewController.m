//
//  WTStatusListViewController.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-23.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTStatusListViewController.h"
#import "WTRepliesStreamViewController.h"
#import "WMUserPreferences.h"
#import "WTDateFormatter.h"
#import "WTEventHandler.h"
#import "WTStatusCell.h"
#import "WUITableViewEndCell.h"
#import "WTComposeWindowController.h"
#import "WMToolbarView.h"
#import "WTStatusTableView.h"
#import "TUIStringDrawing.h"
#import "TUIImage+UIDrawing.h"
#import "WMRootViewController.h"
#import "WMColumnViewController.h"

#import "NSAttributedString+WTAddition.h"
#import "NSArray+WeiboAdditions.h"
#import "WTCGAdditions.h"
#import "WeiboBaseStatus.h"
#import "WeiboBaseStatus+StatusListAdditions.h"
#import "WeiboBaseStatus+StatusCellAdditions.h"
#import "WeiboUser.h"
#import "WeiboUser+Avatar.h"
#import "WeiboRepliesStream.h"
#import "WeiboStatusStreamFilterSimpleSearchFilter.h"
#import "WTActiveTextRanges.h"

#import "WeiboForMacAppDelegate.h"
#import "WMMediaLoaderView.h"
#import "WeiboMac2Window.h"

@interface WTStatusListViewController ()
@property (nonatomic, retain) TUITextRenderer * sharedTextRenderer;
@end

@implementation WTStatusListViewController
@synthesize filteredStatus = _filteredStatus;
@synthesize sharedTextRenderer = _sharedTextRenderer;

- (void)dealloc{
    
    for (WTStatusCell * cell in _tableView.visibleCells)
    {
        if ([cell isKindOfClass:[WTStatusCell class]])
        {
            cell.controller = nil;
        }
    }
    
    [_account release], _account = nil;
    [_filteredStatus release];
    [_sharedTextRenderer release], _sharedTextRenderer = nil;
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    WTStatusListViewController * result = [super copyWithZone:zone];
    result.account = self.account;
    return result;
}

- (Class)tableViewClass
{
    return [WTStatusTableView class];
}

- (BOOL)canPullToRefresh
{
    return NO;
}

- (WeiboStatusID)newestStatusID
{
    WeiboBaseStatus * status = [statuses firstObject];
    if (status) {
        return status.sid;
    }
    return 0;
}

- (BOOL)becomeFirstResponder
{
    if ([self.view.nsWindow makeFirstResponder:self.tableView])
    {
        return YES;
    }
    return [super becomeFirstResponder];
}

#pragma mark - Table View Delegate and Data Source

- (NSInteger)numberOfSectionsInTableView:(TUITableView *)tableView
{
    if (_flags.findMode) {
        return 1;
    }
	return 2;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{
    if (section == 1) return 1;
	return [statuses count];
}
- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    // Check WTStatusStreamViewController.
    if (_flags.findMode) {
        return self.filteredStatus.count;
    }
    return [self numberOfRowsInSection:section];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForBaseStatus:(WeiboBaseStatus *)status
{
    if (![_tableView isKindOfClass:[WTStatusTableView class]])
    {
        return 0;
    }
	return [status heightInTableView:(WTStatusTableView *)_tableView];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return 40;
    }
    
    WeiboBaseStatus * status = nil;
    if (_flags.findMode) {
        status = [self.filteredStatus objectAtIndex:indexPath.row];
    }else {
        status = [statuses objectAtIndex:indexPath.row];
    }
    
    return [self tableView:tableView heightForBaseStatus:status];
}
- (TUIView *)tableView:(TUITableView *)tableView headerViewForSection:(NSInteger)section
{
    return nil;
}

- (void)setUpStatusCell:(WTStatusCell *)cell withBaseStatus:(WeiboBaseStatus*)status
{
    cell.status = status;
    cell.controller = self;
    cell.windowIdentifier = self.windowIdentifier;
    
    // setup user profile image (Head pic)
    
    CGFloat currentScaleFactor = TUICurrentContextScaleFactor();
    
    NSString * avatarURLString = (currentScaleFactor > 1) ? status.user.profileLargeImageUrl : status.user.profileImageUrl;
    NSURL * avatarURL = [NSURL URLWithString:avatarURLString];
    [cell.avatar setImageWithURL:avatarURL drawingStyle:WMWebImageDrawingStyleMacAvatar];

    WeiboBaseStatus * statusMayHavePic = status;
    if (status.quotedBaseStatus)
    {
        statusMayHavePic = status.quotedBaseStatus;
    }
    if (statusMayHavePic.thumbnailPic && [[WMUserPreferences sharedPreferences] showsThumbImage])
    {
        
//        [cell.thumb setImageFromCacheWithURL:[NSURL URLWithString:statusMayHavePic.thumbnailPic] style:@"cell-thumb-style"];
//        cell.thumb.midPicUrl = statusMayHavePic.middlePic;
//        cell.thumb.bigPicUrl = statusMayHavePic.originalPic;
    }
    
    // Setup time.
    NSString * timeString = [[WTDateFormatter shared] stringForTime:(int)status.createdAt];
    TUIAttributedString *time = [TUIAttributedString stringWithString:timeString];
    time.color = [TUIColor colorWithWhite:0.6 alpha:1.0];
    time.font = [TUIFont fontWithName:@"HelveticaNeue-Light" size:11];
    time.alignment = TUITextAlignmentRight;
    cell.time.attributedString = time;
    
    // setup weibo content
    cell.content.attributedString = [status attributedText];
    cell.quotedContent.attributedString = [status.quotedBaseStatus attributedText];
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        WUITableViewEndCell *cell = reusableTableCellOfClass(tableView, WUITableViewEndCell);
        return cell;
    }
    // else is a status cell
    WTStatusCell * cell = reusableTableCellOfClass(tableView, WTStatusCell);
    WeiboBaseStatus * status = nil;
    if (_flags.findMode) {
        status = [self.filteredStatus objectAtIndex:indexPath.row];
    }else {
        status = [statuses objectAtIndex:indexPath.row];
    }
    [self setUpStatusCell:cell withBaseStatus:status];
    return cell;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForSectionAtIndex:(NSUInteger)index
{
    return 0.0;
}
- (BOOL)tableView:(TUITableView *)tableView shouldSelectRowAtIndexPath:(TUIFastIndexPath *)indexPath forEvent:(NSEvent *)event
{
    if ([event type] == NSRightMouseDown)
    {
        return NO;
    }

    return YES;
}

- (void)reloadListWithNewsOfCount:(NSUInteger)count
{
    [_tableView pushNewRowsWithCount:count];
}
- (void)loadNewer:(id)sender
{
    
}
- (void)loadOlder:(id)sender
{
    
}
- (void)scrollToTop:(id)sender
{
    [_tableView scrollToTopAnimated:YES];
}
- (void)relayout
{
    [_tableView pushNewRowsWithCount:0];
}

- (void)pullToRefreshViewShouldRefresh:(WTPullDownView *)view
{
    [self loadNewer:self];
}

- (void)viewWillAppear:(BOOL)animated {
    NSArray * cells = self.tableView.visibleCells;
    
    for (TUITableViewCell * cell in cells)
    {
        [cell prepareForDisplay];
    }
    
    [super viewWillAppear:animated];
}

- (NSMenuItem *)menuItemWithTitle:(NSString *)title action:(SEL)action
{
    NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
    [item setEnabled:YES];
    return [item autorelease];
}
- (BOOL)_addActiveRanges:(NSArray *)ranges forStatus:(WeiboBaseStatus *)status toMenu:(NSMenu *)menu
{
    if (!ranges || !ranges.count || !status || !menu)
    {
        return NO;
    }
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    for (ABFlavoredRange * range in ranges)
    {
        NSString * title = [status.displayText substringWithRange:range.rangeValue];
        NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:title action:@selector(viewActiveRange:) keyEquivalent:@""];
        
        item.tag = range.rangeFlavor;
        
        [menu addItem:item];
    }
    
    return YES;
}
- (BOOL)_addOpenAllLinksItem:(WeiboBaseStatus *)status toMenu:(NSMenu *)menu{
    return NO;
}
- (BOOL)_addUserDetailsItem:(WeiboBaseStatus *)status toMenu:(NSMenu *)menu{
    return NO;
}
- (BOOL)_addViewConversationItem:(WeiboBaseStatus *)status toMenu:(NSMenu *)menu{
    return NO;
}
- (void)addMenuItemsForStatus:(WeiboBaseStatus *)status toMenu:(NSMenu *)menu{
    NSMenuItem * weiboMenuItem = [[WeiboForMacAppDelegate currentDelegate].mainMenu itemAtIndex:3];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 9)];
    NSArray * weiboMenuItemArray = [weiboMenuItem.submenu.itemArray objectsAtIndexes:indexSet];
    for (NSMenuItem * item in weiboMenuItemArray) {
        [menu addItem:[[item copy] autorelease]];
    }
    
    if ([status isKindOfClass:[WeiboStatus class]]) {
        WeiboStatus * s = (WeiboStatus *)status;
        if (s.source && s.source.length > 0 && s.sourceUrl && s.sourceUrl.length > 0) {
            [menu addItem:[NSMenuItem separatorItem]];
            NSString * title = [NSString stringWithFormat:NSLocalizedString(@"From %@", nil),s.source];
            [menu addItem:[self menuItemWithTitle:title action:@selector(viewWeiboSourceApp:)]];
        }
    }
    
    [self _addActiveRanges:status.activeRanges.activeRanges forStatus:status toMenu:menu];
    [self _addActiveRanges:status.quotedBaseStatus.activeRanges.activeRanges forStatus:status.quotedBaseStatus toMenu:menu];
}

#pragma mark -
#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(TUIScrollView *)scrollView
{
    [WTComposeWindow dissociateAllNipples];
}
- (void)scrollView:(TUIScrollView *)scrollView willHideScrollIndicator:(TUIScrollViewIndicator)indicator{
    
}

#pragma mark - Active Clicked

- (void)textRenderer:(TUITextRenderer *)renderer didClickActiveRange:(ABFlavoredRange *)activeRange
{
    
}

- (BOOL)statusCell:(WTStatusCell *)cell didPressAvatarWithUser:(WeiboUser *)user
{
    return NO;
}

#pragma mark - Searching

- (BOOL)textFieldShouldTabToNext:(TUITextField *)aTextField
{
    if (self.filteredStatus.count > 0) {
        [self.tableView selectRowAtIndexPath:[TUIFastIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:TUITableViewScrollPositionToVisible];
    }
    return YES;
}

- (void)didHitReturnButtonInFindMode
{
    if (self.filteredStatus.count > 0)
    {
        [self.tableView selectRowAtIndexPath:[TUIFastIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:TUITableViewScrollPositionToVisible];
    }
}

- (void)filterItemsWithQuery:(NSString *)query
{
    NSMutableArray * filtered = [NSMutableArray arrayWithCapacity:statuses.count];
    WeiboStatusStreamFilterSimpleSearchFilter * filter = [WeiboStatusStreamFilterSimpleSearchFilter defaultStatusStreamFilter];
    filter.query = query;
    for (WeiboBaseStatus * status in statuses)
    {
        if ([filter validStatus:status])
        {
            [filtered addObject:status];
        }
    }
    self.filteredStatus = filtered;
}

- (void)didExitFindMode
{
    self.filteredStatus = nil;
}

- (IBAction)deleteWeibo:(id)sender{}
- (IBAction)viewPhoto:(id)sender{}
- (IBAction)viewReplies:(id)sender{}
- (IBAction)reply:(id)sender{}
- (IBAction)repost:(id)sender{}
- (IBAction)viewUserDetails:(id)sender{}
- (IBAction)viewOnWebPage:(id)sender{}
- (IBAction)viewActiveRange:(id)sender{}
- (BOOL)validateMenuItemWithAction:(SEL)action cell:(WTStatusCell *)cell
{
    return NO;
}


@end
