//
//  WTComposeButton.h
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-26.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTButton.h"

@interface WTComposerButton : WTButton

@property (nonatomic) BOOL pressedDown;

- (void)setShouldInset:(BOOL)inset;

@end
