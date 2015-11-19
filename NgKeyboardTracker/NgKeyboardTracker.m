//
//  NgKeyboardTracker.m
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 29/6/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#import "NgKeyboardTracker.h"
#import "NgPseudoInputAccessoryViewCoordinatorPrivates.h"

static inline UIViewAnimationOptions NgAnimationOptionsWithCurve(UIViewAnimationCurve curve)
{
  switch (curve) {
    case UIViewAnimationCurveEaseInOut:
      return UIViewAnimationOptionCurveEaseInOut;
    case UIViewAnimationCurveEaseIn:
      return UIViewAnimationOptionCurveEaseIn;
    case UIViewAnimationCurveEaseOut:
      return UIViewAnimationOptionCurveEaseOut;
    case UIViewAnimationCurveLinear:
      return UIViewAnimationOptionCurveLinear;
  }
  return 0;
}

NSString * NgAppearanceStateAsString(NgKeyboardTrackerKeyboardAppearanceState state) {
  if (state == NgKeyboardTrackerKeyboardAppearanceStateUndefined) return @"undefined";
  if (state == NgKeyboardTrackerKeyboardAppearanceStateWillShow) return @"will show";
  if (state == NgKeyboardTrackerKeyboardAppearanceStateShown) return @"shown";
  if (state == NgKeyboardTrackerKeyboardAppearanceStateWillHide) return @"will hide";
  if (state == NgKeyboardTrackerKeyboardAppearanceStateHidden) return @"hidden";
  return @"???";
}

#pragma mark -
@interface NgKeyboardTrackerDelegateWrapper : NSObject {
  struct {
    int didChangeAppearanceState, didUpdate;
  } _delegateFlags;
}
@property (nonatomic, weak) NgKeyboardTracker * weakTracker;
@property (nonatomic, weak) id<NgKeyboardTrackerDelegate> weakDelegate;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithKeyboardTracker:(NgKeyboardTracker *)tracker delegate:(id<NgKeyboardTrackerDelegate>)delegate;
- (BOOL)isValid;
- (void)didChangeAppearanceState;
- (void)didUpdate;
@end

@implementation NgKeyboardTrackerDelegateWrapper
- (instancetype)initWithKeyboardTracker:(NgKeyboardTracker *)tracker delegate:(id<NgKeyboardTrackerDelegate>)delegate {
  self = [super init];
  if (self) {
    [self setKeyboardTracker:tracker];
    [self setDelegate:delegate];
  }
  return self;
}
- (void)setDelegate:(id<NgKeyboardTrackerDelegate>)delegate {
  NSParameterAssert(delegate);
  _weakDelegate = delegate;
  id strongDelegate = delegate;
  _delegateFlags.didChangeAppearanceState = [strongDelegate respondsToSelector:@selector(keyboardTrackerDidChangeAppearanceState:)];
  _delegateFlags.didUpdate = [strongDelegate respondsToSelector:@selector(keyboardTrackerDidUpdate:)];
}
- (void)setKeyboardTracker:(NgKeyboardTracker *)tracker {
  NSParameterAssert(tracker);
  _weakTracker = tracker;
}
- (BOOL)performSafely:(void(^)(NgKeyboardTracker *, id<NgKeyboardTrackerDelegate>))block {
  
  __strong NgKeyboardTracker * strongTracker = _weakTracker;
  __strong id<NgKeyboardTrackerDelegate> strongDelegate = _weakDelegate;
  if (!strongTracker || !strongDelegate) return NO;
  
  block(strongTracker, strongDelegate);
  return YES;
}
- (BOOL)isValid {
  __strong NgKeyboardTracker * strongTracker = _weakTracker;
  __strong id<NgKeyboardTrackerDelegate> strongDelegate = _weakDelegate;
  if (!strongTracker || !strongDelegate) return NO;
  return YES;
}
- (void)didChangeAppearanceState {
  if (!_delegateFlags.didChangeAppearanceState) return;
  [self performSafely:^(NgKeyboardTracker * tracker, id<NgKeyboardTrackerDelegate> delegate) {
    [delegate keyboardTrackerDidChangeAppearanceState:tracker];
  }];
}
- (void)didUpdate {
  if (!_delegateFlags.didUpdate) return;
  [self performSafely:^(NgKeyboardTracker * tracker, id<NgKeyboardTrackerDelegate> delegate) {
    [delegate keyboardTrackerDidUpdate:tracker];
  }];
}
@end

#pragma mark -
@interface NgKeyboardTracker () <NgPseudoInputAccessoryViewCoordinatorDelegate> {
  
  BOOL _tracking;
  NSMutableArray * _delegates;
  NSRecursiveLock * _lock;
  CGFloat _inputAccessoryViewHeight;
}
@end

@implementation NgKeyboardTracker

+ (instancetype)sharedTracker {
  
  static NgKeyboardTracker * _tracker;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _tracker = [[NgKeyboardTracker alloc] init];
  });
  return _tracker;
}
- (instancetype)init {
  self = [super init];
  if (self) {
    _delegates = [NSMutableArray array];
    _lock = [[NSRecursiveLock alloc] init];
    [self getInitialKeyboardInfo];
  }
  return self;
}
- (NSString *)description {
  return [NSString stringWithFormat:@"<NgKeyboardTracker: %p>\n- appearanceState: %@\n- animation duration: %f\n- begin frame: %@\n- end frame: %@\n- current frame: %@"
          , self
          , NgAppearanceStateAsString(self.appearanceState)
          , self.animationDuration
          , NSStringFromCGRect(self.beginFrame)
          , NSStringFromCGRect(self.endFrame)
          , NSStringFromCGRect(self.currentFrame)];
}
- (void)dealloc {
  [self stop];
}
- (UIView *)getKeyboardView {
  
  NSArray * windows = [UIApplication sharedApplication].windows;
  if (windows.count <= 1) return nil;
  
  UIWindow * tmpwindow = windows[1];
  UIView * keyboard = nil;
  for (UIView * subview in tmpwindow.subviews) {
    
    if ([[subview description] containsString:@"<UIPeripheralHost"]) {
      keyboard = subview;
      break;
    } else if ([[subview description] containsString:@"<UIInputSetContainerView"]) {
      for (UIView * ssubview in subview.subviews) {
        if ([[ssubview description] containsString:@"<UIInputSetHost"]) {
          keyboard = ssubview;
          break;
        }
      }
      break;
    }
  }
  return keyboard;
}
- (void)getInitialKeyboardInfo {
  
  UIView * keyboardView = [self getKeyboardView];
  if (keyboardView) {
    _appearanceState = NgKeyboardTrackerKeyboardAppearanceStateShown;
    _beginFrame = [keyboardView convertRect:keyboardView.bounds toView:nil];
    _endFrame = _beginFrame;
    [self setAnimationCurve:0];
    _animationDuration = 0;
  } else {
    _appearanceState = NgKeyboardTrackerKeyboardAppearanceStateHidden;
    _beginFrame = CGRectZero;
    _endFrame = CGRectZero;
    [self setAnimationCurve:0];
    _animationDuration = 0;
  }
  
  for (NgKeyboardTrackerDelegateWrapper * wrapper in [_delegates copy]) {
    [wrapper didUpdate];
  }
}
- (void)assertTracking {
  NSAssert(_tracking, @"Invalid state: it's not currently tracking keyboard.");
}
- (void)start {
  
  if (_tracking) return;
  _tracking = YES;
  
  [self getInitialKeyboardInfo];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(onKeyboardWillShow:)
   name:UIKeyboardWillShowNotification object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(onKeyboardWillHide:)
   name:UIKeyboardWillHideNotification object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(onKeyboardDidShow:)
   name:UIKeyboardDidShowNotification object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(onKeyboardDidHide:)
   name:UIKeyboardDidHideNotification object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(onKeyboardWillChangeFrame:)
   name:UIKeyboardWillChangeFrameNotification object:nil];

  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(onKeyboardDidChangeFrame:)
   name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)stop {
  
  if (!_tracking) return;
  _tracking = NO;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NgPseudoInputAccessoryViewCoordinator *)createPseudoInputAccessoryViewCoordinator {
  
  NgPseudoInputAccessoryViewCoordinator * coordinator =
  [[NgPseudoInputAccessoryViewCoordinator alloc] _init];
  coordinator.delegate = self;
  
  return coordinator;
}

#pragma mark Internal
- (void)updateAppearanceState:(NgKeyboardTrackerKeyboardAppearanceState)newState {
  _appearanceState = newState;
  [_lock lock];
  for (NgKeyboardTrackerDelegateWrapper * wrapper in [_delegates copy]) {
    [wrapper didChangeAppearanceState];
  }
  [_lock unlock];
}
- (BOOL)isKeyboardVisible {
  if (self.appearanceState == NgKeyboardTrackerKeyboardAppearanceStateHidden) return NO;
  CGRect intersection = CGRectIntersection([UIScreen mainScreen].bounds, _currentFrame);
  return intersection.size.height - _inputAccessoryViewHeight > 0;
}

#pragma mark Events
- (void)notifyAllDelegates {
  
  [_lock lock];
  for (NgKeyboardTrackerDelegateWrapper * wrapper in [_delegates copy]) {
    [wrapper didUpdate];
  }
  [_lock unlock];
}
- (void)setAnimationCurve:(UIViewAnimationCurve)animationCurve {
  _animationCurve = animationCurve;
  _animationOptions = NgAnimationOptionsWithCurve(animationCurve);
}
- (void)captureInfo:(NSDictionary *)info {
  _beginFrame = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
  _endFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  _currentFrame = _endFrame;
  _animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [self setAnimationCurve:(UIViewAnimationCurve)[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
}
- (void)onKeyboardWillShow:(NSNotification *)note {
  [self updateAppearanceState:NgKeyboardTrackerKeyboardAppearanceStateWillShow];
}
- (void)onKeyboardDidShow:(NSNotification *)note {
  [self updateAppearanceState:NgKeyboardTrackerKeyboardAppearanceStateShown];
}
- (void)onKeyboardWillHide:(NSNotification *)note {
  [self updateAppearanceState:NgKeyboardTrackerKeyboardAppearanceStateWillHide];
}
- (void)onKeyboardDidHide:(NSNotification *)note {
  [self updateAppearanceState:NgKeyboardTrackerKeyboardAppearanceStateHidden];
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)note {
  [self captureInfo:note.userInfo];
  [self notifyAllDelegates];
}
- (void)onKeyboardDidChangeFrame:(NSNotification *)note {
  [self captureInfo:note.userInfo];
  [self notifyAllDelegates];
}

#pragma mark Delegates
- (void)addDelegate:(id<NgKeyboardTrackerDelegate>)delegate {
  [_lock lock];
  [_delegates addObject:[[NgKeyboardTrackerDelegateWrapper alloc] initWithKeyboardTracker:self delegate:delegate]];
  [_lock unlock];
}
- (void)removeDelegate:(id<NgKeyboardTrackerDelegate>)delegate {
  [_lock lock];
  NSMutableArray * matchingDelegates = [NSMutableArray array];
  for (NgKeyboardTrackerDelegateWrapper * wrapper in _delegates) {
    if (wrapper.weakDelegate == delegate) [matchingDelegates addObject:wrapper];
  }
  if (matchingDelegates.count > 0) [_delegates removeObjectsInArray:matchingDelegates];
  [_lock unlock];
}
- (void)removeInvalidDelegates {
  [_lock lock];
  NSMutableArray * invalidDelegates = [NSMutableArray array];
  for (NgKeyboardTrackerDelegateWrapper * wrapper in _delegates) {
    if (![wrapper isValid]) [invalidDelegates addObject:wrapper];
  }
  if (invalidDelegates.count > 0) [_delegates removeObjectsInArray:invalidDelegates];
  [_lock unlock];
}

#pragma mark UIView
- (CGRect)rectFromFrame:(CGRect)frame forView:(UIView *)view {
  NSParameterAssert(view);
  if (CGRectEqualToRect(CGRectZero, frame))
    return CGRectZero;
  return [view convertRect:frame fromView:nil];
}
- (CGRect)keyboardCurrentFrameForView:(UIView *)view {

  return [self rectFromFrame:_currentFrame forView:view];
}

#pragma mark NgPseudoInputAccessoryViewCoordinatorDelegate
- (void)pseudoInputAccessoryViewCoordinator:(NgPseudoInputAccessoryViewCoordinator *)coordinator
                     keyboardFrameDidChange:(CGRect)frame {
  
  if (!_tracking) return;
  _currentFrame = frame;
  _animationDuration = 0;
  [self notifyAllDelegates];
}
- (void)pseudoInputAccessoryViewCoordinator:(NgPseudoInputAccessoryViewCoordinator *)coordinator
                               didSetHeight:(CGFloat)height {
  _inputAccessoryViewHeight = height;
}
@end
