//
//  WebcamSectionTests.swift
//  AuvergneWebcams
//
//  Created by Drusy on 26/02/2017.
//
//

import XCTest
import ObjectMapper
import SwiftyUserDefaults

@testable import AuvergneWebcams

class WebcamTests: AbstractTests {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - 
    
    func loadWebcam() -> Webcam {
        let json = jsonString(ofFile: "webcam")
        
        return Mapper<Webcam>().map(JSONString: json)!
    }
    
    // MARK: - JSON
    
    func testParseWebcamJSON_shouldValid() {
        // Given
        let webcam = loadWebcam()
        
        // When
        
        // Expect
        XCTAssertEqual(webcam.uid, 10)
        XCTAssertEqual(webcam.title, "Sommet de la station")
        XCTAssertEqual(webcam.imageLD, "http://srv02.trinum.com/ibox/ftpcam/1280_lioran_sommet-domaine.jpg")
        XCTAssertEqual(webcam.imageHD, "http://srv02.trinum.com/ibox/ftpcam/mega_lioran_sommet-domaine.jpg")
        XCTAssertEqual(webcam.tags.count, 5)
    }
    
    // MARK: - Model
    
    func testWebcamPreferredImage_lowQuality() {
        // Given
        let webcam = Webcam()
        webcam.imageHD = "HD"
        webcam.imageLD = "LD"
        
        // When
        Defaults[.prefersHighQuality] = false
        let preferredImage = webcam.preferredImage()
        
        // Expect
        XCTAssertEqual(preferredImage, "LD")
    }
    
    func testWebcamPreferredImage_lowQualityPreferredButEmpty_shouldGetHighQuality() {
        // Given
        let webcam = Webcam()
        webcam.imageHD = "HD"
        
        // When
        Defaults[.prefersHighQuality] = false
        let preferredImage = webcam.preferredImage()
        
        // Expect
        XCTAssertEqual(preferredImage, "HD")
    }
    
    func testWebcamPreferredImage_highQualityPreferredButEmpty_shouldGetLowQuality() {
        // Given
        let webcam = Webcam()
        webcam.imageLD = "LD"
        
        // When
        Defaults[.prefersHighQuality] = true
        let preferredImage = webcam.preferredImage()
        
        // Expect
        XCTAssertEqual(preferredImage, "LD")
    }
    
    func testWebcamPreferredImage_highQuality() {
        // Given
        let webcam = Webcam()
        webcam.imageHD = "HD"
        webcam.imageLD = "LD"
        
        // When
        Defaults[.prefersHighQuality] = true
        let preferredImage = webcam.preferredImage()
        
        // Expect
        XCTAssertEqual(preferredImage, "HD")
    }
}
