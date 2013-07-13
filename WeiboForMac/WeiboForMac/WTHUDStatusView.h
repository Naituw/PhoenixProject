//
//  WTHUDStatusView.h
//  WeiboForMac
//
//  Created by Tian Wu on 11-10-4.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIKit.h"

@interface WTHUDStatusView : WUIView {
    TUILabel *stringLabel;
    TUIImageView *imageView;
}

@property (nonatomic, retain) TUILabel *stringLabel;
@property (nonatomic, retain) TUIImageView *imageView;

- (void)showInView:(TUIView*)view status:(NSString*)string;
- (void)dismiss;
@end
