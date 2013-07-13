//
//  WTAlertView.m
//  WeiboForMac
//
//  Created by Wutian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WTAlertView.h"
#import "WTAlertCenter.h"
#import "TUIKit.h"

@implementation WTAlertView

- (id)initWithTitle:(NSString *)titleString style:(WTAlertStyle)style{
    if((self=[super init])){
        self.layer.shadowColor = [TUIColor blackColor].CGColor;
        self.clipsToBounds = NO;
        self.layer.shadowRadius = 6.0;
        self.layer.shadowOpacity = 1.0;
        self.autoresizingMask = (TUIViewAutoresizingFlexibleWidth);
        
        TUIAttributedString * aString = [TUIAttributedString stringWithString:titleString];
        aString.font = [TUIFont fontWithName:@"HelveticaNeue-Light" size:12];
        aString.color = [TUIColor colorWithWhite:1.0 alpha:1.0];
        _title = [[TUITextRenderer alloc] init];
        _title.attributedString = aString;
        _title.shadowBlur = 0.0;
        _title.shadowOffset = CGSizeMake(0, 1);
        _title.shadowColor = [TUIColor colorWithWhite:0.0 alpha:0.6];
        
        self.textRenderers = [NSArray arrayWithObject:_title];
        
        
        _style = style;
    }
    return self;
}

- (void)drawBlueBackgroundInContext:(CGContextRef) ctx{
    CGRect b = self.bounds;
    CGFloat colorA[] = { 86.0/255.0, 180.0/255.0, 255.0/255.0, 1.0 };
    CGFloat colorB[] = { 32.0/255.0, 75.0/255.0, 186.0/255.0, 1.0 };
    CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height), colorA, CGPointMake(0, 0), colorB);
    
    CGContextSetRGBFillColor(ctx, 130.0/255.0, 195.0/255.0, 255.0/255.0, 1.0);
    CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
}

- (void)drawRedBackgroundInContext:(CGContextRef) ctx{
    CGRect b = self.bounds;
    CGFloat colorA[] = { 200.0/255.0, 0.0/255.0, 0.0/255.0, 1.0 };
    CGFloat colorB[] = { 93.0/255.0, 0.0/255.0, 0.0/255.0, 1.0 };
    CGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height), colorA, CGPointMake(0, 0), colorB);
    
    CGContextSetRGBFillColor(ctx, 240.0/255.0, 110.0/255.0, 110.0/255.0, 1.0);
    CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
}

- (void)drawRect:(CGRect)rect{
    CGRect b = self.bounds;
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    switch (_style) {
        case WTAlertStyleError:
            [self drawRedBackgroundInContext:ctx];
            break;
        case WTAlertStyleTip:
            [self drawBlueBackgroundInContext:ctx];
            break;
        default:
            break;
    }
    
    _title.frame = CGRectMake(10, 0, b.size.width - 20, 21);
    [_title draw];
}

- (void)dealloc{
    [_title release];
    [super dealloc];
}


- (void)mouseUp:(NSEvent *)theEvent{
    [[WTAlertCenter sharedCenter] hideAlertView:self];
}

@end
