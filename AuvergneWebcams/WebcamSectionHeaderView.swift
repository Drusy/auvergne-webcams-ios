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
    @IBOutlet var weatherView: UIView!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherViewWidthConstraint: NSLayoutConstraint! {
        didSet {
            weatherViewInitialWidth = weatherViewWidthConstraint.constant
        }
    }
    
    fileprivate var weatherViewInitialWidth: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
     
    static func identifier() -> String {
        return String(describing: WebcamSectionHeaderView.self)
    }
    
    // MARK: - 
    
    func configure(withSection section: WebcamSection) {
        // Configure Header
        sectionImageView.image = section.image
        sectionTitleLabel.text = section.title?.uppercased()
        webcamCountLabel.text = section.webcamCountLabel()
        
        // Configure Weather
        weatherView.alpha = 0
        weatherViewWidthConstraint.constant = 0
        
        let lastWeatherUpdate = section.lastWeatherUpdate?.timeIntervalSinceReferenceDate ?? 0
        let interval = Date().timeIntervalSinceReferenceDate - lastWeatherUpdate
        
        if interval < WebcamSection.weatherAcceptanceInterval  {
            displayWeather(for: section)
        }
        
        section.refreshWeatherIfNeeded { [weak self] section, error in
            if error == nil {
                self?.displayWeather(for: section)
            }
        }
    }
    
    func displayWeather(for section: WebcamSection) {
        weatherImageView.image = section.weatherImage()
        temperatureLabel.text = String(format: "%.0f°C", section.temperature)
        weatherViewWidthConstraint.constant = weatherViewInitialWidth
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: { [weak self] in
                self?.weatherView.alpha = 1
            },
            completion: nil)
    }
}
