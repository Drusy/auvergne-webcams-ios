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
import MessageUI
import NVActivityIndicatorView

class WebcamDetailViewController: AbstractRefreshViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var brokenConnectionView: UIView!
    @IBOutlet var brokenCameraView: UIView!
    
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet var lastUpdateViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var lastUpdateView: UIView!

    @IBOutlet var nvActivityIndicatorView: NVActivityIndicatorView!
    @IBOutlet var lastUpdateLabel: UILabel!
    
    var lastZoomScale: CGFloat = -1
    var webcam: Webcam
    var isDataLoaded: Bool = false
    var shouldSetupInitialZoom: Bool = true
    var retryCount: Int = Webcam.retryCount
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh-icon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(forceRefresh))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDownloadManagerDidUpdateWebcam),
                                               name: Notification.Name.downloadManagerDidUpdateWebcam,
                                               object: nil)
        
        // Prepare indicator
        scrollView.layoutIfNeeded()
        scrollView.delegate = self
        
        brokenConnectionView.isHidden = true
        shareButton.isEnabled = false

        setupGestureRecognizer()
        updateLastUpdateLabel()
        refresh()
        
        AnalyticsManager.logEvent(showWebcam: webcam)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.downloadManagerDidUpdateWebcam,
                                                  object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let navigationController = navigationController {
            let navigationBarHeight = navigationController.navigationBar.bounds.height
            let navigationBarY = navigationController.navigationBar.frame.origin.y
            
            lastUpdateViewTopConstraint.constant = navigationBarY + navigationBarHeight
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
    
    // MARK: - IBActions
    
    @IBAction func onBrokenCameraTouched(_ sender: Any) {
        reportBrokenCamera()
    }
    
    @IBAction func onShareTouched(_ sender: Any) {
        let alertController = UIAlertController(title: title,
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
                                            AnalyticsManager.logEvent(button: "save_webcam")
        })
        
        let cancelAction = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(shareAction)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        if MFMailComposeViewController.canSendMail() {
            let reportAction = UIAlertAction(
                title: "Signaler un problème",
                style: .destructive,
                handler: { [weak self] _ in
                    self?.reportBrokenCamera()
                    
            })
            alertController.addAction(reportAction)
        }
        
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
        retryCount = Webcam.retryCount
        refresh(force: isReachable())
        AnalyticsManager.logEvent(button: "webcam_detail_refresh")
    }
    
    override func refresh(force: Bool = false) {
        if let image = webcam.preferredImage(), let url = URL(string: image) {
            var options: KingfisherOptionsInfo = []
            let currentContentOffset: CGPoint = scrollView.contentOffset
            
            if force {
                options.append(.forceRefresh)
            }
            
            brokenConnectionView.isHidden = true
            brokenCameraView.isHidden = true
            shareButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            isDataLoaded = false
            if !nvActivityIndicatorView.isAnimating {
                nvActivityIndicatorView.startAnimating()
            }
            nvActivityIndicatorView.isHidden = false
            
            imageView?.kf.setImage(
                with: url,
                placeholder: nil,
                options: options,
                progressBlock: nil) { [weak self] image, error, cacheType, url in
                    guard let strongSelf = self else { return }
                    
                    if let error = error {
                        print("ERROR: \(error.code) - \(error.localizedDescription)")
                        
                        if error.code != -999 && strongSelf.isReachable() {
                            
                            if strongSelf.retryCount > 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                                    guard let strongSelf = self else { return }
                                    
                                    print("Retrying to download \(url) ...")
                                    strongSelf.retryCount -= 1
                                    strongSelf.refresh(force: force)
                                }
                            } else {
                                strongSelf.nvActivityIndicatorView.stopAnimating()
                                strongSelf.nvActivityIndicatorView.isHidden = true
                                strongSelf.brokenCameraView.isHidden = false
                                strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
                            }
                        } else {
                            strongSelf.nvActivityIndicatorView.stopAnimating()
                            strongSelf.nvActivityIndicatorView.isHidden = true
                            strongSelf.brokenConnectionView.isHidden = false
                        }
                    } else {
                        strongSelf.retryCount = Webcam.retryCount
                        strongSelf.nvActivityIndicatorView.stopAnimating()
                        strongSelf.nvActivityIndicatorView.isHidden = true
                        strongSelf.shareButton.isEnabled = true
                        strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
                        strongSelf.isDataLoaded = true
                        strongSelf.updateZoom(andRestore: currentContentOffset)
                    }
            }
        }
    }
    
    override func style() {
        super.style()
        
        nvActivityIndicatorView.color = UIColor.white.withAlphaComponent(0.9)
//        nvActivityIndicatorView.color = UIColor.awLightGray
//        nvActivityIndicatorView.color = UIColor.awBlue
        nvActivityIndicatorView.type = .ballGridPulse
        
    }
    
    override func translate() {
        super.translate()
        
        title = webcam.title
    }
    
    override func update() {
        super.update()
    }
    
    // MARK: - Notification Center
    
    func onDownloadManagerDidUpdateWebcam(notification: Notification) {
        guard let webcam = notification.object as? Webcam, webcam == self.webcam else { return }
        
        updateLastUpdateLabel()
    }
    
    // MARK: -
    
    func reportBrokenCamera() {
        guard MFMailComposeViewController.canSendMail() else {
            let alertController = UIAlertController(title: self.title,
                                                    message: "Aucun compte email n'est configuré",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .cancel,
                                         handler: nil)
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let mailComposerVC = MailComposeViewController()
        let title = self.title ?? ""
        let attributes: [String : Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.proximaNovaSemiBold(withSize: 17)
        ]
        
        mailComposerVC.navigationBar.titleTextAttributes = attributes
        mailComposerVC.navigationBar.barStyle = .black
        mailComposerVC.navigationBar.isTranslucent = true
        mailComposerVC.navigationBar.tintColor = UIColor.white
        mailComposerVC.navigationBar.barTintColor = UIColor.black
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["auvergnewebcams@openium.fr"])
        mailComposerVC.setSubject("Signaler un problème - Webcam \(title)")
        mailComposerVC.setMessageBody("La webcam \(title) (\(webcam.uid)) ne fonctionne pas.",
            isHTML: false)
        
        present(mailComposerVC, animated: true, completion: nil)
        AnalyticsManager.logEvent(button: "report_webcam_error")
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        guard isDataLoaded == true else { return }
        let zoomOffset: CGFloat = (scrollView.maximumZoomScale - scrollView.minimumZoomScale) / 2

        if (scrollView.zoomScale == scrollView.minimumZoomScale || scrollView.zoomScale < zoomOffset) {
            let zoom = min(scrollView.maximumZoomScale, scrollView.zoomScale + zoomOffset)
            let pointInView = recognizer.location(in: imageView)
            
            let scrollViewSize = scrollView.bounds.size
            let width: CGFloat = scrollViewSize.width / zoom
            let height: CGFloat = scrollViewSize.height / zoom
            let originX: CGFloat = pointInView.x - (width / 2.0)
            let originY: CGFloat = pointInView.y - (height / 2.0)
            let rectToZoomTo = CGRect(x: originX,
                                      y: originY,
                                      width: width,
                                      height: height)
            
            scrollView.zoom(to: rectToZoomTo, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func updateConstraints() {
        guard let image = imageView.image else { return }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        let hPadding = max(0, (viewWidth - scrollView.zoomScale * imageWidth) / 2)
        let vPadding = max(0, (viewHeight - scrollView.zoomScale * imageHeight) / 2 + lastUpdateView.bounds.height)
        
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
    
    func updateZoom(andRestore contentOffset: CGPoint? = nil) {
        if let image = imageView.image {
            let scrollViewSize = scrollView.bounds.size
            let widthScale = scrollViewSize.width / image.size.width
            let heightScale = scrollViewSize.height / image.size.height
            let minZoom = min(1, min(widthScale, heightScale))

            scrollView.maximumZoomScale = 1
            scrollView.minimumZoomScale = minZoom
            
            if shouldSetupInitialZoom || scrollView.zoomScale < minZoom {
                scrollView.zoomScale = minZoom
            }
            
            if shouldSetupInitialZoom {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    let initialZoomScale: CGFloat
                    if UIApplication.shared.statusBarOrientation == .portrait {
                        initialZoomScale = max(strongSelf.scrollView.minimumZoomScale, max(widthScale, heightScale) / 2)
                    } else {
                        initialZoomScale = max(widthScale, heightScale)
                    }
                    
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
            } else if let contentOffset = contentOffset {
                scrollView.contentOffset = contentOffset
            }
            
            shouldSetupInitialZoom = false
        }
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension WebcamDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate

extension WebcamDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }
}
