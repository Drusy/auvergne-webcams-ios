//
//  UIActivityIndicatorView+OTKAdditions.h
//  OpeniumTestingKit
//
//  Created by Richard Bergoin on 27/02/2015.
//  Copyright (c) 2015 Openium. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityIndicatorView (OTKAdditions)

+ (NSString *)otk_accessibilityLabelForHaltedInstance;
+ (NSString *)otk_accessibilityLabelForAnimatedInstance;

@end
