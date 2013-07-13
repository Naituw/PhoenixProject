//
//  WTImageViewer.m
//  WTImageViewer
//
//  Created by Tian Wu on 11-10-1.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTImageViewer.h"
#import "WTImageView.h"
#import "WTEventHandler.h"
#import "WTUIDragableNSView.h"

#define MIDDLE_PIC_MAX_WIDTH 440.0
#define WHITE_BORDER_WIDTH 20.0

@interface WTImageViewer () <ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    TUIView * rootView;
    TUIScrollView * scrollView;
    WTImageView * imageView;
    WTProgressBar * progressBar;
    WTHUDStatusView * successView;
    TUIButton * closeButton;
    
    NSMenu * popUpMenu;
    
    struct {
        unsigned int isLoading:1;
    } _flags;
}



@property (nonatomic, retain) NSString * currentImageURL;

@end

@implementation WTImageViewer

- (void)dealloc
{
    [_picture release], _picture = nil;
    [_currentRequest clearDelegatesAndCancel];
    [_currentRequest release];
    [_currentImageURL release], _currentImageURL = nil;
    [imageView release];
    [scrollView release];
    [progressBar release];
    [rootView release];
    [successView release];
    [nsView release];
    [super dealloc];
}

+ (NSArray *)imageViewers
{
    NSArray * allWindows = [NSApp windows];
    NSMutableArray * imageViewers = [NSMutableArray array];
    
    for (NSWindow * window in allWindows)
    {
        if ([window isKindOfClass:[WTImageViewer class]])
        {
            [imageViewers addObject:window];
        }
    }
    return imageViewers;
}

+ (void)viewImageWithImageURL:(NSString *)imageURL
{
    if ([imageURL hasSuffix:@"gif"])
    {
        [WTEventHandler openURL:imageURL];
        return;
    }
    
    WTImageViewer * viewer = [[WTImageViewer alloc] init];
    
    [viewer makeKeyAndOrderFront:nil];
    [viewer viewImageAtUrl:imageURL];
}

- (id)init
{
    if (self = [super initWithContentRect:NSMakeRect(0, 0, 200, 200)]){
        
        self.animationBehavior = NSWindowAnimationBehaviorDocumentWindow;
        
        [self setMovableByWindowBackground:YES];
        [[nsView retain] removeFromSuperview];
        
        CGFloat windowLength = MIDDLE_PIC_MAX_WIDTH/2 + 2*WHITE_BORDER_WIDTH;

        CGRect screenFrame = [[NSScreen mainScreen] frame];
        CGFloat screenWidth = screenFrame.size.width;
        CGFloat screenHeight = screenFrame.size.height;
        CGFloat areaHeight = screenHeight * 2 / 3;
        CGFloat areaY = screenHeight - areaHeight;
        NSRect windowFrame = NSMakeRect((screenWidth-windowLength)/2, areaY + (areaHeight-windowLength)/2, windowLength, windowLength);

         
        [self setWindowProposedFrame:windowFrame display:NO];
        [self setReleasedWhenClosed:YES];
        TUINSView * viewContainer = [[TUINSView alloc] init];
        self.contentView = viewContainer;
        
        rootView = [[TUIView alloc] init];
        rootView.backgroundColor = [TUIColor whiteColor];
        rootView.moveWindowByDragging = YES;

        viewContainer.rootView = rootView;
        
        scrollView = [[TUIScrollView alloc] initWithFrame:viewContainer.bounds];
        scrollView.backgroundColor = [TUIColor whiteColor];
        scrollView.autoresizingMask = TUIViewAutoresizingFlexibleSize;
        scrollView.scrollIndicatorStyle = TUIScrollViewIndicatorStyleDefault;
        scrollView.moveWindowByDragging = YES;
        [rootView addSubview:scrollView];
        
        imageView = [[WTImageView alloc] initWithFrame:CGRectZero];
        imageView.viewer = self;
        imageView.moveWindowByDragging = YES;
        [scrollView addSubview:imageView];
        
        [viewContainer release];
        
        
        progressBar = [[WTProgressBar alloc] initWithFrame:scrollView.bounds];
        progressBar.autoresizingMask = TUIViewAutoresizingFlexibleSize;
        progressBar.alpha = 0.5;
        progressBar.moveWindowByDragging = YES;
        
        
        CGRect hudrect = CGRectMake(0, 0, 100, 100);
        successView = [[WTHUDStatusView alloc] initWithFrame:hudrect];
        [rootView addSubview:successView];
        
        closeButton = [TUIButton buttonWithType:TUIButtonTypeCustom];
        [closeButton setImage:[TUIImage imageNamed:@"x.png"] forState:TUIControlStateNormal];
        [closeButton setLayout:^(TUIView * v){
            CGRect superBounds = v.superview.bounds;
            return CGRectMake(7, superBounds.size.height - 16, 9, 9);
        }];
        [closeButton setDimsInBackground:YES];
        [closeButton addTarget:self action:@selector(performClose:) forControlEvents:TUIControlEventTouchUpInside];
        [rootView addSubview:closeButton];
        
        
    }
    return self;
}

- (BOOL)useCustomContentView
{
	return YES;
}

- (BOOL)canBecomeKeyWindow{
    return YES;
}

- (BOOL)canBecomeMainWindow{
    return YES;
}


- (BOOL)windowShouldClose:(id)sender{
    return YES;
}

- (void)setWindowProposedFrame:(CGRect)frame display:(BOOL)display
{
    NSArray * allViewers = [[self class] imageViewers];
    
    NSMutableArray * imageViewers = [NSMutableArray array];
    
    for (WTImageViewer * viewer in allViewers)
    {
        if (!viewer.isVisible ||
            viewer == self)
        {
            continue;
        }
        
        [imageViewers addObject:viewer];
    }
    
#define TopLeft(r) CGPointMake(r.origin.x, r.origin.y + r.size.height)

    if (!imageViewers.count)
    {
        [self setFrame:frame display:display];
    }
    else
    {
        
        CGPoint resultTopLeft = CGPointMake(0, self.screen.visibleFrame.size.height);
        
        if (self.isVisible)
        {
            // Keep top left position if already visible
            
            resultTopLeft = CGPointMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height);
        }
        else
        {
            for (WTImageViewer * viewer in imageViewers)
            {
                if (!viewer.isVisible)
                {
                    return;
                }
                
                CGPoint topLeft = TopLeft(viewer.frame);
                
                resultTopLeft.x = MAX(topLeft.x, resultTopLeft.x);
                resultTopLeft.y = MIN(topLeft.y, resultTopLeft.y);
            }
            
            resultTopLeft.x += 40;
            resultTopLeft.y -= 40;
            
            resultTopLeft.x = MIN(resultTopLeft.x, self.screen.visibleFrame.size.width - 40);
            resultTopLeft.y = MAX(resultTopLeft.y, 40);
        }
        
        
        CGRect resultFrame = frame;
        
        resultFrame.origin = CGPointMake(resultTopLeft.x, resultTopLeft.y - frame.size.height);
        
        [self setFrame:resultFrame display:display];
    }
}

- (void)sizeWindowToFit:(CGSize)size
{
    if (size.width > MIDDLE_PIC_MAX_WIDTH) {
        //return;
    }
    
    CGRect screenFrame = [NSScreen mainScreen].visibleFrame;
    CGFloat screenHeight = screenFrame.size.height;
    
    CGFloat width = size.width + 2*WHITE_BORDER_WIDTH;
    CGFloat height = self.frame.size.height;
    if (size.height + 2*WHITE_BORDER_WIDTH < screenHeight) {
        height = size.height + 2*WHITE_BORDER_WIDTH;
    }
    else if (height < screenHeight*2/3) {
        height = screenHeight*2/3;
    }
    
    CGFloat x = self.frame.origin.x;
    if (x + width > screenFrame.size.width)
    {
        if (width > screenFrame.size.width)
        {
            width = screenFrame.size.width - x - 15.0;
        }
    }
    
    CGFloat screenWidth = screenFrame.size.width;
    CGFloat areaHeight = screenHeight * 2 / 3;
    if (height > areaHeight) {
        areaHeight = height;
    }
    CGFloat areaY = screenHeight - areaHeight;
    CGRect windowRect = CGRectMake((screenWidth-width)/2, areaY + (areaHeight-height)/2, width, height);
    [self setWindowProposedFrame:windowRect display:YES];
}

- (void)showProgressBar{
    [rootView addSubview:progressBar];
    progressBar.alpha = 0.0;
    progressBar.frame = scrollView.frame;
    [TUIView animateWithDuration:0.3 animations:^(void) {
        imageView.alpha = 0.3;
        progressBar.alpha = 0.5;
    }];
    [rootView bringSubviewToFront:progressBar];
    [rootView bringSubviewToFront:closeButton];
}
- (void)hideProgressBar{
    [TUIView animateWithDuration:0.3 animations:^(void) {
        progressBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        [progressBar setProgress:0.0 animated:NO];
        [progressBar removeFromSuperview];
    }];
}

- (void)setImage:(TUIImage *)image
{
    [self setImage:image animated:NO sizeWindowToFit:YES];
}

- (void)setImage:(TUIImage *)image animated:(BOOL)animated sizeWindowToFit:(BOOL)sizeWindow
{
    [self hideProgressBar];
    
    //[image __setScale:[self.screen backingScaleFactor]];
    
    CGSize imageSize = image.size;
    if (sizeWindow)
    {
        [self sizeWindowToFit:imageSize];
    }
    else
    {
        imageSize = self.frame.size;
        imageSize.width -= 2 * WHITE_BORDER_WIDTH;
        imageSize.height -= 2 * WHITE_BORDER_WIDTH;
    }
    
    imageView.image = image;
    CGRect b = rootView.bounds;
    
    if (animated)
    {
        imageView.alpha = 0.0;
        [CATransaction begin];
        imageView.frame = CGRectMake((b.size.width-10)/2, (b.size.height - 10)/2, 10, 10);
        [CATransaction flush];
        [CATransaction commit];
    }
    
    
    CGRect imageRect = CGRectMake(WHITE_BORDER_WIDTH, WHITE_BORDER_WIDTH,
                                  imageSize.width, imageSize.height);
    
    if (animated)
    {
        [TUIView animateWithDuration:0.3 animations:^(void) {
            imageView.alpha = 1.0;
            imageView.frame = imageRect;
        }];
    }
    else
    {
        imageView.frame = imageRect;
    }
    
    
    CGSize scrollSize = CGSizeMake(imageSize.width + 2*WHITE_BORDER_WIDTH,
                                   imageSize.height + 2*WHITE_BORDER_WIDTH);
    scrollView.contentSize = scrollSize;
    [scrollView scrollToTopAnimated:NO];
}

- (void)viewImageAtUrl:(NSString *)urlString
{
    NSURL * url = [NSURL URLWithString:urlString];
    WTImageRequest * request = [WTImageRequest requestWithURL:url];
    request.delegate = self;
    request.downloadProgressDelegate = self;
    [request startAsynchronous];
    self.currentRequest = request;
    self.currentImageURL = urlString;
    _flags.isLoading = YES;
    [self showProgressBar];
}

- (void)setMaxValue:(double)newMax{
    [progressBar setProgress:0.0 animated:NO];
}
- (void)setDoubleValue:(double)newProgress{
    [progressBar setProgress:newProgress animated:YES];
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSURL * saveUrl = [(WTImageRequest *)request saveURL];
    if (saveUrl) {
        TUIImage * image = [TUIImage imageWithData:request.responseData];
        NSData * imageData = TUIImagePNGRepresentation(image);
        [imageData writeToURL:saveUrl atomically:YES];
        [self hideProgressBar];
        
        [successView showInView:rootView status:NSLocalizedString(@"imageviewer_download_success_key", nil)];
        [successView performSelector:@selector(dismiss) withObject:nil afterDelay:2.0];
        [TUIView animateWithDuration:0.3 delay:2.0 curve:TUIViewAnimationCurveEaseInOut animations:^(void) {
            imageView.alpha = 1.0;
        } completion:NULL];
    }
    else{
        NSData * imageData = request.responseData;
        TUIImage * image = [TUIImage imageWithData:imageData];
        [TUIView animateWithDuration:0.0 animations:^(void) {
            [progressBar setProgress:1.0];
            imageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (image) {
                [self setImage:image animated:YES sizeWindowToFit:YES];
            }
        }];
    }
    self.currentRequest = nil;
    if (_flags.isLoading) {
        _flags.isLoading = NO;
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent{
    popUpMenu = [[NSMenu alloc] init];
    [popUpMenu addItemWithTitle:NSLocalizedString(@"Save", nil)
                         action:@selector(savePhoto:)
                  keyEquivalent:@""];
    [popUpMenu addItem:[NSMenuItem separatorItem]];
    if (self.picture.originalImage)
    {
        [popUpMenu addItemWithTitle:NSLocalizedString(@"View Original Image", nil)
                             action:@selector(viewBigOne)
                      keyEquivalent:@""];
        [popUpMenu addItemWithTitle:NSLocalizedString(@"Copy Original Image URL", nil)
                             action:@selector(copyOriginalImageURL)
                      keyEquivalent:@"c"];
        [popUpMenu addItemWithTitle:NSLocalizedString(@"Download Original Image", nil)
                             action:@selector(downloadBigPhoto:)
                      keyEquivalent:@""];
        [popUpMenu addItem:[NSMenuItem separatorItem]];
    }
    [popUpMenu addItemWithTitle:NSLocalizedString(@"Open in Browser", nil)
                         action:@selector(viewInBrowser)
                  keyEquivalent:@""];
    
    for (NSMenuItem * item in popUpMenu.itemArray)
    {
        item.target = self;
    }
    
    if(popUpMenu && !_flags.isLoading)
    {
		NSMenu *menu = popUpMenu;
		NSPoint p = [theEvent locationInWindow];
		p.x += 6;
		p.y -= 2;
		[menu popUpMenuPositioningItem:nil atLocation:p inView:imageView.nsView];
		[imageView.nsView performSelector:@selector(mouseUp:) withObject:theEvent afterDelay:0.0];
	}
    
    
    [popUpMenu autorelease];
}

- (void)savePhoto:(id)sender{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"png"]];
    [savePanel setExtensionHidden:NO];
    
    NSString * urlString = self.currentImageURL;
    
    if (!urlString)
    {
        urlString = self.picture.middleImage;
    }
    
    NSURL * currentURL = [NSURL URLWithString:urlString];
    NSString * fileName = [currentURL lastPathComponent];
    NSString * pathExtension = [currentURL pathExtension];
    
    if (![pathExtension isEqualToString:@"png"])
    {
        fileName = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",pathExtension] withString:@".png"];
    }
    
    if (fileName)
    {
        [savePanel setNameFieldStringValue:fileName];
    }
    
    NSUInteger userChoose = [savePanel runModal];
    switch (userChoose) {
        case NSOKButton:
            break;
        case NSCancelButton:
            return;
        default:
            return;
    }
    NSURL * filename = [savePanel URL];
    TUIImage * image = imageView.image;
    NSData * imageData = TUIImagePNGRepresentation(image);
    [imageData writeToURL:filename atomically:YES];
}

- (void)downloadPhotoToURL:(NSURL*)url{
    [self hideProgressBar];
}
- (void)downloadBigPhoto:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = [NSArray arrayWithObject:@"png"];
    NSUInteger userChoose	= [savePanel runModal];
    switch (userChoose) {
        case NSOKButton:
            break;
        case NSCancelButton:
            return;
        default:
            return;
    }
    
    NSURL * filename = [savePanel URL];
    NSURL * url = [NSURL URLWithString:self.picture.originalImage];
    WTImageRequest * request = [WTImageRequest requestWithURL:url];
    request.saveURL = filename;
    request.delegate = self;
    request.downloadProgressDelegate = self;
    [request startAsynchronous];
    self.currentRequest = request;
    _flags.isLoading = YES;
    [self showProgressBar];
}

- (void)viewInBrowser
{
    NSString * url = self.currentImageURL;
    if (self.picture.originalImage)
    {
        url = self.picture.originalImage;
    }
    [WTEventHandler openURL:url];
}
- (void)viewBigOne
{
    [self viewImageAtUrl:self.picture.originalImage];
}
- (void)copyOriginalImageURL
{
    if (self.picture.originalImage.length)
    {
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] writeObjects:[NSArray arrayWithObject:self.picture.originalImage]];
    }
}
- (void)copy:(id)sender
{
    [self copyOriginalImageURL];
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(copy:))
    {
        return (self.picture.originalImage.length > 0);
    }
    else if (menuItem.action == @selector(performClose:))
    {
        return YES;
    }
    return [super validateMenuItem:menuItem];
}

- (void)performClose:(id)sender
{
    [self close];
}

@end
