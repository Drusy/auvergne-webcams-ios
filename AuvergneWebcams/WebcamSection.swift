//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

class WebcamSection {
    var uid: Int = 0
    var title: String?
    var image: UIImage?
    var webcams = [Webcam]()
    
    // MARK: -
    
    static func pddSection() -> WebcamSection {
        let section = WebcamSection()
        
        section.uid = 1
        section.title = "Puy de Dôme"
        section.image = UIImage(named: "sancy-landscape")
        section.webcams = Webcam.pddWebcams()
        
        return section
    }
    
    static func sancySection() -> WebcamSection {
        let section = WebcamSection()
        
        section.uid = 2
        section.title = "Puy de Sancy"
        section.image = UIImage(named: "goal-landscape")
        section.webcams = Webcam.sancyWebcams()
        
        return section
    }
    
    static func lioranSection() -> WebcamSection {
        let section = WebcamSection()
        
        section.uid = 3
        section.title = "Le Lioran"
        section.image = UIImage(named: "lioran-landscape")
        section.webcams = Webcam.lioranWebcams()
        
        return section
    }
    
    // MARK: - 
    
    func webcamCountLabel() -> String {
        if webcams.count == 1 {
            return "1 webcam"
        } else {
            return "\(webcams.count) webcams"
        }
    }
}

extension WebcamSection: Equatable {

    public static func == (lhs: WebcamSection, rhs: WebcamSection) -> Bool {
        return lhs.uid == rhs.uid
    }
}
