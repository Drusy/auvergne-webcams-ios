//
//  ViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 07/11/2016.
//
//

import UIKit

class WebcamOverviewViewController: AbstractViewController {

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
                                                            action: #selector(onRefreshTouched))
        
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
    
    // MARK: - 
    
    func onRefreshTouched() {
        
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

