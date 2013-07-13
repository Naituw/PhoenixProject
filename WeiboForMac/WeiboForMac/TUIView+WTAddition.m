//
//  TUIView+WTAddition.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "TUIView+WTAddition.h"

@implementation TUIView (WTAddition)

- (TUINSWindow *)findoutNSWindow
{
    TUIView * view = self;
    
    TUINSWindow * nsWindow = view.nsWindow;
    
    if (!nsWindow)
    {
        TUIViewController * controller = view.firstAvailableViewController;
        
        while (controller)
        {
            id next = nil;
            
            if ([controller isKindOfClass:[TUIViewController class]])
            {
                if (controller.view.nsWindow)
                {
                    nsWindow = controller.view.nsWindow;
                    break;
                }
                
                next = controller.parentViewController;
            }
            
            if (!next)
            {
                next = controller.nextResponder;
            }
            
            controller = next;
        }
    }
    
    return nsWindow;
}

@end
