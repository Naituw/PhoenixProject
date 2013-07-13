//
//  main.m
//  WeiboForMac
//
//  Created by Wu Tian on 11-7-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TUIKit.h"

int main(int argc, char *argv[])
{
    SInt32 major = 0;
	SInt32 minor = 0;
	Gestalt(gestaltSystemVersionMajor, &major);
	Gestalt(gestaltSystemVersionMinor, &minor);
	if((major == 10 && minor >= 7) || major >= 11) {
		AtLeastLion = YES;
	}
	    
    return NSApplicationMain(argc, (const char **)argv);
}
