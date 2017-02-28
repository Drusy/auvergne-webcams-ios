//
//  LoadingViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit
import Crashlytics

protocol LoadingViewControllerDelegate: class {
    func didFinishLoading(_: LoadingViewController)
}

class LoadingViewController: AbstractRealmViewController {

    @IBOutlet weak var loadingImageView: UIImageView!
    
    @IBOutlet var cloudsCollectionImageViews: [UIImageView]!
    @IBOutlet weak var cloudOneImageView: UIImageView!
    @IBOutlet weak var cloudTwoImageView: UIImageView!
    @IBOutlet weak var cloudThreeImageView: UIImageView!
    @IBOutlet weak var cloudFourImageView: UIImageView!
    @IBOutlet weak var cloudFiveImageView: UIImageView!
    @IBOutlet weak var cloudSixImageView: UIImageView!
    @IBOutlet weak var cloudSevenImageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    weak var delegate: LoadingViewControllerDelegate?
    
    var loadingEnded = false
    var webcamQueryEnded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showClouds()
        animateClouds()
        refresh()
    }
    
    // MARK: -
    
    func showClouds() {
        cloudsCollectionImageViews.forEach { cloudImageView in
            cloudImageView.applyShadow(opacity: 0.15,
                                       radius: 2,
                                       color: UIColor.black,
                                       offset: CGSize(width: 1, height: 1))
            cloudImageView.alpha = 0.0
        }
        
        UIView.animate(
            withDuration: 1,
            delay: 0,
            options: [],
            animations: { [weak self] in
                self?.cloudsCollectionImageViews.forEach { cloudImageView in
                    cloudImageView.alpha = 1.0
                }
            },
            completion: nil)
    }
    
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
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.loadingEnded = true
            self?.endLoading()
        }
        
        ApiRequest.startQuery(forType: WebcamSectionResponse.self, parameters: nil) { [weak self] response in
            guard let strongSelf = self else { return }
            
            if let error = response.error {
                Crashlytics.sharedInstance().recordError(error)
                print(error.localizedDescription)
            } else if let webcamSectionResponse = response.result.value {
                // Delete all sections & webcams
                let sections = strongSelf.realm.objects(WebcamSection.self)
                let webcams = strongSelf.realm.objects(Webcam.self)
                
                try! strongSelf.realm.write {
                    strongSelf.realm.delete(sections)
                    strongSelf.realm.delete(webcams)
                    
                    strongSelf.realm.add(webcamSectionResponse.sections, update: true)
                }
            }
            
            strongSelf.webcamQueryEnded = true
            strongSelf.endLoading()
        }
    }
    
    // MARK: - 
    
    fileprivate func endLoading() {
        guard loadingEnded && webcamQueryEnded else { return }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: { [weak self] in
                self?.cloudsCollectionImageViews.forEach { cloudImageView in
                    cloudImageView.alpha = 0.0
                }
                self?.loadingLabel.alpha = 0.0
        },
            completion: { [weak self] finished in
                guard let strongSelf = self else { return }
                
                strongSelf.delegate?.didFinishLoading(strongSelf)
        })
    }
}
