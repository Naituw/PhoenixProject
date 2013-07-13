//
//  WMUserCell.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-18.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMUserCell.h"
#import "WTHeadImageView.h"
#import "WTCGAdditions.h"
#import "WTUIViewController+NavigationController.h"
#import "WMColumnViewController+CommonPush.h"

@interface WMUserCell ()<TUIViewDelegate>
{
    struct {
		unsigned int isMouseInside:1;
        unsigned int isMouseInSubView:1;
        unsigned int superBlue:1;
        unsigned int isRightMouseDown:1;
        unsigned int isTracking:1;
	} _cellFlags;
}

@property (nonatomic, retain) WTHeadImageView * avatarView;

@end

@implementation WMUserCell

- (void)dealloc
{
    [_avatarView release], _avatarView = nil;
    [_user release], _user = nil;
    [super dealloc];
}

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.avatarView = [[[WTHeadImageView alloc] init] autorelease];
        self.avatarView.autoresizingMask = TUIViewAutoresizingFlexibleBottomMargin;
        self.avatarView.clipsToBounds = YES;
        self.avatarView.backgroundColor = [TUIColor clearColor];
        self.avatarView.userInteractionEnabled = NO;
        
        [self addSubview:self.avatarView];
    }
    return self;
}

- (void)setUser:(WeiboUser *)user
{
    if (_user != user)
    {
        [user retain];
        [_user release];
        _user = user;
        
        if (user)
        {
            CGFloat currentScaleFactor = self.layer.contentsScale;
            
            NSString * avatarURLString = (currentScaleFactor > 1) ? self.user.profileLargeImageUrl : self.user.profileImageUrl;
            NSURL * avatarURL = [NSURL URLWithString:avatarURLString];

            [self.avatarView setImageWithURL:avatarURL drawingStyle:WMWebImageDrawingStyleMacAvatar];
        }
        else
        {
            self.avatarView.image = self.avatarView.defalutPlaceholder;
        }
        
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.frame = CGRectMake(10, 10, 50, 50);
}

- (void)prepareForReuse
{    
    self.avatarView.loading = NO;
    self.avatarView.loaded = NO;
    
    [super prepareForReuse];
}

- (void)willMoveToSuperview:(TUIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview)
    {
        [self.avatarView cancelCurrentImageLoad];
    }
}

- (void)updateViewAnimated
{
    [TUIView animateWithDuration:0.3 animations:^{
        [self redraw];
    }];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];
    if (!_cellFlags.isMouseInside)
    {
        _cellFlags.isMouseInside = YES;
        [self updateViewAnimated];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];
    if (!_cellFlags.isMouseInSubView & _cellFlags.isMouseInside)
    {
        _cellFlags.isMouseInside = NO;
        [self updateViewAnimated];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    _cellFlags.isTracking = YES;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    
    _cellFlags.isTracking = NO;
    
    [self updateViewAnimated];
}

- (CGFloat)accessoryViewWidth
{
    return 0;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGRect b = self.bounds;
    
    WUICellBackgroundColor color = WUICellBackgroundColorNormal;
    
    BOOL highlighted = _cellFlags.isTracking;
    
    if (highlighted)
    {
        color = WUICellBackgroundColorBlue;
    }
    
    WUIDrawCellBackground(ctx, b, color, NO, _cellFlags.isMouseInside);
    
    CGFloat textWidth = b.size.width - 80 - [self accessoryViewWidth];
    
    if (self.user.screenName)
    {
        TUIFont * font = [TUIFont boldDefaultFontOfSize:13.0];
        
        CGFloat gray = 0.2;
        
        if (highlighted)
        {
            gray = 1.0;
        }
        else if (self.nsWindow && !self.nsWindow.isKeyWindow)
        {
            gray = 0.5;
        }
        
        CGRect nameRect = CGRectMake(70, b.size.height - 30, textWidth, 20);
        CGContextSetGrayFillColor(ctx, gray, 1.0);
        [self.user.screenName ab_drawInRect:nameRect withFont:font lineBreakMode:TUILineBreakModeTailTruncation alignment:TUITextAlignmentLeft];
    }
    
    NSString * description = self.user.description;
    
    if (!description.length)
    {
        description = @"暂无介绍";
    }
    
    {
        TUIFont * font = [TUIFont lightDefaultFontOfSize:12];
        
        CGRect textRect = CGRectMake(70, 5, textWidth, b.size.height - 20 - 10 - 5);
        
        CGFloat gray = 0.5;
        
        if (highlighted)
        {
            gray = 1.0;
        }
        
        CGContextSetGrayFillColor(ctx, gray, 1.0);
        [description ab_drawInRect:textRect withFont:font lineBreakMode:TUILineBreakModeWordWrap alignment:TUITextAlignmentLeft];
    }
}

@end
