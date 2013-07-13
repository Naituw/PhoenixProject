//
//  WTAutoCompleteCell.h
//  WeiboForMac
//
//  Created by Wu Tian on 12-3-31.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUITableViewCell.h"

@class WeiboAutocompleteResultItem, WTWebImageView;

@interface WTAutoCompleteCell : TUITableViewCell {
    WeiboAutocompleteResultItem * result;
    WTWebImageView * imageView;
    struct {
        unsigned int superBlue:1;
    } _flags;
}

@property(retain, nonatomic) WeiboAutocompleteResultItem * result;
@property(retain, nonatomic) WTWebImageView * imageView;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)flash;

@end
