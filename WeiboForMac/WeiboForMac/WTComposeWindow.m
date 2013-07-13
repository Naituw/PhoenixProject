//
//  WTComposeWindow.m
//  ComposeWindowDemo
//
//  Created by Wutian on 12-1-19.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WTComposeWindow.h"
#import "WTCGAdditions.h"
#import "WTComposeTextView.h"
#import "WTComposeAvatarView.h"
#import "WTComposerButton.h"
#import "WTImageAttachmentButton.h"
#import "WTComposeWindowController.h"
#import "WTActiveTextRanges.h"
#import "WeiboConstants.h"
#import "RegexKitLite.h"
#import "WMEmojiCollectorView.h"
#import "WeiboBaseStatus+StatusCellAdditions.h"

@interface WTComposeWindow ()
- (int)sinaCountWord:(NSString*)s;
- (void)sizeWindowToFitTextView;
- (void)showAddMenu:(id)sender;

@property (nonatomic, retain) NSWindow * nipple;

@end

@implementation WTComposeWindow
@synthesize controller = _controller, emojiButton;

- (void)dealloc
{
    [self dissociateNipple];
    
    [textView release];
    [avatarView release];
    [countLabel release];
    
    [postButton release];
    [cancelButton release];
    [addButton release];
    [emojiButton release];
    [imageButton release];
    [nsView release];
    [super dealloc];
}

- (id)initWithContentRect:(CGRect)rect
{
    if((self = [super initWithContentRect:rect]))
    {
        [self performSelector:@selector(constructNippleIfNeeded) withObject:nil afterDelay:0.3];
        
        
        [self setHasShadow:YES];
        [self setLevel:NSFloatingWindowLevel];
        [self setMovableByWindowBackground:YES];
        
        // compose window does NOT use any TUIView based components. so we don't need this TUINSView.
        [[nsView retain] removeFromSuperview];
        
        NSRect countRect = NSMakeRect(70,BOTTOMBAR_HEIGHT + 0 , rect.size.width - 57, 
                                      rect.size.height - BOTTOMBAR_HEIGHT - 10);
        countLabel = [[NSTextField alloc] initWithFrame:countRect];
        [countLabel setAlignment:NSRightTextAlignment];
        [countLabel setEditable:NO];
        [countLabel setSelectable:NO];
        [countLabel setBordered:NO];
        [countLabel setDrawsBackground:NO];
        [countLabel setFont:[NSFont fontWithName:@"HelveticaNeue" size:88.0]];
        [countLabel setTextColor:[NSColor colorWithDeviceWhite:0.88 alpha:1.0]];
        countLabel.stringValue = @"140";
        [[self contentView] addSubview:countLabel];
        
        // add compose textview
        NSRect textRect = NSMakeRect(70,BOTTOMBAR_HEIGHT + 10 , rect.size.width - 80, 
                                     rect.size.height - BOTTOMBAR_HEIGHT - 20);
        textView = [[WTComposeTextView alloc] initWithFrame:textRect];
        textView.delegate = self;
        textView.allowsUndo = YES;
        [[self contentView] addSubview:textView];
        self.initialFirstResponder = textView;
        
        NSRect avatarRect = NSMakeRect(10, rect.size.height - 60, 50, 50);
        avatarView = [[WTComposeAvatarView alloc] initWithFrame:avatarRect];
        [avatarView setWantsLayer:YES];
        avatarView.layer.cornerRadius = 4.0;
        avatarView.layer.masksToBounds = YES;
        avatarView.autoresizingMask = NSViewMinYMargin;
        avatarView.selectedAccountIndex = 1;
        [[self contentView] addSubview:avatarView];
        
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSData * avatarData = [ud objectForKey:[NSString stringWithFormat:@"user-avatar-%@",@"placeholder"]];
        if (avatarData) {
            NSImage * image = [[NSImage alloc] initWithData:avatarData];
            [avatarView setImage:image];
            [image release];
        }
        
        
        NSRect postRect = NSMakeRect(rect.size.width - 90, 10, 80, 26);
        postButton = [[WTComposerButton alloc] initWithFrame:postRect];
        [postButton setTitle:NSLocalizedString(@"composer_send_key", nil)];
        [postButton setEnabled:NO];
        [postButton setTarget:_controller];
        [postButton setAction:@selector(post:)];
        [postButton setShouldInset:YES];
        [[self contentView] addSubview:postButton];
        [self setDefaultButtonCell:[postButton cell]];
        
        NSRect cancelRect = NSMakeRect(10, 10, 70, 26);
        cancelButton = [[WTComposerButton alloc] initWithFrame:cancelRect];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
        [cancelButton setTarget:self];
        [cancelButton setAction:@selector(performClose:)];
        [[self contentView] addSubview:cancelButton];
        
        NSRect addRect = NSMakeRect(rect.size.width - 127, 10, 30, 26);
        addButton = [[WTComposerButton alloc] initWithFrame:addRect];
        [addButton setImage:[NSImage imageNamed:@"composer-add.png"]];
        [[self contentView] addSubview:addButton];
        
        NSRect emojiButtonRect = NSMakeRect(rect.size.width - 163 , 10, 30, 26);
        emojiButton = [[WTComposerButton alloc] initWithFrame:emojiButtonRect];
        [emojiButton setImage:[NSImage imageNamed:@"composer-emoji"]];
        [emojiButton setTarget:self.controller];
        [emojiButton setAction:@selector(toggleEmotionPopover:)];
        [[self contentView] addSubview:emojiButton];
        
        
        NSMenu * addMenu = [[NSMenu alloc] initWithTitle:@"addMenu"];
        [addMenu addItemWithTitle:NSLocalizedString(@"Capture Screen", nil) action:@selector(capture) keyEquivalent:@"p"];
        [addMenu addItemWithTitle:NSLocalizedString(@"Select Image", nil) action:@selector(selectLocalImage) keyEquivalent:@"i"];
        for (NSMenuItem * item in addMenu.itemArray)
        {
            [item setTarget:self];
        }
        [addMenu setAutoenablesItems:YES];
        [addButton setMenu:addMenu];
        [addMenu release];
        
        NSRect imageRect = NSMakeRect(90, 10, 30, 26);
        imageButton = [[WTImageAttachmentButton alloc] initWithFrame:imageRect];
        [imageButton setHidden:YES];
        [[self contentView] addSubview:imageButton];
        
        [self setReleasedWhenClosed:YES];
        
        /*
        containerView = [[WMEmojiCollectorView alloc] initWithFrame:NSMakeRect(20, 20, 20, 20)];
        [containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        [self.contentView addSubview:containerView];*/
    }
    return self;
}

- (void)setButtonsNeedsDisplay
{
    [postButton setNeedsDisplay];
    [addButton setNeedsDisplay];
    [imageButton setNeedsDisplay];
    [emojiButton setNeedsDisplay];
    [cancelButton setNeedsDisplay];
}

- (BOOL)useCustomContentView
{
	return YES;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (void)setController:(WTComposeWindowController *)controller{
    _controller = controller;
    self.windowController = controller;
    if (textView) {
        textView.composeDelegate = _controller;
    }
}

- (NSString *)textToPost{
    return [textView string];
}

- (NSImage *)attachmentImage{
    return [imageButton image];
}

- (void)setAttachmentButtonImage:(NSImage *)image{
    [imageButton setHidden:(image == nil)];
    [imageButton setImage:image];
}

- (BOOL)shouldShowMetaString{
    return NO;
    //return !([_controller composeType] == WTComposeTypeNew);
}

- (CGFloat)minHeightOfWindow{
    CGFloat minHeight = BOTTOMBAR_HEIGHT + 70.0 + 18.0;
    if ([self shouldShowMetaString]) {
        minHeight += METASTRING_AREA_HEIGHT;
    }
    return minHeight;
}


- (void)sizeWindowToFitTextView{
    NSRect oldFrame = textView.frame;
    [textView sizeToFit];
    NSRect textBounds = [textView bounds];
    CGFloat textNewHeight = textBounds.size.height;
    textView.frame = oldFrame;
    
    NSRect frame = [self frame];
    CGFloat textOldHeight = frame.size.height - BOTTOMBAR_HEIGHT - 20;
    CGFloat delta = textNewHeight - textOldHeight;
    if (delta == 0) {
        return;
    }
    NSRect newFrame = frame;
    
    // compose window has a minimal size , we can not make it smaller then this.
    if ((newFrame.size.height + delta) < [self minHeightOfWindow]) {
        delta = [self minHeightOfWindow] - newFrame.size.height;
    }
    
    newFrame.origin.y -= delta;
    newFrame.size.height += delta;
    
    // keep text view in the right place.
    CGFloat addition = [self shouldShowMetaString]?METASTRING_AREA_HEIGHT:0;
    NSRect textRect = NSMakeRect(70,BOTTOMBAR_HEIGHT + 10 + addition , newFrame.size.width - 80, 
                                 newFrame.size.height - BOTTOMBAR_HEIGHT - 20 - addition);
    
    BOOL animate = YES;
        
    if (animate)
    {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            [context setDuration:0.1];
            [[self animator] setFrame:newFrame display:YES];
            [[textView animator] setFrame:textRect];
        } completionHandler:^{
            [self setButtonsNeedsDisplay];
        }];
    }
    else
    {
        [self setFrame:newFrame display:YES];
        [textView setFrame:textRect];
        [self setButtonsNeedsDisplay];
    }
}

- (void)demo{
    NSRect rect = containerView.frame;
    rect.origin.x += 100;
    [[containerView animator] setFrame:rect];
}

- (void)refreshCountLabelWithCount:(NSInteger) count{
    int remain = (int)(140 - count);
    countLabel.stringValue = [NSString stringWithFormat:@"%d",remain];
    if (remain < 0) {
        [countLabel setTextColor:[NSColor colorWithDeviceRed:252/255.0 green:212/255.0 blue:215/255.0 alpha:1.0]];
        [postButton setEnabled:NO];
    }else{
        [countLabel setTextColor:[NSColor colorWithDeviceWhite:0.88 alpha:1.0]];
        [postButton setEnabled:YES];
    }
    if (remain == 140) {
        [postButton setEnabled:NO];
    }
}

- (NSDictionary *)defaultTextAttribute{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont fontWithName:@"HelveticaNeue" size:13.0],NSFontAttributeName,
            NORMALTEXT_COLOR.nsColor, NSForegroundColorAttributeName,nil];
}

- (void)updateTextAttribute{
    NSString * text = [textView string];
    __block int count = [self sinaCountWord:text];
    __block typeof(self) SELF = self;
    [[textView textStorage] addAttributes:[self defaultTextAttribute] range:NSMakeRange(0, text.length)];
    WTActiveTextRanges * ranges = [[WTActiveTextRanges alloc] initWithString:text];
    
    
    for (ABFlavoredRange * range in ranges.activeRanges) {
        NSColor * fontColor = HIGHLIGHTED_COLOR.nsColor;
        if (range.rangeFlavor == ABActiveTextRangeFlavorTwitterHashtag) {
            fontColor = HASHTAG_COLOR.nsColor;
        }
        NSDictionary * linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   fontColor, NSForegroundColorAttributeName,nil];
        [[textView textStorage] addAttributes:linkAttr range:range.rangeValue];
    }
    
    [ranges release];
    
    // WTActiveTextRanges only parses short links (for performance). So we parse links here again.
    [text enumerateStringsMatchedByRegex:WEIBO_LINK_REGEX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSDictionary * linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   HIGHLIGHTED_COLOR.nsColor, NSForegroundColorAttributeName,nil];
        [[textView textStorage] addAttributes:linkAttr range:capturedRanges[0]];
        int linkcount = [SELF sinaCountWord:capturedStrings[0]];
        if (linkcount > 70) {
            count += (linkcount - 70);
        }
        count -= linkcount;
        count += 10;
    }];
    
    [textView setTypingAttributes:[self defaultTextAttribute]];
    
    [self refreshCountLabelWithCount:count];
}

- (void)textDidChange:(NSNotification *)notification

{
    NSTextView * theTextView = (NSTextView *)[notification object];
    if (theTextView == textView) {
        [self sizeWindowToFitTextView];
        [self updateTextAttribute];
        [_controller textDidChange:notification];
    }
}
- (void)textViewDidChangeSelection:(NSNotification *)notification{
    __block BOOL isAutocompleting = NO;
    __block WTComposeTextView * TEXTVIEW = textView;
    __block WTComposeWindowController * CONTROLLER = _controller;
    [textView.string enumerateStringsMatchedByRegex:MENTION_REGEX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSInteger insertionPoint = [[[TEXTVIEW selectedRanges] objectAtIndex:0] rangeValue].location;
        NSRange activeRange = capturedRanges[0];
        NSRange markedRange = [TEXTVIEW markedRange];
        if (insertionPoint > activeRange.location + 1 && insertionPoint <= activeRange.location + activeRange.length &&
            markedRange.length < 1) {
            isAutocompleting = YES;
            NSRect activeRect = [TEXTVIEW firstRectForCharacterRange:activeRange];
            NSString * autocompleteText = [[TEXTVIEW.string substringWithRange:activeRange] substringFromIndex:1];
            [CONTROLLER autocompletingText:autocompleteText inRect:activeRect];
        }
    }];
    [textView setIsAutoCompleting:isAutocompleting];
    if (!isAutocompleting) {
        [_controller cancelAutocomplete];
    }
}

- (void)windowDidFinishDisplaying
{
    [self sizeWindowToFitTextView];
    [self makeFirstResponder:textView];
}

- (void)capture
{
    [_controller captureImage];
}
- (void)selectLocalImage
{
    [_controller selectLocalImage];
}

- (void) drawBackground:(CGRect)rect{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGRect b = [self frame];
    CGFloat temp = 0;
    CGFloat alpha = 0.95;
    b.origin.x = 0;
    b.origin.y = 0;
    
    // draw rounded corner background with transparency.
    CGContextClipToRoundRect(ctx, b, 10.0);
    
    // bottom gradient
    WTCGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, BOTTOMBAR_HEIGHT-2), 55.0/255.0, CGPointMake(0, 0), 30.0/255.0, alpha);
    
    temp = 0.0/255.0;
    CGContextSetRGBFillColor(ctx, temp, temp, temp, alpha); // dark at the top
    CGContextFillRect(ctx, CGRectMake(0, BOTTOMBAR_HEIGHT - 1, b.size.width, 1));
    temp = 120.0/255.0;
    CGContextSetRGBFillColor(ctx, temp, temp, temp, 0.9); // light beyond the top
    CGContextFillRect(ctx, CGRectMake(0, BOTTOMBAR_HEIGHT - 2, b.size.width, 1));
    
    // top gradient
    WTCGContextDrawLinearGradientBetweenPoints(ctx, CGPointMake(0, b.size.height), 252.0/255.0, CGPointMake(0, BOTTOMBAR_HEIGHT), 237.0/255.0, 1.0);
    
    /*
    NSString * metaString = [_controller metaString];
    if (metaString) {
        NSColor * fontColor = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
        NSDictionary * atts = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSFont fontWithName:@"HelveticaNeue" size:12.0],NSFontAttributeName, 
                               fontColor,NSForegroundColorAttributeName,
                               nil];
        NSRect metaStringRect = NSMakeRect(70, BOTTOMBAR_HEIGHT + 5, b.size.width - 80, 18);
        //[metaString drawInRect:metaStringRect withAttributes:atts];
    }
     */
}

- (void)showAddMenu:(id)sender{
    
}

- (int)sinaCountWord:(NSString*)s
{
    int i,n=(int)[s length],l=0,a=0,b=0;
    unichar c;
    for(i=0;i<n;i++){
        c=[s characterAtIndex:i];
        if(isblank(c)){
            b++;
        }else if(isascii(c)){
            a++;
        }else{
            l++;
        }
    }
    if(a==0 && l==0) return 0;
    return l+(int)ceilf((float)(a+b)/2.0);
}


/*  -------------------------------------------------------------
 *      make cmd+w work
 *  -------------------------------------------------------------
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL action = [menuItem action];
    if (action == @selector(capture) || action == @selector(selectLocalImage)) {
        return [_controller canSendImage];
    }
    return ([menuItem action] == @selector(performClose:) || [menuItem action] == @selector(performMiniaturize:))? YES : [super validateMenuItem:menuItem];
}

- (BOOL)windowShouldClose:(id)sender
{
    return YES;
}

- (void)performClose:(id)sender
{    
    if([[self delegate] respondsToSelector:@selector(windowShouldClose:)])
    {
        if(![[self delegate] windowShouldClose:self]) return;
    }
    else if([self respondsToSelector:@selector(windowShouldClose:)])
    {
        if(![self windowShouldClose:self]) return;
    }
    
    [self.controller performClose:sender];
}

- (void)performMiniaturize:(id)sender
{
    [self miniaturize:self];
}

- (void)performZoom:(id)sender
{
    //[self zoom:self];
}

- (void)setAvatarImage:(NSImage *)anImage
{
    [avatarView setImage:anImage];
}
- (void)setText:(NSString *)text selectedRange:(NSRange)range
{
    [textView.textStorage replaceCharactersInRange:NSMakeRange(0, textView.attributedString.string.length) withString:text];
    [self updateTextAttribute];
    [textView setSelectedRange:range];
}
- (void)setComposeButtonTitle:(NSString *)title
{
    postButton.title = title;
}

- (WTComposeTextView *)textView{
    return textView;
}

- (NSInteger)selectedAccountIndex
{
    return avatarView.selectedAccountIndex;
}
- (void)setSelectedAccountIndex:(NSInteger)selectedAccountIndex
{
    avatarView.selectedAccountIndex = selectedAccountIndex;
}

- (void)constructNippleIfNeeded
{
    if (!self.shouldShowNipple)
    {
        return;
    }
    
    if (self.nipple)
    {
        [self dissociateNipple];
    }
    
    NSRect nippleFrame = NSMakeRect(0, self.frame.origin.y + self.frame.size.height - 45, 10, 20);
    
    NSString * imageName = nil;
    
    if (self.nippleDirection == WTComposeWindowNippleDirectionLeft)
    {
        nippleFrame.origin.x = self.frame.origin.x - nippleFrame.size.width;
        imageName = @"compose-nipple-left";
    }
    else
    {
        nippleFrame.origin.x = CGRectGetMaxX(self.frame);
        imageName = @"compose-nipple-right";
    }
    
    self.nipple = [[[NSWindow alloc] initWithContentRect:nippleFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO] autorelease];
    
    NSImage * image = [NSImage imageNamed:imageName];
    
    [self.nipple.contentView setWantsLayer:YES];
    [[self.nipple.contentView layer] setContents:image];
    
    [self.nipple setOpaque:NO];
    [self.nipple setBackgroundColor:[NSColor clearColor]];
    [self.nipple setHasShadow:NO];
    [self.nipple setIgnoresMouseEvents:NO];
    [self.nipple setLevel:self.level + 1];
    [self.nipple setAlphaValue:0.0];
    
    [self addChildWindow:self.nipple ordered:NSWindowAbove];
    
    [[self.nipple animator] setAlphaValue:1.0];
}

+ (NSArray *)composeWindows
{
    NSArray * allWindows = [NSApp windows];
    NSMutableArray * composeWindows = [NSMutableArray array];
    
    for (NSWindow * window in allWindows)
    {
        if ([window isKindOfClass:[WTComposeWindow class]])
        {
            [composeWindows addObject:window];
        }
    }
    return composeWindows;
}

+ (void)dissociateAllNipples
{
    [[self composeWindows] makeObjectsPerformSelector:@selector(dissociateNipple)];
}

- (void)dissociateNipple
{
    [self removeChildWindow:self.nipple];
    [self.nipple orderOut:self];
    [self setNipple:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [super mouseDragged:theEvent];
    
    [self dissociateNipple];

}

@end
