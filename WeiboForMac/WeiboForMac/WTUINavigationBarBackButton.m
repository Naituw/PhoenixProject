//
//  WTUINavigationBarBackButton.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-17.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUINavigationBarBackButton.h"
#import "WTCGAdditions.h"

@implementation WTUINavigationBarBackButton

- (id)initWithString:(NSString *)string{
    return [self initWithString:string fontSize:10.0];
}

- (id)initWithString:(NSString *)string fontSize:(CGFloat)fontSize{
    if ((self = [super initWithFrame:CGRectZero])) {
        self.bounds = CGRectMake(0, 0, 64, 36);
        title = [[WTUIStaticTextRenderer alloc] init];
        TUIAttributedString * attString = [TUIAttributedString stringWithString:string];
        [attString setAlignment:TUITextAlignmentCenter lineBreakMode:TUILineBreakModeTailTruncation];
        attString.color = [TUIColor colorWithWhite:0.0 alpha:0.6];
        attString.font = [TUIFont fontWithName:@"Lucida Grande" size:fontSize];
        title.attributedString = attString;
        title.shadowColor = [TUIColor colorWithWhite:0.9 alpha:1.0];
        title.shadowOffset = CGSizeMake(0, -1);
        title.verticalAlignment = TUITextVerticalAlignmentMiddle;
        self.textRenderers = [NSArray arrayWithObjects:title, nil];
        self.backgroundColor = [TUIColor clearColor];
    }
    return self;
}

- (void)dealloc{
    [title release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect{
    
    CGRect titleFrame = CGRectMake(4, 0, 50, 36);
    WTCUIDraw(TUIGraphicsGetCurrentContext(), titleFrame, self.nsWindow.isKeyWindow);
    title.frame = titleFrame;
    [title draw];

    TUIImage * image = [TUIImage imageNamed:@"titlebar-divider.png" cache:YES];
    [image drawInRect:CGRectMake(54, 1, 10, 34)];
}

- (void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
    self.alpha = 0.6;
}

- (void)mouseUp:(NSEvent *)theEvent{
    self.alpha = 1.0;
    [super mouseUp:theEvent];
    
}



@end
