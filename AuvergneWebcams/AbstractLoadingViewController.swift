//
//  LoadingViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit
import Crashlytics
import SwiftyUserDefaults

protocol LoadingViewControllerDelegate: class {
    func didFinishLoading(_: AbstractLoadingViewController)
}

class AbstractLoadingViewController: AbstractRealmViewController {
    
    weak var delegate: LoadingViewControllerDelegate?
    
    var loadingEnded = false
    var webcamQueryEnded = false
    
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet var cloudsCollectionImageViews: [UIImageView]!
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Defaults[.appOpenCount] += 1
        showClouds()
        
        #if DEBUG && true
            DownloadManager.shared.bootstrapRealmDevelopmentData()
            webcamQueryEnded = true
        #else
            refresh()
        #endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.loadingEnded = true
            self?.endLoading()
        }
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
    
    func refresh() {
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
                    QuickActionsService.shared.registerQuickActions()
                }
            }
            
            strongSelf.webcamQueryEnded = true
            strongSelf.endLoading()
        }
    }
    
    // MARK: - 
    
    fileprivate func endLoading() {
        guard loadingEnded && webcamQueryEnded else { return }
        
        loadingCompletion()
    }
    
    fileprivate func loadingCompletion() {
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
