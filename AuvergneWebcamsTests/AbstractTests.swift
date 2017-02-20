//
//  AbstractTests.swift
//  Koboo
//
//  Created by Drusy on 07/02/2017.
//  Copyright © 2017 Koboo. All rights reserved.
//

import XCTest
import RealmSwift
import ObjectMapper

@testable import AuvergneWebcams

class AbstractTests: XCTestCase {
    var realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: -
    
    func jsonString(ofFile file: String, handler: (_ content: String) -> Void) {
        let path = Bundle(for: AbstractTests.self).path(forResource: file, ofType: "json")
        let json = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        handler(json)
    }
}
