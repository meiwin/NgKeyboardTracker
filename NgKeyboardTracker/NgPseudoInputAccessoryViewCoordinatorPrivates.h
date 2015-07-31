//
//  NgPseudoInputAccessoryViewCoordinatorPrivates.h
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 3/7/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#ifndef NgKeyboardTracker_NgPseudoInputAccessoryViewCoordinatorPrivates_h
#define NgKeyboardTracker_NgPseudoInputAccessoryViewCoordinatorPrivates_h

@protocol NgPseudoInputAccessoryViewCoordinatorDelegate
@optional
- (void)pseudoInputAccessoryViewCoordinator:(NgPseudoInputAccessoryViewCoordinator *)coordinator
                               didSetHeight:(CGFloat)height;
- (void)pseudoInputAccessoryViewCoordinator:(NgPseudoInputAccessoryViewCoordinator *)coordinator
                     keyboardFrameDidChange:(CGRect)frame;
@end

@interface NgPseudoInputAccessoryViewCoordinator (Privates)
- (instancetype)_init;
- (void)setDelegate:(id<NgPseudoInputAccessoryViewCoordinatorDelegate>)delegate;
@end

#endif
