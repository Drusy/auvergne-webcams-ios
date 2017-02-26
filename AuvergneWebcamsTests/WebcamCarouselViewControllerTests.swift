//
//  MyRentsViewControllerTests.swift
//  AuvergneWebcams
//
//  Created by Drusy on 25/01/2017.
//  Copyright © 2017 AuvergneWebcams. All rights reserved.
//

import XCTest

@testable import AuvergneWebcams

class WebcamCarouselViewControllerTests: AbstractViewControllerTests {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Tests
    
    func testViewController() {
        // Given
        
        // When
        let webcamCarouselVC = WebcamCarouselViewController()
        let nav = NavigationController(rootViewController: webcamCarouselVC)
        
        // Expect
        _ = solo?.showViewController(inCleanWindow: nav, inNavigationController: false)
        solo?.wait(forTimeInterval: 10)
        solo?.screenshot(toTmpSuffixed: "home", withStatusBar: true)
        solo?.waitForever()
    }
    
    func testViewController_presentSettings() {
        // Given
        
        // When
        let webcamCarouselVC = WebcamCarouselViewController()
        let nav = NavigationController(rootViewController: webcamCarouselVC)
        
        // Expect
        _ = solo?.showViewController(inCleanWindow: nav, inNavigationController: false)
        webcamCarouselVC.onSettingsTouched()
        solo?.wait(forTimeInterval: 10)
        solo?.screenshot(toTmpSuffixed: "settings", withStatusBar: true)
        solo?.waitForever()
    }
}
