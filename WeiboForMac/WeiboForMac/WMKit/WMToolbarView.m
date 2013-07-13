//
//  WMToolbarView.m
//  WeiboForMac
//
//  Created by 吴 天 on 12-11-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMToolbarView.h"
#import "WTCGAdditions.h"
#import "TUIKit.h"

@interface WMToolbarView ()
@property (nonatomic, retain) WTWebImageView * imageView;
@property (nonatomic, retain) TUIButton * backButton;
@end

@implementation WMToolbarView
@synthesize title = _title;
@synthesize backButton = _backButton;

- (void)dealloc
{
    [_imageView release], _imageView = nil;
    [_title release], _title = nil;
    [_backButton release], _backButton = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.moveWindowByDragging = YES;
        
        TUIButton * backButton = [TUIButton buttonWithType:TUIButtonTypeCustom];
        [backButton setImage:[TUIImage imageNamed:@"toolbar-back-arrow.png" cache:YES] forState:TUIControlStateNormal];
        [self addSubview:backButton];
        [backButton setMoveWindowByDragging:YES];
        self.backButton = backButton;

        self.imageView = [[[WTWebImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)] autorelease];
        self.imageView.layer.cornerRadius = 3;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.userInteractionEnabled = NO;
        
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.backButton setFrame:CGRectMake(10, self.bounds.size.height - 10 - 19, 14, 19)];
}

- (CGSize)imageViewSize
{
    if (!self.imageView.image && !self.imageView.imageURL)
    {
        return CGSizeMake(0, 0);
    }
    return CGSizeMake(24, 24);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    BOOL drawsAsMainWindow = self.nsWindow.isKeyWindow;
    WTCUIDraw(ctx, CGRectInset(rect, -5, 0), drawsAsMainWindow); // inset to prevent roundcorners
    
    self.imageView.hidden = YES;
    
    if (self.title)
    {
        TUIAttributedString * string = [TUIAttributedString stringWithString:self.title];
        string.font = [TUIFont fontWithName:@"HelveticaNeue" size:14];
        [string setAlignment:TUITextAlignmentLeft lineBreakMode:TUILineBreakModeTailTruncation];
        
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 1, [TUIColor whiteColor].CGColor);
        
        [string setColor:[TUIColor colorWithWhite:drawsAsMainWindow?0.3:0.6 alpha:1.0]];
        
        CGFloat gapWidth = 8;
        CGSize titleSize = [string ab_size];
        titleSize.width = MIN(titleSize.width, rect.size.width / 2);
        
        CGSize imageViewSize = [self imageViewSize];
        
        BOOL showsImageView = imageViewSize.width > 0;
        
        CGSize totalSize = titleSize;
        if (showsImageView)
        {
            totalSize.width += imageViewSize.width + gapWidth;
        }
        
        CGRect totalRect = ABIntegralRectWithSizeCenteredInRect(totalSize, rect);
        
        CGRect textRect = totalRect;
        CGRect imageViewRect = CGRectZero;
        
        if (showsImageView)
        {
            imageViewRect = ABIntegralRectWithSizeCenteredInRect(imageViewSize, totalRect);
            imageViewRect.origin.x = totalRect.origin.x;
            
            textRect.size.width -= (imageViewSize.width + gapWidth);
            textRect.origin.x = (imageViewSize.width + gapWidth + totalRect.origin.x);
        }
        
        [string ab_drawInRect:textRect];
        
        self.imageView.hidden = !showsImageView;
        if (showsImageView)
        {
            self.imageView.frame = imageViewRect;
            self.imageView.alpha = drawsAsMainWindow ? 1.0 : 0.7;
        }
    }
}

- (void)setTitle:(NSString *)title
{
    if (_title != title)
    {
        [_title release];
        _title = [title retain];
        
        [self setNeedsDisplay];
    }
}

- (void)setBackButtonTarget:(id)target action:(SEL)selector
{
    [self.backButton addTarget:target action:selector forControlEvents:TUIControlEventTouchUpInside];
}

- (void)setBackButtonHidden:(BOOL)backButtonHidden
{
    self.backButton.hidden = backButtonHidden;
}

- (BOOL)backButtonHidden
{
    return self.backButton.hidden;
}

@end
