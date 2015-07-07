//
//  NgKeyboardTracker.h
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 29/6/15.
//  Copyright (c) 2015 BlockThirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NgPseudoInputAccessoryViewCoordinator.h"

typedef NS_ENUM(int32_t, NgKeyboardTrackerKeyboardAppearanceState) {
  NgKeyboardTrackerKeyboardAppearanceStateUndefined,
  NgKeyboardTrackerKeyboardAppearanceStateWillShow,
  NgKeyboardTrackerKeyboardAppearanceStateWillHide,
  NgKeyboardTrackerKeyboardAppearanceStateShown,
  NgKeyboardTrackerKeyboardAppearanceStateHidden
};
NSString * NgAppearanceStateAsString(NgKeyboardTrackerKeyboardAppearanceState state);

#pragma mark -
@class NgKeyboardTracker;
@protocol NgKeyboardTrackerDelegate
@optional
- (void)keyboardTrackerDidUpdate:(NgKeyboardTracker *)tracker;
- (void)keyboardTrackerDidChangeAppearanceState:(NgKeyboardTracker *)tracker;
@end


@interface NgKeyboardTracker : NSObject

@property (nonatomic, readonly) NgKeyboardTrackerKeyboardAppearanceState appearanceState;

// frames
@property (nonatomic, readonly) CGRect                                    beginFrame;
@property (nonatomic, readonly) CGRect                                    endFrame;
@property (nonatomic, readonly) CGRect                                    currentFrame;

// animation
@property (nonatomic, readonly) NSTimeInterval                            animationDuration;
@property (nonatomic, readonly) UIViewAnimationCurve                      animationCurve;
@property (nonatomic, readonly) UIViewAnimationOptions                    animationOptions;

+ (instancetype)sharedTracker;
- (void)start;
- (void)stop;

- (void)addDelegate:(id<NgKeyboardTrackerDelegate>)delegate;
- (void)removeDelegate:(id<NgKeyboardTrackerDelegate>)delegate;

- (NgPseudoInputAccessoryViewCoordinator *)createPseudoInputAccessoryViewCoordinator;
- (BOOL)isKeyboardVisible;

@end

@interface NgKeyboardTracker (UIView)
- (CGRect)keyboardCurrentFrameForView:(UIView *)view;
@end
