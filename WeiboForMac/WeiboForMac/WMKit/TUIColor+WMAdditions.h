//
//  TUIColor+WMAdditions.h
//  WeiboForMac
//
//  Created by 吴 天 on 12-11-29.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "TUIColor.h"

@interface TUIColor (WMAdditions)

inline TUIColor * TUIRGBColor(CGFloat r, CGFloat g, CGFloat b);
inline TUIColor * TUIRGBAColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);

inline TUIColor * TUIHEXColor(NSInteger hex);
inline TUIColor * TUIHEXAColor(NSInteger hex, CGFloat alpha);

@end
