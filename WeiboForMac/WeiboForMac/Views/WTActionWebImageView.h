//
//  WTActionWebImageView.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-8.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTWebImageView.h"

@interface WTActionWebImageView : WTWebImageView {
    id target;
    SEL action;
}

@property (assign, nonatomic) id target;
@property (assign, nonatomic) SEL action;

@end
