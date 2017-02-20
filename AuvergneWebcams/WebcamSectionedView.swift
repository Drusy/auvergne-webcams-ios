//
//  WebcamSectionedView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit


class WebcamSectionedView: AbstractWebcamView {
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var webcamTitleLabel: UILabel!
    
    class func loadFromXib() -> WebcamSectionedView {
        let views = Bundle.main.loadNibNamed(String(describing: WebcamSectionedView.self), owner: nil, options: nil)
        let webcamView = views?.first as? WebcamSectionedView ?? WebcamSectionedView()
        
        return webcamView
    }

    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.applyShadow(opacity: 0.35,
                               radius: 6,
                               color: UIColor.black,
                               offset: CGSize(width: 1, height: 1))
    }
    
    override func configure(withWebcam webcam: Webcam) {
        super.configure(withWebcam: webcam)
        
        webcamTitleLabel.text = webcam.title
    }
}
