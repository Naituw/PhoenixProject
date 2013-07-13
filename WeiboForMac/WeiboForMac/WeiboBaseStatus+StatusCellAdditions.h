//
//  WeiboBaseStatus+StatusCellAdditions.h
//  WeiboForMac
//
//  Created by 吴 天 on 12-11-25.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboBaseStatus.h"
#import "TUIAttributedString.h"

#define HIGHLIGHTED_COLOR [TUIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:121.0/255.0 alpha:1.0]
#define HASHTAG_COLOR [TUIColor colorWithWhite:0.6 alpha:1.0]
#define NORMALTEXT_COLOR [TUIColor colorWithWhite:0.35 alpha:1.0]

@interface WeiboBaseStatus (StatusCellAdditions)

- (BOOL)placeThumbImageOnSideOfCell;
- (CGFloat)textWidthInCellWithWidth:(CGFloat)cellWidth;
- (TUIAttributedString *)attributedText;

@end
