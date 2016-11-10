//
//  Webcam.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

class Webcam {
    
    var title: String?
    var imageHD: String?
    var imageLD: String?
    var video: String?
    
    var image: UIImage?
    
    // MARK: -
    
    func preferedImage() -> String? {
        return imageHD ?? imageLD
    }
    
    // MARK: - Webcam groups
    
    static func pddWebcams() -> [Webcam] {
        return [
            pdd_sommet(),
            pdd_campus(),
        ]
    }
    
    static func sancyWebcams() -> [Webcam] {
        return [
            md_bas(),
            md_sommet(),
            sb_bas(),
            sb_sommet(),
            sb_front(),
            sancy_charstreix(),
            sancy_lac_chambon()
        ]
    }
    
    // MARK: - Puy de Sancy
    
    fileprivate static func md_bas() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Mont Dore - Bas de la station"
        webcam.imageLD = "http://srv02.trinum.com/ibox/ftpcam/1280_mont-dore_bas-station.jpg"
        webcam.imageHD = "http://srv02.trinum.com/ibox/ftpcam/mega_mont-dore_bas-station.jpg"
        
        return webcam
    }
    
    fileprivate static func md_sommet() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Mont Dore - Sommet"
        webcam.imageLD = "http://www.trinum.com/ibox/ftpcam/1280_mont-dore_sommet.jpg"
        webcam.imageHD = "http://www.trinum.com/ibox/ftpcam/mega_mont-dore_sommet.jpg"
        
        return webcam
    }
    
    fileprivate static func sb_bas() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Super Besse - Ecole (Bas)"
        webcam.imageLD = "http://srv13.trinum.com/ibox/ftpcam/1280_superbesse_ecole.jpg"
        webcam.imageHD = "http://srv13.trinum.com/ibox/ftpcam/mega_superbesse_ecole.jpg"
        
        return webcam
    }
    
    fileprivate static func sb_sommet() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Super Besse - Tyrolienne (Haut)"
        webcam.imageLD = "http://srv06.trinum.com/ibox/ftpcam/1280_superbesse_superbesse-haut.jpg"
        webcam.imageHD = "http://srv06.trinum.com/ibox/ftpcam/mega_superbesse_superbesse-haut.jpg"
        
        return webcam
    }
    
    fileprivate static func sb_front() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Super Besse - Front de neige"
        webcam.imageLD = "http://srv05.trinum.com/ibox/ftpcam/1280_superbesseM.jpg"
        webcam.imageHD = "http://srv05.trinum.com/ibox/ftpcam/mega_superbesseM.jpg"
        
        return webcam
    }
    
    fileprivate static func sancy_charstreix() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Sancy - Station Chastreix"
        webcam.imageLD = "http://srv02.trinum.com/ibox/ftpcam/1280_chastreix-sancy_station.jpg"
        webcam.imageHD = "http://srv02.trinum.com/ibox/ftpcam/mega_chastreix-sancy_station.jpg"
        
        return webcam
    }
    
    fileprivate static func sancy_lac_chambon() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Sancy - Lac Chambon"
        webcam.imageLD = "http://srv13.trinum.com/ibox/ftpcam/1280_chastreix-sancy_lac-chambon.jpg"
        webcam.imageHD = "http://srv13.trinum.com/ibox/ftpcam/mega_chastreix-sancy_lac-chambon.jpg"
        
        return webcam
    }
    
    // MARK: - Puy de Dome
    
    fileprivate static func pdd_sommet() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Sommet du Puy de Dôme"
        webcam.imageLD = "http://wwwobs.univ-bpclermont.fr/opgc/webcampdd.jpg"
        
        return webcam
    }
    
    fileprivate static func pdd_campus() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Campus des Cézeaux"
        webcam.imageLD = "http://wwwobs.univ-bpclermont.fr/opgc/webcamcez.jpg"
        
        return webcam
    }
}
