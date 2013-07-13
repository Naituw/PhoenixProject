//
//  WeiboMac2Window.h
//  new-window
//
//  Created by Wu Tian on 12-7-10.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUINSWindow.h"

#define WeiboMac2WindowCornerRadius 8.0
#define WeiboMac2WindowSideBarWidth 68.0 + WeiboMac2WindowCornerRadius

@interface WeiboMac2Window : TUINSWindow

- (IBAction)toggleKeepsOnTop:(id)sender;
- (BOOL)presentingSheet;

- (void)updateAutoSavedFrame;

@end

@interface TUINSWindow (UniqueIdentifier)

- (NSString *)uniqueIdentifier;

@end