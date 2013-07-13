//
//  WTHUDStatusView.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-10-4.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTHUDStatusView.h"

@implementation WTHUDStatusView
@synthesize stringLabel, imageView;

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.layer.cornerRadius = 10;
		self.backgroundColor = [TUIColor colorWithWhite:0 alpha:0.8];
		self.userInteractionEnabled = NO;
		self.layer.opacity = 0;
        self.autoresizingMask = (TUIViewAutoresizingFlexibleBottomMargin | TUIViewAutoresizingFlexibleTopMargin |
                                 TUIViewAutoresizingFlexibleRightMargin | TUIViewAutoresizingFlexibleLeftMargin);
    }
	
    return self;
}

- (TUILabel *)stringLabel {
    
    if (stringLabel == nil) {
        stringLabel = [[TUILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [TUIColor whiteColor];
		stringLabel.backgroundColor = [TUIColor clearColor];
		stringLabel.alignment = TUITextAlignmentCenter;
		stringLabel.font = [TUIFont boldSystemFontOfSize:16];
		[self addSubview:stringLabel];
		[stringLabel release];
    }
    
    return stringLabel;
}

- (TUIImageView *)imageView {
    
    if (imageView == nil) {
        imageView = [[TUIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        imageView.backgroundColor = [TUIColor clearColor];
		[self addSubview:imageView];
		[imageView release];
    }
    
    return imageView;
}


- (void)setStatus:(NSString *)string {
	
    CGFloat hudWidth = 100;
    
    // need calculate
	CGFloat stringWidth = [string length]*12 +28;
	
	if(stringWidth > hudWidth)
		hudWidth = ceil(stringWidth/2)*2;
	
	self.bounds = CGRectMake(0, 0, hudWidth, 100);
	
	self.imageView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, 64);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
	self.stringLabel.frame = CGRectMake(0, 20, CGRectGetWidth(self.bounds), 20);
	
}

- (void)showInView:(TUIView*)view status:(NSString*)string{
    [self setStatus:string];
    self.imageView.image = [TUIImage imageNamed:@"SVProgressHUD.bundle/success.png"];
    if(self.alpha != 1) {
		CGFloat posY = CGRectGetHeight(self.superview.bounds)/2;
		self.center = CGPointMake(CGRectGetWidth(self.superview.bounds)/2, posY);
		
		self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1.3, 1.3, 1);
		self.layer.opacity = 0.3;
		
        [TUIView animateWithDuration:0.15
                         animations:^{	
							 self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
							 self.layer.opacity = 1;
						 }];
	}
}

- (void)dismiss {
	[TUIView animateWithDuration:0.15
					 animations:^{	
						 self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 0.8, 0.8, 1.0);
						 self.layer.opacity = 0;
					 }];
}


@end
