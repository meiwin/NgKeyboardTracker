//
//  NgPseudoInputAccessoryViewCoordinator.m
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 3/7/15.
//  Copyright (c) 2015 BlockThirty. All rights reserved.
//

#import "NgPseudoInputAccessoryViewCoordinator.h"
#import "NgPseudoInputAccessoryViewCoordinatorPrivates.h"

#pragma mark -
@class NgPseudoInputAccessoryView;
@protocol NgPseudoInputAccessoryViewDelegate
@optional
- (void)pseudoInputAccessoryView:(NgPseudoInputAccessoryView *)v
          keyboardFrameDidChange:(CGRect)frame;
@end

@interface NgPseudoInputAccessoryView : UIView {
  struct { int keyboardFrameDidChange; } _delegateFlags;
}
@property (nonatomic, weak) id<NgPseudoInputAccessoryViewDelegate> delegate;
@end

@implementation NgPseudoInputAccessoryView
- (void)setDelegate:(id<NgPseudoInputAccessoryViewDelegate>)delegate {
  _delegate = delegate;
  _delegateFlags.keyboardFrameDidChange = _delegate && [(id)_delegate respondsToSelector:@selector(pseudoInputAccessoryView:keyboardFrameDidChange:)];
}
- (void)keyboardFrameDidChange:(CGRect)frame {
  if (_delegateFlags.keyboardFrameDidChange) [_delegate pseudoInputAccessoryView:self keyboardFrameDidChange:frame];
}
- (NSString *)selectorForSuperview
{
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
    return @"center";
  }
  return @"frame";
}
- (void)willMoveToSuperview:(UIView *)aSuperview
{
  [super willMoveToSuperview:aSuperview];
  NSString *sel = [self selectorForSuperview];
  [self.superview removeObserver:self forKeyPath:sel];
  [aSuperview addObserver:self forKeyPath:sel options:0 context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (object == self.superview && [keyPath isEqualToString:[self selectorForSuperview]]) {
    [self keyboardFrameDidChange:self.superview.frame];
  }
}
- (void)dealloc
{
  NSString *sel = [self selectorForSuperview];
  [self.superview removeObserver:self forKeyPath:sel];
}
@end

#pragma mark -
@interface NgPseudoInputAccessoryViewCoordinator () <NgPseudoInputAccessoryViewDelegate> {
  struct {
    int didSetFrame;
    int keyboardFrameDidChange;
  } _delegateFlags;
  
  __weak UIResponder * _weakTrackedResponder;
  BOOL _tracking;
  __weak id<NgPseudoInputAccessoryViewCoordinatorDelegate> _delegate;
}
@property (nonatomic, strong, readonly) NgPseudoInputAccessoryView * inputAccessoryView;
@end

@implementation NgPseudoInputAccessoryViewCoordinator

- (instancetype)_init {
  self = [super init];
  if (self) {
    _inputAccessoryView = [NgPseudoInputAccessoryView new];
    _inputAccessoryView.backgroundColor = [UIColor clearColor];
    _inputAccessoryView.userInteractionEnabled = NO;
    _inputAccessoryView.delegate = self;
  }
  return self;
}
- (void)dealloc {
  _inputAccessoryView.delegate = nil;
}
- (void)setDelegate:(id<NgPseudoInputAccessoryViewCoordinatorDelegate>)delegate {
  _delegate = delegate;
  _delegateFlags.didSetFrame = delegate && [(id)delegate respondsToSelector:@selector(pseudoInputAccessoryViewCoordinatorDidSetFrame:)];
  _delegateFlags.keyboardFrameDidChange = delegate && [(id)delegate respondsToSelector:@selector(pseudoInputAccessoryViewCoordinator:keyboardFrameDidChangeInteractively:)];
}
- (void)didSetFrame {
  if (_delegateFlags.didSetFrame) [_delegate pseudoInputAccessoryViewCoordinatorDidSetFrame:self];
}
- (void)keyboardFrameDidChangeInteractively:(CGRect)frame {
  if (_delegateFlags.keyboardFrameDidChange) [_delegate pseudoInputAccessoryViewCoordinator:self keyboardFrameDidChangeInteractively:frame];
}
#pragma mark NgKeyboardInputAccessoryViewDelegate
- (void)pseudoInputAccessoryView:(NgPseudoInputAccessoryView *)v keyboardFrameDidChange:(CGRect)frame {
  [self keyboardFrameDidChangeInteractively:frame];
}

#pragma mark Public
- (void)setPseudoInputAccessoryViewFrame:(CGRect)frame {
  self.inputAccessoryView.frame = frame;
  [self didSetFrame];
}
- (void)trackInteractiveKeyboardDismissalForTextView:(UITextView *)textView {
  NSParameterAssert(textView);
  NSAssert(!_tracking, @"Invalid state: already tracking other responder.");
  _weakTrackedResponder = textView;
  textView.inputAccessoryView = _inputAccessoryView;
  _tracking = YES;
}
- (void)trackInteractiveKeyboardDismissalForTextField:(UITextField *)textField {
  NSParameterAssert(textField);
  NSAssert(!_tracking, @"Invalid state: already tracking other responder.");
  _weakTrackedResponder = textField;
  textField.inputAccessoryView = _inputAccessoryView;
  _tracking = YES;
}
- (void)endTracking {
  __strong UIResponder * strongResponder = _weakTrackedResponder;
  if (strongResponder) {
    if ([strongResponder isKindOfClass:[UITextView class]]) {
      ((UITextView *)strongResponder).inputAccessoryView = nil;
    } else if ([strongResponder isKindOfClass:[UITextField class]]) {
      ((UITextField *)strongResponder).inputAccessoryView = nil;
    } else {
      NSAssert(NO, @"Invalid state: responder is neither a UITextView or UITextField.");
    }
    _tracking = NO;
    _weakTrackedResponder = nil;
  }
}
@end
