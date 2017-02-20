//
//  UIImage+OTKAdditions.h
//  OpeniumTestingKit
//
//  Created by Richard Bergoin on 18/03/14.
//  Copyright (c) 2014 Openium. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (OTKAdditions)

+ (UIImage *)otk_imageWithContentsOfResource:(NSString *)imageName inBundleOfClass:(Class)aClass;

- (UIImage *)otk_diffWithImage:(UIImage *)image;
- (UIImage *)otk_addImagesToLeft:(NSArray *)images;
- (NSInteger)otk_numberOfPixels;
- (NSInteger)otk_numberOfNonBlackPixels;
- (NSInteger)otk_sumOfGreyValuesMax;
- (NSInteger)otk_sumOfGreyValuesOfNonBlackPixels;
- (NSInteger)otk_sumOfGreyValuesOfNonBlackPixelsUsingRadius:(int)radius;
- (NSInteger)otk_averageGreyValueOfNonBlackPixels;
- (NSInteger)otk_sumOfGreyValuesOfNonBlackPixelsAboveAverageGrey;

@end
