//
//  WebcamView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit

class WebcamView: AbstractWebcamView {
    
    class func loadFromXib() -> WebcamView {
        let views = Bundle.main.loadNibNamed(String(describing: WebcamView.self), owner: nil, options: nil)
        let webcamView = views?.first as? WebcamView ?? WebcamView()
        
        webcamView.applyShadow(opacity: 0.35,
                               radius: 6,
                               color: UIColor.black,
                               offset: CGSize(width: 1, height: 1))
        
        return webcamView
    }
}
