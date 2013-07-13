//
//  WTComposeTextView.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-23.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTComposeTextView.h"

@implementation WTComposeTextView

@synthesize composeDelegate = _composeDelegate, isAutoCompleting;

- (id)initWithFrame:(NSRect)frameRect{
    if((self = [super initWithFrame:frameRect])){
        [self setBackgroundColor:[NSColor clearColor]];
        [self setDrawsBackground:NO];
        [self setEditable:YES];
        [self setTextContainerInset:NSMakeSize(0, 0)];
        [[self textContainer] setLineFragmentPadding:0.0];
        [self becomeFirstResponder];
        NSFont * font = [NSFont fontWithName:@"HelveticaNeue" size:13.0];
        [self setFont:font];
        [self setRichText:NO];
        [[self textStorage] setFont:font];
        [self setTextColor:[NSColor colorWithDeviceWhite:0.4 alpha:1.0]];
    }
    return self;
}

- (NSArray *)readablePasteboardTypes {
    return [NSArray arrayWithObjects:NSStringPboardType, NSTIFFPboardType, 
            NSFilenamesPboardType,
            nil];
}

- (void)keyDown:(NSEvent *)theEvent{
    if (![self isAutoCompleting]) {
        [super keyDown:theEvent];
        return;
    }
    switch([[theEvent charactersIgnoringModifiers] characterAtIndex:0]){
        case NSUpArrowFunctionKey:{
            [_composeDelegate textViewDidHighlightPreviousAutoComplete:self];
            return;
        }
        case NSDownArrowFunctionKey:{
            [_composeDelegate textViewDidHighlightNextAutoComplete:self];
            return;
        }
        case 27:{ // Escape Key
            [_composeDelegate textViewDidCancelAutoComplete:self];
            return;
        }
    }
    switch ([theEvent keyCode]) {
        case 36:{ // Enter Key
            [_composeDelegate textViewDidConfirmAutoComplete:self];
            return;
        }    
    }
    [super keyDown:theEvent];
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ( [NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
        [sender draggingSourceOperationMask] &
        NSDragOperationCopy ) {
        return NSDragOperationCopy;
    } // end if
	return NSDragOperationNone;		
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)deriveImageDataFromPasteboard:(NSPasteboard *)pasteboard
{    
    NSString * filenamesType = [pasteboard availableTypeFromArray:@[NSFilenamesPboardType]];
    
    if (filenamesType)
    {
		NSArray * filenames = [pasteboard propertyListForType:@"NSFilenamesPboardType"];
		NSString * path = [filenames objectAtIndex:0];
		NSImage * image = [[NSImage alloc] initWithContentsOfFile:path];
        
        if (image)
        {
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:path];
            
            [image release];
            
            if(_composeDelegate && [_composeDelegate respondsToSelector:@selector(textView:didReceiveDragedImageData:)]){
                [_composeDelegate textView:self didReceiveDragedImageData:imageData];
            }
            [imageData autorelease];
            
            return YES;
        }
    }
    
    NSString * imageDataType = [pasteboard availableTypeFromArray:@[NSPasteboardTypeTIFF, NSPasteboardTypePNG]];
    
	if (imageDataType)
    {
		NSData * pasteboardData = [pasteboard dataForType:imageDataType];
		if (!pasteboardData)
        {
			return NO;
		}
        
        NSData * imageData = pasteboardData;
        
        
        if ([imageDataType isEqualToString:NSPasteboardTypeTIFF])
        {
            NSImage * image = [[NSImage alloc] initWithData:pasteboardData];
            NSBitmapImageRep * bits = [[image representations] objectAtIndex:0];
            
            imageData = [bits representationUsingType:NSPNGFileType properties:nil];
            
            [image release];
        }
        
        
        if(_composeDelegate && [_composeDelegate respondsToSelector:@selector(textView:didReceiveDragedImageData:)])
        {
            [_composeDelegate textView:self didReceiveDragedImageData:imageData];
        }
        
		return YES;
		
	}
	
	return NO;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
	
    return [self deriveImageDataFromPasteboard:zPasteboard];
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation{
}

- (void)draggingExited:(id<NSDraggingInfo>)sender{
    
}

- (void)paste:(id)sender
{
    NSPasteboard * pb = [NSPasteboard generalPasteboard];
    
    if (![self deriveImageDataFromPasteboard:pb])
    {
        [self pasteAsPlainText:sender];
    }
}

- (void)cancelOperation:(id)sender{
    NSLog(@"canceled");
}
@end
