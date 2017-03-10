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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onFavoriteWebcamDidUpdate),
                                               name: Notification.Name.favoriteWebcamDidUpdate,
                                               object: nil)
        
        provider.itemSelectionHandler = { [weak self] webcam, indexPath in
            let webcamDetail = WebcamDetailViewController(webcam: webcam)
            self?.navigationController?.pushViewController(webcamDetail, animated: true)
        }
        
        update()
        AnalyticsManager.logEvent(showSection: section)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.favoriteWebcamDidUpdate,
                                                  object: nil)
    }
    
    // MARK: - Actions
    
    func onFavoriteWebcamDidUpdate(notification: Notification) {
        update()
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
        
        let webcams = Array(section.sortedWebcams())
        
        provider.section = section
        provider.objects = webcams
        
        if let navigationController = navigationController {
            if let index = navigationController.viewControllers.index(of: self), webcams.isEmpty {
                navigationController.viewControllers.remove(at: index)
            } else if !navigationController.viewControllers.contains(self), !webcams.isEmpty {
                navigationController.viewControllers.insert(self, at: 1)
            }
        }
    }
}
