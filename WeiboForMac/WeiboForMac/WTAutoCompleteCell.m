//
//  WTAutoCompleteCell.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-31.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTAutoCompleteCell.h"
#import "WeiboAutocompleteResultItem.h"
#import "WTWebImageView.h"
#import "WTCGAdditions.h"
#import "TUIKit.h"

@implementation WTAutoCompleteCell
@synthesize result, imageView;

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        imageView = [[WTWebImageView alloc] initWithFrame:CGRectMake(7, 7, 26, 26)];
        imageView.layer.cornerRadius = 3.0;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        _flags.superBlue = NO;
    }
    return self;
}

- (void)dealloc{
    [result release];
    [imageView release];
    [super dealloc];
}
- (void)_requestImage{
    [imageView setImage:nil];
    [imageView setImageWithURL:[result autocompleteImageURL]];
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.loaded = NO;
    self.imageView.loading = NO;
}

- (void)willMoveToSuperview:(TUIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview)
    {
        [self.imageView cancelCurrentImageLoad];
    }
}


- (void)setResult:(WeiboAutocompleteResultItem *)newResult{
    [newResult retain];
    [result release];
    result = newResult;
    [self _requestImage];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (selected && animated) {
        _flags.superBlue = YES;
        [CATransaction begin];
        [self redraw];
        [CATransaction flush];
        [CATransaction commit];
        _flags.superBlue = NO;
    }
    NSTimeInterval duration = 0.0;
    
    if (animated)
    {
        if (!selected)
        {
            duration = 0.1;
        }
        else
        {
            duration = 0.25;
        }
    }
    
    if (duration)
    {
        [TUIView animateWithDuration:duration delay:(animated && selected) ? 0.1 : 0.0 curve:TUIViewAnimationCurveEaseInOut animations:^{
            [self redraw];
        } completion:nil];
    }
    else
    {
        [self redraw];
    }
}
- (void)_flashStep:(BOOL)flash{
    
}
- (void)flash{
    
}
- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGRect b = [self bounds];
    if (_flags.superBlue) {
        CGFloat colorA[] = { 50.0/255.0, 162.0/255.0, 255.0/255.0, 1.0 };
        CGFloat colorB[] = { 70.0/255.0, 80.0/255.0, 238.0/255.0, 1.0 };
        CGContextDrawLinearGradientBetweenPoints(ctx, 
                                                 CGPointMake(0, b.size.height)  , colorA, 
                                                 CGPointMake(0, 0), colorB);
    }else if (self.selected) {
        CGFloat colorA[] = { 98.0/255.0, 198.0/255.0, 250.0/255.0, 1.0 };
        CGFloat colorB[] = { 90.0/255.0, 103.0/255.0, 233.0/255.0, 1.0 };
        CGContextDrawLinearGradientBetweenPoints(ctx, 
                                                 CGPointMake(0, b.size.height)  , colorA, 
                                                 CGPointMake(0, 0), colorB);
    }
    else {
        WTCGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height), 0.94, CGPointMake(0, 0), 0.90, 0.7);
    }
    CGContextSetRGBFillColor(ctx, 0.2, 0.2, 0.2, 0.05);
    CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
    
    CGContextSetRGBFillColor(ctx, 0.2, 0.2, 0.2, 1.0);
    NSString * text = [@"@" stringByAppendingString:result.autocompleteText];
    NSColor * fontColor = [NSColor colorWithDeviceWhite:(_flags.superBlue || self.selected)?1.0:0.5 alpha:1.0];
    NSMutableParagraphStyle * fontPara = [[NSMutableParagraphStyle alloc] init];
    [fontPara setAlignment:NSLeftTextAlignment];
    [fontPara setLineBreakMode:NSLineBreakByTruncatingTail];
    NSDictionary * atts = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSFont fontWithName:@"HelveticaNeue" size:13.0],NSFontAttributeName, 
                           fontColor,NSForegroundColorAttributeName,
                           fontPara,NSParagraphStyleAttributeName,
                           nil];
    [fontPara release];
    [text drawInRect:CGRectMake(40, 12, b.size.width - 47, 20) withAttributes:atts];
}

@end
