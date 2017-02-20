//
//  UIView+OTKAdditions.h
//  OpeniumTestingKit
//
//  Created by Richard Bergoin on 18/03/14.
//  Copyright (c) 2014 Openium. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (OTKAdditions)

- (UIImage *)otk_viewshot;
- (UIImage *)otk_screenshotWithStatusBar:(BOOL)withStatusBar;
- (NSString *)otk_recursiveDescription;
- (BOOL)otk_matchPredicate:(NSPredicate *)predicate;
- (UIView *)otk_firstViewMatchingPredicate:(NSPredicate *)predicate;

@end
