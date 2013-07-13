//
//  WMSideBarItemView.h
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIView.h"

@protocol WMSidebarViewDelegate;

@class TUIFastIndexPath;

@interface WMSideBarItemView : WUIView

@property (nonatomic, retain) TUIImage * image;
@property (nonatomic) BOOL sectionHeading;
@property (nonatomic) BOOL sectionHeadingSelected;
@property (nonatomic, assign) id <WMSidebarViewDelegate> delegate;
@property (nonatomic) NSInteger section;
@property (retain, nonatomic) TUIFastIndexPath *indexPath;
@property (nonatomic) NSInteger badge;
@property (nonatomic) BOOL highlight;
@property (retain, nonatomic) NSString * imageName;

@end
