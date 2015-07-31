//
//  NgKeyboardTracker.h
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 29/6/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
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
/**
 * This method is called when there is change to keyboard tracker's state
 */
- (void)keyboardTrackerDidUpdate:(NgKeyboardTracker *)tracker;
/**
 * This method is called when the following notification occurred:
 * - UIKeyboardWillHideNotification
 * - UIKeyboardDidHideNotification
 * - UIKeyboardWillShowNotification
 * - UIKeyboardDidShowNotification
 */
- (void)keyboardTrackerDidChangeAppearanceState:(NgKeyboardTracker *)tracker;
@end

#pragma mark -
@interface NgKeyboardTracker : NSObject

#pragma mark Properties
@property (nonatomic, readonly) NgKeyboardTrackerKeyboardAppearanceState appearanceState;

// frames
@property (nonatomic, readonly) CGRect beginFrame;   // from most recent UIKeyboardFrameBeginUserInfoKey
@property (nonatomic, readonly) CGRect endFrame;     // from most recent UIKeyboardFrameEndUserInfoKey
@property (nonatomic, readonly) CGRect currentFrame;
                                                                          // current keyboard frame (inclusive of inputAccessoryView's height)

// animation
@property (nonatomic, readonly) NSTimeInterval         animationDuration; // from most recent UIKeyboardAnimationDurationUserInfoKey
@property (nonatomic, readonly) UIViewAnimationCurve   animationCurve;    // from most recent UIKeyboardAnimationCurveUserInfoKey
@property (nonatomic, readonly) UIViewAnimationOptions animationOptions;  // mapped from `animationCurve`

#pragma mark Getting Instance
/**
 * Get the shared instance of keyboard tracker.
 */
+ (instancetype)sharedTracker;

#pragma mark Start/Stop Tracking
/**
 * Start tracking keyboard. 
 * This method should be called as soon as possible within the application lifecycle, for example:
 * in `-application:didFinishLaunchingWithOptions:`
 */
- (void)start;

/**
 * Stop tracking keyboard.
 * This method should be called when your application terminate.
 */
- (void)stop;

#pragma mark Delegate
- (void)addDelegate:(id<NgKeyboardTrackerDelegate>)delegate;
- (void)removeDelegate:(id<NgKeyboardTrackerDelegate>)delegate;

#pragma mark Pseudo Input Accessory
/**
 * Create instance of pseudo inputAccessoryView coordinator.
 * Instance created by this tracker will update the tracker
 *   whenever layout changes occurred.
 */
- (NgPseudoInputAccessoryViewCoordinator *)createPseudoInputAccessoryViewCoordinator;

#pragma mark Convenience Methods
/**
 * Returns YES if keyboard is currently visible on screen, otherwise NO.
 * The visiblity is calculated based on `currentFrame` state.
 */
- (BOOL)isKeyboardVisible;

@end

#pragma mark -
@interface NgKeyboardTracker (UIView)
/**
 * Convenience method to convert keyboard tracker's `currentFrame`
 * to coordinate system of specified `view`.
 */
- (CGRect)keyboardCurrentFrameForView:(UIView *)view;
@end
