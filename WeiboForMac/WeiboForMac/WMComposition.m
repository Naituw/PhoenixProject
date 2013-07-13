//
//  WMComposition.m
//  WeiboForMac
//
//  Created by Wutian on 13-5-23.
//  Copyright (c) 2013年 Wutian. All rights reserved.
//

#import "WMComposition.h"
#import "WTCallback.h"
#import "WTComposeWindowController.h"
#import "WMConstants.h"

@interface WMComposition ()
{
    struct {
        unsigned int didBeginSend:1;
        unsigned int isSending:1;
        unsigned int isWaitingForLocation:1;
    } _flags;
}

@end

@implementation WMComposition
@synthesize imageData = _imageData;
@synthesize text = _text;
@synthesize replyToUser = _replyToUser;
@synthesize directMessageUser = _directMessageUser;
@synthesize retweetingStatus = _retweetingStatus;
@synthesize replyToStatus = _replyToStatus;
@synthesize type = _type;
@synthesize didSendCallback = _didSendCallback;

- (void)dealloc
{
    [_imageData release], _imageData = nil;
    [_text release], _text = nil;
    [_replyToUser release], _replyToUser = nil;
    [_directMessageUser release], _directMessageUser = nil;
    [_replyToStatus release], _replyToStatus = nil;
    [_retweetingStatus release], _retweetingStatus = nil;
    [_didSendCallback release], _didSendCallback = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        // Add your subclass-specific initialization here.
    }
    return self;
}

#pragma mark -
#pragma mark Sending
- (void)_sendFromAccount:(WeiboAccount *)account
{
    [account sendCompletedComposition:self];
}
- (void)didSend:(id)response
{
    _flags.isSending = NO;
    if (self.didSendCallback)
    {
        [self.didSendCallback invoke:response];
        [self setDidSendCallback:nil];
    }
}
- (void)errorSending
{
    self.hadFailedSend = YES;
}
- (void)sendFromAccount:(WeiboAccount *)account
{
    _flags.didBeginSend = YES;
    _flags.isSending = YES;
    [self _sendFromAccount:account];
}

- (BOOL)isSending
{
    return _flags.isSending;
}

#pragma mark -
#pragma mark Locaion (Delegate) Methods
- (void)refreshLocation{
    CLLocationManager * manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    [manager startUpdatingLocation];
}

- (void)doneRefreshingLocation
{
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CGFloat latitude = newLocation.coordinate.latitude;
    CGFloat longitude = newLocation.coordinate.longitude;
    
    NSLog(@"new location: %f, %f",latitude,longitude);
    
    [manager stopUpdatingLocation];
    [manager autorelease];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // handle error here
    NSLog(@"error:%@",error);
    [self doneRefreshingLocation];
    [manager stopUpdatingLocation];
    [manager autorelease];
}

#pragma mark - NSDocument

- (NSWindowController *)controller
{
    return [self.windowControllers lastObject];
}

- (void)makeWindowControllers
{
    [self updateChangeCount:NSChangeDone];
    
    WTComposeWindowController * controller = [[WTComposeWindowController alloc] init];
    
    [self addWindowController:controller];
    
    [controller release];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (BOOL)isDocumentEdited
{
    return self.dirty;
}

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{        
    if ([delegate respondsToSelector:shouldCloseSelector])
    {
        NSMethodSignature * signature = [delegate methodSignatureForSelector:shouldCloseSelector];
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        [invocation setTarget:delegate];
        [invocation setSelector:shouldCloseSelector];
        [invocation setArgument:&self atIndex:2];
        [invocation setArgument:&contextInfo atIndex:4];
        
        if (!self.dirty || self.isSending)
        {
            BOOL shouldClose = YES;
            [invocation setArgument:&shouldClose atIndex:3];
            [invocation invoke];
            return;
        }
        
        NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Are you sure you want to discard this unsaved message?", nil) defaultButton:NSLocalizedString(@"Discard", nil) alternateButton:NSLocalizedString(@"Cancel", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Your message will be lost.", nil)];
        
        NSWindow * window = [[self controller] window];
        
        CGRect sheetRect = window.frame;
        sheetRect.origin = CGPointZero;
        sheetRect.origin.y += BOTTOMBAR_HEIGHT;
        sheetRect.size.height = 0;
        
        NSValue * rectValue = [NSValue valueWithRect:sheetRect];
        
        [alert.window setObject:rectValue forAssociatedKey:kWindowSheetPositionRect retained:YES];
        
        [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(dismissSheetDidEnd:returnCode:contextInfo:) contextInfo:[invocation retain]];
    }
    else
    {
        [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
    }
}
- (void)dismissSheetDidEnd:(id)sheet returnCode:(NSUInteger)returnCode contextInfo:(void *)contextInfo
{
    NSInvocation * invocation = [(NSInvocation *)contextInfo autorelease];
    
    BOOL shouldClose = NO;
    
    if (returnCode == NSAlertDefaultReturn)
    {
        shouldClose = YES;
    }
    
    [invocation setArgument:&shouldClose atIndex:3];
    [invocation invoke];
}

@end
