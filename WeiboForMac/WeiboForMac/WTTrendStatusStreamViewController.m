//
//  WTTrendStatusStreamViewController.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-10.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WTTrendStatusStreamViewController.h"
#import "WeiboTrendStatusesStream.h"

@implementation WTTrendStatusStreamViewController

- (CGFloat)toolbarViewHeight
{
    return 40.0;
}

- (WeiboTrendStatusesStream *)trendStream
{
    if ([self.statusStream isKindOfClass:[WeiboTrendStatusesStream class]])
    {
        return (WeiboTrendStatusesStream *)self.statusStream;
    }
    return nil;
}

- (NSString *)title
{
    WeiboTrendStatusesStream * trendStream = [self trendStream];
    if (trendStream && trendStream.trendName.length)
    {
        return [NSString stringWithFormat:@"#%@#",trendStream.trendName];
    }
    else if (_title.length)
    {
        return _title;
    }
    return NSLocalizedString(@"Topic", nil);
}

@end
