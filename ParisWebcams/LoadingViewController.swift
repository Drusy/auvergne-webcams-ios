//
//  LoadingViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 28/03/2017.
//
//

import UIKit

class LoadingViewController: AbstractLoadingViewController {
    
    @IBOutlet weak var cloudOneImageView: UIImageView!
    @IBOutlet weak var cloudTwoImageView: UIImageView!
    @IBOutlet weak var sunImageView: UIImageView!
    
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
                self?.cloudOneImageView.transform = CGAffineTransform(translationX: 150, y: 0)
            },
            completion: nil)
        
        UIView.animate(
            withDuration: baseDuration / 1.25,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.cloudTwoImageView.transform = CGAffineTransform(translationX: -150, y: 0)
                self?.sunImageView.transform = CGAffineTransform(translationX: 25, y: -10).scaledBy(x: 0.7, y: 0.7)
                
            },
            completion: nil)
    }
}
