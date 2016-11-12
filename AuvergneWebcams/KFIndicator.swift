//
//  KFIndicator.swift
//  AuvergneWebcams
//
//  Created by Drusy on 12/11/2016.
//
//

import UIKit
import Kingfisher

struct KFIndicator: Indicator {
    let view: UIView = UIActivityIndicatorView()
    
    func startAnimatingView() {
        guard let indicatorView = view as? UIActivityIndicatorView else { return }
        
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
    func stopAnimatingView() {
        guard let indicatorView = view as? UIActivityIndicatorView else { return }

        indicatorView.isHidden = true
        indicatorView.stopAnimating()
    }
    
    init(_ style: UIActivityIndicatorViewStyle) {
        if let indicatorView = view as? UIActivityIndicatorView {
            indicatorView.activityIndicatorViewStyle = style
        }
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
    }
}
