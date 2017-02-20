//
//  Webcam.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit
import SwiftyUserDefaults

class Webcam {
    
    #if DEBUG
    static let refreshInterval: TimeInterval = 60 * 1
    #else
    static let refreshInterval: TimeInterval = 60 * 10
    #endif
    
    var lastUpdate: Date?
    var title: String?
    var imageHD: String?
    var imageLD: String?
    var video: String?
    var tags = [String]()
    
    // MARK: -
    
    func preferedImage() -> String? {
        if Defaults[.prefersHighQuality] {
            return imageHD ?? imageLD
        } else {
            return imageLD ?? imageHD
        }
    }
    
    // MARK: - Webcam groups
    
    static func pddWebcams() -> [Webcam] {
        return [
            pdd_sommet(),
            pdd_campus()
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
    
    static func lioranWebcams() -> [Webcam] {
        return [
            ll_sommet(),
            ll_station(),
            ll_alagnon()
        ]
    }
    
    // MARK: - Le Lioran
    
    fileprivate static func ll_station() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Centre station"
        webcam.imageLD = "http://srv02.trinum.com/ibox/ftpcam/1280_lioran_station.jpg"
        webcam.imageHD = "http://www.trinum.com/ibox/ftpcam/mega_lioran_station.jpg"
        webcam.tags = [
            "lioran",
            "auvergne",
            "station",
            "sky"
        ]
        
        return webcam
    }
    
    fileprivate static func ll_sommet() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Sommet de la station"
        webcam.imageLD = "http://srv02.trinum.com/ibox/ftpcam/1280_lioran_sommet-domaine.jpg"
        webcam.imageHD = "http://srv02.trinum.com/ibox/ftpcam/mega_lioran_sommet-domaine.jpg"
        webcam.tags = [
            "lioran",
            "auvergne",
            "station",
            "sky",
            "sommet"
        ]
        
        return webcam
    }
    
    fileprivate static func ll_alagnon() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Font d'Alagnon"
        webcam.imageLD = "http://srv04.trinum.com/ibox/ftpcam/1280_lioran_font-d-alagnon.jpg"
        webcam.imageHD = "http://srv04.trinum.com/ibox/ftpcam/mega_lioran_font-d-alagnon.jpg"
        webcam.tags = [
            "lioran",
            "auvergne",
            "station",
            "sky"
        ]
        
        return webcam
    }
    
    // MARK: - Puy de Sancy
    
    fileprivate static func md_bas() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Mont Dore - Bas de la station"
        webcam.imageLD = "http://srv02.trinum.com/ibox/ftpcam/1280_mont-dore_bas-station.jpg"
        webcam.imageHD = "http://srv02.trinum.com/ibox/ftpcam/mega_mont-dore_bas-station.jpg"
        webcam.tags = [
            "sancy",
            "mot dore",
            "auvergne",
            "station",
            "sky"
        ]
        
        return webcam
    }
    
    fileprivate static func md_sommet() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Mont Dore - Sommet"
        webcam.imageLD = "http://www.trinum.com/ibox/ftpcam/1280_mont-dore_sommet.jpg"
        webcam.imageHD = "http://www.trinum.com/ibox/ftpcam/mega_mont-dore_sommet.jpg"
        webcam.tags = [
            "sancy",
            "mot dore",
            "auvergne",
            "station",
            "sky"
        ]
    
        return webcam
    }
    
    fileprivate static func sb_bas() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Super Besse - Ecole (Bas)"
        webcam.imageLD = "http://srv14.trinum.com/ibox/ftpcam/1280_superbesse_ecole.jpg"
        webcam.imageHD = "http://srv14.trinum.com/ibox/ftpcam/mega_superbesse_ecole.jpg"
        webcam.tags = [
            "sancy",
            "super besse",
            "auvergne",
            "station",
            "sky"
        ]
        
        return webcam
    }
    
    fileprivate static func sb_sommet() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Super Besse - Tyrolienne (Haut)"
        webcam.imageLD = "http://srv06.trinum.com/ibox/ftpcam/1280_superbesse_superbesse-haut.jpg"
        webcam.imageHD = "http://srv06.trinum.com/ibox/ftpcam/mega_superbesse_superbesse-haut.jpg"
        webcam.tags = [
            "sancy",
            "super besse",
            "auvergne",
            "station",
            "sky"
        ]
        
        return webcam
    }
    
    fileprivate static func sb_front() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Super Besse - Front de neige"
        webcam.imageLD = "http://srv05.trinum.com/ibox/ftpcam/1280_superbesseM.jpg"
        webcam.imageHD = "http://srv05.trinum.com/ibox/ftpcam/mega_superbesseM.jpg"
        webcam.tags = [
            "sancy",
            "super besse",
            "auvergne",
            "station",
            "sky"
        ]
        
        return webcam
    }
    
    fileprivate static func sancy_charstreix() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Sancy - Station Chastreix"
        webcam.imageLD = "http://srv02.trinum.com/ibox/ftpcam/1280_chastreix-sancy_station.jpg"
        webcam.imageHD = "http://srv02.trinum.com/ibox/ftpcam/mega_chastreix-sancy_station.jpg"
        webcam.tags = [
            "sancy",
            "charstreix",
            "auvergne",
            "station",
            "sky"
        ]
        
        return webcam
    }
    
    fileprivate static func sancy_lac_chambon() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Sancy - Lac Chambon"
        webcam.imageLD = "http://srv14.trinum.com/ibox/ftpcam/1280_chastreix-sancy_lac-chambon.jpg"
        webcam.imageHD = "http://srv14.trinum.com/ibox/ftpcam/mega_chastreix-sancy_lac-chambon.jpg"
        webcam.tags = [
            "sancy",
            "lac chambon",
            "auvergne",
            "station",
            "sky"
        ]
        
        return webcam
    }
    
    // MARK: - Puy de Dome
    
    fileprivate static func pdd_sommet() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Sommet du Puy de Dôme"
        webcam.imageLD = "http://wwwobs.univ-bpclermont.fr/opgc/webcampdd.jpg"
        webcam.tags = [
            "puy de dome",
            "auvergne",
            "volcan"
        ]
        
        return webcam
    }
    
    fileprivate static func pdd_campus() -> Webcam {
        let webcam = Webcam()
        
        webcam.title = "Campus des Cézeaux"
        webcam.imageLD = "http://wwwobs.univ-bpclermont.fr/opgc/webcamcez.jpg"
        webcam.tags = [
            "puy de dome",
            "auvergne",
            "volcan"
        ]
        
        return webcam
    }
}
