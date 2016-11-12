//
//  ViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 07/11/2016.
//
//

import UIKit
import Kingfisher

class WebcamOverviewViewController: AbstractRefreshViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    var webcamProvider: WebcamsViewProvider?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-icon"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(onSettingsTouched))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh-icon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(refresh))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let objects = [
            Webcam.pddWebcams(),
            Webcam.sancyWebcams()
        ]
        
        let sections = [
            WebcamSection.pddSection(),
            WebcamSection.sancySection()
        ]
        
        webcamProvider = WebcamsViewProvider(collectionView: collectionView)
        webcamProvider?.set(objects: objects,
                            forSections: sections)
        webcamProvider?.itemSelectionHandler = { [weak self] webcam in
            let detail = WebcamDetailViewController(webcam: webcam)
            self?.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }
    
    // MARK: -
    
    override func refresh(force: Bool) {
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
        
        collectionView.reloadData()
        lastUpdate = NSDate().timeIntervalSinceReferenceDate
    }
    
    func onSettingsTouched() {
        
    }
    
    // MARK: -
    
    override func translate() {
        super.translate()
        
        title = "Auvergne Webcams"
    }
    
    override func update() {
        super.update()
    }
}

