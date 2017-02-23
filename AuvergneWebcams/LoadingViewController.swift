//
//  LoadingViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit

protocol LoadingViewControllerDelegate: class {
    func didFinishLoading(_: LoadingViewController)
}

class LoadingViewController: AbstractViewController {

    @IBOutlet var loadingImageView: UIImageView!
    
    weak var delegate: LoadingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    // MARK: -
    
    func refresh() {
        loadingImageView.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.endLoading()
        }
    }
    
    // MARK: - 
    
    fileprivate func endLoading() {
        delegate?.didFinishLoading(self)
    }
}
