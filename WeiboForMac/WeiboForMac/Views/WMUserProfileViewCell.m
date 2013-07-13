//
//  WMUserProfileViewCell.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-1.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMUserProfileViewCell.h"
#import "TUIKit.h"
#import "WTUIStaticTextRenderer.h"

@implementation WMUserProfileViewCell

@synthesize title = _title, text = _text;

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		textRenderer = [[WTUIStaticTextRenderer alloc] init];
        textRenderer.verticalAlignment = TUITextVerticalAlignmentTop;
		self.textRenderers = [NSArray arrayWithObjects:textRenderer, nil];
	}
	return self;
}

- (void)dealloc{
    [textRenderer release];
    [_title release];
    [super dealloc];
}

- (CGFloat)titleRectWidth{
    return 70;
}

- (CGRect)textRect{
    CGRect b = self.bounds;
    return CGRectMake(self.paddingLeftRight + 10 + [self titleRectWidth] + 10,
                      0, b.size.width - 2*self.paddingLeftRight - 10 - [self titleRectWidth] - 10 - 10, b.size.height - 14);
}


- (void)setText:(NSString *)text{
    TUIAttributedString * string = [TUIAttributedString stringWithString:text];
    string.font = [TUIFont fontWithName:@"HelveticaNeue" size:12];
    string.color = [TUIColor colorWithWhite:0.3 alpha:1.0];
    string.alignment = TUITextAlignmentLeft;
    textRenderer.attributedString = string;
}
- (NSString *)text{
    return textRenderer.attributedString.string;
}

- (void)drawCellContent:(CGRect)b{
    [[TUIColor colorWithWhite:0.5 alpha:1.0] set];
    
    TUIFont * font = [TUIFont lightDefaultFontOfSize:12];
    
    CGSize titleSize = [self.title ab_sizeWithFont:font constrainedToSize:CGSizeMake([self titleRectWidth], b.size.height)];
    
    CGRect titleRect = CGRectMake(self.paddingLeftRight + 10,
                      b.size.height - 25, [self titleRectWidth], titleSize.height);
    
    [self.title ab_drawInRect:titleRect withFont:font lineBreakMode:TUILineBreakModeMiddleTruncation alignment:TUITextAlignmentRight];
    
    textRenderer.frame = [self textRect];
    [textRenderer draw];
}


@end
