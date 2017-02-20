//
//  OTKSolo.h
//  OpeniumTestingKit
//
//  Created by Richard Bergoin on 18/02/2015.
//  Copyright (c) 2015 Openium. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTKSolo : NSObject

@property (nonatomic, strong) NSString *statusBarCarrierName; // OPENIUM by default
@property (nonatomic, assign) NSTimeInterval timeToWaitForever; // 1000000. by default
@property (nonatomic, assign) NSTimeInterval timeoutForWaitForMethods; // 5. by default
@property (nonatomic, assign) NSTimeInterval timeBetweenChecks; // 0.1 by default
@property (nonatomic, assign) float animationSpeed; // 1. by default
@property (nonatomic, assign) Class navigationControllerClass; // [UINavigationController class]
@property (nonatomic, assign) Class windowClass; // [UIWindow class]
@property (nonatomic, readonly) UIWindow *window;

- (UINavigationController *)showViewControllerInCleanWindow:(UIViewController *)viewController
                                     inNavigationController:(BOOL)inNavigationController;
- (UINavigationController *)showViewControllerInCleanWindow:(UIViewController *)viewController;
- (void)cleanupWindow;
- (void)dumpWindowHierarchy;

#pragma mark Texts

- (void)setStepDelay:(NSTimeInterval)stepDelay;

- (BOOL)waitForText:(NSString *)text;

- (BOOL)waitForTappableText:(NSString *)text andTapIt:(BOOL)tapIt;

- (BOOL)waitForTextToBecomeInvalid:(NSString *)text;

- (void)waitForever;
- (void)waitForTimeInterval:(NSTimeInterval)timeToWait;

- (void)tapScreenAtPoint:(CGPoint)screenPoint;
- (void)swipeDownViewWithAccessibilityLabel:(NSString *)text;
- (void)swipeUpViewWithAccessibilityLabel:(NSString *)label;
- (void)swipeLeftViewWithAccessibilityLabel:(NSString *)label;
- (void)swipeRightViewWithAccessibilityLabel:(NSString *)label;
- (void)toggleSwitchWithAccessibilityLabel:(NSString *)label;

- (void)simulateDeviceRotationToOrientation:(UIDeviceOrientation)deviceOrientation;

- (void)enterTextInCurrentFirstResponder:(NSString *)text;

- (void)acknowledgeSystemAlert;
- (void)disableAccessibility;
/**
 Take a screenshot, and save it to /tmp/AppName-$fileSuffix.jpg (only if user runing tests is not jenkins or hudson)
 */
- (void)screenshotToTmpSuffixed:(NSString *)fileSuffix
                  withStatusBar:(BOOL)withStatusBar;

@end
