//
//  WebcamSectionHeaderView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit

class WebcamSectionHeaderView: UICollectionReusableView {

    @IBOutlet var sectionImageView: UIImageView!
    @IBOutlet var sectionTitleLabel: UILabel!
    @IBOutlet var webcamCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
 
    static func identifier() -> String {
        return String(describing: WebcamSectionHeaderView.self)
    }
    
    // MARK: - 
    
    func configure(withSection section: WebcamSection) {
        sectionImageView.image = section.image
        sectionTitleLabel.text = section.title?.uppercased()
        webcamCountLabel.text = section.webcamCountLabel()
    }
}
