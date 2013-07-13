//
//  WTImageView.m
//  WTImageViewer
//
//  Created by Tian Wu on 11-10-2.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTImageView.h"

@implementation WTImageView
@synthesize viewer;

- (void)rightMouseUp:(NSEvent *)theEvent{    
    [super rightMouseUp:theEvent];
    if (viewer)
    {
        [viewer rightMouseUp:theEvent];
    }
}

@end
