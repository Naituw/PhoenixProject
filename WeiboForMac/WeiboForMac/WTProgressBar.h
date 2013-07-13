//
//  WTProgressBar.h
//  WTImageViewer
//
//  Created by Tian Wu on 11-10-2.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIView.h"

@interface WTProgressBar : WUIView {
    NSPoint initialLocation;
	float progress;
	TUIView *_progressFillLayer;
	TUIView *_borderLayer;
	TUIView *_progressLayer;
}

@property (nonatomic) float progress;

- (void) setProgress:(float)f animated:(BOOL)b;

@end
