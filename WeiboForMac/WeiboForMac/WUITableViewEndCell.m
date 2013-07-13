//
//  WUITableViewEndCell.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-30.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WUITableViewEndCell.h"

@interface WUITableViewEndCell ()

@property (nonatomic, assign) BOOL needsUpdate;
@property (nonatomic, retain) TUIActivityIndicatorView * activityIndicator;

@end

@implementation WUITableViewEndCell

- (void)dealloc
{
    [_error release], _error = nil;
    [_activityIndicator release], _activityIndicator = nil;
    [super dealloc];
}

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.activityIndicator = [[[TUIActivityIndicatorView alloc] initWithActivityIndicatorStyle:TUIActivityIndicatorViewStyleGray] autorelease];
        
        [self addSubview:self.activityIndicator];
    }
    return self;
}

- (void)setLoading:(BOOL)loading
{
    if (_loading != loading)
    {
        _loading = loading;
        
        self.needsUpdate = YES;
    }
}

- (void)setError:(WeiboRequestError *)error
{
    if (_error != error)
    {
        [_error release];
        _error = [error retain];
        
        self.needsUpdate = YES;
    }
}

- (void)setIsEnded:(BOOL)isEnded
{
    if (_isEnded != isEnded)
    {
        _isEnded = isEnded;
        
        self.needsUpdate = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    
    if (!self.activityIndicator.hidden)
    {
        [self.activityIndicator setFrame:CGRectMake(b.size.width/2 - 10, 10, 20.0, 20.0)];
    }
}

- (void)update
{
    self.activityIndicator.hidden = !self.loading;
    
    if (self.activityIndicator.hidden)
    {
        [self.activityIndicator stopAnimating];
    }
    else
    {
        [self.activityIndicator startAnimating];
        [self setNeedsLayout];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.needsUpdate)
    {
        [self update];
    }
    
    CGRect b = self.bounds;
    
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx, rect);
	
    CGContextSetRGBFillColor(ctx, 245.0/255.0, 245.0/255.0, 245.0/255.0, 1.0); // dark at the bottom
    CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, b.size.height));
    
    if (self.isEnded)
    {
        TUIImage * endImage = [TUIImage imageNamed:@"end-of-stream.png" cache:YES];
        
        CGRect endRect = b;
        endRect.size.height = 40;
        
        endRect = ABIntegralRectWithSizeCenteredInRect(endImage.size, endRect);

        [endImage drawInRect:endRect blendMode:kCGBlendModeNormal alpha:0.3];
    }
    
    
    CGContextSaveGState(ctx);
    if (self.error)
    {
        NSString * errorDescription = self.error.errorStringInChinese;
        
        if (!errorDescription)
        {
            NSMutableString * descp = [NSMutableString string];
            
            [descp appendString:NSLocalizedString(@"Error Loading List", nil)];
            
            if (self.error.errorDetailCode && self.error.errorDetailCode != 200)
            {
                [descp appendFormat:@" (%ld)", self.error.errorDetailCode];
            }
            
            errorDescription = descp;
        }
                
        // Draw Background
        TUIEdgeInsets boxInsets = TUIEdgeInsetsMake(10, 28, 10, 28);
        
        CGRect boxRect = b;
        boxRect.size.height = 40;
        boxRect.origin.y = b.size.height - boxRect.size.height;
        boxRect = TUIEdgeInsetsInsetRect(boxRect, boxInsets);
        
        CGContextSetGrayFillColor(ctx, 0.7, 1.0);
        CGContextFillRoundRect(ctx, CGRectOffset(boxRect, 0, 1), boxRect.size.height / 2);
        
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, [TUIColor colorWithWhite:1.0 alpha:1.0].CGColor);
        CGContextSetGrayFillColor(ctx, 0.8, 1.0);
        CGContextFillRoundRect(ctx, boxRect, boxRect.size.height / 2);
        
        // Draw Text
        TUIFont * font = [TUIFont defaultFontOfSize:12];
        
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, [TUIColor colorWithWhite:0.45 alpha:1.0].CGColor);
        CGContextSetGrayFillColor(ctx, 1.0, 1.0);
        
        CGSize textSize = [errorDescription ab_sizeWithFont:font constrainedToSize:boxRect.size];
        CGRect textRect = ABIntegralRectWithSizeCenteredInRect(textSize, boxRect);
        
        [errorDescription ab_drawInRect:textRect withFont:font lineBreakMode:TUILineBreakModeTailTruncation alignment:TUITextAlignmentCenter];
    }
    CGContextRestoreGState(ctx);
}

@end
