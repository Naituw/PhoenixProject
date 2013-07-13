//
//  WTUINavigationController.m
//  WeiboForMac
//
//  Created by Tian Wu on 11-9-6.
//  Copyright 2011年 NFSYSU. All rights reserved.
//

#import "WTUINavigationController.h"
#import "WTUIViewController+UIPrivate.h"
//#import "WTUITabBarController.h"
#import "WTUINavigationBar.h"
#import "WTUIToolbar.h"
#import "UIBezierPath.h"

static const NSTimeInterval kAnimationDuration = 0.3;
static const CGFloat NavBarHeight = 28;
static const CGFloat ToolbarHeight = 28;

@implementation WTUINavigationController
@synthesize viewControllers=_viewControllers, delegate=_delegate, navigationBar=_navigationBar;
@synthesize toolbar=_toolbar, toolbarHidden=_toolbarHidden, navigationBarHidden=_navigationBarHidden;

- (WTUIViewController *)visibleViewController
{
	return [self.viewControllers lastObject];
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if ((self=[super initWithNibName:nibName bundle:bundle])) {
        _viewControllers = [[NSMutableArray alloc] initWithCapacity:1];
        _navigationBar = [[WTUINavigationBar alloc] init];
        _navigationBar.delegate = self;
        _toolbar = [[WTUIToolbar alloc] init];
        _toolbarHidden = YES;
    }
    return self;
}

- (id)initWithRootViewController:(WTUIViewController *)rootViewController
{
    if ((self=[self initWithNibName:nil bundle:nil])) {
        self.viewControllers = [NSArray arrayWithObject:rootViewController];
        [rootViewController.view becomeFirstResponder];
    }
    return self;
}

- (void)dealloc
{
    [_viewControllers release];
    [_navigationBar release];
    [_toolbar release];
    [super dealloc];
}

- (void)setDelegate:(id<WTUINavigationControllerDelegate>)newDelegate
{
    _delegate = newDelegate;
    _delegateHas.didShowViewController = [_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)];
    _delegateHas.willShowViewController = [_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)];
}

- (CGRect)_navigationBarFrame
{
    CGRect navBarFrame = CGRectZero;
    
    return navBarFrame;
}

- (CGRect)_toolbarFrame
{
    /*
    CGRect toolbarRect = self.view.bounds;
    toolbarRect.origin.y = toolbarRect.origin.y + toolbarRect.size.height - ToolbarHeight;
    toolbarRect.size.height = ToolbarHeight;
     */
    CGRect toolbarRect = CGRectZero;
    return toolbarRect;
}

- (CGRect)_controllerFrame
{
    CGRect controllerFrame = self.view.bounds;
    
    /*
    // adjust for the nav bar
    if (!self.navigationBarHidden) {
        controllerFrame.origin.y += NavBarHeight;
        controllerFrame.size.height -= NavBarHeight;
    }
    
    // adjust for toolbar (if there is one)
    if (!self.toolbarHidden) {
        controllerFrame.size.height -= ToolbarHeight;
    }
     */

    return controllerFrame;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [TUIColor colorWithWhite:0.92 alpha:1.0];
    self.view.clipsToBounds = YES;
    
    WTUIViewController *topViewController = self.topViewController;
    topViewController.view.frame = [self _controllerFrame];
    topViewController.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight;
    [self.view addSubview:topViewController.view];
    [topViewController viewDidAppear:NO];
    
    _navigationBar.frame = [self _navigationBarFrame];
    _navigationBar.autoresizingMask = TUIViewAutoresizingFlexibleWidth;
    //_navigationBar.hidden = self.navigationBarHidden;
    //[self.view addSubview:_navigationBar];

    _toolbar.frame = [self _toolbarFrame];
    _toolbar.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleTopMargin;
    _toolbar.hidden = self.toolbarHidden;
    [self.view addSubview:_toolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.topViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.topViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.topViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.topViewController viewDidDisappear:animated];
}

- (void)_updateToolbar:(BOOL)animated
{
    WTUIViewController *topController = self.topViewController;
    [_toolbar setItems:topController.toolbarItems animated:animated];
    _toolbar.hidden = self.toolbarHidden;
    topController.view.frame = [self _controllerFrame];
}

- (void)setViewControllers:(NSArray *)newViewControllers animated:(BOOL)animated
{
    assert([newViewControllers count] >= 1);
    if (newViewControllers != _viewControllers) {
        WTUIViewController *previousTopController = self.topViewController;
        
        if (previousTopController) {
            [previousTopController.view removeFromSuperview];
        }
        
        for (WTUIViewController *controller in _viewControllers) {
            [controller setParentViewController:nil];
        }
        
        [_viewControllers release];
        _viewControllers = [newViewControllers mutableCopy];
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:[_viewControllers count]];
        
        for (WTUIViewController *controller in _viewControllers) {
            [controller setParentViewController:self];
            [items addObject:controller.navigationItem];
        }
        
        if ([self isViewLoaded]) {
            WTUIViewController *newTopController = self.topViewController;
            newTopController.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight;
            
            [newTopController viewWillAppear:animated];
            if (_delegateHas.willShowViewController) {
                [_delegate navigationController:self willShowViewController:newTopController animated:animated];
            }
            
            newTopController.view.frame = [self _controllerFrame];
            [self.view insertSubview:newTopController.view atIndex:0];
            
            [newTopController viewDidAppear:animated];
            if (_delegateHas.didShowViewController) {
                [_delegate navigationController:self didShowViewController:newTopController animated:animated];
            }
        }
        
        [_navigationBar setItems:items animated:animated];
        [self _updateToolbar:animated];
    }
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
    [self setViewControllers:newViewControllers animated:NO];
}

- (WTUIViewController *)topViewController
{
    return [_viewControllers lastObject];
}

- (void)pushViewController:(WTUIViewController *)viewController animated:(BOOL)animated
{
    //assert(![viewController isKindOfClass:[UITabBarController class]]);
    assert(![_viewControllers containsObject:viewController]);
    [viewController _setParentViewController:self];
    
    if ([self isViewLoaded]) {
        WTUIViewController *oldViewController = self.topViewController;
        
        const CGRect controllerFrame = [self _controllerFrame];
        const CGRect nextFrameStart = CGRectOffset(controllerFrame, controllerFrame.size.width + 60.0, 0);
        const CGRect nextFrameEnd = controllerFrame;
        const CGRect oldFrameStart = controllerFrame;
        const CGRect oldFrameEnd = CGRectOffset(controllerFrame, - 40, 0);
        //CGRectOffset(controllerFrame, -controllerFrame.size.width, 0);
        
        viewController.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight;
        [self.view addSubview:viewController.view];
        //[self.view insertSubview:viewController.view atIndex:0];
        
        [viewController viewWillAppear:animated];
        if (_delegateHas.willShowViewController) {
            [_delegate navigationController:self willShowViewController:viewController animated:animated];
        }
        
        if (animated) {
            [CATransaction begin];
            viewController.view.frame = nextFrameStart;
            [self addShadowToViewController:viewController];
            oldViewController.view.frame = oldFrameStart;
            [CATransaction flush];
            [CATransaction commit];
            
            [oldViewController retain];
            [oldViewController viewWillDisappear:YES];
            [TUIView animateWithDuration:kAnimationDuration
                             animations:^(void) {
                                 viewController.view.frame = nextFrameEnd;
                                 oldViewController.view.frame = oldFrameEnd;
                             }
                             completion:^(BOOL finished) {
                                 [viewController viewDidAppear:animated];
                                 [oldViewController.view removeFromSuperview];
                                 [oldViewController release];
                             }];
        } else {
            viewController.view.frame = nextFrameEnd;
            [viewController viewDidAppear:animated];
            [oldViewController viewWillDisappear:NO];
            [oldViewController.view removeFromSuperview];
        }
        if (_delegateHas.didShowViewController) {
            [_delegate navigationController:self didShowViewController:viewController animated:animated];
        }
    }
    
    [_viewControllers addObject:viewController];
    [_navigationBar pushNavigationItem:viewController.navigationItem animated:animated];
    [self _updateToolbar:animated];
}

- (WTUIViewController *)_popViewControllerWithoutPoppingNavigationBarAnimated:(BOOL)animated
{
    if ([_viewControllers count] > 1) {
        WTUIViewController *oldViewController = [self.topViewController retain];
        
        [_viewControllers removeLastObject];
        [oldViewController setParentViewController:nil];
        if ([self isViewLoaded]) {
            WTUIViewController *nextViewController = self.topViewController;
            
            const CGRect controllerFrame = [self _controllerFrame];
            const CGRect nextFrameStart = CGRectOffset(controllerFrame, -40, 0);;
            //CGRectOffset(controllerFrame, -controllerFrame.size.width, 0);
            const CGRect nextFrameEnd = controllerFrame;
            const CGRect oldFrameStart = controllerFrame;
            const CGRect oldFrameEnd = CGRectOffset(controllerFrame, controllerFrame.size.width + 60.0, 0);
            
            nextViewController.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:nextViewController.view atIndex:0];
            
            [nextViewController viewWillAppear:animated];
            if (_delegateHas.willShowViewController) {
                [_delegate navigationController:self willShowViewController:nextViewController animated:animated];
            }
            
            if (animated) {
                [CATransaction begin];
                nextViewController.view.frame = nextFrameStart;
                oldViewController.view.frame = oldFrameStart;
                [CATransaction flush];
                [CATransaction commit];
                
                [oldViewController retain];
                [oldViewController viewWillDisappear:YES];
                [TUIView animateWithDuration:kAnimationDuration
                                 animations:^(void) {
                                     nextViewController.view.frame = nextFrameEnd;
                                     oldViewController.view.frame = oldFrameEnd;
                                 }
                                 completion:^(BOOL finished) {
                                     [oldViewController.view removeFromSuperview];
                                     [oldViewController release];
                                     
                                 }];
            } else {
                nextViewController.view.frame = nextFrameEnd;
                [oldViewController viewWillDisappear:NO];
                [oldViewController.view removeFromSuperview];
            }
            
            [nextViewController viewDidAppear:animated];
            if (_delegateHas.didShowViewController) {
                [_delegate navigationController:self didShowViewController:nextViewController animated:animated];
            }
        }
        
        [self _updateToolbar:animated];
        return [oldViewController autorelease];
    } else {
        return nil;
    }
}

- (WTUIViewController *)popViewControllerAnimated:(BOOL)animate
{
    WTUIViewController *controller = [self _popViewControllerWithoutPoppingNavigationBarAnimated:animate];
    if (controller) {
        [_navigationBar popNavigationItemAnimated:animate];
    }
    return controller;
}

- (NSArray *)popToViewController:(WTUIViewController *)viewController animated:(BOOL)animated
{
    NSMutableArray *popped = [[NSMutableArray alloc] init];
    
    while (self.topViewController != viewController) {
        WTUIViewController *poppedController = [self popViewControllerAnimated:animated];
        if (poppedController) {
            [popped addObject:poppedController];
        } else {
            break;
        }
    }
    
    return [popped autorelease];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:[_viewControllers objectAtIndex:0] animated:animated];
}

- (void)addShadowToViewController:(WTUIViewController *)viewController{
    if (AtLeastLion) {
        [viewController.view.layer setMasksToBounds:NO];
        [viewController.view.layer setShadowColor:[[TUIColor colorWithWhite:0 alpha:1.0f] CGColor]];
        [viewController.view.layer setShadowOpacity:0.7];
        [viewController.view.layer setShadowRadius:50];
        [viewController.view.layer setShadowPath:[UIBezierPath bezierPathWithRect:viewController.view.bounds].CGPath];
        [viewController.view.layer setShouldRasterize:YES];
    }
}

- (void)removeShadowFromViewController:(WTUIViewController *)viewController{
    if (AtLeastLion) {
        [viewController.view.layer setMasksToBounds:YES];
        [viewController.view.layer setShadowColor:nil];
        [viewController.view.layer setShadowOpacity:1.0];
        [viewController.view.layer setShadowRadius:0];
        [viewController.view.layer setShouldRasterize:NO];
    }
}

- (void)setRootViewController:(WTUIViewController *)viewController animated:(BOOL)animated{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    /*
    if ([_viewControllers count] > 1) {
        [self popToRootViewControllerAnimated:NO];
    }*/
    
    [viewController _setParentViewController:self];
    
    if ([self isViewLoaded] && _viewControllers.count > 0) {
        WTUIViewController *oldViewController = [self.topViewController retain];//2
        while (_viewControllers.count > 0) {
            [_viewControllers removeLastObject];
        }
        [oldViewController setParentViewController:nil];
        
        const CGRect controllerFrame = [self _controllerFrame];
        const CGRect nextFrameStart = CGRectOffset(controllerFrame, -(controllerFrame.size.width + 50.0), 0);
        const CGRect nextFrameEnd = controllerFrame;
        const CGRect oldFrameStart = controllerFrame;
        const CGRect oldFrameEnd = CGRectOffset(controllerFrame, -controllerFrame.size.width/2, 0);
        
        viewController.view.autoresizingMask = TUIViewAutoresizingFlexibleWidth | TUIViewAutoresizingFlexibleHeight;
        [self.view addSubview:viewController.view];
        
        [viewController viewWillAppear:animated];
        if (_delegateHas.willShowViewController) {
            [_delegate navigationController:self willShowViewController:viewController animated:animated];
        }
        
        //1
        if (animated) {
            
            [CATransaction begin];
            viewController.view.frame = nextFrameStart;
            [self addShadowToViewController:viewController];
            oldViewController.view.frame = oldFrameStart;
            [self addShadowToViewController:oldViewController];
            [CATransaction flush];
            [CATransaction commit];
            
            [oldViewController retain];
            [oldViewController viewWillDisappear:YES];
            
            [TUIView animateWithDuration:kAnimationDuration * 1.5
                                   delay:0
                                 curve:TUIViewAnimationCurveEaseInOut
                              animations:^(void) {
                                  oldViewController.view.frame = oldFrameEnd;
                              }
                              completion:^(BOOL finished) {
                                  [oldViewController.view removeFromSuperview];
                                  [self removeShadowFromViewController:oldViewController];
                                  [oldViewController release];
                              }];
            [TUIView animateWithDuration:kAnimationDuration * 0.85
                                   delay:kAnimationDuration * 0.25
                                   curve:TUIViewAnimationCurveEaseInOut
                              animations:^(void) {
                                  viewController.view.frame = nextFrameEnd;
                              }
                              completion:^(BOOL finished) {
                                  [viewController viewDidAppear:YES];
                                  [viewController.view makeFirstResponder];
                                  [self removeShadowFromViewController:viewController];
                              }];
        } else {
            viewController.view.frame = nextFrameEnd;
            [viewController.view makeFirstResponder];
            [viewController viewDidAppear:NO];
            [oldViewController viewWillDisappear:NO];
            [oldViewController.view removeFromSuperview];
        }
        
        //[viewController viewDidAppear:animated];
        [oldViewController release];
        if (_delegateHas.didShowViewController) {
            [_delegate navigationController:self didShowViewController:viewController animated:animated];
        }
    }
    
    [_viewControllers addObject:viewController];
    //NSLog(@"controllers count:%ld",[_viewControllers count]);
    [_navigationBar setItemWithFade:viewController.navigationItem];
    //[self _updateToolbar:animated];
    [pool drain];
}

- (BOOL)navigationBar:(WTUINavigationBar *)navigationBar shouldPopItem:(WTUINavigationItem *)item
{
    //[self _popViewControllerWithoutPoppingNavigationBarAnimated:YES];
    return YES;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    _toolbarHidden = hidden;
    [self _updateToolbar:animated];
}

- (void)setToolbarHidden:(BOOL)hidden
{
    [self setToolbarHidden:hidden animated:NO];
}

- (BOOL)isToolbarHidden
{
    return _toolbarHidden ;//|| self.topViewController.hidesBottomBarWhenPushed;
}

- (void)setContentSizeForViewInPopover:(CGSize)newSize
{
    self.topViewController.contentSizeForViewInPopover = newSize;
}

- (CGSize)contentSizeForViewInPopover
{
    return self.topViewController.contentSizeForViewInPopover;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated; // doesn't yet animate
{
    _navigationBarHidden = navigationBarHidden;
    
    // this shouldn't just hide it, but should animate it out of view (if animated==YES) and then adjust the layout
    // so the main view fills the whole space, etc.
    _navigationBar.hidden = navigationBarHidden;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

@end
