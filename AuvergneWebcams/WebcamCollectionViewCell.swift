//
//  WebcamCollectionViewCell.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit
import Kingfisher
import SwiftyUserDefaults

class WebcamCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var blurView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(style),
                                               name: NSNotification.Name(rawValue: SettingsViewController.kSettingsDidUpdateTheme),
                                               object: nil)
        style()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: SettingsViewController.kSettingsDidUpdateTheme),
                                                  object: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

//        imageView.kf.cancelDownloadTask()
//        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.kf.indicator?.view.layoutIfNeeded()
    }
}

extension WebcamCollectionViewCell: ConfigurableCell {
    typealias ItemType = Webcam
    
    static func identifier() -> String {
        return String(describing: WebcamCollectionViewCell.self)
    }
    
    static func nibName() -> String {
        return String(describing: WebcamCollectionViewCell.self)
    }
    
    func configure(with item: Webcam) {
        if let image = item.preferedImage(), let url = URL(string: image) {
            imageView.kf.setImage(with: url) { [weak self] (image, error, cacheType, imageUrl) in
                if let error = error {
                    print("ERROR: \(error.code) - \(error.localizedDescription)")
                    
                    if error.code != -999 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            print("Retrying to download \(imageUrl) ...")
                            self?.configure(with: item)
                        }
                    }
                }
            }
        }
    
        titleLabel.text = item.title
    }
    
    func style() {
        let style: UIActivityIndicatorViewStyle
        backgroundColor = ThemeUtils.backgroundColor()
//        titleLabel.textColor = ThemeUtils.tintColor()
        
        if Defaults[.isDarkTheme] {
            style = .white
            blurView.effect = UIBlurEffect(style: .dark)
        } else {
            style = .gray
            blurView.effect = UIBlurEffect(style: .light)
        }
        
        let indicator = KFIndicator(style)
        imageView.kf.indicatorType = .custom(indicator: indicator)
    }
}
