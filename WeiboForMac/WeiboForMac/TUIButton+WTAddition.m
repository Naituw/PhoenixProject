//
//  TUIButton+WTAddition.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-8.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIButton+WTAddition.h"

@implementation TUIButton (WTAddition)

- (id) initWithNSButton:(NSButton *) nsButton{
    if ((self = [super init])) {
        TUIImage * image = [TUIImage imageWithNSImage:nsButton.image];
        [self setImage:image forState:TUIControlStateNormal];
        
        TUIImage * altImage = [TUIImage imageWithNSImage:nsButton.alternateImage];
        [self setImage:altImage forState:TUIControlStateSelected];
        
        
    }
    return self;
}

@end