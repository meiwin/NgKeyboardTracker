//
//  NgPseudoInputAccessoryViewCoordinatorPrivates.h
//  NgKeyboardTracker
//
//  Created by Meiwin Fu on 3/7/15.
//  Copyright (c) 2015 BlockThirty. All rights reserved.
//

#ifndef NgKeyboardTracker_NgPseudoInputAccessoryViewCoordinatorPrivates_h
#define NgKeyboardTracker_NgPseudoInputAccessoryViewCoordinatorPrivates_h

@protocol NgPseudoInputAccessoryViewCoordinatorDelegate
@optional
- (void)pseudoInputAccessoryViewCoordinatorDidSetFrame:(NgPseudoInputAccessoryViewCoordinator *)coordinator;
- (void)pseudoInputAccessoryViewCoordinator:(NgPseudoInputAccessoryViewCoordinator *)coordinator
        keyboardFrameDidChangeInteractively:(CGRect)frame;
@end

@interface NgPseudoInputAccessoryViewCoordinator (Privates)
- (instancetype)_init;
- (void)setDelegate:(id<NgPseudoInputAccessoryViewCoordinatorDelegate>)delegate;
@end

#endif
