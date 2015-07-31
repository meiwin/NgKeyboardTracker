//
//  NgPseudoInputAccessoryViewCoordinator.h
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 3/7/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Instance of this class creates and manages one instance of pseudo inputAccessoryView.
 * You can create instance of this class via `NgKeyboardTracker` instance.
 * 
 * The coordinator will reports keyboard layout updates to `NgKeyboardTracker` that created it.
 */
@interface NgPseudoInputAccessoryViewCoordinator : NSObject

#pragma mark Properties
@property (nonatomic, strong, readonly) UIView * pseudoInputAccessoryView;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

#pragma mark Input Accessory Height
- (void)setPseudoInputAccessoryViewHeight:(CGFloat)height;
- (CGFloat)pseudoInputAccessoryViewHeight;

#pragma mark Convenience Methods
/**
 * If `isActive` is true, it means the pseudo input accessory view managed by this coordinator
 * is presently attached to keyboard
 */
- (BOOL)isActive;

@end
