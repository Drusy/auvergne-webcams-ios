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
    
    override func translate() {
        super.translate()
        
        title = "Auvergne Webcams"
    }
    
    override func update() {
        super.update()
    }
}

