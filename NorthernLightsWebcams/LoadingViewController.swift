//
//  LoadingViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 28/03/2017.
//
//

import UIKit

class LoadingViewController: AbstractLoadingViewController {

    @IBOutlet var starsImageView: UIImageView!
    @IBOutlet var reindeerImageView: UIImageView!
    @IBOutlet var moonImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateClouds()
    }
    
    // MARK: -
    
    func animateClouds() {
        let options: UIViewAnimationOptions = [.autoreverse, .curveEaseInOut, .repeat]
        let baseDuration: TimeInterval = 5
        
        UIView.animate(
            withDuration: baseDuration,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.moonImageView.transform = CGAffineTransform(translationX: 25, y: -15).scaledBy(x: 0.7, y: 0.7)
            },
            completion: nil)
        
        UIView.animate(
            withDuration: baseDuration / 2,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.starsImageView.alpha = 0.1
            },
            completion: nil)
    }
}
