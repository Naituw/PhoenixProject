//
//  WMTrendTitleCell.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-7.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMTrendTitleCell.h"
#import "TUIKit.h"
#import "WTUIStaticTextRenderer.h"

@interface WMTrendTitleCell ()

@property (nonatomic, retain) TUIActivityIndicatorView * indicatorView;

@end

@implementation WMTrendTitleCell
@synthesize text = _text;

- (void)dealloc{
    [textRenderer release];
    [_indicatorView release], _indicatorView = nil;
    [super dealloc];
}

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		textRenderer = [[WTUIStaticTextRenderer alloc] init];
        textRenderer.verticalAlignment = TUITextVerticalAlignmentMiddle;
		self.textRenderers = [NSArray arrayWithObjects:textRenderer, nil];
	}
	return self;
}

- (void)setText:(NSString *)text{
    if (!text)
    {
        textRenderer.attributedString = nil;
        return;
    }
    TUIAttributedString * string = [TUIAttributedString stringWithString:text];
    string.font = [TUIFont fontWithName:@"HelveticaNeue" size:14];
    string.color = [TUIColor colorWithWhite:0.2 alpha:1.0];
    string.alignment = TUITextAlignmentCenter;
    textRenderer.attributedString = string;
}
- (NSString *)text{
    return textRenderer.attributedString.string;
}
- (TUIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[TUIActivityIndicatorView alloc] initWithActivityIndicatorStyle:TUIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}
- (void)setLoading:(BOOL)loading
{
    if (loading)
    {
        TUIActivityIndicatorView * indicator = self.indicatorView;
        [indicator sizeToFit];
        [self addSubview:indicator];
        [indicator setFrame:CGRectGetCenterRect(self.bounds, indicator.size)];
        [indicator startAnimating];
        [indicator setAutoresizingMask:TUIViewAutoresizingFlexibleLeftMargin | TUIViewAutoresizingFlexibleRightMargin | TUIViewAutoresizingFlexibleTopMargin | TUIViewAutoresizingFlexibleBottomMargin];
    }
    else if (_indicatorView)
    {
        [self.indicatorView removeFromSuperview];
        self.indicatorView = nil;
    }
}
- (void)drawCellContent:(CGRect)b{
    if (!self.loading)
    {
        textRenderer.frame = CGRectInset(self.bounds, self.paddingLeftRight, 0);
        [textRenderer draw];
    }
}

@end
