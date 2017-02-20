//
//  WebcamDetailViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit
import Kingfisher
import Reachability
import SwiftyUserDefaults

class WebcamDetailViewController: AbstractRefreshViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var brokenConnectionView: UIView!
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet var lastUpdateViewTopConstraint: NSLayoutConstraint!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var lastUpdateLabel: UILabel!
    
    var lastZoomScale: CGFloat = -1
    var webcam: Webcam
    var isDataLoaded: Bool = false
    
    init(webcam: Webcam) {
        self.webcam = webcam
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        view.bounds = UIScreen.main.bounds
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "refresh-icon"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(forceRefresh))
        
        // Prepare indicator
        scrollView.layoutIfNeeded()
        scrollView.delegate = self
        
        brokenConnectionView.isHidden = true
        shareButton.isEnabled = false

        setupGestureRecognizer()
        updateLastUpdateLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load image
        refresh()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let navigationController = navigationController {
            var height = navigationController.navigationBar.bounds.height
            
            if !UIApplication.shared.isStatusBarHidden {
                height += UIApplication.shared.statusBarFrame.height
            }
            
            lastUpdateViewTopConstraint.constant = height
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let transition: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            self?.updateZoom()
        }
        
        coordinator.animate(alongsideTransition: transition,
                            completion: nil)
    }
    
    // MARK: - 
    
    @IBAction func onShareTouched(_ sender: Any) {
        let alertController = UIAlertController(title: self.title,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let shareAction = UIAlertAction(title: "Partager",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                guard let strongSelf = self else { return }
                                                
                                                strongSelf.share(strongSelf.title,
                                                                 image: strongSelf.imageView.image,
                                                                 fromView: strongSelf.shareButton)
        })
        
        let saveAction = UIAlertAction(title: "Sauvegarder",
                                          style: .default,
                                          handler: { [weak self] _ in
                                            guard let strongSelf = self else { return }
                                            guard let image = self?.imageView.image else { return }

                                            UIImageWriteToSavedPhotosAlbum(image,
                                                                           strongSelf,
                                                                           #selector(strongSelf.image(_:didFinishSavingWithError:contextInfo:)),
                                                                           nil)
        })
        
        let cancelAction = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(shareAction)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = shareButton
        
        present(alertController, animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        if let error = error {
            let ac = UIAlertController(title: "Erreur",
                                       message: error.localizedDescription,
                                       preferredStyle: .alert)
            ac.addAction(okAction)
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: title,
                                       message: "Image sauvegardée dans la bibliothèque",
                                       preferredStyle: .alert)
            ac.addAction(okAction)
            present(ac, animated: true)
        }
    }
    
    func forceRefresh() {
        refresh(force: isReachable())
    }
    
    override func refresh(force: Bool = false) {
        if let image = webcam.preferedImage(), let url = URL(string: image) {
            let options: KingfisherOptionsInfo = force ? [.forceRefresh] : []
            
            brokenConnectionView.isHidden = true
            shareButton.isEnabled = false
            isDataLoaded = false

            activityIndicator.startAnimating()
            imageView?.kf.setImage(with: url,
                                   placeholder: nil,
                                   options: options,
                                   progressBlock: nil) { [weak self] image, error, cacheType, url in
                                    guard let strongSelf = self else { return }
                                    
                                    if let error = error {
                                        print("ERROR: \(error.code) - \(error.localizedDescription)")
                                        
                                        if error.code != -999 && strongSelf.isReachable() {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                                                guard let strongSelf = self else { return }

                                                print("Retrying to download \(url) ...")
                                                strongSelf.refresh(force: force)
                                            }
                                        } else {
                                            strongSelf.webcam.lastUpdate = Date()
                                            strongSelf.updateLastUpdateLabel()
                                            strongSelf.activityIndicator.stopAnimating()
                                            strongSelf.brokenConnectionView.isHidden = false
                                        }
                                    } else {
                                        strongSelf.webcam.lastUpdate = Date()
                                        strongSelf.updateLastUpdateLabel()
                                        strongSelf.activityIndicator.stopAnimating()
                                        strongSelf.shareButton.isEnabled = true
                                        strongSelf.isDataLoaded = true
                                        strongSelf.updateZoom()
                                    }
            }
        }
    }
    
    override func translate() {
        super.translate()
        
        title = webcam.title
    }
    
    override func update() {
        super.update()
    }
    
    // MARK: -
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        guard isDataLoaded == true else { return }
        
        if (scrollView.zoomScale == scrollView.maximumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let offset: CGFloat = (scrollView.maximumZoomScale - scrollView.minimumZoomScale) / 4
            let zoom = min(scrollView.maximumZoomScale, scrollView.zoomScale + offset)
            
            scrollView.setZoomScale(zoom, animated: true)
        }
    }
    
    func updateConstraints() {
        guard let image = imageView.image else { return }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        let hPadding = max(0, (viewWidth - scrollView.zoomScale * imageWidth) / 2)
        let vPadding = max(0, (viewHeight - scrollView.zoomScale * imageHeight) / 2)
        
        imageConstraintLeft.constant = hPadding
        imageConstraintRight.constant = hPadding
        
        imageConstraintTop.constant = vPadding
        imageConstraintBottom.constant = vPadding
        
        scrollView.layoutIfNeeded()
        view.layoutIfNeeded()
    }
    
    func updateLastUpdateLabel() {
        if let date = webcam.lastUpdate {
            let dateFormatter = DateFormatterCache.shared.dateFormatter(withFormat: "'Mise à jour le' dd.MM.YY à HH'h'mm")
            lastUpdateLabel.text = dateFormatter.string(from: date)
        } else {
            lastUpdateLabel.text = nil
        }
    }
    
    func updateZoom() {
        if let image = imageView.image {
            let scrollViewSize = scrollView.bounds.size
            let widthScale = scrollViewSize.width / image.size.width
            let heightScale = scrollViewSize.height / image.size.height
            let minZoom = min(1, min(widthScale, heightScale))

            scrollView.maximumZoomScale = 1
            scrollView.minimumZoomScale = minZoom
            scrollView.zoomScale = minZoom
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                
                let initialZoomScale = max(widthScale, heightScale)
                if initialZoomScale <= strongSelf.scrollView.maximumZoomScale &&
                   initialZoomScale >= strongSelf.scrollView.minimumZoomScale {
                    
                    UIView.animate(withDuration: 1,
                                   delay: 0,
                                   options: .beginFromCurrentState,
                                   animations: { [weak self] in
                                    guard let strongSelf = self else { return }

                                    strongSelf.scrollView.setZoomScale(initialZoomScale, animated: false)
                        },
                                   completion: nil)
                    strongSelf.lastZoomScale = minZoom
                }
            }
        }
    }
}

extension WebcamDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }
}
