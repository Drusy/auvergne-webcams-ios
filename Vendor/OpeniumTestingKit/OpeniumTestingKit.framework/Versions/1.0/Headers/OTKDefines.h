//
//  OTKDefines.h
//  OpeniumTestingKit
//
//  Created by Richard Bergoin on 18/03/14.
//  Copyright (c) 2014 Openium. All rights reserved.
//

#import "UIView+OTKAdditions.h"
#import "UIImage+OTKAdditions.h"

#if defined __IPHONE_8_0
// They changed the call to _XCTRegisterFailure in iOS 8. Once we no longer need to support
// the iOS 7 SDK, we can remove this.
#define _OKXCRegisterFailure(expression, format...) _XCTRegisterFailure(self, expression, format)
#else
#define _OKXCRegisterFailure(expression, format...) _XCTRegisterFailure(expression, format)
#endif  // defined __IPHONE_8_0

extern NSString *OTKTooManyDifferentsPixelsException;

extern NSException *otk_exceptionIfViewEqualsToImageNameIsBelowPercent(UIView *view, NSString *imageName, Class aClass, float percent);

#ifndef OpeniumTestingKit_OTKDefines_h
#define OpeniumTestingKit_OTKDefines_h

#define OTKAssertViewEqualsToImageNameAtPercent(view, imageName, percent, format...)\
({ \
@try { \
    NSException *__exception = otk_exceptionIfViewEqualsToImageNameIsBelowPercent(view, imageName, [self class], percent);\
    if( __exception )\
    {\
        if( [__exception.name isEqualToString:OTKTooManyDifferentsPixelsException] )\
        {\
            UIImage *__viewShot = __exception.userInfo[@"viewShot"];\
            UIImage *__expectedShot = __exception.userInfo[@"expectedShot"];\
            UIImage *__mineDiffExpectedImage = __exception.userInfo[@"mineDiffExpectedImage"];\
            NSNumber *__pixelsInCommonPercent = __exception.userInfo[@"pixelsInCommonPercent"];\
\
            _OKXCRegisterFailure(__exception.reason, format);\
            __viewShot = nil;\
            __expectedShot = nil;\
            __mineDiffExpectedImage = nil;\
            __pixelsInCommonPercent = nil;\
        }\
        else\
        {\
            @throw __exception;\
        }\
    }\
} \
@catch (NSException *exception) { \
    _OKXCRegisterFailure(_XCTFailureDescription(_XCTAssertion_NotNil, 1, @#imageName, [exception reason]),format); \
} \
@catch (...) { \
    _OKXCRegisterFailure(_XCTFailureDescription(_XCTAssertion_NotNil, 2, @#imageName),format); \
} \
})

#ifdef OTK_SHORTHAND
    #define assertViewEqualsToImageNameAtPercent OTKAssertViewEqualsToImageNameAtPercent
#endif

#endif
