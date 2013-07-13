//
//  WTImageAttachmentButton.h
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-27.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTComposerButton.h"

@interface WTImageAttachmentButton : WTComposerButton {
    NSEvent* downEvent;
    
}

@property (retain) NSEvent* downEvent;

@end
