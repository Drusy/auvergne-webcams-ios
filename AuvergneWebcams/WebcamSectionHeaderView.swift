//
//  WebcamSectionHeaderView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

class WebcamSectionHeaderView: UICollectionReusableView {

    @IBOutlet var leftSectionIcon: UIImageView!
    @IBOutlet var rightSectionIcon: UIImageView!
    @IBOutlet var sectionTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: -
    
    static func identifier() -> String {
        return String(describing: WebcamSectionHeaderView.self)
    }
    
    static func nibName() -> String {
        return String(describing: WebcamSectionHeaderView.self)
    }
    
    func configure(with item: WebcamSection, atIndexPath indexPath: IndexPath) {
        let evenSection: Bool = (indexPath.section % 2) == 0

        sectionTitle.text = item.title?.uppercased()
        sectionTitle.textAlignment = evenSection ? .left : .right
        
        leftSectionIcon.isHidden = !evenSection
        rightSectionIcon.isHidden = evenSection
        
        leftSectionIcon.image = item.image
        rightSectionIcon.image = item.image
    }
}
