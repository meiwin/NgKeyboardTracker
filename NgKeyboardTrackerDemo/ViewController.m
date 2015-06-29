//
//  ViewController.m
//  NgKeyboardTrackerDemo
//
//  Created by Meiwin Fu on 29/6/15.
//  Copyright (c) 2015 BlockThirty. All rights reserved.
//

#import "ViewController.h"
#import "NgKeyboardTracker.h"

NSString * AppearanceStateAsString(NgKeyboardTrackerKeyboardAppearanceState state) {
  if (state == NgKeyboardTrackerKeyboardAppearanceStateUndefined) return @"undefined";
  if (state == NgKeyboardTrackerKeyboardAppearanceStateWillShow) return @"will show";
  if (state == NgKeyboardTrackerKeyboardAppearanceStateShown) return @"shown";
  if (state == NgKeyboardTrackerKeyboardAppearanceStateWillHide) return @"will hide";
  if (state == NgKeyboardTrackerKeyboardAppearanceStateHidden) return @"hidden";
  return @"???";
}

NSString * DescriptionFromKeyboardTracker(NgKeyboardTracker * tracker) {
  return [NSString stringWithFormat:@"[%@]\n%@"
          , AppearanceStateAsString(tracker.appearanceState)
          , NSStringFromCGRect(tracker.endFrame)];
}

@interface LayoutView : UIView <NgKeyboardTrackerDelegate>
@property (nonatomic, strong, readonly) UITextView * textView;
@property (nonatomic, strong, readonly) UIScrollView * scrollView;
@property (nonatomic, strong, readonly) UILabel * label;
@property (nonatomic, strong, readonly) UIButton * button;
@property (nonatomic, strong, readonly) NgPseudoInputAccessoryViewCoordinator * coordinator;
@end

@implementation LayoutView
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupViews];
    
    _coordinator = [[NgKeyboardTracker sharedTracker] createPseudoInputAccessoryViewCoordinator];
    [_coordinator trackInteractiveKeyboardDismissalForTextView:_textView];
    
    [[NgKeyboardTracker sharedTracker] addDelegate:self];
  }
  return self;
}
- (void)dealloc {
  [_coordinator endTracking];
  [[NgKeyboardTracker sharedTracker] removeDelegate:self];
}
- (void)setupViews {
  _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  _scrollView.backgroundColor = [UIColor whiteColor];
  _scrollView.alwaysBounceVertical = YES;
  _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
  [self addSubview:_scrollView];
  
  _textView = [[UITextView alloc] init];
  _textView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1.f];
  _textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
  _textView.font = [UIFont systemFontOfSize:17];
  [self addSubview:_textView];
  
  UIView * border = [UIView new];
  border.tag = 1000;
  border.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.f];
  [_textView addSubview:border];
  
  _button = [UIButton buttonWithType:UIButtonTypeSystem];
  [_button setTitle:@"Dismiss Keyboard" forState:UIControlStateNormal];
  [_button sizeToFit];
  [_scrollView addSubview:_button];
  
  _label = [UILabel new];
  _label.font = [UIFont systemFontOfSize:16];
  _label.numberOfLines = 3;
  _label.textAlignment = NSTextAlignmentCenter;
  [_scrollView addSubview:_label];
}
- (void)layoutTextView {
  
  CGRect kbframe = [[NgKeyboardTracker sharedTracker] keyboardEndFrameForView:self];
  CGSize s = self.frame.size;
  CGFloat textViewH = 44;
  CGFloat bottomPadding = -textViewH;
  
  if (!CGRectEqualToRect(CGRectZero, kbframe)) {
    bottomPadding += ( s.height - kbframe.origin.y );
  }

  bottomPadding = MAX(0, bottomPadding);
  
  _textView.frame = (CGRect) {
    0,
    s.height - textViewH - bottomPadding,
    s.width,
    textViewH
  };

  UIView * border = [_textView viewWithTag:1000];
  border.frame = (CGRect) { 0, 0, _textView.frame.size.width, .6 };
  [_coordinator setPseudoInputAccessoryViewFrame:_textView.bounds];
}
- (void)layoutSubviews {
  
  [super layoutSubviews];
  
  CGSize s = self.frame.size;
  _scrollView.frame = self.bounds;
  _scrollView.contentSize = s;

  [self layoutTextView];
  
  _button.frame = (CGRect) {
    30,
    60,
    s.width - 60,
    30
  };
  
  _label.frame = (CGRect) {
    30,
    120,
    s.width - 60,
    60
  };
  
}
- (void)keyboardTrackerDidChangeAppearanceState:(NgKeyboardTracker *)tracker {
  _label.text = DescriptionFromKeyboardTracker(tracker);
  [UIView animateWithDuration:tracker.animationDuration
                        delay:0
                      options:tracker.animationOptions
                   animations:^{
                     [self layoutTextView];
                   }
                   completion:nil];
}
- (void)keyboardTrackerDidUpdate:(NgKeyboardTracker *)tracker {
  _label.text = DescriptionFromKeyboardTracker(tracker);
  [UIView animateWithDuration:tracker.animationDuration
                        delay:0
                      options:tracker.animationOptions
                   animations:^{
                     [self layoutTextView];
                   }
                   completion:nil];
}
@end

@interface ViewController () <NgKeyboardTrackerDelegate>
@property (nonatomic, strong, readonly) LayoutView * layoutView;
@end

@implementation ViewController

- (void)loadView {
  [super loadView];
  
  _layoutView = [[LayoutView alloc] initWithFrame:self.view.bounds];
  _layoutView.autoresizingMask = ~UIViewAutoresizingNone;
  [self.view addSubview:_layoutView];
}
- (void)viewDidLoad {
  [super viewDidLoad];

  [_layoutView.button addTarget:self action:@selector(onButtonTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onButtonTap:(id)sender {
  [_layoutView.textView resignFirstResponder];
}

@end
