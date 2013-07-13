//
//  WMSearchableTableViewController.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-17.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMSearchableTableViewController.h"

@interface WMSearchableTableViewController ()

@property (nonatomic, retain) TUIView * topFadeView;
@property (nonatomic, retain) TUIView * bottomFadeView;

@end

@implementation WMSearchableTableViewController

- (void)dealloc
{
    [_tableView removeFromSuperview];
    [_tableView release];
    [_findView release];
    [_topFadeView release], _topFadeView = nil;
    [_bottomFadeView release], _bottomFadeView = nil;

    [super dealloc];
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    _tableView = [[[self tableViewClass] alloc] initWithFrame:[self tableViewFrame] style:[self tableViewStyle]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if (self.canPullToRefresh)
    {
        [_tableView setPullDownViewDelegate:self];
    }
    
    [self.view addSubview:_tableView];
    
    _findView = [[TUIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _findView.opaque = YES;
    _findView.backgroundColor = [TUIColor blueColor];
    
    
    _findView.drawRect = ^(TUIView *v, CGRect rect) {
        CGContextRef ctx = TUIGraphicsGetCurrentContext();
        CGRect b = v.bounds;
        CGFloat topColor = 237.0/255.0;
        CGFloat bottomColor = 217.0/255.0;
        CGFloat topColors[] = {topColor,topColor,topColor,1.0};
        CGFloat bottomColors[] = {bottomColor,bottomColor,bottomColor,1.0};
        CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height), topColors, CGPointMake(0, 0), bottomColors);
        [[TUIColor colorWithWhite:130.0/255.0 alpha:1.0] set];
        CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
    };
    
    textField = [[TUITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    textField.opaque = NO;
    textField.rightButton = textField.clearButton;
    textField.drawFrame = TUITextViewSearchFrame();
    textField.contentInset = TUIEdgeInsetsMake(5, 10, 5, 11);
    textField.font = [TUIFont fontWithName:@"HelveticaNeue" size:13];
    textField.textColor = [TUIColor colorWithWhite:0.2 alpha:1.0];
    textField.delegate = self;
    textField.layout = ^(TUIView * v){
        return CGRectInset(v.superview.bounds, 10, 5);
    };
    
    [_findView addSubview:textField];
    [textField release];
    
    [self setupToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.topFadeView removeFromSuperview];
    self.topFadeView = [[[TUIView alloc] init] autorelease];
    BOOL bleedsToTop = [self bleedsToTopOfWindow];
    CGFloat fadeViewHeight = bleedsToTop?8:5;
    [self.topFadeView setDrawRect:^(TUIView * v,CGRect rect){
        CGContextRef ctx = TUIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, rect);
        CGFloat colorValue = bleedsToTop?1:0;
        CGFloat colorTop[] = {colorValue, colorValue, colorValue, bleedsToTop?0.6:0.1};
        CGFloat colorBottom[] = {colorValue, colorValue, colorValue, 0.0};
        CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, rect.size.height), colorTop, CGPointZero, colorBottom);
    }];
    
    [self.topFadeView setBackgroundColor:[TUIColor clearColor]];
    [self.topFadeView setMoveWindowByDragging:bleedsToTop];
    [self.topFadeView setUserInteractionEnabled:bleedsToTop];
    [self.topFadeView setFrame:CGRectMake(0, self.view.bounds.size.height - fadeViewHeight - [self toolbarViewHeight], self.view.bounds.size.width, fadeViewHeight)];
    [self.topFadeView setAutoresizingMask:TUIViewAutoresizingFlexibleBottomMargin | TUIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.topFadeView];
    
    self.topFadeView.hidden = (bleedsToTop && self.toolbarViewHeight);
    
    [self.bottomFadeView removeFromSuperview];
    if (![self bleedsToBottomOfWindow])
    {
        self.bottomFadeView = [[[TUIView alloc] init] autorelease];
        CGFloat fadeViewHeight = 5;
        [self.bottomFadeView setDrawRect:^(TUIView * v,CGRect rect){
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            CGContextClearRect(ctx, rect);
            CGFloat colorValue = 0;
            CGFloat colorTop[] = {colorValue, colorValue, colorValue, 0.0};
            CGFloat colorBottom[] = {colorValue, colorValue, colorValue, 0.1};
            CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, rect.size.height), colorTop, CGPointZero, colorBottom);
        }];
        
        [self.bottomFadeView setBackgroundColor:[TUIColor clearColor]];
        [self.bottomFadeView setUserInteractionEnabled:NO];
        [self.bottomFadeView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, fadeViewHeight)];
        [self.bottomFadeView setAutoresizingMask:TUIViewAutoresizingFlexibleTopMargin | TUIViewAutoresizingFlexibleWidth];
        [self.view addSubview:self.bottomFadeView];
    }

    self.tableView.frame = [self tableViewFrame];
    
    if (toolbar)
    {
        [toolbar setTitle:self.title];
        [toolbar setBackButtonHidden:self.isRootViewController];
    }
}


- (Class)tableViewClass
{
    return [WTPullToRefreshTableView class];
}
- (TUITableViewStyle)tableViewStyle
{
    return TUITableViewStylePinnedHeader;
}

- (BOOL)isReloading
{
    return _flags.isReloading;
}
- (void)setIsReloading:(BOOL)isReloading
{
    _flags.isReloading = isReloading;
}
- (BOOL)canPullToRefresh
{
    return YES;
}

- (CGFloat)toolbarViewHeight
{
    if (self.showsToolbar)
    {
        return 40.0;
    }
    return 0.0;
}
- (CGFloat)findViewHeight
{
    return 35.0;
}
- (void)setupToolBar
{
    CGFloat toolbarHeight = [self toolbarViewHeight];
    if (toolbarHeight > 0)
    {
        if (toolbar)
        {
            [toolbar release];
        }
        toolbar = [[WMToolbarView alloc] initWithFrame:CGRectZero];
        toolbar.layout = ^(TUIView * v){
            CGSize viewSize = v.superview.bounds.size;
            CGRect toolBarFrame = CGRectMake(0, viewSize.height - toolbarHeight, viewSize.width, toolbarHeight);
            return toolBarFrame;
        };
        [toolbar setBackButtonTarget:self action:@selector(popBack)];
        [self.view addSubview:toolbar];
    }
}
- (CGRect)tableViewFrame
{
    CGRect frame = self.view.bounds;
    frame.size.height -= [self toolbarViewHeight];

    if (_flags.findViewVisible)
    {
        frame.size.height -= [self findViewHeight];
    }
    
    return frame;
}

- (BOOL)bleedsToTopOfWindow
{
    CGRect frameInNSView = self.view.frameInNSView;
    NSView * nsView = self.view.nsView;
    BOOL viewBleedsToTop = frameInNSView.origin.y + frameInNSView.size.height == nsView.bounds.size.height;
    return viewBleedsToTop && ([self toolbarViewHeight] <= 0);
}
- (BOOL)bleedsToBottomOfWindow
{
    return self.view.frameInNSView.origin.y == 0;
}

#pragma mark - Searching

- (void)filterItemsWithQuery:(NSString *)query
{
    
}
- (void)didExitFindMode
{
    
}
- (void)didHitReturnButtonInFindMode
{
    
}

- (void)_startFind
{
    if (_findView.superview == self.view)
    {
        return;
    }
    CGFloat findViewHeight = [self findViewHeight];
    CGFloat toolBarHeight = [self toolbarViewHeight];
    CGRect desRect = CGRectMake(0, self.view.bounds.size.height - toolBarHeight, self.view.bounds.size.width, findViewHeight);
    [CATransaction begin];
    [self.view addSubview:_findView];
    if (toolbar) [self.view bringSubviewToFront:toolbar];
    [_findView setFrame:desRect];
    [CATransaction flush];
    [CATransaction commit];
    desRect.origin.y -= findViewHeight;
    
    _flags.findViewVisible = YES;

    [textField makeFirstResponder];
    [TUIView animateWithDuration:0.3 animations:^{
        [_findView setFrame:desRect];
        [_tableView setFrame:[self tableViewFrame]];
    } completion:^(BOOL finished) {
        _findView.layout = ^(TUIView * v){
            CGRect b = v.superview.bounds;
            return CGRectMake(0, b.size.height - findViewHeight - toolBarHeight, b.size.width, findViewHeight);
        };
    }];
}
- (void)_endFind
{
    _flags.findViewVisible = NO;
    
    CGFloat findViewHeight = [self findViewHeight];
    CGRect desRect = CGRectMake(0, self.view.bounds.size.height - [self toolbarViewHeight], self.view.bounds.size.width, findViewHeight);
    CGRect tableViewFrame = [self tableViewFrame];
    _findView.layout = nil;
    [TUIView animateWithDuration:0.3 animations:^{
        [_findView setFrame:desRect];
        [_tableView setFrame:tableViewFrame];
    } completion:^(BOOL finished) {
        [_findView removeFromSuperview];
    }];
}
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    if (theEvent.modifierFlags & NSCommandKeyMask)
    {
        if (theEvent.keyCode == 3) {
            [self _startFind];
            return YES;
        }
    }
    return [super performKeyEquivalent:theEvent];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldClear:(TUITextField *)aTextField{
    [self _endFind];
    if ([textField text].length > 0)
    {
        [self.tableView reloadAndKeepInTop];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(TUITextField *)aTextField
{
    if ([textField text].length > 0)
    {
        [self didHitReturnButtonInFindMode];
    }
    else
    {
        [self _endFind];
    }
    return NO;
}
- (BOOL)textFieldShouldTabToNext:(TUITextField *)aTextField
{
    return YES;
}
- (void)textViewDidChange:(TUITextView *)textView{
    NSString * qurey = textView.text;
    if (qurey.length > 0) {
        _flags.findMode = YES;
        [self filterItemsWithQuery:qurey];
    }else {
        _flags.findMode = NO;
    }
    [self.tableView reloadAndKeepInTop];
}


- (void)pullToRefreshViewShouldRefresh:(WTPullDownView *)view
{
    
}

#pragma mark - TableView Delegate Datasource

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    return 0;
}
- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    return nil;
}

@end
