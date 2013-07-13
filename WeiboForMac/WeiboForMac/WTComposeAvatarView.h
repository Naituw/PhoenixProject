//
//  WTComposeAvatarView.h
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-24.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface WTComposeAvatarView : NSImageView

@property (nonatomic, assign) NSInteger selectedAccountIndex;

- (void)switchAccount:(id)sender;

@end
