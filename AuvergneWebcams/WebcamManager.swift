//
//  WebcamManager.swift
//  AuvergneWebcams
//
//  Created by Drusy on 15/02/2018.
//

import Foundation
import RealmSwift

class WebcamManager {
    static let shared = WebcamManager()
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    private init() {
        
    }
    
    // MARK: -
    
    func favoriteWebcams() -> Results<Webcam> {
        return realm.objects(Webcam.self)
            .filter("%K = true AND %K = false", #keyPath(Webcam.favorite), #keyPath(Webcam.isHidden))
            .sorted(byKeyPath: #keyPath(Webcam.title), ascending: true)
    }
    
    func webcams() -> Results<Webcam> {
        return realm.objects(Webcam.self)
            .filter("%K = false", #keyPath(Webcam.isHidden))
            .sorted(byKeyPath: #keyPath(Webcam.order), ascending: true)
    }
}
