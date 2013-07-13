//
//  WMUserProfileViewCell.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-5-1.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMGroupedCell.h"

@interface WMUserProfileViewCell : WMGroupedCell {
    TUITextRenderer * textRenderer;
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, assign) NSString * text;

@end
