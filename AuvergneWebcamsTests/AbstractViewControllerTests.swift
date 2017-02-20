//
//  AbstractViewControllerTests.swift
//  rives-de-moselle
//
//  Created by Drusy on 18/08/2016.
//  Copyright © 2016 Clément Samson. All rights reserved.
//

import XCTest
import RealmSwift
import ObjectMapper
import OpeniumTestingKit

@testable import AuvergneWebcams

class AbstractViewControllerTests: AbstractTests {
    var solo: OTKSolo?

    override func setUp() {
        super.setUp()
        
        solo = OTKSolo()
        solo?.statusBarCarrierName = "OPENIUM"
    }
    
    override func tearDown() {
        solo?.cleanupWindow()
        solo = nil;

        super.tearDown()
    }
}
