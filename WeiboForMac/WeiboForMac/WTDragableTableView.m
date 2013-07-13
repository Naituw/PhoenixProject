//
//  WTDragableTableView.m
//  WTTabbarController
//
//  Created by Wu Tian on 11-8-21.
//  Copyright 2011年 Wutian. All rights reserved.
//

#import "WTDragableTableView.h"

@implementation WTDragableTableView


- (NSUInteger) selectedRow{
    return _selectedIndexPath.row;
}
- (TUIFastIndexPath *)selectedIndexPath{
    return _selectedIndexPath;
}
/**
 * make view dragable
 *
 */
-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    NSRect  windowFrame = [[self nsWindow] frame];
    
    initialLocation = [NSEvent mouseLocation];
    
    initialLocation.x -= windowFrame.origin.x;
    initialLocation.y -= windowFrame.origin.y;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    NSPoint currentLocation;
    NSPoint newOrigin;
    
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    //go ahead and move the window to the new location
    [[self nsWindow] setFrameOrigin:newOrigin];
}

@end
