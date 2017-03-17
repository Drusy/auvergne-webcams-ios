//
//  WebcamView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit

class WebcamViewPool {
    static let shared = WebcamViewPool()
    var pool = [WebcamView]()
    
    private init() {
        load(count: 20)
    }
    
    private func load(count: Int) {
        for _ in 1...20 {
            give(view: WebcamView.loadFromXib())
        }
    }
    
    func take() -> WebcamView {
        if pool.isEmpty {
            return WebcamView.loadFromXib()
        } else {
            return pool.removeFirst()
        }
    }
    
    func give(view: WebcamView) {
        pool.append(view)
    }
}

class WebcamView: AbstractWebcamView {
    
    class func loadFromXib() -> WebcamView {
        let views = Bundle.main.loadNibNamed(String(describing: WebcamView.self), owner: nil, options: nil)
        let webcamView = views?.first as? WebcamView ?? WebcamView()
        
        webcamView.applyShadow(opacity: 0.30,
                               radius: 5,
                               color: UIColor.black,
                               offset: CGSize(width: 1, height: 1),
                               shouldRasterize: true)
        
        return webcamView
    }
}
