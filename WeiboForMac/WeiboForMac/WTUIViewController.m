//
//  WTUIViewController.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUIViewController.h"
#import "WTUINavigationItem.h"
#import "WTUINavigationController.h"
#import "TUIKit.h"
#import "WUIView.h"

@interface WTUIViewController ()
{
    struct {
        unsigned int needsRelayout:1;
    } _flags;
}

@end

@implementation WTUIViewController
@synthesize title = _title,navigationItem, navigationController,toolbarItems,contentSizeForViewInPopover;

- (id)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self=[super init])) {
        _contentSizeForViewInPopover = CGSizeMake(320,1100);
        //_hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)dealloc
{
    [_navigationItem release];
    [_title release];
    [_toolbarItems release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    WTUIViewController * result = [super copyWithZone:zone];
    result.title = [self.title.copy autorelease];
    return result;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view.nsWindow makeFirstResponder:self];
}

- (WTUINavigationItem *)navigationItem
{
    if (!_navigationItem) {
        _navigationItem = [[WTUINavigationItem alloc] initWithTitle:self.title];
    }
    return _navigationItem;
}


- (id)_nearestParentViewControllerThatIsKindOf:(Class)c
{
    TUIViewController *controller = [self parentViewController];
    
    while (controller && ![controller isKindOfClass:c]) {
        controller = [controller parentViewController];
    }
    
    return controller;
}

- (WTUINavigationController *)navigationController
{
    return [self _nearestParentViewControllerThatIsKindOf:[WTUINavigationController class]];
}

- (void)setParentViewController:(TUIViewController *)parentViewController
{
    [super setParentViewController:parentViewController];
    
    if ([parentViewController isKindOfClass:[WTUIViewController class]])
    {
        self.windowIdentifier = [(WTUIViewController *)parentViewController windowIdentifier];
    }
}

- (TUIView *)shadowView
{
    TUIView * view = [[TUIView alloc] initWithFrame:CGRectZero];
    [view setBackgroundColor:[TUIColor clearColor]];
    
    [view setDrawRect:^(TUIView * v, CGRect rect){
        CGContextRef ctx = TUIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, rect);
        TUIImage * image = [TUIImage imageNamed:@"column-shadow.png" cache:YES];
        
        CGContextDrawImage(ctx, rect, image.CGImage);
    }];
    
    view.alpha = 0.75;
    
    return [view autorelease];
}

- (void)loadView
{
    if (!_view)
    {
        CGRect frame = CGRectMake(0, 0, 100, 100);
        if (!CGRectIsEmpty(self.initialBounds))
        {
            frame= self.initialBounds;
        }
        _view = [[WUIView alloc] initWithFrame:frame];
    }
}

- (TUIView *)view
{
	if(!_view) {
		[self loadView];
        [_view setNextResponder:self];
		[self viewDidLoad];
	}
	return _view;
}

#define kBoxShadowViewTag 4365

- (BOOL)boxShadowAppended
{
    return [self.view viewWithTag:kBoxShadowViewTag] && [self.view viewWithTag:kBoxShadowViewTag + 1];
}

- (void)appendBoxShadow
{
    if ([self boxShadowAppended])
    {
        return;
    }
    
    [self removeBoxShadow];
        
    TUIView * leftShadow = [self shadowView];
    leftShadow.frame = CGRectMake(-112, 0, 112, self.view.frame.size.height);
    leftShadow.tag = kBoxShadowViewTag;
    leftShadow.autoresizingMask = TUIViewAutoresizingFlexibleHeight | TUIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:leftShadow];
    
    TUIView * rightShadow = [self shadowView];
    rightShadow.frame = CGRectMake(self.view.frame.size.width, 0, 112, self.view.frame.size.height);
    rightShadow.tag = kBoxShadowViewTag + 1;
    rightShadow.transform = CGAffineTransformMakeScale(-1, 1);
    rightShadow.autoresizingMask = TUIViewAutoresizingFlexibleHeight | TUIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:rightShadow];
}

- (void)removeBoxShadow
{
    [[self.view viewWithTag:kBoxShadowViewTag] removeFromSuperview];
    [[self.view viewWithTag:kBoxShadowViewTag + 1] removeFromSuperview];
}

- (void)setNeedsRelayout
{
    _flags.needsRelayout = YES;
}

- (void)relayout
{
    // subclass can implement
}

- (void)relayoutIfNeeded
{
    if (_flags.needsRelayout)
    {
        [self relayout];
        _flags.needsRelayout = NO;
    }
}

@end
