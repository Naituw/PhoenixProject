//
//  WMUserProfileTableHeaderView.m
//  WeiboForMac
//
//  Created by 吴 天 on 12-8-26.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMUserProfileTableHeaderView.h"
#import "WTActionWebImageView.h"
#import "TUIKit.h"
#import "TUIImage+UIDrawing.h"

@interface WMUserProfileTableHeaderView ()
@property (nonatomic, retain) WTActionWebImageView * avatarView;
@property (nonatomic, retain) TUITextRenderer * nameRenderer;
@property (nonatomic, retain) TUITextRenderer * locationRenderer;
@property (nonatomic, retain) TUITextRenderer * userIDRenderer;
@end

@implementation WMUserProfileTableHeaderView
@synthesize userViewController = _userViewController;
@synthesize nameRenderer = _nameRenderer;
@synthesize locationRenderer = _locationRenderer;
@synthesize userIDRenderer = _userIDRenderer;

- (void)dealloc
{
    [_nameRenderer release], _nameRenderer = nil;
    [_locationRenderer release], _locationRenderer = nil;
    [_userIDRenderer release], _userIDRenderer = nil;
    [_avatarView release], _avatarView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [TUIColor clearColor];
        
        self.moveWindowByDragging = YES;
        
        self.nameRenderer = [[[TUITextRenderer alloc] init] autorelease];
        self.locationRenderer = [[[TUITextRenderer alloc] init] autorelease];
        self.userIDRenderer = [[[TUITextRenderer alloc] init] autorelease];
        self.textRenderers = [NSArray arrayWithObjects:self.nameRenderer, self.locationRenderer, self.userIDRenderer, nil];
        
        self.avatarView = [[[WTActionWebImageView alloc] init] autorelease];
        self.avatarView.backgroundColor = [TUIColor clearColor];
        self.avatarView.target = self;
        self.avatarView.action = @selector(viewAvatar:);
        self.avatarView.frame = CGRectMake(12, frame.size.height - 60, 50, 50);
        
        [self addSubview:self.avatarView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect b = self.bounds;
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    [[[self superview] backgroundColor] set];
    CGContextFillRect(ctx, rect);
    
    CGRect rectToDraw = CGRectMake(70, b.size.height - 28, b.size.width - 50.0, 17.0);
    self.nameRenderer.frame = rectToDraw;
    [self.nameRenderer draw];
    
    rectToDraw.size.height = 15.0;
    
    rectToDraw.origin.y -= 18.0;
    self.locationRenderer.frame = rectToDraw;
    [self.locationRenderer draw];
    
    rectToDraw.origin.y -= 15.0;
    self.userIDRenderer.frame = rectToDraw;
    [self.userIDRenderer draw];
}

- (void)setName:(NSString *)name{
    TUIAttributedString * string = [TUIAttributedString stringWithString:name];
    string.font = [TUIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    string.color = [TUIColor colorWithWhite:66.0/255.0 alpha:1.0];
    [string setAlignment:TUITextAlignmentLeft lineBreakMode:TUILineBreakModeTailTruncation];
    [self.nameRenderer setAttributedString:string];
}
- (void)setUserID:(NSString *)uid{
    NSString * theString = [NSString stringWithFormat:@"#%@",uid];
    TUIAttributedString * string = [TUIAttributedString stringWithString:theString];
    string.font = [TUIFont fontWithName:@"HelveticaNeue" size:12];
    string.color = [TUIColor colorWithWhite:90.0/255.0 alpha:1.0];
    [string setAlignment:TUITextAlignmentLeft lineBreakMode:TUILineBreakModeTailTruncation];
    [self.userIDRenderer setAttributedString:string];
}
- (void)setLocation:(NSString *)location{
    if (location.length == 0) {
        location = NSLocalizedString(@"Earth", nil);
    }
    TUIAttributedString * string = [TUIAttributedString stringWithString:location];
    string.font = [TUIFont fontWithName:@"HelveticaNeue" size:12];
    string.color = [TUIColor colorWithWhite:90.0/255.0 alpha:1.0];
    [string setAlignment:TUITextAlignmentLeft lineBreakMode:TUILineBreakModeTailTruncation];
    [self.locationRenderer setAttributedString:string];
}

- (void)setAvatarURL:(NSString *)url
{
    [self.avatarView setImageWithURL:[NSURL URLWithString:url]
                      drawingStyle:WMWebImageDrawingStyleMacAvatar];
}

- (void)viewAvatar:(id)sender
{
    if ([self.userViewController respondsToSelector:@selector(viewAvatar:)])
    {
        [self.userViewController performSelector:@selector(viewAvatar:) withObject:sender];
    }
}

@end
