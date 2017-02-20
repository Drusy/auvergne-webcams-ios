//
//  WebcamCarouselTableViewCell.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit
import Kingfisher

protocol WebcamCarouselTableViewCellDelegate: class {
    func webcamCarousel(tableViewCell: WebcamCarouselTableViewCell, didSelectSection section: WebcamSection)
    func webcamCarousel(tableViewCell: WebcamCarouselTableViewCell, didSelectWebcam webcam: Webcam)
}

class WebcamCarouselTableViewCell: UITableViewCell, ConfigurableCell {
    
    typealias ItemType = WebcamSection
    
    @IBOutlet var carousel: iCarousel!
    @IBOutlet var sectionImageView: UIImageView!
    @IBOutlet var sectionTitleLabel: UILabel!
    @IBOutlet var webcamCountLabel: UILabel!
    @IBOutlet var webcamTitleLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    
    let portraitWidthRatio: CGFloat = 0.75
    let landscapeWidthRatio: CGFloat = 0.5
    
    var section: WebcamSection?
    
    weak var delegate: WebcamCarouselTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        carousel.type = .rotary
        carousel.perspective = -0.0015
        carousel.decelerationRate = 0.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        section = nil
        delegate = nil
        
        carousel.delegate = nil
        carousel.dataSource = nil
    }
    
    // MARK: - ConfigurableCell
    
    static func identifier() -> String {
        return String(describing: WebcamCarouselTableViewCell.self)
    }
    
    func set(isLast last: Bool) {
        separatorView.isHidden = last
    }
    
    func set(delegate: WebcamCarouselTableViewCellDelegate?) {
        self.delegate = delegate
    }
    
    func configure(with item: ItemType) {
        layoutIfNeeded()
        carousel.layoutIfNeeded()
        
        section = item
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.reloadData()
        
        sectionImageView.image = item.image
        sectionTitleLabel.text = item.title?.uppercased()
        webcamTitleLabel.text = item.webcams.first?.title
        webcamCountLabel.text = item.webcamCountLabel()
    }
    
    func widthRatio() -> CGFloat {
        if UIApplication.shared.statusBarOrientation == .portrait {
            return portraitWidthRatio
        } else {
            return landscapeWidthRatio
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func onSectionTouched(_ sender: Any) {
        guard let section = section else { return }
        
        delegate?.webcamCarousel(tableViewCell: self, didSelectSection: section)
    }
}

extension WebcamCarouselTableViewCell: iCarouselDelegate, iCarouselDataSource {
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        guard let section = section else { return }
        let webcam = section.webcams[index % section.webcams.count]
        
        delegate?.webcamCarousel(tableViewCell: self, didSelectWebcam: webcam)
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        guard let section = section else { return }
        let webcam = section.webcams[carousel.currentItemIndex % section.webcams.count]
        
        webcamTitleLabel.text = webcam.title
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        guard let section = section else { return 0 }
        
        // One element is managed by turning off the wrap option
        // Two elements /!\ needs the be doubled (prevent crash using modulo) to fill the circle rotary
        if section.webcams.count == 2 {
            return 4
        }
        
        // More than 2 elements are managed natively
        return section.webcams.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        guard let section = section else { return UIView() }
        
        var webcamView: WebcamView
        let webcam = section.webcams[index % section.webcams.count]
        let width: CGFloat = UIScreen.main.bounds.width * widthRatio()
        let height: CGFloat = min(width * 0.55, carousel.bounds.height)
        
        if let view = view as? WebcamView {
            webcamView = view
        } else {
            webcamView = WebcamView.loadFromXib()
        }
        
        webcamView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        webcamView.configure(withWebcam: webcam)
        
        return webcamView
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        return UIScreen.main.bounds.width * widthRatio()
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        let count = section?.webcams.count ?? 0
        
        switch option {
        case .wrap:
            return count > 1 ? 1.0 : 0.0
        case .visibleItems:
            return 3.0
        case .count:
            return 3.0
        case .fadeMin:
            return -0.4
        case .fadeMax:
            return 0.4
        case .arc:
            if UIApplication.shared.statusBarOrientation == .portrait {
                return CGFloat(2 * M_PI)
            } else {
                return CGFloat(M_PI)
            }
            
        default:
            return value
        }
    }
}
