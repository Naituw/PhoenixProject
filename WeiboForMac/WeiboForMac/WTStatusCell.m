//
//  WTStatusCell.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-8-1.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTStatusCell.h"
#import "WTEventHandler.h"
#import "WTUIViewController+NavigationController.h"
#import "WTStatusStreamViewController.h"
#import "WMColumnViewController.h"
#import "WTActiveTextRanges.h"
#import "WMRootViewController.h"
#import "WeiboBaseStatus.h"
#import "WeiboStatus.h"
#import "WeiboLayoutCache.h"
#import "WeiboUser.h"
#import "WeiboComment.h"
#import "WeiboForMacAppDelegate.h"
#import "WeiboBaseStatus+StatusCellAdditions.h"
#import "WeiboMac2Window.h"
#import "WMMediaViewerController.h"
#import "WTCGAdditions.h"
#import "WMUserPreferences.h"
#import "WTImageViewer.h"

#define SCROLLER_WIDTH

@interface WTStatusCell (Private)
- (void)setShouldShowControlPanel:(BOOL) control;
- (void)_setupControls;
- (void)keepPanelOn;
- (void)reply;
- (void)repost;
- (void)viewReplies;
@end

@implementation WTStatusCell

@synthesize avatar , name , content , time ,status, controller = _controller;
@synthesize quotedContent = _quotedContent;

- (void)dealloc
{
    [avatar cancelCurrentImageLoad];
    [_imageContentView cancelCurrentImageLoad];

    [avatar release];
    [name release];
    [content release];
    [_quotedContent release];
    [_imageContentView release];
    [time release];
    
    [controls release];//[panel release];
	[super dealloc];
}


- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.pasteboardDraggingEnabled = YES;
        
        _cellFlags.isMouseInside = NO;
        
        avatar = [[WTHeadImageView alloc] init];
        avatar.autoresizingMask = TUIViewAutoresizingFlexibleBottomMargin;
        avatar.clipsToBounds = YES;
        avatar.backgroundColor = [TUIColor clearColor];
        [self addSubview:avatar];
        
        self.imageContentView = [[[WMStatusImageContentView alloc] init] autorelease];
        self.imageContentView.autoresizingMask = TUIViewAutoresizingFlexibleLeftMargin;
        self.imageContentView.backgroundColor = [TUIColor clearColor];
        [self addSubview:self.self.imageContentView];
        
        self.name = [[[WTTextRenderer alloc] init] autorelease];
        self.content = [[[WTTextRenderer alloc] init] autorelease];
        self.content.delegate = self;
        self.content.clickDelegate = self;
        self.quotedContent = [[[WTTextRenderer alloc] init] autorelease];
        self.quotedContent.delegate = self;
        self.quotedContent.clickDelegate = self;
        self.time = [[[TUITextRenderer alloc] init] autorelease];
        self.textRenderers = [NSArray arrayWithObjects:self.name,self.content,
                              self.quotedContent,self.time, nil];
        
        
        controls = [[TUIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        controls.layout = ^(TUIView *v) {
            CGRect b = v.superview.bounds;
            CGFloat width = 100.0;
            CGFloat height = 20.0;
            return CGRectMake(b.size.width - width - 10 - 10,b.size.height - height - 8,width,height);
        };
        [self _setupControls];
        [self addSubview:controls];
    }
	return self;
}

- (void)_setupControls
{
    viewPic = [[TUIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [viewPic setImage:[TUIImage imageNamed:@"pic.png" cache:YES] 
             forState:TUIControlStateNormal];
    [viewPic setImageEdgeInsets:TUIEdgeInsetsMake(0, 2, 0, 3)];
    [viewPic setDimsInBackground:NO];
    [viewPic addTarget:self action:@selector(viewPhoto:) forControlEvents:TUIControlEventTouchUpInside];
    [viewPic setViewDelegate:self];
    [controls addSubview:viewPic];
    [viewPic release];
    
    viewComment = [[TUIButton alloc] initWithFrame:CGRectMake(25, 0, 20, 20)];
    [viewComment setImage:[TUIImage imageNamed:@"conversation.png" cache:YES] 
                 forState:TUIControlStateNormal];
    [viewComment setImageEdgeInsets:TUIEdgeInsetsMake(0, 2, 0, 3)];
    [viewComment setDimsInBackground:NO];
    [viewComment addTarget:self action:@selector(viewReplies:) forControlEvents:TUIControlEventTouchUpInside];
    [viewComment setViewDelegate:self];
    viewComment.alpha = 0.3;
    [controls addSubview:viewComment];
    [viewComment release];
    
    reply = [[TUIButton alloc] initWithFrame:CGRectMake(50, 0, 20, 20)];
    [reply setImage:[TUIImage imageNamed:@"reply.png" cache:YES] 
           forState:TUIControlStateNormal];
    [reply setImageEdgeInsets:TUIEdgeInsetsMake(0, 3, 0, 3)];
    [reply setDimsInBackground:NO];
    [reply addTarget:self action:@selector(reply:) forControlEvents:TUIControlEventTouchUpInside];
    [reply setViewDelegate:self];
    reply.alpha = 0.3;
    [controls addSubview:reply];
    [reply release];
    
    retweet = [[TUIButton alloc] initWithFrame:CGRectMake(75, 0, 20, 20)];
    [retweet setImage:[TUIImage imageNamed:@"retweet.png" cache:YES] 
           forState:TUIControlStateNormal];
    [retweet setImageEdgeInsets:TUIEdgeInsetsMake(0, 2, 0, 3)];
    [retweet setDimsInBackground:NO];
    [retweet addTarget:self action:@selector(repost:) forControlEvents:TUIControlEventTouchUpInside];
    [retweet setViewDelegate:self];
    retweet.alpha = 0.3;
    [controls addSubview:retweet];
    [retweet release];
    
    [self updateControls];
}

- (BOOL)hasPhoto
{
    return status.thumbnailPic || status.quotedBaseStatus.thumbnailPic;
}
- (BOOL)showsViewPhotoControl
{
    return [self hasPhoto] && ![[WMUserPreferences sharedPreferences] showsThumbImage];
}
- (void)updateControls
{
    BOOL isComment = [status isKindOfClass:[WeiboComment class]];
    [viewPic setHidden:(isComment || ![self showsViewPhotoControl])];
    [viewComment setHidden:isComment];
    [retweet setHidden:isComment];
    [reply setFrame:CGRectMake(isComment?75:50, 0, 20, 20)];
}
- (void)setStatus:(WeiboBaseStatus *)newStatus
{
    if (status != newStatus)
    {
        _cellFlags.drawInBackgroundNextTime = YES;
    }
    SetRetainedIvar(status, newStatus);
    
    [self updateControls];
}

- (BOOL)drawInBackground
{
    if (NO && _cellFlags.drawInBackgroundNextTime)
    {
        _cellFlags.drawInBackgroundNextTime = NO;
        
        return YES;
    }
    
    return NO;
}

- (void)prepareForReuse
{
    status = nil;
    [self.imageContentView setPictures:nil];
    [self.imageContentView reloadImageViews];
    
    self.avatar.loading = NO;
    self.avatar.loaded = NO;
    
    [super prepareForReuse];
}
- (void)willMoveToSuperview:(TUIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview)
    {
        [avatar cancelCurrentImageLoad];
        [self.imageContentView cancelCurrentImageLoad];
    }
}

- (void)prepareForDisplay
{
    controls.alpha = 0;
    avatar.frame = CGRectMake(10,  self.bounds.size.height - 60, 50, 50);
}

- (WTStatusStreamViewController *)streamController{
    if ([_controller isKindOfClass:[WTStatusStreamViewController class]]) {
        return (WTStatusStreamViewController *)_controller;
    }
    return nil;
}

- (NSMenu *)menuForEvent:(NSEvent *)event{
    NSMenu * menu = [[NSMenu alloc] init];

    [_controller addMenuItemsForStatus:status toMenu:menu];
    for (NSMenuItem * item in menu.itemArray) {
        [item setTarget:self];
    }
    return [menu autorelease];
}

- (void)setSelected:(BOOL)s animated:(BOOL)animated
{
    if (s && animated)
    {
        _cellFlags.superBlue = YES;
        [CATransaction begin];
        [self redraw];
        [CATransaction flush];
        [CATransaction commit];
        _cellFlags.superBlue = NO;
    }
    [super setSelected:s animated:NO];
    
    CGFloat duration = 0.0;
    
    if (!s)
    {
        animated = YES; // Always animate cell deselection.
    }
    
    if (animated)
    {
        duration = s?0.5:0.3;
    }
    
    if (duration)
    {
        [TUIView animateWithDuration:duration animations:^{
            [self redraw];
        }];
    }
    else
    {
        [self redraw];
    }
}

- (void)drawRect:(CGRect)rect
{
	CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    CGContextRetain(ctx);
    
    NSString * identifier = self.windowIdentifier;
    NSAssert(identifier != nil, @"window identifier should NOT be nil");

    WeiboLayoutCache * layoutCache = [self.status layoutCacheWithIdentifier:identifier];
    
    WUICellBackgroundColor cellColor = WUICellBackgroundColorNormal;
    if (_cellFlags.superBlue)
    {
        cellColor = WUICellBackgroundColorSuperBlue;
    }
    
    WUIDrawCellBackground(ctx, b, cellColor, self.selected, _cellFlags.isMouseInside);
    
    if (status && [status isKindOfClass:[WeiboStatus class]]) {
        if ([(WeiboStatus *)status favorited]) {
            TUIImage * favoriteBadge = [TUIImage imageNamed:@"badge-favorite.png" cache:YES];
            [favoriteBadge drawInRect:CGRectMake(b.size.width-25, b.size.height-25, 25, 25)];
        }
    }
	    
    // Configure Texts
    {
        // Setup user screen name
        NSString * screenName = self.status.user.screenName;
        if (!screenName) {
            screenName = @"未知";
        }
        BOOL darkText = YES;
        if (self.nsWindow && !self.nsWindow.isKeyWindow)
        {
            darkText = NO;
        }
        TUIAttributedString *s = [TUIAttributedString stringWithString:screenName];
        s.color = [TUIColor colorWithWhite:darkText?0.0:0.3 alpha:1.0];
        s.font = [TUIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        [s setAlignment:TUITextAlignmentLeft lineBreakMode:TUILineBreakModeTailTruncation];
        name.attributedString = s;
    }
    
	// text
    CGFloat relativeWidth = (_cellFlags.isMouseInside ? 120.0:60.0);
    CGRect nameRect = CGRectMake(70, b.size.height-30, b.size.width-80-relativeWidth, 20);
	name.frame = nameRect;
    [name draw];
    
    CGRect panelRect = CGRectMake(b.size.width - 10 - 90, b.size.height - 14 -10, 90, 14);
    panel.frame = panelRect;
    
    if (!_cellFlags.isMouseInside) {
        CGRect timeRect = CGRectMake(b.size.width - 70, b.size.height-30, 50, 20);
        time.frame = timeRect;
        [time draw];
    }
    
    controls.alpha = (_cellFlags.isMouseInside ? 1.0:0.0);
    //panel.alpha = (_cellFlags.isMouseInside ? 1.0:0.0);
    
    
    
    /**
     * @note All CGRect value in layoutCache is filped
     */

#define Fliped(r) CGRectMake(r.origin.x, b.size.height - r.origin.y - r.size.height,\
r.size.width, r.size.height)
    {
        if (!CGRectEqualToRect(Fliped(layoutCache.textFrame), content.frame))
        {
            content.frame = Fliped(layoutCache.textFrame);
        }
        
        [content draw];
    }
    
    if (status.quotedBaseStatus)
    {
        CGFloat lineAlpha = 0.08;
        
        CGContextSetFillColorWithColor(ctx, [TUIColor colorWithWhite:0.0 alpha:lineAlpha].CGColor);
        CGContextFillRect(ctx, Fliped(layoutCache.quoteLineFrame));
        
        if (!CGRectEqualToRect(Fliped(layoutCache.quotedTextFrame), self.quotedContent.frame))
        {
            self.quotedContent.frame = Fliped(layoutCache.quotedTextFrame);
        }
        
        [self.quotedContent draw];

    }
    
    [self updateControls];
    
    if (!viewPic.hidden)
    {
        viewPic.alpha = 0.3;
    }

    if (CGRectIsEmpty(layoutCache.imageContentViewFrame))
    {
        self.imageContentView.hidden = YES;
    }
    else
    {
        self.imageContentView.hidden = NO;
        
        WeiboBaseStatus * imageStatus = self.status;
        if (imageStatus.quotedBaseStatus)
        {
            imageStatus = status.quotedBaseStatus;
        }
        
        self.imageContentView.pictures = imageStatus.pics;
        self.imageContentView.frame = Fliped(layoutCache.imageContentViewFrame);
        [self.imageContentView reloadImageViews];
    }
    
    CGContextRelease(ctx);
}

- (void)updateViewAnimated
{
    [TUIView animateWithDuration:0.3 animations:^{
        [self redraw];
    }];
}

- (void)forceToTakeMouseOut
{
    if (_cellFlags.isMouseInside) {
        _cellFlags.isMouseInside = NO;
        _cellFlags.isMouseInSubView = NO;
        
        [self.nsView invalidateHoverForView:self];
        [self updateViewAnimated];
    }
}
- (void)setWasSeened
{
    self.status.wasSeen = YES;
}


- (void)scrollWheel:(NSEvent *)theEvent
{
    [super scrollWheel:theEvent];
    [self forceToTakeMouseOut];
}

- (void)mouseEntered:(NSEvent *)event onSubview:(TUIView *)subview
{
    if (!self.nsWindow.isKeyWindow)
    {
        return;
    }
    
    if (!_cellFlags.isMouseInSubView) {
        _cellFlags.isMouseInSubView = YES;
    }
    if (!_cellFlags.isMouseInside) {
        _cellFlags.isMouseInside = YES;
        [self updateViewAnimated];
    }
}

- (void)mouseExited:(NSEvent *)event fromSubview:(TUIView *)subview
{
    if (!self.nsWindow.isKeyWindow)
    {
        return;
    }
    
    // must confirm it is childview.
    if (_cellFlags.isMouseInSubView) {
        _cellFlags.isMouseInSubView = NO;
    }
    if (![self eventInside:event]) {
        _cellFlags.isMouseInside = NO;
        [self updateViewAnimated];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];
    if (!_cellFlags.isMouseInside) {
        _cellFlags.isMouseInside = YES;
        [self updateViewAnimated];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];
    if (!_cellFlags.isMouseInSubView & _cellFlags.isMouseInside) {
        _cellFlags.isMouseInside = NO;
        [self updateViewAnimated];
    }
}

- (void)mouseUp:(NSEvent *)event fromSubview:(TUIView *)subview
{
    if (subview == avatar) {
        [self viewUserDetails:self];
    }
    if (subview == avatar || subview == reply|| subview == retweet|| subview == viewPic||
        subview == viewComment || [subview isDescendantOfView:self.imageContentView]) {
        [self forceToTakeMouseOut];
    }
}

- (void)view:(TUIView *)v mouseEntered:(NSEvent *)event{
    [TUIView animateWithDuration:0.3 animations:^{
        v.superview.alpha = 0.4;
        v.alpha = 0.8;
    }];
}
- (void)view:(TUIView *)v mouseExited:(NSEvent *)event{
    [TUIView animateWithDuration:0.3 animations:^{
        if ([self eventInside:event]) {
            v.superview.alpha = 1.0;
        }
        v.alpha = 0.3;
    }];
}

- (void)rightMouseDown:(NSEvent *)theEvent{
    _cellFlags.isRightMouseDown = YES;
    [super rightMouseDown:theEvent];
}
- (void)rightMouseUp:(NSEvent *)theEvent{
    [super rightMouseUp:theEvent];
    _cellFlags.isRightMouseDown = NO;
}

- (NSArray *)activeRangesForTextRenderer:(TUITextRenderer *)t{
    if (t == self.content)
    {
        return status.activeRanges.activeRanges;
    }
    else
    {
        return status.quotedBaseStatus.activeRanges.activeRanges;
    }
}
- (void)textRenderer:(WTTextRenderer *)renderer didClickActiveRange:(ABFlavoredRange *)activeRange
{
    WTStatusListViewController * controller = (WTStatusListViewController *)[self firstAvailableViewController];
    if ([controller isKindOfClass:[WTStatusListViewController class]])
    {
        [controller textRenderer:renderer didClickActiveRange:activeRange];
    }
}

#pragma mark - Responds to Context Menu

- (void)viewWeiboSourceApp:(id)sender
{
    WeiboStatus * s = (WeiboStatus *)status;
    [WTEventHandler openURL:s.sourceUrl];
}

- (void)viewPhoto:(id)sender
{
    WeiboBaseStatus * s = status;
    if (s.quotedBaseStatus)
    {
        s = s.quotedBaseStatus;
    }
    
    if (!s.pics.count)
    {
        return;
    }
    
    WeiboPicture * picture = s.pics[0];
    
    if ([picture.middleImage hasSuffix:@".gif"])
    {
        [WTEventHandler openURL:picture.originalImage];
    }
    else
    {
        WMMediaViewerController * controller = [WMMediaViewerController controllerForMedia:picture sourceView:nil sourcePoint:CGPointZero];
        [controller startMediaLoading];
    }
    
    [self forceToTakeMouseOut];
}
- (void)deleteWeibo:(id)sender
{
    [self.controller performSelector:_cmd withObject:self];
}
- (void)viewReplies:(id)sender
{
    [self.controller performSelector:_cmd withObject:self];
}
- (void)reply:(id)sender
{
    [self.controller performSelector:_cmd withObject:self];
}
- (void)repost:(id)sender
{
    [self.controller performSelector:_cmd withObject:self];
}
- (void)viewUserDetails:(id)sender
{
    [self.controller performSelector:_cmd withObject:self];
}
- (void)viewOnWebPage:(id)sender
{
    [self.controller performSelector:_cmd withObject:self];
}
- (void)viewActiveRange:(id)sender
{
    [self.controller performSelector:_cmd withObject:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    return [self.controller validateMenuItemWithAction:menuItem.action cell:self];
}

#pragma mark - Pasteboard Dragging

- (id<NSPasteboardWriting>)representedPasteboardObject
{
    if ([self.status isKindOfClass:[WeiboStatus class]])
    {
        return [(WeiboStatus *)self.status webLink];
    }
    else
    {
        return [NSString stringWithFormat:@"%@:%@",self.status.user.screenName, self.status.text];
    }
}

@end
