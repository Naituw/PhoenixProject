//
//  WMStatusItemMenuView.m
//  WeiboForMac
//
//  Created by 吴 天 on 12-9-2.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMStatusItemMenuView.h"
#import "TUIKit.h"
#import "TUIStringDrawing.h"
#import "WTWebImageView.h"
#import "WTCGAdditions.h"
#import "Weibo.h"
#import "WeiboAccount.h"
#import "WeiboUser.h"

@interface WTMenuTableView : TUITableView

@end

@implementation WTMenuTableView
- (TUIView *)hitTest:(CGPoint)point withEvent:(id)event
{
    CGPoint fixedPoint = point;
    fixedPoint.y -= 0;
    return [super hitTest:fixedPoint withEvent:event];
}
@end

#pragma mark - WMStatusItemMenuViewCell
@interface WMStatusItemMenuViewCell : TUITableViewCell
@property (nonatomic, retain) NSString * imagePartialName;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, assign) BOOL hovering;
@property (nonatomic, assign) BOOL lastCell;
@property (nonatomic, assign) BOOL highlightImage;

- (void)flashSelection;

@end

@implementation WMStatusItemMenuViewCell
@synthesize imagePartialName = _imagePartialName;
@synthesize text = _text;
@synthesize hovering = _hovering;
@synthesize lastCell = _lastCell;
- (void)dealloc
{
    [_imagePartialName release], _imagePartialName = nil;
    [_text release], _text = nil;
    [super dealloc];
}
- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [TUIColor clearColor];
    }
    return self;
}
- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];
    self.hovering = YES;
    [self redraw];
}
- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];
    self.hovering = NO;
    [self redraw];
}
- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    return YES;
}
- (void)drawRect:(CGRect)rect
{
    CGRect b = self.bounds;
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    BOOL hovering = self.hovering;
    if (hovering) {
        BOOL oldFashion = YES;
        if (oldFashion)
        {
            CGFloat colorA[] = { 81.0/255.0, 113.0/255.0, 245.0/255.0, 1.0 };
            CGFloat colorB[] = { 26.0/255.0,68.0/255.0, 243.0/255.0, 1.0 };
            CGContextDrawLinearGradientBetweenPoints(ctx,
                                                     CGPointMake(0, b.size.height)  , colorA,
                                                     CGPointMake(0, 0), colorB);
        }
        else
        {
            CGFloat colorA[] = { 98.0/255.0, 198.0/255.0, 250.0/255.0, 1.0 };
            CGFloat colorB[] = { 90.0/255.0, 103.0/255.0, 233.0/255.0, 1.0 };
            CGContextDrawLinearGradientBetweenPoints(ctx,
                                                     CGPointMake(0, b.size.height)  , colorA,
                                                     CGPointMake(0, 0), colorB);
            
            CGContextSetGrayFillColor(ctx, 1.0, 0.6);
            CGContextFillRect(ctx, CGRectMake(0, b.size.height - 1, b.size.width, 1));
        }
    }
    else {
        CGContextSetGrayFillColor(ctx, 1, 1);
        CGContextFillRect(ctx, b);
    }
    
    if (!self.lastCell)
    {
        CGContextSetGrayFillColor(ctx, 0.9, 1.0);
        //CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
    }
    
    CGFloat padding = 10;
    
    if (self.imagePartialName)
    {
        NSString * state = (self.highlightImage)?@"blue":@"gray";
        if (hovering)
        {
            state = @"white";
        }
        NSImage * image = [NSImage imageNamed:[NSString stringWithFormat:@"menu-%@-%@",self.imagePartialName,state]];
        if (image)
        {
            CGSize imageSize = image.size;
            CGRect rectForImage = CGRectMake(0, 0, 30 + padding, b.size.height);
            CGRect imageRect = ABIntegralRectWithSizeCenteredInRect(imageSize, rectForImage);
            [image drawInRect:imageRect fromRect:CGRectMake(0, 0, imageSize.width, imageSize.height) operation:NSCompositeSourceAtop fraction:1.0];
        }
    }
    
    CGFloat textLeft = 30 + padding;
    
    TUIAttributedString * s = [TUIAttributedString stringWithString:self.text];
    s.font = [TUIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    s.color = [TUIColor colorWithWhite:hovering?1:0.3 alpha:1.0];
    CGFloat textHeight = [s ab_size].height;
    CGRect textRect = CGRectMake(textLeft, (b.size.height - textHeight)/2, b.size.width - textLeft - padding, textHeight);
    [s ab_drawInRect:textRect];
}

- (void)flashSelection
{
    [self setHovering:YES];
    [self redraw];
        
    [TUIView animateWithDuration:0.02 delay:0.0 curve:TUIViewAnimationCurveEaseInOut animations:^{
        [self setHovering:NO];
        [self redraw];

    } completion:^(BOOL finished) {
        [TUIView animateWithDuration:0.02 delay:0.02 curve:TUIViewAnimationCurveEaseInOut animations:^{
            [self setHovering:YES];
            [self redraw];
        } completion:^(BOOL finished) {
            
        }];
    }];
}

@end

#pragma mark - WMStatusItemMenuSectionView

@interface WMStatusItemMenuSectionView : WUIView
@property (nonatomic, retain) WTWebImageView * avatarView;
@property (nonatomic, retain) NSString * screenName;
@end

@implementation WMStatusItemMenuSectionView
@synthesize avatarView = _avatarView;
@synthesize screenName = _screenName;
- (void)dealloc
{
    [_avatarView release], _avatarView = nil;
    [_screenName release], _screenName = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [TUIColor clearColor];
        
        self.avatarView = [[[WTWebImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.avatarView.frame = CGRectMake(frame.size.width - 26 - 5, 5 + 5, 26, 26);
        self.avatarView.autoresizingMask = TUIViewAutoresizingFlexibleLeftMargin;
        
        self.avatarView.layer.borderColor = [TUIColor colorWithWhite:0.4 alpha:1.0].CGColor;
        self.avatarView.layer.borderWidth = 1;
        self.avatarView.layer.cornerRadius = 3;
        self.avatarView.layer.masksToBounds = YES;
        
        [self addSubview:self.avatarView];
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGFloat paddingBottom = 4;
    
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGFloat topColor[] = {0.93,0.94,0.95,1.0};
    CGFloat bottomColor[] = {0.83,0.84,0.85,1.0};
    CGPoint top = CGPointMake(0, rect.size.height);
    CGPoint bottom = CGPointMake(0, paddingBottom);
    CGContextDrawLinearGradientBetweenPoints(ctx, top, topColor, bottom, bottomColor);
    
    CGRect topDark = CGRectMake(0, rect.size.height - 1, rect.size.width, 1);
    CGRect topLight = CGRectMake(0, rect.size.height - 2, rect.size.width, 1);
    CGRect bottomDark = CGRectMake(0, paddingBottom, rect.size.width, 1);
    
    CGContextSetGrayFillColor(ctx, 0.57, 1.0);
    CGContextFillRect(ctx, topDark);
    CGContextFillRect(ctx, bottomDark);
    
    CGContextSetGrayFillColor(ctx, 1.0, 1.0);
    CGContextFillRect(ctx, topLight);
        
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, [TUIColor whiteColor].CGColor);
    
    TUIAttributedString * name = [TUIAttributedString stringWithString:self.screenName];
    [name setAlignment:TUITextAlignmentLeft lineBreakMode:TUILineBreakModeTailTruncation];
    name.font = [TUIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    name.color = [TUIColor colorWithWhite:0.2 alpha:1.0];
    
    CGFloat textHeight = [name ab_sizeConstrainedToWidth:CGFLOAT_MAX].height;
    
    CGRect nameRect = CGRectZero;
    nameRect.origin = CGPointMake(5, (rect.size.height - paddingBottom - textHeight)/2 + paddingBottom);
    nameRect.size = CGSizeMake(rect.size.width - 30 - 10 - 5, textHeight);

    [name ab_drawInRect:nameRect];
}
@end


#pragma mark - WMStatusItemMenuView

@interface WMStatusItemMenuView ()
@property (nonatomic, retain) WTMenuTableView * tableView;
@end

@implementation WMStatusItemMenuView
@synthesize tableView = _tableView;

- (void)dealloc
{
    [_tableView release], _tableView = nil;
    [super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        TUINSView * hostView = [[TUINSView alloc] initWithFrame:frame];
        [hostView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
        [self addSubview:hostView];
        [hostView release];
        
        self.tableView = [[[WTMenuTableView alloc] initWithFrame:frame] autorelease];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [TUIColor whiteColor];
        self.tableView.alwaysBounceVertical = YES;
        [hostView setRootView:self.tableView];
    }
    
    return self;
}

+ (CGFloat)defaultWidth
{
    return 220;
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}
- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
}
- (BOOL)acceptsFirstResponder
{
    return YES;
}

#pragma mark - TUITableView Delegate & Datasource
- (NSInteger)numberOfAccounts
{
    return [[[Weibo sharedWeibo] accounts] count];
}

- (NSString *)imagePartialNameAtIndex:(NSInteger)index{
    switch (index) {
        case 0:return @"timeline";
        case 1:return @"mentions";
        case 2:return @"comments";
        case 3:return @"messages";
        case 4:return @"followers";
        default:return nil;
    }
}
- (NSInteger)numberOfSectionsInTableView:(TUITableView *)tableView
{
    // 最后一个Section是发新微博
    return [self numberOfAccounts] + 1;
}
- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (section < [self numberOfAccounts])
    {
        // 目前有五个 新微博、提及、评论、私信、粉丝
        return 5;
    }
    // 新微博
    return 1;
}
- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    return 24;
}
- (TUITableViewCell *)accountCellForRow:(NSInteger)row
{
    return nil;
}
- (NSString *)textForCellAtIndexPath:(TUIFastIndexPath *)indexPath
{
    if (indexPath.section == [self numberOfAccounts])
    {
        // 发新微博
        return NSLocalizedString(@"New Weibo", nil);
    }
    
    return @[NSLocalizedString(@"status_bar_tweets_key", nil),
             NSLocalizedString(@"status_bar_mentions_key", nil),
             NSLocalizedString(@"status_bar_comments_key", nil),
             NSLocalizedString(@"status_bar_messages_key", nil),
             NSLocalizedString(@"status_bar_followers_key", nil),][indexPath.row];
}
- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    WMStatusItemMenuViewCell *cell = reusableTableCellOfClass(tableView, WMStatusItemMenuViewCell);
    cell.lastCell = (indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection:indexPath.section]);
    cell.text = [self textForCellAtIndexPath:indexPath];
    cell.highlightImage = NO;
    cell.imagePartialName = [self imagePartialNameAtIndex:indexPath.row];
    if (indexPath.section == [self numberOfAccounts])
    {
        cell.imagePartialName = nil;
    }
    else if ([self.delegate respondsToSelector:@selector(menuView:shouldHighlightImageAtIndex:forAccount:)])
    {
        WeiboAccount * account = [[Weibo sharedWeibo] accounts][indexPath.section];
        cell.highlightImage = [self.delegate menuView:self shouldHighlightImageAtIndex:indexPath.row forAccount:account];
    }

    return cell;
}
- (TUIView *)tableView:(TUITableView *)tableView headerViewForSection:(NSInteger)section
{
    if ([self numberOfAccounts] > section)
    {
        WeiboAccount * account = [[[Weibo sharedWeibo] accounts] objectAtIndex:section];
        WMStatusItemMenuSectionView * sectionView = [[WMStatusItemMenuSectionView alloc] initWithFrame:CGRectZero];
        [sectionView setFrame:CGRectMake(0, 0, [[self class] defaultWidth], 36 + 4)];
        [sectionView setScreenName:account.user.screenName];
        [sectionView.avatarView setImage:[TUIImage imageWithNSImage:account.profileImage]];
        return [sectionView autorelease];
    }
    else if ([self numberOfAccounts] == section)
    {
        CGFloat lineWidth = 1.0, padding = 5.0;
        TUIView * view = [[TUIView alloc] initWithFrame:CGRectMake(0, 0, [[self class] defaultWidth],lineWidth + 2 * padding)];
        [view setDrawRect:^(TUIView * v, CGRect rect){
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            CGContextSetGrayFillColor(ctx, 1, 1);
            CGContextFillRect(ctx, rect);
            
            CGContextSetGrayFillColor(ctx, 0.8, 1.0);
            CGContextFillRect(ctx, CGRectMake(0, padding, rect.size.width, lineWidth));
        }];
        return [view autorelease];
    }
    return nil;
}
- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event
{
    WMStatusItemMenuViewCell * cell = (WMStatusItemMenuViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[WMStatusItemMenuViewCell class]])
    {
        return;
    }
    
    [cell flashSelection];
    
    if ([self.delegate respondsToSelector:@selector(menuView:didClickRowAtIndexPath:)])
    {        
        double delayInSeconds = 0.08;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.delegate menuView:self didClickRowAtIndexPath:indexPath];
        });
    }
}

- (void)reloadData
{
    [self.tableView reloadData];
}
- (CGFloat)contentHeight
{
    return self.tableView.contentSize.height;
}
- (void)sizeToFit
{
    self.frame = CGRectMake(0, 0, [[self class] defaultWidth], [self contentHeight]);
}
@end
