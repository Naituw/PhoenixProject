#import "TUIView.h"

@interface TUIViewAnimation : NSObject <CAAction>
{
	void *context;
	NSString *animationID;

	id delegate;
	SEL animationWillStartSelector;
	SEL animationDidStopSelector;
	void (^animationCompletionBlock)(BOOL finished);
	
	CABasicAnimation *basicAnimation;
}

@property (nonatomic, assign) void *context;
@property (nonatomic, copy) NSString *animationID;

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL animationWillStartSelector;
@property (nonatomic, assign) SEL animationDidStopSelector;
@property (nonatomic, assign) BOOL animationBeginsFromCurrentState;
@property (nonatomic, copy) void (^animationCompletionBlock)(BOOL finished);

@property (nonatomic, readonly) CABasicAnimation *basicAnimation;


@end

@implementation TUIViewAnimation

@synthesize context;
@synthesize animationID;

@synthesize delegate;
@synthesize animationWillStartSelector;
@synthesize animationDidStopSelector;
@synthesize animationCompletionBlock;
@synthesize animationBeginsFromCurrentState = _animationBeginsFromCurrentState;

@synthesize basicAnimation;

//static int animcount = 0;

- (id)init
{
	if((self = [super init]))
	{
		basicAnimation = [[CABasicAnimation animation] retain];
//		NSLog(@"+anims %d", ++animcount);
	}
	return self;
}

- (void)dealloc
{
//	NSLog(@"-anims %d", --animcount);
	[animationID release];
	[basicAnimation release];
	if(animationCompletionBlock != nil) {
		animationCompletionBlock(NO);
		NSLog(@"Error: completion block didn't complete! %@", self);
	}
	[animationCompletionBlock release]; // should be nil at this point
	[super dealloc];
}

- (void)runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{
	CAAnimation *animation = [[basicAnimation copyWithZone:nil] autorelease];
	animation.delegate = self;
	[animation runActionForKey:event object:anObject arguments:dict];
}

//static int animstart = 0;

- (void)animationDidStart:(CAAnimation *)anim
{
//	NSLog(@"+animstart %d", ++animstart);
	if(delegate && animationWillStartSelector) {
		void (*animationWillStartIMP)(id,SEL,NSString*,void*) = (void(*)(id,SEL,NSString*,void*))[(NSObject *)delegate methodForSelector:animationWillStartSelector];
		animationWillStartIMP(delegate, animationWillStartSelector, animationID, context);
		animationWillStartSelector = NULL; // only fire this once
	}
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//	NSLog(@"-animstart %d", --animstart);
	if(delegate && animationDidStopSelector) {
		void (*animationDidStopIMP)(id,SEL,NSString*,NSNumber*,void*) = (void(*)(id,SEL,NSString*,NSNumber*,void*))[(NSObject *)delegate methodForSelector:animationDidStopSelector];
		animationDidStopIMP(delegate, animationDidStopSelector, animationID, [NSNumber numberWithBool:flag], context);
		animationDidStopSelector = NULL; // only fire this once
	} else if(animationCompletionBlock) {
		animationCompletionBlock(flag);
		self.animationCompletionBlock = nil; // only fire this once
	}
}

@end


@implementation TUIView (TUIViewAnimation)

static NSMutableArray *AnimationStack = nil;

+ (NSMutableArray *)_animationStack
{
	if(!AnimationStack)
		AnimationStack = [[NSMutableArray alloc] init];
	return AnimationStack;
}

+ (TUIViewAnimation *)_currentAnimation
{
	return [AnimationStack lastObject];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations
{
	[self animateWithDuration:duration animations:animations completion:NULL];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
	[self beginAnimations:nil context:NULL];
	[self setAnimationDuration:duration];
    [self setAnimationCurve:TUIViewAnimationCurveEaseInOut];
	[[self _currentAnimation] setAnimationCompletionBlock:completion];
	animations();
	[self commitAnimations];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay curve:(TUIViewAnimationCurve)animationCurve  animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [self animateWithDuration:duration delay:delay curve:animationCurve options:0 animations:animations completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay curve:(TUIViewAnimationCurve)animationCurve options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    const BOOL repeatAnimation = (options & UIViewAnimationOptionRepeat);
    const BOOL autoreverseRepeat = (options & UIViewAnimationOptionAutoreverse);
    const BOOL beginFromCurrentState = (options & UIViewAnimationOptionBeginFromCurrentState);
    
    [TUIView beginAnimations:nil context:NULL];
    [TUIView setAnimationCurve:animationCurve];
    [TUIView setAnimationDelay:delay];
    [TUIView setAnimationDuration:duration];
    [TUIView setAnimationBeginsFromCurrentState:beginFromCurrentState];
    [[self _currentAnimation] setAnimationCompletionBlock:completion];
    [TUIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    [TUIView setAnimationRepeatCount:(repeatAnimation? FLT_MAX : 0)];
    [TUIView setAnimationRepeatAutoreverses:autoreverseRepeat];
    
    animations();
    
    [TUIView commitAnimations];
}




+ (void)beginAnimations:(NSString *)animationID context:(void *)context
{
	TUIViewAnimation *animation = [[TUIViewAnimation alloc] init];
	animation.context = context;
	animation.animationID = animationID;
	[[self _animationStack] addObject:animation];
	[animation release];
	
	// setup defaults
	[self setAnimationDuration:0.25];
	[self setAnimationCurve:TUIViewAnimationCurveEaseInOut];
	
//	NSLog(@"+++ %d", [[self _animationStack] count]);
}

+ (void)commitAnimations
{
	[[self _animationStack] removeLastObject];
	
//	NSLog(@"--- %d", [[self _animationStack] count]);
}

+ (void)setAnimationDelegate:(id)delegate
{
	[self _currentAnimation].delegate = delegate;
}

+ (void)setAnimationWillStartSelector:(SEL)selector                // default = NULL. -animationWillStart:(NSString *)animationID context:(void *)context
{
	[self _currentAnimation].animationWillStartSelector = selector;
}

+ (void)setAnimationDidStopSelector:(SEL)selector                  // default = NULL. -animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self _currentAnimation].animationDidStopSelector = selector;
}

static CGFloat SlomoTime()
{
	if((NSUInteger)([NSEvent modifierFlags]&NSDeviceIndependentModifierFlagsMask) == (NSUInteger)(NSShiftKeyMask))
		return 5.0;
	return 1.0;
}

+ (void)setAnimationDuration:(NSTimeInterval)duration
{
	[self _currentAnimation].basicAnimation.duration = duration * SlomoTime();
}

+ (void)setAnimationDelay:(NSTimeInterval)delay                    // default = 0.0
{
	[self _currentAnimation].basicAnimation.beginTime = CACurrentMediaTime() + delay * SlomoTime();
	[self _currentAnimation].basicAnimation.fillMode = kCAFillModeBoth;
}

+ (void)setAnimationStartDate:(NSDate *)startDate                  // default = now ([NSDate date])
{
	NSLog(@"%@ %@ unimplemented", self, NSStringFromSelector(_cmd));
	//[self _currentAnimation].basicAnimation.beginTime = startDate;
}

+ (void)setAnimationCurve:(TUIViewAnimationCurve)curve              // default = UIViewAnimationCurveEaseInOut
{
	NSString *functionName = kCAMediaTimingFunctionEaseInEaseOut;
	switch(curve) {
		case TUIViewAnimationCurveLinear:
			functionName = kCAMediaTimingFunctionLinear;
			break;
		case TUIViewAnimationCurveEaseIn:
			functionName = kCAMediaTimingFunctionEaseIn;
			break;
		case TUIViewAnimationCurveEaseOut:
			functionName = kCAMediaTimingFunctionEaseOut;
			break;
		case TUIViewAnimationCurveEaseInOut:
			functionName = kCAMediaTimingFunctionEaseInEaseOut;
			break;
	}
	[self _currentAnimation].basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:functionName];
}

+ (void)setAnimationRepeatCount:(float)repeatCount                 // default = 0.0.  May be fractional
{
	[self _currentAnimation].basicAnimation.repeatCount = repeatCount;
}

+ (void)setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses    // default = NO. used if repeat count is non-zero
{
	[self _currentAnimation].basicAnimation.autoreverses = repeatAutoreverses;
}

+ (void)setAnimationIsAdditive:(BOOL)additive
{
	[self _currentAnimation].basicAnimation.additive = additive;
}

+ (void)setAnimationBeginsFromCurrentState:(BOOL)fromCurrentState  // default = NO. If YES, the current view position is always used for new animations -- allowing animations to "pile up" on each other. Otherwise, the last end state is used for the animation (the default).
{
    [[self _currentAnimation] setAnimationBeginsFromCurrentState:fromCurrentState];
	//NSLog(@"%@ %@ unimplemented", self, NSStringFromSelector(_cmd));
}

+ (void)setAnimationTransition:(TUIViewAnimationTransition)transition forView:(TUIView *)view cache:(BOOL)cache  // current limitation - only one per begin/commit block
{
	NSLog(@"%@ %@ unimplemented", self, NSStringFromSelector(_cmd));
}

static BOOL disableAnimations = NO;

+ (void)setAnimationsEnabled:(BOOL)enabled block:(void(^)(void))block
{
	BOOL save = disableAnimations;
	disableAnimations = !enabled;
	block();
	disableAnimations = save;
}

+ (void)setAnimationsEnabled:(BOOL)enabled                         // ignore any attribute changes while set.
{
	disableAnimations = !enabled;
}

+ (BOOL)areAnimationsEnabled
{
	return !disableAnimations;
}

static BOOL animateContents = NO;

+ (void)setAnimateContents:(BOOL)enabled
{
	animateContents = enabled;
}

+ (BOOL)willAnimateContents
{
	return animateContents;
}

- (void)removeAllAnimations
{
	[self.layer removeAllAnimations];
	[self.subviews makeObjectsPerformSelector:@selector(removeAllAnimations)];
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	if(disableAnimations == NO) {
		if((animateContents == NO) && [event isEqualToString:@"contents"])
			return (id<CAAction>)[NSNull null]; // default - don't animate contents
		
		TUIViewAnimation * animation = [TUIView _currentAnimation];
		if(animation){
            //animation.basicAnimation.fromValue =  animation.animationBeginsFromCurrentState? [layer.presentationLayer valueForKey:event] : [layer valueForKey:event];
            return animation;
        }
	}
	
	return (id<CAAction>)[NSNull null];
}

@end
