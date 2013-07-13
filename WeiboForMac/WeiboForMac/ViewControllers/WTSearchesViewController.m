//
//  WTSearchesViewController.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTSearchesViewController.h"
#import "WMTrendTitleCell.h"
#import "WTCallback.h"
#import "WMRootViewController.h"
#import "WeiboForMacAppDelegate.h"
#import "TUIKit.h"
#import "WeiboAPI+StatusMethods.h"
#import "WeiboRequestError.h"
#import "WMColumnViewController+CommonPush.h"
#import "WTUIViewController+NavigationController.h"

@interface WTSearchesViewController ()

@property (nonatomic, assign) BOOL trendsLoaded;

@end

@implementation WTSearchesViewController
@synthesize account = _account, trends = _trends;

- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_account release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    WTSearchesViewController * result = [super copyWithZone:zone];
    [result setAccount:self.account];
    return  result;
}

- (void)viewDidLoad
{    
    CGFloat findViewHeight = 45.0;
    
    self.containerView.opaque = NO;
    self.containerView.backgroundColor = [TUIColor colorWithWhite:247.0/255.0 alpha:1.0];
    self.tableView.layout = ^(TUIView * v){
        CGRect frame = v.superview.bounds;
        frame.size.height -= findViewHeight;
        return frame;
    };
    
    TUIView * _findView = [[TUIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _findView.opaque = YES;
    _findView.moveWindowByDragging = YES;
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
    _findView.layout = ^(TUIView * v){
        CGRect b = v.superview.bounds;
        return CGRectMake(0, b.size.height - findViewHeight, b.size.width, findViewHeight);
    };
    [self.containerView addSubview:_findView];
    [_findView release];
    
    textField = [[TUITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    textField.opaque = NO;
    textField.rightButton = textField.clearButton;
    textField.drawFrame = TUITextViewSearchFrame();
    textField.contentInset = TUIEdgeInsetsMake(6, 10, 6, 11);
    textField.font = [TUIFont fontWithName:@"HelveticaNeue" size:13];
    textField.textColor = [TUIColor colorWithWhite:0.2 alpha:1.0];
    textField.delegate = self;
    textField.layout = ^(TUIView * v){
        CGRect frame = CGRectInset(v.superview.bounds, 10, 0);
        frame.origin.y += 8;
        frame.size.height -= 18;
        return frame;
    };
    
    [_findView addSubview:textField];
    [textField release];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[textField makeFirstResponder];
    [textField performSelector:@selector(makeFirstResponder) withObject:nil afterDelay:0.1];
    [textField setSelectedRange:NSMakeRange(0, textField.text.length)];
    
    if (!self.trendsLoaded)
    {
        [self performSelector:@selector(refreshTrends) withObject:nil afterDelay:0.8];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
- (void)refreshTrends
{
    WTCallback * callback = WTCallbackMake(self, @selector(trendsResponse:info:), nil);
    WeiboAPI * api = [self.account authenticatedRequest:callback];
    [api trendsInHourly];
}
- (void)trendsResponse:(id)returnValue info:(id)info{
    if ([returnValue isKindOfClass:[WeiboRequestError class]]) {
        return;
    }
    self.trendsLoaded = YES;
    self.trends = returnValue;
    [self.tableView reloadData];
}


#pragma mark - Text Field Delegates
- (BOOL)textFieldShouldReturn:(TUITextField *)aTextField
{
    NSString * text = [aTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length > 0)
    {
        [self.columnViewController pushTrendViewControllerWithTrendName:text account:self.account];
    }
    return NO;
}



#pragma mark - Grouped Table View
- (Class)cellClass{
    return [WMTrendTitleCell class];
}
- (NSInteger)numberOfSectionsInTableView:(TUITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section{
    if (!self.trendsLoaded)
    {
        return 1;
    }
    return self.trends.count;
}
- (void)configureCell:(WMGroupedCell *)aCell atIndexPath:(TUIFastIndexPath *)indexPath
{    
    WMTrendTitleCell * cell = (WMTrendTitleCell *)aCell;
    
    cell.loading = !self.trendsLoaded;
    if (!cell.loading)
    {
        cell.text = [self.trends objectAtIndex:indexPath.row];
    }
}
- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event{
    if (!self.trendsLoaded)
    {
        return;
    }
    NSString * query = [self.trends objectAtIndex:indexPath.row];
    [self.columnViewController pushTrendViewControllerWithTrendName:query account:self.account];
}

@end
