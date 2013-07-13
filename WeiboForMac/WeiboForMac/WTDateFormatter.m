//
//  WTDateFormatter.m
//  weibo3
//
//  Created by 吴天 on 11-7-15.
//  Copyright 2011年 nfsysu. All rights reserved.
//

#import "WTDateFormatter.h"

static WTDateFormatter * shared = nil;

@implementation WTDateFormatter

+ (WTDateFormatter * ) shared {
    if (!shared) {
        shared = [[WTDateFormatter alloc] init];
    }
    return shared;
}

- (void)dealloc{
    [super dealloc];
}



- (NSString *) stringForTime:(int)time {
	// Get time difference
	int currentDateAsSeconds = [[NSDate date] timeIntervalSince1970];
	int seconds = currentDateAsSeconds - time;

	
	// check whether it's days away
	int dayInSecs = 24 * 60 * 60;
	int days = seconds / dayInSecs;
	if (days > 0) {
		if (days > 1) {
			return [NSString stringWithFormat:@"%i days", days];
		} else {
			return @"1 day";
		}
	}
	
	// check whether it's hours away
	int hourInSecs = 60 * 60;
	int hours = seconds / hourInSecs;
	if (hours > 0) {
		if (hours > 1) {
			return [NSString stringWithFormat:@"%i hours", hours];
		} else {
			return @"1 hour";
		}
	}
	
	// check whether it's minutes away
	int minuteInSecs = 60;
	int minutes = seconds / minuteInSecs;
	if (minutes > 0) {
		if (minutes > 1) {
			return [NSString stringWithFormat:@"%i mins", minutes];
		} else {
			return @"1 min";
		}
	}
	
	// if not any of the above, it's seconds away
	if (seconds > 1) {
		return [NSString stringWithFormat:@"%i secs", seconds];
	} else if (seconds == 1) {
		return @"1 sec";
	} else {
		return @"now";
	}
}


@end
