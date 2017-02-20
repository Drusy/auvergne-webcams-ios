//
//  AbstractWebcamView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit
import Reachability

class AbstractWebcamView: UIView {
    
    @IBOutlet var noDataView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.kf.indicatorType = .custom(indicator: KFIndicator(.white))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.kf.indicator?.view.layoutIfNeeded()
    }
    
    
    // MARK: -
    
    func configure(withWebcam webcam: Webcam) {
        noDataView.isHidden = true
        
        if let image = webcam.preferedImage(), let url = URL(string: image) {
            noDataView.isHidden = true
            
            imageView.kf.setImage(with: url) { [weak self] (image, error, cacheType, imageUrl) in
                if let error = error {
                    print("ERROR: \(error.code) - \(error.localizedDescription)")
                    
                    let reachability = Reachability()
                    let isReachable = (reachability == nil || (reachability != nil && reachability!.isReachable))
                    
                    if error.code != -999 && isReachable {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            print("Retrying to download \(imageUrl) ...")
                            self?.configure(withWebcam: webcam)
                        }
                    } else {
                        webcam.lastUpdate = Date()
                        self?.noDataView.isHidden = false
                    }
                } else {
                    webcam.lastUpdate = Date()
                }
            }
        } else {
            imageView.image = nil
        }
    }
}
