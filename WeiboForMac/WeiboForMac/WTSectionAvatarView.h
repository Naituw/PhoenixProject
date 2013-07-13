//
//  WTSectionAvatarView.h
//  WTTabbarController
//
//  Created by Wu Tian on 11-8-21.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "TUIKit.h"

@interface WTSectionAvatarView : WUIView {
    TUIImage * avatar;
}

@property (retain, nonatomic) TUIImage *avatar;

- (id)initWithAvatar:(TUIImage *)aAvatar;

@end
