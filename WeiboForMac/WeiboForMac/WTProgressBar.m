//
//  WTProgressBar.m
//  WTImageViewer
//
//  Created by Tian Wu on 11-10-2.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTProgressBar.h"

#define BAR_WIDTH 200.0
#define BAR_HEIGHT 20.0
#define BORDER_WIDTH 2.0

@implementation WTProgressBar

@synthesize progress;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [TUIColor clearColor];
        
        _progressLayer = [[TUIView alloc] init];
        [self addSubview:_progressLayer];
        
        _borderLayer = [[TUIView alloc] init];
        _borderLayer.backgroundColor = [TUIColor whiteColor];
        [_borderLayer.layer setBorderWidth:BORDER_WIDTH];
        [_borderLayer.layer setBorderColor:[[TUIColor blackColor] CGColor]];
        [_borderLayer.layer setCornerRadius:BAR_HEIGHT/2];
        [_progressLayer addSubview:_borderLayer];
        
        _progressFillLayer = [[TUIView alloc] init];
        _progressFillLayer.backgroundColor = [TUIColor blackColor];
        [_progressFillLayer.layer setCornerRadius:BAR_HEIGHT/2-2*BORDER_WIDTH];
        [_progressLayer addSubview:_progressFillLayer];
        [self redraw];
    }
    return self;
}

- (void) drawRect:(CGRect)drect
{
    CGRect b = [self bounds];
	CGRect progressRect = ABIntegralRectWithSizeCenteredInRect(CGSizeMake(BAR_WIDTH, BAR_HEIGHT), b);
    [_progressLayer setFrame:progressRect];
	

	CGRect borderFrame = CGRectMake(0, 0, (_progressLayer.frame.size.width), (_progressLayer.frame.size.height));
	[_borderLayer setFrame:borderFrame];
    
	CGRect progressFillFrame = ABRectRoundOrigin(CGRectMake(2*BORDER_WIDTH, 2*BORDER_WIDTH,
                                      (BAR_WIDTH* progress) - 4*BORDER_WIDTH, 
                                      BAR_HEIGHT - 4*BORDER_WIDTH));
	[_progressFillLayer setFrame:progressFillFrame];
}

- (void) setProgress:(float)p
{
	progress = p;
    [self redraw];
}

- (void) setProgress:(float)f animated:(BOOL)b
{
	progress = f;
    if(progress < 0.1){
        progress = 0.1;
    }
    [TUIView animateWithDuration:b?0.5:0.0
                      animations:^(void) {
                          [self redraw];
                      }];
    
}

- (void)dealloc {
    [_borderLayer release];
    [_progressLayer release];
    [_progressFillLayer release];
    [super dealloc];
}



/**
 * make view dragable
 *
 */
-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
}


@end
