//
//  WebcamCarouselTableViewCell.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit
import Kingfisher
import RealmSwift

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
    @IBOutlet var webcamCountArrowImageView: UIImageView!
    @IBOutlet var webcamTitleLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var weatherView: UIView!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    
    let portraitWidthRatio: CGFloat = 0.75
    let landscapeWidthRatio: CGFloat = 0.5
    
    var section: WebcamSection?
    var webcams: Results<Webcam>?
    
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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if let selectedWebcamView = carousel.currentItemView as? WebcamView {
            selectedWebcamView.isHighlighted = highlighted
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        section = nil
        webcams = nil
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
        webcams = item.sortedWebcams()
        
        // Configure Carousel
        carousel.delegate = self
        carousel.dataSource = self
        carousel.reloadData()
        
        // Configure header
        sectionImageView.image = item.image
        sectionTitleLabel.text = item.title?.uppercased()
        webcamTitleLabel.text = webcams?.first?.title
        webcamCountLabel.text = item.webcamCountLabel()
        
        // Configure Weather
        weatherView.alpha = 0
        
        let lastWeatherUpdate = item.lastWeatherUpdate?.timeIntervalSinceReferenceDate ?? 0
        let interval = Date().timeIntervalSinceReferenceDate - lastWeatherUpdate
        
        if interval < WebcamSection.weatherAcceptanceInterval  {
            displayWeather(for: item)
        }
        
        item.refreshWeatherIfNeeded { [weak self] section, error in
            if error == nil {
                self?.displayWeather(for: section)
            }
        }
    }
    
    func displayWeather(for section: WebcamSection) {
        weatherImageView.image = section.weatherImage()
        temperatureLabel.text = String(format: "%.0f°C", section.temperature)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: { [weak self] in
                self?.weatherView.alpha = 1
        },
            completion: nil)
    }
    
    func widthRatio() -> CGFloat {
        if UIApplication.shared.statusBarOrientation == .portrait {
            return portraitWidthRatio
        } else {
            return landscapeWidthRatio
        }
    }
    
    fileprivate func setWebcamCount(highlighted: Bool) {
        let color = highlighted ? UIColor.awBlue : UIColor.awLightGray
        
        webcamCountLabel.textColor = color
        webcamCountArrowImageView.image = webcamCountArrowImageView.image?.colorizedImage(withColor: color)
    }
    
    // MARK: - IBActions
    
    @IBAction func onSectionTouchedDragExit(_ sender: Any) {
        setWebcamCount(highlighted: false)
    }
    
    @IBAction func onSectionTouchedCancel(_ sender: Any) {
        setWebcamCount(highlighted: false)
    }
    
    @IBAction func onSectionTouchedDown(_ sender: Any) {
        setWebcamCount(highlighted: true)
    }
    
    @IBAction func onSectionTouched(_ sender: Any) {
        guard let section = section else { return }
        
        setWebcamCount(highlighted: false)
        delegate?.webcamCarousel(tableViewCell: self, didSelectSection: section)
    }
}

extension WebcamCarouselTableViewCell: iCarouselDelegate, iCarouselDataSource {
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        guard let webcams = webcams else { return }
        let webcam = webcams[index % webcams.count]
        
        delegate?.webcamCarousel(tableViewCell: self, didSelectWebcam: webcam)
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        guard let webcams = webcams else { return }
        let webcam = webcams[carousel.currentItemIndex % webcams.count]
        
        webcamTitleLabel.text = webcam.title
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        guard let webcams = webcams else { return 0 }
        
        // One element is managed by turning off the wrap option
        // Two elements /!\ needs the be doubled (prevent crash using modulo) to fill the circle rotary
        if webcams.count == 2 {
            return 4
        }
        
        // More than 2 elements are managed natively
        return webcams.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        guard let webcams = webcams else { return UIView() }

        var webcamView: WebcamView
        let webcam = webcams[index % webcams.count]
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
        let count = webcams?.count ?? 0
        
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
