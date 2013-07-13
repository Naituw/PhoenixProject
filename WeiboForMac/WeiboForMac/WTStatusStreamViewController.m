//
//  WTStatusStreamViewController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-20.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTStatusStreamViewController.h"
#import "TUITableView+WTAddition.h"
#import "WeiboBaseStatus.h"
#import "WTStatusCell.h"
#import "WeiboConcreteStatusesStream.h"
#import "WMConstants.h"
#import "WUITableViewEndCell.h"
#import "WeiboMac2Window.h"
#import "NSWindow+WMAdditions.h"

#import "WMRootViewController.h"
#import "WTEventHandler.h"
#import "WeiboForMacAppDelegate.h"
#import "WTUIViewController+NavigationController.h"
#import "WMColumnViewController+CommonPush.h"
#import "WTRepliesStreamViewController.h"
#import "WTComposeWindowController.h"

#import "Weibo.h"
#import "WeiboAccountStream.h"
#import "WeiboRepliesStream.h"
#import "WeiboStatus.h"
#import "WMComposition.h"

@implementation WTStatusStreamViewController

- (id)init{
    if (self = [super init]) {
    }
    return self;
}
- (void)dealloc{
    [self unregisterStatusStreamNotifications];
    [statusStream release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    WTStatusStreamViewController * result = [super copyWithZone:zone];
    
    [self saveScrollPosition];
    
    [result setStatusStream:statusStream];
    
    return result;
}

- (void)setStatusStream:(WeiboStream *)newStream{
    [newStream retain];
    [statusStream release];
    statusStream = newStream;
    statuses = [newStream statuses];
}
- (WeiboStream *)statusStream{
    return statusStream;
}
- (WeiboConcreteStatusesStream *)concreteStatusStream{
    if ([statusStream isKindOfClass:[WeiboConcreteStatusesStream class]]) {
        return (WeiboConcreteStatusesStream *)statusStream;
    }
    return nil;
}
- (void)setViewedMostRecentID:(WeiboStatusID)viewedMostRecentID
{
    if (statusStream)
    {
        statusStream.viewedMostRecentID = viewedMostRecentID;
    }
}
- (WeiboStatusID)viewedMostRecentID
{
    return statusStream.viewedMostRecentID;
}

- (BOOL)canPullToRefresh
{
    return [statusStream canLoadNewer];
}

- (void)postStreamViewDidReachTopNofitication{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kStreamViewDidReachTopNotification object:self];
}

- (WeiboRequestError *)loadingError
{
    WeiboRequestError * loadOlderError = [[self concreteStatusStream] loadOlderError];
    if (loadOlderError)
    {
        return loadOlderError;
    }
    else if (!self.statusStream.hasData)
    {
        return [[self concreteStatusStream] loadNewerError];
    }
    return nil;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return [self loadingError] ? 80 : 40;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    TUITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1 && [cell isKindOfClass:[WUITableViewEndCell class]])
    {
        WUITableViewEndCell * endCell = (WUITableViewEndCell *)cell;

        endCell.isEnded = self.statusStream.isStreamEnded;
        endCell.loading = !endCell.isEnded;
        endCell.error = [self loadingError];
    }
    return cell;
}

- (void)tableView:(TUITableView *)aTableView willDisplayCell:(TUITableViewCell *)cell forRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (![statusStream isStreamEnded] && [statusStream hasData])
        {
            [statusStream loadOlder];
        }
    }
    else
    {
        if ([cell isKindOfClass:[WTStatusCell class]])
        {
            WeiboBaseStatus * statusToDisplay = [(WTStatusCell *)cell status];
            if (statusToDisplay.sid > self.viewedMostRecentID)
            {
                self.viewedMostRecentID = statusToDisplay.sid;
                statusToDisplay.wasSeen = YES;
            }
            if (indexPath.row == 0)
            {
                [self postStreamViewDidReachTopNofitication];
            }
        }
    }
}

- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event
{
    if (event.clickCount == 2)
    {
        if (indexPath.section == 1)
        {
            [statusStream retryLoadOlder];
            [self.tableView reloadData];
        }
        else
        {
            // 容易误操作，暂时去掉
            // [self viewReplies:nil];
        }
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{
    if (section == 1) return 1;
    NSInteger count = [statuses count];
    if ([statusStream isKindOfClass:[WeiboConcreteStatusesStream class]])
    {
        if (count > [(WeiboConcreteStatusesStream *)statusStream maxCount]) {
            return [(WeiboConcreteStatusesStream *)statusStream maxCount];
        }
    }
	return count;
}

- (void)loadNewer:(id)sender
{
    [statusStream loadNewer];
}
- (void)loadOlder:(id)sender
{
    [statusStream loadOlder];
}

- (void)reloadAndTryToRestoreScrollPosition
{
    [self.tableView finishedLoadingNewer];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dic = [defaults objectForKey:[statusStream autosaveName]];
    
    TUIFastIndexPath * indexPath = nil;
    CGFloat offset = 0;
    
    if (dic)
    {
        NSUInteger row = [[dic objectForKey:@"possibleRow"] intValue];
        WeiboStatusID sid = [[dic objectForKey:@"statusID"] longLongValue];
        offset = [[dic objectForKey:@"relativeOffset"] doubleValue];
        if (row >= statuses.count)
        {
            row = statuses.count - 1;
        }
        if ([(WeiboBaseStatus *)[statuses objectAtIndex:row] sid] != sid) {
            row = [statusStream statuseIndexByID:sid];
            if (row == NSNotFound)
            {
                row = 0;
                offset = 0;
            }
        }
        indexPath = [TUIFastIndexPath indexPathForRow:row inSection:0];
    }
    else
    {
        indexPath = [TUIFastIndexPath indexPathForRow:0 inSection:0];
    }
    
    _flags.isReloading = YES;
    
    [_tableView reloadDataMaintainingVisibleIndexPath:indexPath relativeOffset:-offset];
    
    _flags.isReloading = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForStatusStreamNotifications];
    
    if ([statusStream hasData])
    {
        [self reloadAndTryToRestoreScrollPosition];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    //[self.tableView reloadData];
    if (![statusStream hasData])
    {
        [statusStream loadNewer];
    }
    else
    {
        TUIFastIndexPath * indexPath = [self.tableView indexPathForVisibleRow];
        if (indexPath.row == 0 && indexPath.section == 0) {
            [self postStreamViewDidReachTopNofitication];
        }
    }
    [super viewDidAppear:animated];
}

- (void)saveScrollPosition
{
    TUIFastIndexPath * indexPath = [_tableView indexPathForVisibleRow];
    if (indexPath.section == 1) {
        return;
    }
    if (![statusStream hasData]) {
        return;
    }
    NSUInteger currentRow = [_tableView indexPathForVisibleRow].row;
    saveScrollPosition.possibleRow = currentRow;
    saveScrollPosition.statusID = [(WeiboBaseStatus *)[statuses objectAtIndex:currentRow] sid];
    saveScrollPosition.relativeOffset = [_tableView relativeOffset];
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithLongLong:saveScrollPosition.statusID], @"statusID",
                                 [NSNumber numberWithDouble:saveScrollPosition.relativeOffset], @"relativeOffset",
                                 [NSNumber numberWithInteger:saveScrollPosition.possibleRow], @"possibleRow"
                                 ,nil];
    
    [[NSUserDefaults standardUserDefaults] setValue:dic forKey:[statusStream autosaveName]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self saveScrollPosition];
    [statusStream setCacheTime:[NSDate timeIntervalSinceReferenceDate]];
}

- (BOOL)scrollToTopAutomatically
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"scroll-to-top-automatically"];
}

- (void)pushNewRowsWithCount:(NSNumber *)count
{
    TUIFastIndexPath * currentIndexPath = [[self.tableView indexPathForVisibleRow] copy];
        
    if (!_flags.findMode)
    {
        [_tableView pushNewRowsWithCount:[count intValue]];
    }
    [_tableView finishedLoadingNewer];
    
    NSArray * cells = [_tableView visibleCells];
    for (TUITableViewCell * cell in cells) {
        if ([cell isKindOfClass:[WTStatusCell class]]) {
            [cell performSelector:@selector(setWasSeened)];
        }
    }
    
    if ([self scrollToTopAutomatically] &&
        currentIndexPath.row == 0 && currentIndexPath.section == 0)
    {
        [self.tableView scrollToTopAnimated:YES];
    }
    
    [currentIndexPath release];
}

- (void)statusesStream:(WeiboConcreteStatusesStream *)stream 
  didReceiveNewStatuses:(NSArray *)newStatuses
        withAddingType:(WeiboStatusesAddingType)type{
    switch (type) {
        case WeiboStatusesAddingTypePrepend:{
            if ([newStatuses count] > 0) {
                // If Network is too fast, some problem may occur, wait some times here.
                [self performSelector:@selector(pushNewRowsWithCount:) 
                           withObject:[NSNumber numberWithInteger:[newStatuses count]]
                           afterDelay:0.1];
            }else {
                [_tableView performSelector:@selector(finishedLoadingNewer) 
                                 withObject:nil
                                 afterDelay:0.1];
                
            }
            break;
        }
        case WeiboStatusesAddingTypeAppend:
            if (stream.statuses.count == newStatuses.count)
            {
                // first load
                [self performSelector:@selector(reloadAndTryToRestoreScrollPosition) withObject:nil afterDelay:0.1];
            }
            else
            {
                [_tableView appendNewRows];
            }
            break;
        default:
            break;
    }
}

- (void)statusesStream:(WeiboStream *)stream didRemoveStatus:(WeiboBaseStatus *)status atIndex:(NSInteger)index{
    [_tableView appendNewRows];
}

- (void)statusesStream:(WeiboStream *)stream didReceiveRequestError:(WeiboRequestError *)error{
    WeiboConcreteStatusesStream * statusesStream = (WeiboConcreteStatusesStream *)self.statusStream;
    if (![statusesStream isKindOfClass:[WeiboConcreteStatusesStream class]]) return;
    
    [statusesStream markAtEnd];
    [self.tableView finishedLoadingNewer];
}

#pragma mark - Notifications

- (void)registerForStatusStreamNotifications
{
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(statusStreamDidReceiveNewStatusesNotification:) name:WeiboStatusStreamDidReceiveNewStatusesNotificationKey object:nil];
    [nc addObserver:self selector:@selector(statusStreamDidReceiveRequestErrorNotification:) name:WeiboStatusStreamDidReceiveRequestErrorNotificationKey object:nil];
    [nc addObserver:self selector:@selector(statusStreamDidRemoveStatusNotification:) name:WeiboStatusStreamDidRemoveStatusNotificationKey object:nil];
}
- (void)unregisterStatusStreamNotifications
{
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self name:WeiboStatusStreamDidReceiveNewStatusesNotificationKey object:nil];
    [nc removeObserver:self name:WeiboStatusStreamDidReceiveRequestErrorNotificationKey object:nil];
    [nc removeObserver:self name:WeiboStatusStreamDidRemoveStatusNotificationKey object:nil];
}

- (void)statusStreamDidReceiveNewStatusesNotification:(NSNotification *)notification
{
    if (notification.object != statusStream)
    {
        return;
    }
    
    NSArray * newStatuses = notification.userInfo[WeiboStatusStreamNotificationStatusesArrayKey];
    WeiboStatusesAddingType type = [notification.userInfo[WeiboStatusStreamNotificationAddingTypeKey] integerValue];
    [self statusesStream:notification.object didReceiveNewStatuses:newStatuses withAddingType:type];
}
- (void)statusStreamDidReceiveRequestErrorNotification:(NSNotification *)notification
{
    if (notification.object != statusStream)
    {
        return;
    }
    
    WeiboRequestError * error = notification.userInfo[WeiboStatusStreamNotificationRequestErrorKey];
    [self statusesStream:notification.object didReceiveRequestError:error];
}
- (void)statusStreamDidRemoveStatusNotification:(NSNotification *)notification
{
    if (notification.object != statusStream)
    {
        return;
    }
    
    WeiboBaseStatus * status = notification.userInfo[WeiboStatusStreamNotificationBaseStatusKey];
    NSInteger index = [notification.userInfo[WeiboStatusStreamNotificationStatusIndexKey] integerValue];
    [self statusesStream:notification.object didRemoveStatus:status atIndex:index];
}

- (BOOL)performKeyAction:(NSEvent *)event
{
    return [self.tableView performKeyAction:event];
}

- (void)openActiveRangeWithValue:(NSString *)value flavor:(ABActiveTextRangeFlavor)flavor
{
    WeiboAccount * account = self.account;
    
    switch (flavor)
    {
        case ABActiveTextRangeFlavorURL:{
            [WTEventHandler openURL:value];
            break;
        }
        case ABActiveTextRangeFlavorTwitterUsername:{
            NSString * username = [value substringFromIndex:1];
            [self.columnViewController pushUserViewControllerWithUsername:username account:account];
            break;
        }
        case ABActiveTextRangeFlavorTwitterHashtag:{
            NSString * hashTag = [value substringWithRange:NSMakeRange(1, value.length - 2)];
            [self.columnViewController pushTrendViewControllerWithTrendName:hashTag account:account];
        }
        default:
            break;
    }

}

- (void)textRenderer:(TUITextRenderer *)renderer didClickActiveRange:(ABFlavoredRange *)activeRange
{
    NSRange rangeValue = activeRange.rangeValue;    
    NSString * value = [renderer.attributedString.string substringWithRange:rangeValue];

    [self openActiveRangeWithValue:value flavor:activeRange.rangeFlavor];
}


#pragma mark - Responds to Main Menu

- (WeiboBaseStatus *)selectedStatus
{
    TUIFastIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
    
    if (indexPath.section == 0 && indexPath.row < statuses.count)
    {
        return statuses[indexPath.row];
    }
    
    return nil;
}

- (WTStatusCell *)selectedStatusCell
{
    TUIFastIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
    
    if (!indexPath)
    {
        return nil;
    }
    
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (![cell isKindOfClass:[WTStatusCell class]])
    {
        return nil;
    }
    return cell;
}

- (NSPoint)composerPointForCell:(WTStatusCell *)cell
{
    WeiboMac2Window * window = (WeiboMac2Window *)self.view.nsWindow;
    if (![window isKindOfClass:WeiboMac2Window.class])
    {
        return NSZeroPoint;
    }
        
    NSRect cellFrame = [cell frameOnScreen];
    CGFloat windowWidth = 325.0;
    CGFloat xPoint = cellFrame.origin.x + cellFrame.size.width + 30;
    if (![window isOnLeftSideOfScreen])
    {
        xPoint = cellFrame.origin.x - windowWidth - 30;
    }
    return NSMakePoint(xPoint, cellFrame.origin.y + cellFrame.size.height);
}

- (void)reply:(id)sender
{
    WTStatusCell * cell = sender;
    
    if (![sender isKindOfClass:[WTStatusCell class]])
    {
        cell = [self selectedStatusCell];
    }
    if (!cell)
    {
        return;
    }
    
    NSPoint toPoint = [self composerPointForCell:cell];
    
    WMComposition * composition = [WMComposition new];
    
    composition.replyToStatus = cell.status;
    composition.type = WeiboCompositionTypeComment;
    
    NSDocumentController * documentController = [NSDocumentController sharedDocumentController];
    [documentController addDocument:composition];
    [composition makeWindowControllers];
    [composition showWindows];
    [composition release];
    
    WTComposeWindowController * controller = composition.windowControllers.lastObject;
    controller.account = self.account;
    controller.composeWindow.shouldShowNipple = YES;
    controller.composeWindow.nippleDirection = self.view.nsWindow.isOnLeftSideOfScreen ? WTComposeWindowNippleDirectionLeft : WTComposeWindowNippleDirectionRight;
    
    toPoint.y -= controller.window.frame.size.height;
    
    [controller.window setFrameOrigin:toPoint];
}

- (void)repost:(id)sender
{
    WTStatusCell * cell = sender;
    
    if (![sender isKindOfClass:[WTStatusCell class]])
    {
        cell = [self selectedStatusCell];
    }
    
    if (!cell)
    {
        return;
    }
    
    NSPoint toPoint = [self composerPointForCell:cell];
    
    WMComposition * composition = [WMComposition new];
    
    composition.retweetingStatus = cell.status;
    composition.type = WeiboCompositionTypeRetweet;
    
    NSDocumentController * documentController = [NSDocumentController sharedDocumentController];
    [documentController addDocument:composition];
    [composition makeWindowControllers];
    [composition showWindows];
    [composition release];
    
    WTComposeWindowController * controller = composition.windowControllers.lastObject;
    controller.account = self.account;
    controller.composeWindow.shouldShowNipple = YES;
    controller.composeWindow.nippleDirection = self.view.nsWindow.isOnLeftSideOfScreen ? WTComposeWindowNippleDirectionLeft : WTComposeWindowNippleDirectionRight;
    
    toPoint.y -= controller.window.frame.size.height;
    
    [controller.window setFrameOrigin:toPoint];
}


- (void)viewOnWebPage:(id)sender
{
    WTStatusCell * cell = sender;
    
    if (![sender isKindOfClass:[WTStatusCell class]])
    {
        cell = [self selectedStatusCell];
    }
    
    WeiboBaseStatus * status = cell.status;
    if (status)
    {
        [WTEventHandler openStatusPageForStatus:status];
    }
}

- (void)deleteWeibo:(id)sender
{
    WTStatusCell * statusCell = sender;
    
    if (![sender isKindOfClass:[WTStatusCell class]])
    {
        statusCell = [self selectedStatusCell];
    }
    
    if (!statusCell)
    {
        return;
    }
    
    WeiboBaseStatus * status = statusCell.status;
    
    
    NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Delete Weibo?", nil) defaultButton:NSLocalizedString(@"Delete", nil) alternateButton:NSLocalizedString(@"Cancel", nil) otherButton:nil informativeTextWithFormat:@"%@",status.text];
    [alert setIcon:statusCell.avatar.image.nsImage];
    CGRect cellRect = [statusCell frameInNSView];
    cellRect.origin.y += cellRect.size.height;
    cellRect.size.height = 0;
    
    NSValue * rect = [NSValue valueWithRect:cellRect];
    
    [alert.window setObject:rect forAssociatedKey:kWindowSheetPositionRect retained:YES];
    
    [alert beginSheetModalForWindow:self.view.nsWindow modalDelegate:self didEndSelector:@selector(deleteAlertDidEnd:returnCode:contextInfo:) contextInfo:[[status retain] autorelease]];
}
- (void)deleteAlertDidEnd:(NSAlert *)alert returnCode:(NSUInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn && contextInfo)
    {
        [self.account deleteStatus:contextInfo];
    }
}

- (BOOL)canViewConversation:(WeiboBaseStatus *)status
{
    return YES;
}
- (void)viewReplies:(id)sender
{
    WTStatusCell * cell = sender;
    
    if (![sender isKindOfClass:[WTStatusCell class]])
    {
        cell = [self selectedStatusCell];
    }
    
    WeiboBaseStatus * status = cell.status;
    if (![self canViewConversation:status])
    {
        return;
    }
    
    if (![status isKindOfClass:[WeiboStatus class]])
    {
        return;
    }
    
    WTRepliesStreamViewController * controller = [[WTRepliesStreamViewController alloc] init];
    WeiboRepliesStream * stream = [self.account repliesStreamForStatus:(WeiboStatus *)status];
    [controller setTitle:NSLocalizedString(@"Replies", nil)];
    [controller setStatusStream:stream];
    [controller setAccount:self.account];
    [self.columnViewController pushViewController:controller animated:YES];
    [controller release];
}

- (void)viewUserDetails:(id)sender
{
    WTStatusCell * cell = sender;
    
    if (![sender isKindOfClass:[WTStatusCell class]])
    {
        cell = [self selectedStatusCell];
    }
    
    WeiboBaseStatus * status = cell.status;
    WeiboUser * user = [status user];
    
    [self.columnViewController pushUserViewControllerWithUser:user account:self.account];
}

- (void)viewActiveRange:(id)sender
{
    NSMenuItem * item = sender;
    if (![item isKindOfClass:[NSMenuItem class]])
    {
        return;
    }
    
    NSString * value = item.title;
    ABActiveTextRangeFlavor flavor = (ABActiveTextRangeFlavor)item.tag;
    
    [self openActiveRangeWithValue:value flavor:flavor];
}

- (BOOL)validateMenuItemWithAction:(SEL)action cell:(WTStatusCell *)cell
{
    if (!cell)
    {
        return NO;
    }
    
    WeiboBaseStatus * status = cell.status;
    
    BOOL isComment = status.isComment;
    BOOL isMine = [status.user isEqual:self.account.user];
    
    SEL s = action;
    
    if (s == @selector(repost:) ||
        s == @selector(viewOnWebPage:) ||
        s == @selector(viewReplies:) ||
        s == @selector(viewWeiboSourceApp:))
    {
        return !isComment;
    }
    if (s == @selector(reply:) ||
        s == @selector(viewUserDetails:) ||
        s == @selector(viewActiveRange:))
    {
        return YES;
    }
    if (s==@selector(deleteWeibo:))
    {
        return isMine;
    }
    if (s==@selector(viewPhoto:))
    {
        return (status.middlePic || status.quotedBaseStatus.middlePic);
    }
    
    return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    WTStatusCell * cell = [self selectedStatusCell];

    return [self validateMenuItemWithAction:menuItem.action cell:cell];
}

@end
