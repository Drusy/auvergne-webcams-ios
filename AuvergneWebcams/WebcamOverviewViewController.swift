//
//  ViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 07/11/2016.
//
//

import UIKit
import Kingfisher

class WebcamOverviewViewController: AbstractViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    var webcamProvider: WebcamsViewProvider?
    var refreshTimer: Timer?
    var lastUpdate: TimeInterval?

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTimer = Timer.scheduledTimer(timeInterval: Webcam.refreshInterval,
                                            target: self,
                                            selector: #selector(refresh),
                                            userInfo: nil,
                                            repeats: true)
        
        let now = NSDate().timeIntervalSinceReferenceDate
        if let lastUpdate = lastUpdate {
            let interval = now - lastUpdate
            if interval > Webcam.refreshInterval {
                refresh()
            }
        } else {
            lastUpdate = now
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTimer?.invalidate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }
    
    // MARK: -
    
    func refresh() {
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

