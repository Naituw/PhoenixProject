//
//  WMColumnViewController.m
//  new-window
//
//  Created by Wu Tian on 12-7-11.
//  Copyright (c) 2012年 Wutian. All rights reserved.
//

#import "WMColumnViewController.h"
#import "WMSatelliteWindow.h"
#import "TUIKit.h"
#import "WMUserPreferences.h"

#define kAnimationDuration 0.3

@interface WMColumnViewController () <WUIGestureRecognizerDelegate>
{
    struct {
        unsigned int animatingPush:1;
        unsigned int animatingPop:1;
    } _flags;
}
@property (nonatomic, retain) TUIView * resizeKnob;
@property (nonatomic, retain) NSMutableArray *columns;
@end

@implementation WMColumnViewController
@synthesize columns = _columns;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_columns release], _columns = nil;
    [_resizeKnob release], _resizeKnob = nil;
    [super dealloc];
}

- (id)init{
    if (self = [super init])
    {
        self.columns = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayPreferenceSetDidChange:) name:WMUserDisplayPreferenceSetDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad{
    self.view.layer.cornerRadius = 8.0;
    self.view.layer.masksToBounds = YES;
    
    self.resizeKnob = [[[TUIView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)] autorelease];
    
    [self.resizeKnob setOpaque:NO];
    [self.resizeKnob setLayout:^(TUIView * v){
        CGRect superBounds = v.superview.bounds;
        return CGRectMake(superBounds.size.width - 17, 0, 17, 17);
    }];
    [self.resizeKnob setDrawRect:^(TUIView * v,CGRect rect){
        TUIImage * dots = [TUIImage imageNamed:@"resize-dots.png"];
        [dots drawInRect:CGRectMake(0, 0, 17, 17)];
    }];
    [self.resizeKnob setResizeWindowByDragging:YES];
    [self.view addSubview:self.resizeKnob];
    
    if ([self.view isKindOfClass:[WUIView class]])
    {
        WUIPanGestureRecognizer * recognizer = [[WUIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:withEvent:)];
        [recognizer setCancelsEvent:YES];
        [recognizer setDelegate:self];
        [recognizer setDirection:WUIPanGestureRecognizerDirectionRight];
        [(WUIView *)self.view addGestureRecognizer:recognizer];
        [recognizer release];
    }
}

#pragma mark - Accessors

- (WTUIViewController *)topViewController{
    if (self.viewControllers.count > 0)
    {
        return [self.viewControllers lastObject];
    }
    return nil;
}

- (NSArray *)viewControllers
{
    return self.columns;
}

- (BOOL)isRoot:(WTUIViewController *)aViewController{
    if (self.viewControllers.count > 0)
    {
        WTUIViewController * rootViewController = [self.viewControllers objectAtIndex:0];
        if (aViewController == rootViewController)
        {
            return YES;
        }
    }
    return NO;
}
- (void)_updateFirstResponder:(TUIResponder *)newResponder
{
    [self.view.nsWindow makeFirstResponder:newResponder];
}
- (CGRect)_controllerFrame
{
    return self.view.bounds;
}


#pragma mark - View Transition.

- (BOOL)viewIsAnimating:(TUIView *)view
{
    return (view.layer.animationKeys.count > 0);
}


- (void)pushViewController:(WTUIViewController *)viewController animated:(BOOL)animated{
    if (_flags.animatingPop)
    {
        return;
    }
    
    assert(![self.columns containsObject:viewController]);
    [viewController setParentViewController:self];
    
    if ([self isViewLoaded]) {
        WTUIViewController *oldViewController = self.topViewController;
        
        const CGRect controllerFrame = [self _controllerFrame];
        const CGRect nextFrameStart = CGRectOffset(controllerFrame, controllerFrame.size.width + 112.0, 0);
        const CGRect nextFrameEnd = controllerFrame;
        
        viewController.initialBounds = [self  _controllerFrame];
        viewController.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight;
        [viewController appendBoxShadow];
        [self.view addSubview:viewController.view];
                
        if (animated) {
            
            _flags.animatingPush = YES;
            
            [CATransaction begin];
            viewController.view.frame = nextFrameStart;
            [CATransaction flush];
            [CATransaction commit];
            
            [oldViewController retain];
            [oldViewController viewWillDisappear:YES];
            [viewController viewWillAppear:animated];
            [TUIView animateWithDuration:kAnimationDuration * 0.8
                              animations:^(void) {
                                  viewController.view.frame = nextFrameEnd;
                              }
                              completion:^(BOOL finished) {
                                  [viewController viewDidAppear:animated];
                                  [oldViewController.view removeFromSuperview];
                                  [oldViewController release];
                                  
                                  _flags.animatingPush = NO;
                              }];
        } else {
            viewController.view.frame = nextFrameEnd;
            [viewController viewWillAppear:animated];
            [viewController viewDidAppear:animated];
            [oldViewController viewWillDisappear:NO];
            [oldViewController.view removeFromSuperview];
        }
    }
    
    [self.columns addObject:viewController];
    [self afterLayout];
}

- (BOOL)popViewControllerAnimated:(BOOL)animated
{
    if (_flags.animatingPush)
    {
        return NO;
    }
    
    if ([self.columns count] > 1)
    {
        WTUIViewController *oldViewController = [self.topViewController retain];
        [oldViewController setParentViewController:nil];
        [self.columns removeLastObject];
        
        if ([self isViewLoaded]) {
            WTUIViewController *nextViewController = self.topViewController;
            
            const CGRect controllerFrame = [self _controllerFrame];
            const CGRect nextFrameEnd = controllerFrame;
            const CGRect oldFrameStart = controllerFrame;
            const CGRect oldFrameEnd = CGRectOffset(controllerFrame, controllerFrame.size.width + 112.0, 0);
            
            nextViewController.initialBounds = [self  _controllerFrame];
            nextViewController.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight;
            [nextViewController relayoutIfNeeded];
            
            [self.view insertSubview:nextViewController.view atIndex:0];
            
            
            if (animated) {
                _flags.animatingPop = YES;
                
                [CATransaction begin];
                nextViewController.view.frame = nextFrameEnd;
                oldViewController.view.frame = oldFrameStart;
                [CATransaction flush];
                [CATransaction commit];
                
                [oldViewController retain];
                [oldViewController viewWillDisappear:YES];
                [oldViewController appendBoxShadow];
                [nextViewController viewWillAppear:animated];

                [TUIView animateWithDuration:kAnimationDuration * 0.8
                                  animations:^(void) {
                                      oldViewController.view.frame = oldFrameEnd;
                                  }
                                  completion:^(BOOL finished) {
                                      [oldViewController.view removeFromSuperview];
                                      [oldViewController release];
                                      [nextViewController viewDidAppear:animated];
                                      [self _updateFirstResponder:nextViewController];
                                      
                                      _flags.animatingPop = NO;
                                  }];
            } else {
                nextViewController.view.frame = nextFrameEnd;
                [nextViewController viewWillAppear:animated];
                [oldViewController viewWillDisappear:NO];
                [oldViewController.view removeFromSuperview];
                [nextViewController viewDidAppear:animated];
                [self _updateFirstResponder:nextViewController];
            }
        }
        [oldViewController release];
        
        return YES;
    }
    return NO;
}
- (void)popToViewController:(WTUIViewController *)viewController animated:(BOOL)animated
{
    if (_flags.animatingPush)
    {
        return;
    }
    
    NSInteger targetIndex = [self.columns indexOfObject:viewController];
    NSInteger currentIndex = self.columns.count - 1;
    
    if (currentIndex - targetIndex == 0)
    {
        return;
    }
    else if (currentIndex - targetIndex > 1)
    {
        NSIndexSet * set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(targetIndex + 1, currentIndex - targetIndex - 1)];
        NSArray * toRemove = [self.columns objectsAtIndexes:set];
        // Any teardown ?
        [self.columns removeObjectsInArray:toRemove];
    }
    
    [self popViewControllerAnimated:animated];
}
- (void)pushViewController:(WTUIViewController *)newController afterViewController:(WTUIViewController *)afterController animated:(BOOL)animate{
    
}

- (void)setRootViewController:(WTUIViewController *)viewController animated:(BOOL)animated{
    [viewController setParentViewController:self];
    
    if ([self isViewLoaded])
    {
        WTUIViewController *oldViewController = [self.topViewController retain];
        [oldViewController setParentViewController:nil];
        
        [self.columns removeAllObjects];
        
        BOOL oldFashionAnimation = YES;
        
        
        const CGRect controllerFrame = [self _controllerFrame];
        const CGRect nextFrameStart = CGRectOffset(controllerFrame, -(controllerFrame.size.width + 112.0), 0);
        const CGRect nextFrameEnd = controllerFrame;
        
        CGFloat oldFrameOffsetX = oldFashionAnimation?controllerFrame.size.width/4:-controllerFrame.size.width/2;
        
        const CGRect oldFrameStart = controllerFrame;
        const CGRect oldFrameEnd = CGRectOffset(controllerFrame, oldFrameOffsetX, 0);
        
        [viewController setInitialBounds:[self _controllerFrame]];
        [viewController.view setAutoresizingMask:TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight];
        [self.view addSubview:viewController.view];
        
        [self.columns addObject:viewController];
        
        if (animated) {
            
            [CATransaction begin];
            viewController.view.frame = nextFrameStart;
            if (!oldFashionAnimation) oldViewController.view.frame = oldFrameStart;
            [CATransaction flush];
            [CATransaction commit];
            
            [viewController appendBoxShadow];
            [oldViewController appendBoxShadow];

            [oldViewController retain];
            [oldViewController viewWillDisappear:YES];
            
            NSTimeInterval oldViewDuration = kAnimationDuration * 1, oldViewDelay = kAnimationDuration * 0.25;
            NSTimeInterval newViewDuration = kAnimationDuration * 1, newViewDelay = 0;
            if (!oldFashionAnimation) {
                oldViewDuration = kAnimationDuration * 1.5, oldViewDelay = 0;
                newViewDuration = kAnimationDuration * 0.85, newViewDelay = kAnimationDuration * 0.25;
            }
            
            UIViewAnimationOptions oldViewAnimationOptions = UIViewAnimationOptionBeginFromCurrentState;
            TUIViewAnimationCurve oldViewAnimationCurve = TUIViewAnimationCurveEaseInOut;
            
            if ([self viewIsAnimating:oldViewController.view])
            {
                oldViewDelay = 0;
                oldViewAnimationCurve = TUIViewAnimationCurveEaseOut;
            }
            
            [viewController viewWillAppear:animated];
            
            if (oldViewController) {
                [TUIView animateWithDuration:oldViewDuration
                                       delay:oldViewDelay
                                       curve:oldViewAnimationCurve
                                     options:oldViewAnimationOptions
                                  animations:^(void) {
                                      oldViewController.view.frame = oldFrameEnd;
                                  }
                                  completion:^(BOOL finished) {
                                      [oldViewController.view removeFromSuperview];
                                      [oldViewController viewDidDisappear:YES];
                                      [oldViewController release];
                                  }];
            }
            
            if (viewController) {
                [TUIView animateWithDuration:newViewDuration
                                       delay:newViewDelay
                                       curve:TUIViewAnimationCurveEaseInOut
                                  animations:^(void) {
                                      viewController.view.frame = nextFrameEnd;
                                  }
                                  completion:^(BOOL finished) {
                                      [viewController viewDidAppear:YES];
                                      [self _updateFirstResponder:viewController];
                                  }];
            }
            
        } else {
            [viewController.view setFrame:nextFrameEnd];
            [viewController appendBoxShadow];
            [viewController viewWillAppear:animated];
            [self _updateFirstResponder:viewController];
            [viewController viewDidAppear:NO];
            [oldViewController viewWillDisappear:NO];
            [oldViewController.view removeFromSuperview];
            [oldViewController viewDidDisappear:NO];
        }
        [oldViewController release];
    }
    
    [self afterLayout];
}

- (BOOL)popToRootViewControllerAnimated:(BOOL)animate{
    if (self.columns.count > 1)
    {
        [self popToViewController:[self.columns objectAtIndex:0] animated:animate];
        return YES;
    }
    return NO;
}

- (void)afterLayout
{
    [self.view bringSubviewToFront:self.resizeKnob];
}

#pragma mark - Gesture Recognize

- (BOOL)gestureRecognizerShouldBegin:(WUIGestureRecognizer *)r
{
    if (_flags.animatingPush)
    {
        return NO;
    }
    return YES;
}

- (void)gestureRecognized:(WUIPanGestureRecognizer *)r withEvent:(NSEvent *)event
{
    WTUIViewController * currentViewController = self.topViewController;
    WTUIViewController * nextViewController = nil;
    if (self.viewControllers.count > 1)
    {
        nextViewController = self.viewControllers[self.viewControllers.count - 2];
    }

    if (r.state == WUIGestureRecognizerStateBegan)
    {
        if (nextViewController)
        {
            nextViewController.initialBounds = [self  _controllerFrame];
            [self.view insertSubview:nextViewController.view belowSubview:currentViewController.view];
            [nextViewController relayoutIfNeeded];
            
            [CATransaction begin];
            [nextViewController.view setFrame:[self _controllerFrame]];
            nextViewController.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight;
            
            [CATransaction flush];
            [CATransaction commit];

            [nextViewController viewWillAppear:YES];
        }
    }
    else if (r.state == WUIGestureRecognizerStateChanged)
    {
        CGFloat offset = MAX(0, r.offset.x) * 2.2;
        if (nextViewController)
        {
            currentViewController.view.left = offset;
        }
        else
        {
            currentViewController.view.left = sqrtf(offset);
        }
    }
    else if (r.state == WUIGestureRecognizerStateEnded ||
             r.state == WUIGestureRecognizerStateCancelled)
    {
        if (!nextViewController || currentViewController.view.left < 120 || r.lastDeltaOffset.x < 0)
        {
            [nextViewController viewWillDisappear:YES];
            
            void (^completion)(BOOL) = ^(BOOL finished){
                [nextViewController viewDidDisappear:YES];
                [nextViewController.view removeFromSuperview];
            };
            
            if (currentViewController.view.left == 0)
            {
                completion(YES);
            }
            else
            {
                [TUIView animateWithDuration:kAnimationDuration * 0.6 animations:^{
                    currentViewController.view.left = 0;
                } completion:completion];
            }

        }
        else
        {
            [currentViewController viewWillDisappear:YES];
            [currentViewController retain];
            [currentViewController setParentViewController:nil];
            [self.columns removeLastObject];
            
            [TUIView animateWithDuration:kAnimationDuration * 0.8 animations:^(void) {
                currentViewController.view.left = currentViewController.view.width + 112.0;
            } completion:^(BOOL finished) {
                [currentViewController viewDidDisappear:YES];
                [currentViewController.view removeFromSuperview];
                [currentViewController release];
                [nextViewController viewDidAppear:YES];
            }];
        }
    }
}

- (void)openCurrentViewControllerInSatelliteWindow:(id)sender
{
    WTUIViewController * viewController = self.topViewController;
    
    if (!viewController) return;
    
    WTUIViewController * newController = [[viewController copy] autorelease];
    
    TUINSWindow * currentWindow = self.view.nsWindow;
    NSInteger currentWindowLevel = currentWindow.level;
        
    WMSatelliteWindow * window = [[WMSatelliteWindow alloc] initWithViewController:newController oldFrameOnScreen:[viewController.view frameOnScreen]];
    window.level = currentWindowLevel;

    [window display];
    [window makeKeyAndOrderFront:nil];
    
    if (self.columns.count > 1)
    {
        [self popViewControllerAnimated:NO];
    }
}

- (void)runRootViewBounceAnimation
{    
    WTUIViewController * viewController = self.topViewController;
        
    [TUIView animateWithDuration:0.1 animations:^{
        viewController.view.left = 10;
    } completion:^(BOOL finished) {
        [TUIView animateWithDuration:0.1 animations:^{
            viewController.view.left = 0;
        }];
    }];
}

- (BOOL)performKeyAction:(NSEvent *)event
{
    switch([[event charactersIgnoringModifiers] characterAtIndex:0])
    {
		case NSLeftArrowFunctionKey:
        {
            if (self.columns.count > 1)
            {
                [self popViewControllerAnimated:YES];
                return YES;
            }
            else if (self.topViewController)
            {
                [self runRootViewBounceAnimation];
                return NO;
            }
        }
        default:break;
    }
    return [super performKeyAction:event];
}

#pragma mark - Notification Responding

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self.topViewController viewWillDisappear:NO];
}

- (void)displayPreferenceSetDidChange:(NSNotification *)notification
{
    for (WTUIViewController * c in self.columns)
    {
        if (![c isKindOfClass:[WTUIViewController class]])
        {
            continue;
        }
        
        [c setNeedsRelayout];
    }
    
    [self.topViewController relayoutIfNeeded];
}

@end
