//
//  WebcamCollectionViewCell.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit

class WebcamCollectionViewCell: UICollectionViewCell, ConfigurableCell {
    typealias ItemType = Webcam
    
    let webcamView = WebcamSectionedView.loadFromXib()
    
    override var isHighlighted: Bool {
        didSet {
            webcamView.isHighlighted = isHighlighted
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(webcamView)
        fit(toSubview: webcamView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        webcamView.reset()
    }
    
    // MARK: - 
    
    static func identifier() -> String {
        return String(describing: WebcamCollectionViewCell.self)
    }
    
    func configure(with item: ItemType) {
        webcamView.configure(withWebcam: item)
    }
}
