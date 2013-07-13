//
//  WTComposeWindowController.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTComposeWindowController.h"
#import "WTComposeWindow.h"
#import "WTComposerButton.h"
#import "WTActiveTextRanges.h"
#import "WTCallback.h"
#import "Weibo.h"
#import "WeiboComposition.h"
#import "WeiboUser.h"
#import "LocalAutocompleteDB.h"
#import "RegexKitLite.h"
#import "WeiboForMacAppDelegate.h"
#import "WeiboEmotionManager.h"
#import "WMComposition.h"
#import "WeiboRequestError.h"
#import "NSWindow+WMAdditions.h"
#import "WMConstants.h"

#define WINDOW_WIDTH  325.0
#define WINDOW_HEIGHT 132.0

@implementation WTComposeWindowController
@synthesize account, initialText;

#pragma mark -
#pragma mark Lift Cycle

- (id)init
{
    NSRect windowInitFrame = NSMakeRect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    WTComposeWindow * composeWindow = [[[WTComposeWindow alloc] initWithContentRect:windowInitFrame] autorelease];

    if (self = [super initWithWindow:composeWindow])
    {
        
        composeWindow.controller = self;
        
        [self setShouldCascadeWindows:YES];
        [self.window setDelegate:self];
                        
        capturer = [[WTScreenCapturer alloc] init];
        capturer.delegate = self;
        
        [self prepareAutoCompleteMenu];
        
        self.popover = [[[NSPopover alloc] init] autorelease];
        self.popover.appearance = NSPopoverAppearanceMinimal;
        self.popover.animates = YES;
        self.popover.behavior = NSPopoverBehaviorTransient;
        self.popover.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSetChanged:) name:WeiboAccountSetDidChangeNotification object:nil];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WeiboAccountSetDidChangeNotification object:nil];
    
    [capturer release];
    [autocompleteWindow setReleasedWhenClosed:YES];
    [autocompleteWindow close];
    
    WMEmotionViewController * c = (WMEmotionViewController *)self.popover.contentViewController;
    [c destory];
    [_popover release], _popover = nil;
    [super dealloc];
}

- (void)setInitialText:(NSString *)initialText_
{
    if (initialText_)
    {
        [self setInitialText:initialText_ selectedRange:initialRange];
    }
}


#pragma mark -
#pragma mark Accessor
+ (CGSize)defaultWindowSize
{
    return CGSizeMake(WINDOW_WIDTH, WINDOW_HEIGHT);
}

- (WTComposeWindow *)composeWindow
{
    return (WTComposeWindow *)[self window];
}
- (WMComposition *)composition
{
    if (![self.document isKindOfClass:[WMComposition class]])
    {
        return nil;
    }
    return self.document;
}
- (WeiboAccount *)selectedAccount
{
    NSInteger index = self.composeWindow.selectedAccountIndex;
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    if (index >= 0 && index < accounts.count)
    {
        return accounts[index];
    }
    return [[Weibo sharedWeibo] defaultAccount];
}
- (NSData *)imageData
{
    return self.composition.imageData;
}
- (void)setImageData:(NSData *)imageData
{
    [self.composition setImageData:imageData];
}
- (NSString *)textToPost
{
    WTComposeWindow * theWindow = (WTComposeWindow *)[self window];
    return [[[theWindow textToPost] 
             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
            stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

- (void)setAccount:(WeiboAccount *)newAccount{
    [newAccount retain];
    [account release];
    account = newAccount;
    [self accountChanged];
}
- (NSURL *)profileImageURL
{
    if (!account) {
        return nil;
    }
    return [NSURL URLWithString:account.user.profileImageUrl];
}
- (void)setAvatarImage:(TUIImage *)anImage
{
    NSImage * image = [anImage nsImage];
    [[self composeWindow] setAvatarImage:image];
}
- (void)setInitialText:(NSString *)string selectedRange:(NSRange)range
{
    [[self composeWindow] setText:string selectedRange:range];
}

- (void)setDocument:(NSDocument *)document
{
    [super setDocument:document];
    
    initialRange = NSMakeRange(self.initialText.length, 0);
    self.initialText = self.composition.text;
    
    if (self.composition.replyToStatus)
    {
        [self.composeWindow setComposeButtonTitle:NSLocalizedString(@"composer_reply_key", nil)];
    }
    else if (self.composition.retweetingStatus)
    {
        WeiboStatus * status = (WeiboStatus *)self.composition.retweetingStatus;
        if ([status isKindOfClass:[WeiboStatus class]] && status.quotedBaseStatus)
        {
            self.initialText = [NSString stringWithFormat:@" //@%@:%@",status.user.screenName,status.text];
        }
        [[self composeWindow] setComposeButtonTitle:NSLocalizedString(@"composer_repost_key", nil)];
    }
}

- (BOOL)canSendImage
{
    if (self.composition.retweetingStatus ||
        self.composition.replyToStatus)
    {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark UserInterface

- (void)accountChanged
{
    NSInteger index = [[[Weibo sharedWeibo] accounts] indexOfObject:self.account];
    if (index == NSNotFound)
    {
        index = 0;
    }
    self.composeWindow.selectedAccountIndex = index;
}

- (void)accountSetChanged:(NSNotification *)notification
{
    [self accountChanged];
}

- (void)imageLoaderDidLoad:(NSNotification*)notification {
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:[self profileImageURL]]) return;
	UIImage* nsImage = [[notification userInfo] objectForKey:@"image"];
    TUIImage* anImage = [TUIImage imageWithNSImage:nsImage];
	[self setAvatarImage:anImage];
}

#pragma mark -
#pragma mark Actions
- (void)setImageDataToUpload:(NSData *)newImageData
{
    self.composition.dirty = YES;
    self.imageData = newImageData;
    NSImage * image = [[NSImage alloc] initWithData:self.imageData];
    if (newImageData && image) {
        
    }else {
        self.imageData = nil;
    }
    [[self composeWindow] setAttachmentButtonImage:image];
    [image release];
}

- (void)textView:(WTComposeTextView *)textView didReceiveDragedImageData:(NSData *)newImageData{
    [self setImageDataToUpload:newImageData];
}
- (void)screenCapturer:(WTScreenCapturer *)capturer didFinishWithImageData:(NSData *)data{
    [self setImageDataToUpload:data];
}
- (void)compositionSent:(id)response info:(id)info
{
    if ([response isKindOfClass:[WeiboRequestError class]])
    {
        NSPoint origin = self.window.frame.origin;
        origin.y -= 30;
        [self.window setFrameOrigin:origin];
        [self.window setAlphaValue:1.0];
        [self.window makeKeyAndOrderFront:self];
                
        NSAlert * alert = [NSAlert alertWithMessageText:NSLocalizedString(@"There was an error posting your message", nil) defaultButton:NSLocalizedString(@"OK", nil) alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",[response message]];
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:nil];
    }
    else
    {
        [self.document close];
    }
}
- (IBAction)post:(id)sender
{
    WTComposeWindow * theWindow = (WTComposeWindow *)[self window];

    [theWindow dissociateNipple];
    
    [self.composition setText:[self textToPost]];
    [self.composition setDidSendCallback:WTCallbackMake(self, @selector(compositionSent:info:), nil)];
    [self.composition sendFromAccount:[self selectedAccount]];
    
    NSRect frame = [theWindow frame];
    frame.origin.y += 30;
    
    
    NSDictionary * animationOpt = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self.window,NSViewAnimationTargetKey,
                                   [NSValue valueWithRect:frame],NSViewAnimationEndFrameKey,
                                   NSViewAnimationFadeOutEffect,NSViewAnimationEffectKey,nil];
    NSViewAnimation * animation = [[NSViewAnimation alloc] 
                                   initWithViewAnimations:[NSArray arrayWithObject:animationOpt]];
    
    [animation setDuration:0.2f];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setAnimationCurve:NSAnimationLinear];
    [animation startAnimation];
    [animation release];
        
    [theWindow resignKeyWindow];
}

- (void)captureImage{
    [capturer startCapture];
}
- (void)selectLocalImage{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setPrompt: NSLocalizedString(@"Select", nil)];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"png",@"PNG",@"jpg",@"JPG",@"JPEG",@"jpeg",@"gif",@"GIF", nil]];
    [panel beginSheetModalForWindow:[self composeWindow] completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL * fileURL = [[panel URLs] objectAtIndex:0];
            NSData * newImageData = [[NSData alloc] initWithContentsOfURL:fileURL];
            [self setImageDataToUpload:newImageData];
            [newImageData release];
        }
    }];
}
- (void)toggleEmotionPopover:(id)sender{
    if (![[WeiboEmotionManager sharedManager] ready])
    {
        return;
    }
    
    if (self.popover.isShown)
    {
        [self.popover performClose:sender];
    }
    else
    {
        [self cleanPopover];
        
        WMEmotionViewController * emojiViewController = [[WMEmotionViewController alloc] init];
        
        self.popover.contentViewController = emojiViewController;
        
        emojiViewController.delegate = self;
        [emojiViewController release];
        
        [self.popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    }
}

- (void)close
{
    [self.composeWindow dissociateNipple];
    [super close];
}

- (void)performClose:(id)sender
{
    if (!self.composition.dirty)
    {
        [self close];
    }
    else
    {
        [self.composition canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(composition:shouldClose:contextInfo:) contextInfo:nil];
    }
}

- (void)composition:(WMComposition *)composition shouldClose:(BOOL)close contextInfo:(void *)contextInfo
{
    if (close)
    {
        [self close];
    }
}

- (void)selectNextAccount:(id)sender
{
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    NSInteger count = [accounts count];
    NSInteger index = self.composeWindow.selectedAccountIndex;
    
    index = (index + 1) % count;
    
    self.composeWindow.selectedAccountIndex = index;
}

- (void)selectPreviousAccount:(id)sender
{
    NSArray * accounts = [[Weibo sharedWeibo] accounts];
    NSInteger count = [accounts count];
    NSInteger index = self.composeWindow.selectedAccountIndex;
    
    index = (index - 1 + count) % count;
    
    self.composeWindow.selectedAccountIndex = index;
}

#pragma mark -
#pragma mark NSWindow Delegate Methods
- (BOOL)windowShouldClose:(id)sender{
    return YES;
}
- (void)windowDidResignKey:(NSNotification *)notification{
    [self cancelAutocomplete];
}
- (void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
    [self cancelAutocomplete];
}

- (void)emotionViewController:(WMEmotionViewController *)controller didSelectEmotion:(NSString *)phrase{
    [[[self composeWindow] textView] insertText:phrase];
    [self toggleEmotionPopover:nil];
}

- (void)cleanPopover
{
    WMEmotionViewController * controller = (WMEmotionViewController *)self.popover.contentViewController;
    
    if (controller)
    {
        [controller destory];
        
        self.popover.contentViewController = nil;
    }
}

- (void)popoverDidClose:(NSNotification *)notification
{
    [self cleanPopover];
    [[self composeWindow] emojiButton].pressedDown = NO;
    [[[self composeWindow] emojiButton] setNeedsDisplay];
}
- (void)popoverWillShow:(NSNotification *)notification
{
    [[self composeWindow] emojiButton].pressedDown = YES;
}

#pragma mark -
#pragma mark Autocomplete
- (void)prepareAutoCompleteMenu{
    autocompleteWindow = [[WTAutoCompleteWindow alloc] init];
    autocompleteWindow.delegate = self;
}
- (void)updateAutoComplete{
    
}
- (void)updateAutoCompleteItems{
    [autocompleteWindow setAutocompleteType:WeiboAutocompleteTypeUser];
    [autocompleteWindow setAutocompleteItems:autocompleteItems];
}

- (void)autocompletingText:(NSString *)text inRect:(NSRect)rect{
    autocompleteItems = [[LocalAutocompleteDB sharedAutocompleteDB] resultsForPartialText:text type:WeiboAutocompleteTypeUser];
    [self updateAutoCompleteItems];
    [self sizeAndPositionAutocompleteWindowWithTextRect:rect];
}
- (void)sizeAndPositionAutocompleteWindowWithTextRect:(NSRect)rect{
    CGFloat width = 140.0;
    CGFloat height = [autocompleteItems count] * 40.0;
    if (height > 200.0) {
        height = 200.0;
    }
    CGRect windowRect = CGRectMake(rect.origin.x, rect.origin.y - height - 5, width, height);
    [autocompleteWindow setFrame:windowRect display:YES];
    [autocompleteWindow orderFront:self];
    if ([autocompleteItems count] == 0) {
        [self cancelAutocomplete];
    }else {
        [autocompleteWindow.tableView reloadData];
        [autocompleteWindow selectFirstItem];
    }
}
- (void)cancelAutocomplete{
    [autocompleteWindow orderOut:self];
    [autocompleteWindow setFrame:NSZeroRect display:NO];
    [[[self composeWindow] textView] setIsAutoCompleting:NO];
}

- (void)completeWithItem:(WeiboAutocompleteResultItem *)item{
    __block WTComposeTextView * textView = [[self composeWindow] textView];
    __block NSRange replaceRange;
    [textView.string enumerateStringsMatchedByRegex:MENTION_REGEX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSInteger insertionPoint = [[[textView selectedRanges] objectAtIndex:0] rangeValue].location;
        NSRange activeRange = capturedRanges[0];
        if (insertionPoint > activeRange.location + 1 && insertionPoint <= activeRange.location + activeRange.length) {
            replaceRange = activeRange;
        }
    }];
    NSString * replaceWithText = [NSString stringWithFormat:@"@%@ ",item.autocompleteText];
    [textView replaceCharactersInRange:replaceRange withString:replaceWithText];
    NSNotification * notification = [NSNotification notificationWithName:@"FAKEDNOTIFICATION" object:textView];
    [[self composeWindow] textDidChange:notification];
    [self cancelAutocomplete];
}
- (void)textViewDidConfirmAutoComplete:(WTComposeTextView *)textView{
    NSInteger row = [[autocompleteWindow tableView] indexPathForSelectedRow].row;
    WeiboAutocompleteResultItem * item = [autocompleteItems objectAtIndex:row];
    
    [autocompleteWindow flashSelectedItemWithCompletion:^(BOOL finished) {
        [self completeWithItem:item];
    }];
}
- (void)textViewDidHighlightNextAutoComplete:(WTComposeTextView *)textView{
    [autocompleteWindow nextItem];
}
- (void)textViewDidHighlightPreviousAutoComplete:(WTComposeTextView *)textView{
    [autocompleteWindow previousItem];
}
- (void)textViewDidCancelAutoComplete:(WTComposeTextView *)textView{
    [self cancelAutocomplete];
}
- (void)autoCompleteTableView:(TUITableView *)tableView didSelectAutoCompleteItem:(WeiboAutocompleteResultItem *)item{
    [self completeWithItem:item];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if (menuItem.action == @selector(post:))
    {
        return self.window.isKeyWindow && [self composeWindow].textView.string.length > 0;
    }
    else if (menuItem.action == @selector(selectNextAccount:) ||
             menuItem.action == @selector(selectPreviousAccount:))
    {
        return [[[Weibo sharedWeibo] accounts] count] > 1;
    }
    
    return NO;
}

- (void)showWindow:(id)sender
{    
    [super showWindow:sender];
}

#pragma mark - NSTextView Delegate Methods

- (void)textDidChange:(NSNotification *)notification
{
    [self updateAutoCompleteItems];
    [self.composition setDirty:YES];
}

#pragma mark - Sheet Positioning

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect
{
    NSValue * rectValue = [sheet objectWithAssociatedKey:kWindowSheetPositionRect];
    if (rectValue) return [rectValue rectValue];
    
    return rect;
}

@end
