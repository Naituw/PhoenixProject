//
//  WTImageView.h
//  WTImageViewer
//
//  Created by Tian Wu on 11-10-2.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIImageView.h"
#import "WTImageViewer.h"

@interface WTImageView : TUIImageView {
    WTImageViewer * viewer;
    NSPoint initialLocation;
}

@property (assign) WTImageViewer * viewer;

@end
