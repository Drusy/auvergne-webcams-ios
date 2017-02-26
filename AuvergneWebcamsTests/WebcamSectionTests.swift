//
//  WebcamSectionTests.swift
//  AuvergneWebcams
//
//  Created by Drusy on 26/02/2017.
//
//

import XCTest
import ObjectMapper

@testable import AuvergneWebcams

class WebcamSectionTests: AbstractTests {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - 
    
    func loadWebcamSections() -> [WebcamSection] {
        let json = jsonString(ofFile: "sections")
        
        return Mapper<WebcamSection>().mapArray(JSONString: json)!
    }
    
    // MARK: - JSON
    
    func testParseWebcamSectionsJSON_shouldContainSections() {
        // Given
        
        // When
        let sections = loadWebcamSections()
        
        // Expect
        XCTAssertEqual(sections.count, 3)
    }
    
    func testParseWebcamSectionsJSON_shouldValidSection() {
        // Given
        let sections = loadWebcamSections()
        
        // When
        let section = sections.first!
        
        // Expect
        XCTAssertEqual(section.uid, 1)
        XCTAssertEqual(section.order, 1)
        XCTAssertEqual(section.title, "Puy de Dôme")
        XCTAssertEqual(section.imageName, "sancy-landscape")
        XCTAssertEqual(section.webcams.count, 2)
    }
    
    // MARK: - Model
    
    func testWebcamCountLabel_oneWebcam() {
        // Given
        let section = WebcamSection()
        section.webcams.append(Webcam())
        
        // When
        let webcamCountLabel = section.webcamCountLabel()
        
        // Expect
        XCTAssertEqual(webcamCountLabel, "1 webcam")
    }
    
    func testWebcamCountLabel_fiveWebcam() {
        // Given
        let section = WebcamSection()
        for _ in 1...5 {
            section.webcams.append(Webcam())
        }
        
        // When
        let webcamCountLabel = section.webcamCountLabel()
        
        // Expect
        XCTAssertEqual(webcamCountLabel, "5 webcams")
    }
}
