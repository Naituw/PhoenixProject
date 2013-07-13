//
//  WeiboForMacApp.m
//  WeiboForMac
//
//  Created by Wu Tian on 12-4-3.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WeiboForMacApp.h"

@implementation WeiboForMacApp

- (void)relaunchAfterDelay:(CGFloat)seconds
{
	NSTask *task = [[[NSTask alloc] init] autorelease];
	NSMutableArray *args = [NSMutableArray array];
	[args addObject:@"-c"];
	[args addObject:[NSString stringWithFormat:@"sleep %f; open \"%@\"", seconds, [[NSBundle mainBundle] bundlePath]]];
	[task setLaunchPath:@"/bin/sh"];
	[task setArguments:args];
	[task launch];
	
	[self terminate:nil];
}
- (void)terminate:(id)sender
{
    [super terminate:sender];
}

@end
