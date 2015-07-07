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
@property (nonatomic, strong, readonly) UIView * pseudoInputAccessoryView;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (void)setPseudoInputAccessoryViewHeight:(CGFloat)height;
- (CGFloat)pseudoInputAccessoryViewHeight;
/**
 * If `isActive` is true, it means the pseudo input accessory view managed by this coordinator
 * is presently attached to keyboard
 */
- (BOOL)isActive;
@end
