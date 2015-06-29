//
//  NgPseudoInputAccessoryViewCoordinator.h
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 3/7/15.
//  Copyright (c) 2015 BlockThirty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NgPseudoInputAccessoryViewCoordinator : NSObject
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (void)setPseudoInputAccessoryViewFrame:(CGRect)frame;
- (void)trackInteractiveKeyboardDismissalForTextView:(UITextView *)textView;
- (void)trackInteractiveKeyboardDismissalForTextField:(UITextField *)textField;
- (void)endTracking;
@end
