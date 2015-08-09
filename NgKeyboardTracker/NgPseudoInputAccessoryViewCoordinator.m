//
//  NgPseudoInputAccessoryViewCoordinator.m
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 3/7/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
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

  CGFloat _height;
  NSLayoutConstraint * _heightConstraint;
}
@property (nonatomic, weak) id<NgPseudoInputAccessoryViewDelegate> delegate;
@property (nonatomic) CGFloat height;
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
- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  
  __block NSLayoutConstraint * heightConstraint = nil;
  [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint * constraint, NSUInteger idx, BOOL *stop) {
    if (constraint.firstItem == self &&
        constraint.firstAttribute == NSLayoutAttributeHeight &&
        constraint.relation == NSLayoutRelationEqual) {
      heightConstraint = constraint;
      *stop = YES;
    }
  }];
  _heightConstraint = heightConstraint;
  _heightConstraint.constant = _height;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (object == self.superview && [keyPath isEqualToString:[self selectorForSuperview]]) {
    CGRect kbframe = [self.superview convertRect:self.superview.bounds toView:nil];
    [self keyboardFrameDidChange:kbframe];
  }
}
- (void)dealloc
{
  NSString *sel = [self selectorForSuperview];
  [self.superview removeObserver:self forKeyPath:sel];
}
- (void)setHeight:(CGFloat)height {
  if (_height == height) return;
  _height = height;
  _heightConstraint.constant = height;
}
- (CGFloat)height {
  return _height;
}
@end

#pragma mark -
@interface NgPseudoInputAccessoryViewCoordinator () <NgPseudoInputAccessoryViewDelegate> {
  struct {
    int didSetHeight;
    int keyboardFrameDidChange;
  } _delegateFlags;
  
  __weak UIResponder * _weakTrackedResponder;
  BOOL _tracking;
  __weak id<NgPseudoInputAccessoryViewCoordinatorDelegate> _delegate;
}
@end

@implementation NgPseudoInputAccessoryViewCoordinator

- (instancetype)_init {
  self = [super init];
  if (self) {
    _pseudoInputAccessoryView = [NgPseudoInputAccessoryView new];
    _pseudoInputAccessoryView.backgroundColor = [UIColor clearColor];
    _pseudoInputAccessoryView.userInteractionEnabled = NO;
    ((NgPseudoInputAccessoryView *)_pseudoInputAccessoryView).delegate = self;
  }
  return self;
}
- (void)dealloc {
  ((NgPseudoInputAccessoryView *)_pseudoInputAccessoryView).delegate = nil;
  _pseudoInputAccessoryView = nil;
}
- (void)setDelegate:(id<NgPseudoInputAccessoryViewCoordinatorDelegate>)delegate {
  _delegate = delegate;
  _delegateFlags.didSetHeight = delegate && [(id)delegate respondsToSelector:@selector(pseudoInputAccessoryViewCoordinator:didSetHeight:)];
  _delegateFlags.keyboardFrameDidChange = delegate && [(id)delegate respondsToSelector:@selector(pseudoInputAccessoryViewCoordinator:keyboardFrameDidChange:)];
}
- (void)didSetHeight:(CGFloat)height {
  if (_delegateFlags.didSetHeight) [_delegate pseudoInputAccessoryViewCoordinator:self didSetHeight:height];
}
- (void)keyboardFrameDidChange:(CGRect)frame {
  if (_delegateFlags.keyboardFrameDidChange) [_delegate pseudoInputAccessoryViewCoordinator:self keyboardFrameDidChange:frame];
}
#pragma mark NgKeyboardInputAccessoryViewDelegate
- (void)pseudoInputAccessoryView:(NgPseudoInputAccessoryView *)v keyboardFrameDidChange:(CGRect)frame {
  [self keyboardFrameDidChange:frame];
}

#pragma mark Public
- (void)setPseudoInputAccessoryViewHeight:(CGFloat)height {
  [(NgPseudoInputAccessoryView *)_pseudoInputAccessoryView setHeight:height];
  [self didSetHeight:height];
}
- (CGFloat)pseudoInputAccessoryViewHeight {
  return [(NgPseudoInputAccessoryView *)_pseudoInputAccessoryView height];
}
- (BOOL)isActive {
  return _pseudoInputAccessoryView.superview != nil;
}
@end
