//
//  WebcamCarouselViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 19/02/2017.
//
//

import UIKit
import Kingfisher

protocol WebcamCarouselViewProviderDelegate: class {
    func webcamCarousel(viewProvider: WebcamCarouselViewProvider, scrollViewDidScroll scrollView: UIScrollView)
}

class WebcamCarouselViewProvider: AbstractRealmResultsViewProvider<WebcamSection, WebcamCarouselTableViewCell> {
    weak var delegate: WebcamCarouselViewProviderDelegate?
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 450
        } else {
            return 320
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.webcamCarousel(viewProvider: self, scrollViewDidScroll: scrollView)
    }
}

class WebcamCarouselViewController: AbstractRefreshViewController {
    
    @IBOutlet var clearSearchButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var loadingAnimationView: UIView!
    @IBOutlet var loadingAnimationImageView: UIImageView!
    
    lazy var provider: WebcamCarouselViewProvider = {
        let provider = WebcamCarouselViewProvider(tableView: self.tableView)
        provider.delegate = self
        return provider
    }()
    
    var isFirstAppear: Bool = true

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
        
        clearSearchButton.isHidden = true
        
        provider.objects = realm.objects(WebcamSection.self).sorted(byKeyPath: #keyPath(WebcamSection.order), ascending: true)
        provider.additionalCellConfigurationCustomizer = { [weak self](cell: WebcamCarouselTableViewCell, item: WebcamSection) in
            guard let lastObject = self?.provider.objects?.last else { return }
            
            cell.set(isLast: item == lastObject)
            cell.set(delegate: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstAppear {
            isFirstAppear = false
            
            startShowAnimation()
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
    
    // MARK: -
    
    func startShowAnimation() {
        loadingAnimationView.alpha = 1
        
        view.layoutIfNeeded()
        loadingAnimationView.layoutIfNeeded()
        loadingAnimationImageView.layoutIfNeeded()
        
        navigationController?.view.layer.mask = CALayer()
        navigationController?.view.layer.mask?.contents = loadingAnimationImageView.image!.cgImage
        navigationController?.view.layer.mask?.bounds = loadingAnimationImageView.bounds
        navigationController?.view.layer.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        navigationController?.view.layer.mask?.position = CGPoint(x: view.frame.width / 2,
                                                                  y: view.frame.height / 2)
        
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        let initalBounds = NSValue(cgRect: loadingAnimationImageView.bounds)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0,
                                                  width: loadingAnimationImageView.bounds.width * 0.9,
                                                  height: loadingAnimationImageView.bounds.height * 0.9))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0,
                                                 width: loadingAnimationImageView.bounds.width * 5,
                                                 height: loadingAnimationImageView.bounds.height * 5))
        
        transformAnimation.duration = 1
        transformAnimation.delegate = self
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        transformAnimation.fillMode = kCAFillModeForwards
        transformAnimation.isRemovedOnCompletion = false
        
        navigationController?.view.layer.mask?.add(transformAnimation, forKey: transformAnimation.keyPath)
        loadingAnimationImageView.layer.add(transformAnimation, forKey: transformAnimation.keyPath)
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.35,
            options: .curveEaseIn,
            animations: { [weak self] in
                self?.loadingAnimationView.alpha = 0.0
            },
            completion: nil)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0.3,
            options: [],
            animations: { [weak self] in
                self?.navigationController?.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            },
            completion: { [weak self] finished in
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               options: UIViewAnimationOptions.curveEaseInOut,
                               animations: {
                                self?.navigationController?.view.transform = .identity
                },
                               completion: nil)
        })
    }
    
    override func style() {
        super.style()
    }
    
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
        
        title = "Auvergne Webcams"
        searchTextField.attributedPlaceholder = "Rechercher une webcam"
            .withFont(UIFont.proximaNovaLightItalic(withSize: 16))
            .withTextColor(UIColor.awLightGray)
    }
    
    override func update() {
        super.update()
    }
    
    // MARK: - IBActions
    
    func onRefreshTouched() {
        refresh()
        AnalyticsManager.logEvent(button: "home_refresh")
    }
    
    func onSettingsTouched() {
        let settingsVC = SettingsViewController()
        let navigationVC = NavigationController(rootViewController: settingsVC)
        
        navigationVC.modalPresentationStyle = .overCurrentContext
        
        present(navigationVC, animated: true, completion: nil)
        AnalyticsManager.logEvent(button: "settings")
    }
    
    @IBAction func onSearchTouched(_ sender: Any) {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
        AnalyticsManager.logEvent(button: "search")
    }
}

// MARK: - WebcamCarouselViewProviderDelegate

extension WebcamCarouselViewController: WebcamCarouselViewProviderDelegate {
    func webcamCarousel(viewProvider: WebcamCarouselViewProvider, scrollViewDidScroll scrollView: UIScrollView) {
        if searchTextField.isEditing {
            searchTextField.endEditing(true)
        }
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

// MARK: - CAAnimationDelegate

extension WebcamCarouselViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        navigationController?.view.layer.mask = nil
    }
}
