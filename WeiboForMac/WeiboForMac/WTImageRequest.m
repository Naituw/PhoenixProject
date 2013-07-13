//
//  WTImageRequest.m
//  WTImageViewer
//
//  Created by Tian Wu on 11-10-2.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTImageRequest.h"

@implementation WTImageRequest
@synthesize saveURL;

- (void)dealloc
{
    self.saveURL = nil;
    [super dealloc];
}

@end
