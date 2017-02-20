//
//  WebcamSectionViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit
import Kingfisher

class WebcamSectionViewController: AbstractRefreshViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var section: WebcamSection
    
    lazy var provider: WebcamSectionViewProvider = {
       return WebcamSectionViewProvider(collectionView: self.collectionView)
    }()
    
    init(section: WebcamSection) {
        self.section = section
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh-icon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(refresh))
        
        provider.section = section
        provider.objects = section.webcams
        provider.itemSelectionHandler = { [weak self] webcam, indexPath in
            let webcamDetail = WebcamDetailViewController(webcam: webcam)
            self?.navigationController?.pushViewController(webcamDetail, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }
    
    // MARK: -
    
    override func style() {
        super.style()
    }
    
    override func refresh(force: Bool) {
        if isReachable() {
            ImageCache.default.clearDiskCache()
            ImageCache.default.clearMemoryCache()
        }
        
        collectionView.reloadData()
        lastUpdate = NSDate().timeIntervalSinceReferenceDate
    }
    
    override func translate() {
        super.translate()
        
        title = section.title
    }
    
    override func update() {
        super.update()
    }
}
