//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

class WebcamSection {
    var title: String?
    var image: UIImage?
    
    // MARK: -
    
    static func pddSection() -> WebcamSection {
        let section = WebcamSection()
        
        section.title = "Puy de Dôme"
        section.image = UIImage(named: "sancy-landscape")
        
        return section
    }
    
    static func sancySection() -> WebcamSection {
        let section = WebcamSection()
        
        section.title = "Puy de Sancy"
        section.image = UIImage(named: "goal-landscape")
        
        return section
    }
}
