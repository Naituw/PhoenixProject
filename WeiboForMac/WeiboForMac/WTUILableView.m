//
//  WTUILableView.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-11.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUILableView.h"
#import "WTUIStringDrawing.h"
#import "WTCGAdditions.h"

@implementation WTUILableView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithString:(NSString *)string{
    return [self initWithString:string fontSize:13.0];
}

- (id)initWithString:(NSString *)string fontSize:(CGFloat)fontSize{
    if ((self = [super init])) {
        text = [[WTUIStaticTextRenderer alloc] init];
        //NSLog(@"%@",string);
        TUIAttributedString * attString = [TUIAttributedString stringWithString:string];
        [attString setAlignment:TUITextAlignmentCenter lineBreakMode:TUILineBreakModeTailTruncation];
        attString.color = [TUIColor colorWithWhite:0.0 alpha:0.6];
        //NSShadow * textShadow = [NSShadow shadowWithRadius:1.0 offset:CGSizeMake(0, -1) color:[TUIColor colorWithWhite:0.9 alpha:1.0]];
        //attString.shadow = textShadow;
        //attString.backgroundColor = [TUIColor clearColor];
        attString.font = [TUIFont fontWithName:@"Lucida Grande" size:fontSize];
        //attString.lineHeight = 20.0;
        text.attributedString = attString;
        text.shadowColor = [TUIColor colorWithWhite:0.9 alpha:1.0];
        text.shadowOffset = CGSizeMake(0, -1);
        text.verticalAlignment = TUITextVerticalAlignmentMiddle;
        self.textRenderers = [NSArray arrayWithObjects:text, nil];
        self.backgroundColor = [TUIColor clearColor];
    }
    return self;
}

- (void)dealloc{
    [text release];
    [super dealloc];
}


- (void)drawRect:(CGRect)rect{
    CGRect b = self.bounds;
    CGSize textSize = [text sizeConstrainedToWidth:b.size.width];
    CGRect textFrame = CGRectMake(0, 0, textSize.width, b.size.height);
    textFrame.origin.x = b.size.width/2 - textSize.width/2;
    WTCUIDraw(TUIGraphicsGetCurrentContext(), textFrame, self.nsWindow.isKeyWindow);
    text.frame = textFrame;
    [text draw];
}

- (CGFloat) textPositionX{
    return self.frame.origin.x + text.frame.origin.x;
}

-(void)mouseDown:(NSEvent *)theEvent {    
    [super mouseDown:theEvent];
    if ([self superview]) {
        [[self superview] mouseDown:theEvent];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    if ([self superview]) {
        [[self superview] mouseDragged:theEvent];
    }
}

- (void)setAlpha:(CGFloat)alpha{
    [super setAlpha:alpha];
}

@end
