//
//  WTUserToolbarView.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-2-26.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTUserToolbarView.h"
#import "TUITextRenderer.h"
#import "TUIKit.h"
#import "TUIView+Sizes.h"
#import "TUIImage+UIDrawing.h"
#import "TUIStringDrawing.h"
#import "WTCGAdditions.h"
#import "WTWebImageView.h"

@interface WTUserToolbarView ()
@property (nonatomic, retain) TUIAttributedString * string;
@property (nonatomic, retain) WTWebImageView * avatar;
@end

@implementation WTUserToolbarView
@synthesize string = _string;
@synthesize avatar = _avatar;

- (void)dealloc{
    [_string release], _string = nil;
    [_avatar release], _avatar = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.moveWindowByDragging = YES;
                
        self.avatar = [[[WTWebImageView alloc] init] autorelease];
        self.avatar.clipsToBounds = YES;
        self.avatar.layer.cornerRadius = 3;
        self.avatar.backgroundColor = [TUIColor clearColor];
        self.avatar.size = [self avatarSize];
        self.avatar.userInteractionEnabled = NO;

        [self addSubview:self.avatar];

    }
    return self;
}

- (void)setName:(NSString *)name{
    TUIAttributedString * string = [TUIAttributedString stringWithString:name];
    string.font = [TUIFont fontWithName:@"HelveticaNeue" size:14];
    [string setAlignment:TUITextAlignmentLeft lineBreakMode:TUILineBreakModeTailTruncation];
    self.string = string;
}
- (void)setAvatarImageURL:(NSString *)url
{
    [self.avatar setImageWithURL:[NSURL URLWithString:url]];
}

- (CGSize)avatarSize
{
    return CGSizeMake(24,24);
}
- (CGRect)nameRect
{
    CGFloat totalWidth = self.width;
    CGFloat avatarWidth = [self avatarSize].width;
    CGFloat span = 6;
    CGFloat padding = 80;
    CGFloat maxWidth = totalWidth - 2 * padding - avatarWidth - span;
    
    TUIAttributedString * name = self.string;
    if (name) {
        CGSize  nameSize = [name ab_size];
        CGFloat actualNameWidth = MIN(nameSize.width, maxWidth);
        CGFloat actualTotalWidth = actualNameWidth + span + avatarWidth;
        CGFloat avatarLeft = (totalWidth - actualTotalWidth)/2;
        CGFloat left = avatarLeft + avatarWidth + span;
        CGFloat top = ([self avatarSize].height - nameSize.height)/2 + 5;

        return CGRectMake(left, self.height - top - nameSize.height, actualNameWidth, nameSize.height);
    }
    
    return CGRectZero;
}

- (void)drawRect:(CGRect)rect{
    CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    BOOL drawsAsMainWindow = !self.nsWindow || self.nsWindow.isKeyWindow;
    
    WTCUIDraw(ctx, CGRectInset(b, -5, 0), drawsAsMainWindow);
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 1, [TUIColor whiteColor].CGColor);
    
    // draw texts
    CGRect nameRect = [self nameRect];
    
    self.string.color = [TUIColor colorWithWhite:drawsAsMainWindow?0.3:0.5 alpha:1.0];
    [self.string ab_drawInRect:nameRect];
    
    
    self.avatar.alpha = drawsAsMainWindow?1.0:0.7;
    self.avatar.right = nameRect.origin.x - 6;
    self.avatar.top = self.height - 5;
}

@end
