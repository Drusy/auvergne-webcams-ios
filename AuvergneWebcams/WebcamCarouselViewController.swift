//
//  WebcamCarouselViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit
import Kingfisher
import RealmSwift
import StoreKit
import SwiftyUserDefaults

protocol WebcamCarouselViewProviderDelegate: class {
    func webcamCarousel(viewProvider: WebcamCarouselViewProvider, scrollViewDidScroll scrollView: UIScrollView)
}

class WebcamCarouselViewProvider: AbstractArrayViewProvider<WebcamSection, WebcamCarouselTableViewCell> {
    weak var delegate: WebcamCarouselViewProviderDelegate?
    
    @objc func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 450
        } else {
            return 320
        }
    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.webcamCarousel(viewProvider: self, scrollViewDidScroll: scrollView)
    }
}

protocol WebcamCarouselViewControllerDelegate: class {
    func webcamCarouselDidTriggerSettings(viewController: WebcamCarouselViewController)
}

class WebcamCarouselViewController: AbstractRefreshViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    
    lazy var provider: WebcamCarouselViewProvider = {
        let provider = WebcamCarouselViewProvider(tableView: self.tableView)
        provider.delegate = self
        return provider
    }()
    
    weak var delegate: WebcamCarouselViewControllerDelegate?
    var shortcutItem: UIApplicationShortcutItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings-icon"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(onSettingsTouched))
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh-icon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onRefreshTouched))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onFavoriteWebcamDidUpdate),
                                               name: Notification.Name.favoriteWebcamDidUpdate,
                                               object: nil)
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        provider.additionalCellConfigurationCustomizer = { [weak self](cell: WebcamCarouselTableViewCell, item: WebcamSection) in
            guard let lastObject = self?.provider.objects?.last else { return }
            
            cell.set(isLast: item == lastObject)
            cell.set(delegate: self)
        }
        
        update()
        
        if let item = shortcutItem, let navigationController = navigationController {
            QuickActionsService.shared.performActionFor(shortcutItem: item, for: navigationController)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if Defaults[.cameraDetailCount] >= 4 && Defaults[.appOpenCount] >= 2 {
            if #available(iOS 10.3, *){
                Defaults[.cameraDetailCount] = 0
                Defaults[.appOpenCount] = 0
                
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let transition: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        coordinator.animate(alongsideTransition: transition,
                            completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.favoriteWebcamDidUpdate,
                                                  object: nil)
    }
    
    // MARK: -
    
    override func refresh(force: Bool = false) {
        if isReachable() {
            ImageCache.default.clearDiskCache()
            ImageCache.default.clearMemoryCache()
        }
        
        tableView.reloadData()
        lastUpdate = NSDate().timeIntervalSinceReferenceDate
    }
    
    override func translate() {
        super.translate()
        
        title = Configuration.applicationName
        
        searchTextField.attributedPlaceholder = "Rechercher une webcam"
            .withFont(UIFont.proximaNovaLightItalic(withSize: 16))
            .withTextColor(UIColor.awLightGray)
    }
    
    override func update() {
        super.update()
        
        let sections = realm.objects(WebcamSection.self)
            .filter("webcams.@count > 0")
            .sorted(byKeyPath: #keyPath(WebcamSection.order), ascending: true)
        var sectionsArray = Array(sections)
        let favoriteWebcams = WebcamManager.shared.favoriteWebcams()
        
        if !favoriteWebcams.isEmpty {
            let favoriteSection = FavoriteWebcamSection()
            
            favoriteSection.uid = -1
            favoriteSection.order = -1
            favoriteSection.title = "Favoris"
            favoriteSection.imageName = "favorite-landscape"
            favoriteSection.favoriteWebcams = favoriteWebcams
            
            sectionsArray.insert(favoriteSection, at: 0)
        }
        
        provider.objects = sectionsArray
    }
    
    // MARK: - IBActions
    
    @objc func onFavoriteWebcamDidUpdate(notification: Notification) {
        update()
    }
    
    @objc func onRefreshTouched() {
        refresh()
        AnalyticsManager.logEvent(button: "home_refresh")
    }
    
    @objc func onSettingsTouched() {
        delegate?.webcamCarouselDidTriggerSettings(viewController: self)
    }
    
    @IBAction func onSearchTouched(_ sender: Any) {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
        AnalyticsManager.logEvent(button: "search")
    }
    
    @objc func onMapTouched() {
        let mapVC = MapViewController(webcams: WebcamManager.shared.webcams(), subtitle: title)
        navigationController?.pushViewController(mapVC, animated: true)
        AnalyticsManager.logEvent(button: "home_map")
    }
}

// MARK: - WebcamCarouselViewProviderDelegate

extension WebcamCarouselViewController: WebcamCarouselViewProviderDelegate {
    func webcamCarousel(viewProvider: WebcamCarouselViewProvider, scrollViewDidScroll scrollView: UIScrollView) {

    }
}

// MARK: - WebcamCarouselTableViewCellDelegate

extension WebcamCarouselViewController: WebcamCarouselTableViewCellDelegate {
    func webcamCarousel(tableViewCell: WebcamCarouselTableViewCell, didSelectWebcam webcam: Webcam) {
        let webcamDetail = WebcamDetailViewController(webcam: webcam)
        navigationController?.pushViewController(webcamDetail, animated: true)
    }
    
    func webcamCarousel(tableViewCell: WebcamCarouselTableViewCell, didSelectSection section: WebcamSection) {
        let sectionDetail = WebcamSectionViewController(section: section)
        navigationController?.pushViewController(sectionDetail, animated: true)
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension WebcamCarouselViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let pointConverted = tableView.convert(location, from: view)
        
        if let indexPath = tableView.indexPathForRow(at: pointConverted) {
            
            previewingContext.sourceRect = view.convert(tableView.rectForRow(at: indexPath), from: tableView)
            
            let cell: WebcamCarouselTableViewCell = tableView.cellForRow(at: indexPath) as! WebcamCarouselTableViewCell
            let locationInCell = view.convert(location, to: cell.contentView)
            if locationInCell.y <= cell.headerView.frame.size.height {
                if let section = cell.section {
                    return WebcamSectionViewController(section: section)
                }
            } else {
                if let webcams = cell.webcams {
                    if webcams.count > 0 {
                        if let webcam = webcams[safe: (cell.carousel.currentItemIndex % webcams.count)] {
                            let detail = WebcamDetailViewController(webcam: webcam)
                            detail.initiatingPreviewActionController = self
                            return detail
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
