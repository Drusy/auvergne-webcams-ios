//
//  LoadingViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 28/03/2017.
//
//

import UIKit

class LoadingViewController: AbstractLoadingViewController {
    
    @IBOutlet var cloudOneImageView: UIImageView!
    @IBOutlet var cloudTwoImageView: UIImageView!
    @IBOutlet var cloudThreeImageView: UIImageView!
    @IBOutlet var cloudFourImageView: UIImageView!
    @IBOutlet var cloudFiveImageView: UIImageView!
    @IBOutlet var cloudSixImageView: UIImageView!
    @IBOutlet var cloudSevenImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateClouds()
    }
    
    // MARK: -
    
    func animateClouds() {
        let options: UIViewAnimationOptions = [.autoreverse, .curveEaseInOut, .repeat]
        let baseDuration: TimeInterval = 12
        
        UIView.animate(
            withDuration: baseDuration,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.cloudOneImageView.transform = CGAffineTransform(translationX: 100, y: 0)
                self?.cloudFiveImageView.transform = CGAffineTransform(translationX: -100, y: 0)
            },
            completion: nil)
        
        UIView.animate(
            withDuration: baseDuration / 1.25,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.cloudTwoImageView.transform = CGAffineTransform(translationX: 150, y: 0)
                self?.cloudSixImageView.transform = CGAffineTransform(translationX: -150, y: 0)
                
            },
            completion: nil)
    }
}
