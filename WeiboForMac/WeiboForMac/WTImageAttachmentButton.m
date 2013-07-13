//
//  WTImageAttachmentButton.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-27.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTImageAttachmentButton.h"
#import "WTImageAttachmentCell.h"
#import "WTComposeWindow.h"
#import "WTComposeWindowController.h"

@interface WTImageAttachmentButton()
- (void)startDrag:(NSEvent *)event;
@end

@implementation WTImageAttachmentButton
@synthesize downEvent;

NSString *kPrivateDragUTI = @"com.yourcompany.cocoadraganddrop";

+ (Class)cellClass{
    return [WTImageAttachmentCell class];
}

- (id)initWithFrame:(NSRect)frameRect{
    if((self = [super initWithFrame:frameRect])){
        [self setAlphaValue:0.0];
    }
    return self;
}

- (void)setImage:(NSImage *)image{
    if (image) {
        [super setImage:image];
        [NSAnimationContext beginGrouping]; 
        [[NSAnimationContext currentContext] setDuration:0.3]; 
        [[self animator] setAlphaValue:1.0];
        [NSAnimationContext endGrouping];
        [[NSCursor arrowCursor] setOnMouseEntered:YES];
    }else{
        [self setAlphaValue:0.0];
        [super setImage:image];
        [[NSCursor arrowCursor] setOnMouseEntered:NO];
    }
}

- (NSImage *) getSnapshotOfView
{
    NSRect rect = [self bounds] ;
    
    NSImage *image = [[[NSImage alloc] initWithSize: rect.size] autorelease];
    
    NSRect imageBounds;
    imageBounds.origin = NSZeroPoint;
    imageBounds.size = rect.size;
    
    [self lockFocus];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:imageBounds];
    [self unlockFocus];
    
    [image addRepresentation:rep];
    [rep release];
    
    return image;
}

- (void)startDrag:(NSEvent *)event
{
   	NSImage *scaledImage = [self getSnapshotOfView];
	NSImage *dragImage = [[[NSImage alloc] initWithSize: [scaledImage size]] autorelease];
    [dragImage lockFocus];
    NSImage * snapshot = [self getSnapshotOfView];
    NSRect imageRect = NSZeroRect;
    imageRect.size = snapshot.size;
    [snapshot drawAtPoint:NSMakePoint(0,0) fromRect:imageRect operation:NSCompositeSourceOver fraction:0.8];
    [dragImage unlockFocus];
	
    [self setAlphaValue:0.0];
    
	NSPoint dragPoint = NSMakePoint(
									([self bounds].size.width - [scaledImage size].width) / 2,
									([self bounds].size.height + [scaledImage size].height) / 2);
	if (!event) {
        return;
    }
    [self dragImage:dragImage
                 at:dragPoint
             offset:NSZeroSize
              event:event
         pasteboard:nil
             source:self
          slideBack:NO];
}

- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)event
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
	self.downEvent = event;
    [[self superview] mouseDown:event];
}

- (void)mouseDragged:(NSEvent *)event
{
    if ([self image]) {
        [self startDrag:self.downEvent ];
	}else{
        [[self superview] mouseDragged:event];
    }
	self.downEvent = nil;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation{
    if ( !NSPointInRect(screenPoint, [[self window] frame]) ) //is outside views bounds
    {
        NSSize imageSize = [image size];
        screenPoint.x += imageSize.width/2;
        screenPoint.y += imageSize.height/2;
        
        NSShowAnimationEffect(NSAnimationEffectPoof,
                              screenPoint, NSZeroSize, nil, nil, nil);
        [[NSCursor arrowCursor] set];
        WTComposeWindow * window = (WTComposeWindow *)[self window];
        WTComposeWindowController * theController = [window controller];
        [theController setImageDataToUpload:nil];
    }
    
    [self setAlphaValue:1.0];
}

- (void)draggedImage:(NSImage *)image movedTo:(NSPoint)screenPoint{
    NSRect windowRect = NSOffsetRect([[self window] frame], -10, -10);
    if ( !NSPointInRect(screenPoint, windowRect) ) //is outside views bounds
    {
        [[NSCursor disappearingItemCursor] set];
    }else{
        if ([NSCursor currentCursor] == [NSCursor disappearingItemCursor]) {
            [[NSCursor arrowCursor] set];
        }
    }
}
@end
