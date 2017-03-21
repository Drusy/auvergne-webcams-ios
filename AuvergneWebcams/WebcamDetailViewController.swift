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
import DOFavoriteButton
import Alamofire
import AVFoundation
import AVKit
import SVProgressHUD

class WebcamDetailViewController: AbstractRefreshViewController {
    
    // MARK: - Properties
    
    @IBOutlet var brokenConnectionView: UIView!
    @IBOutlet var brokenCameraView: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet var lastUpdateViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var videoContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var lastUpdateView: UIView!
    @IBOutlet var nvActivityIndicatorView: NVActivityIndicatorView!
    @IBOutlet var lastUpdateLabel: UILabel!
    @IBOutlet var lowQualityView: UIVisualEffectView!
    @IBOutlet var favoriteButton: DOFavoriteButton!
    @IBOutlet var videoContainer: UIView!
    
    var lastZoomScale: CGFloat = -1
    var webcam: Webcam
    var isDataLoaded: Bool = false
    var shouldSetupInitialZoom: Bool = true
    var retryCount: Int = Webcam.retryCount
    var avPlayerController = AVPlayerViewController()
    var avPlayerURL: URL?
    var avExportTimer: Timer?
    var avExporter: AVAssetExportSession?
    
    // MARK: - Initializers

    init(webcam: Webcam) {
        self.webcam = webcam
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.downloadManagerDidUpdateWebcam,
                                                  object: nil)
        clearAVPlayerObservers()
    }
    
    // MARK: - Cycle
    
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
        
        // Favorite button
        favoriteButton.image = UIImage(named: "star-icon")
        favoriteButton.imageColorOn = UIColor.awBlue
        favoriteButton.imageColorOff = UIColor.awLightGray
        favoriteButton.duration = 1
        favoriteButton.lineColor = UIColor.awBlue
        favoriteButton.circleColor = UIColor.awBlue
        favoriteButton.isSelected = webcam.favorite
        
        // Prepare indicator
        scrollView.layoutIfNeeded()
        scrollView.delegate = self
        
        brokenConnectionView.isHidden = true
        brokenCameraView.isHidden = true
        shareButton.isEnabled = false
        
        // AVPlayer
        addChildViewController(avPlayerController)
        videoContainer.addSubview(avPlayerController.view)
        videoContainer.fit(toSubview: avPlayerController.view)
        
        // Insert subview
        [brokenCameraView, brokenConnectionView].forEach { [unowned self] subview in
            self.view.addSubview(subview!)
            self.view.fit(toSubview: subview!)
        }
        
        setupGestureRecognizer()
        updateLastUpdateLabel()
        refresh()
        
        AnalyticsManager.logEvent(showWebcam: webcam)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
        avExporter?.cancelExport()
        avExportTimer?.invalidate()
        avPlayerController.player?.pause()
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
    
    @IBAction func onFavoriteTouched(_ sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
        
        try? realm.write {
            webcam.favorite = sender.isSelected
        }
        
        AnalyticsManager.logEvent(set: webcam, asFavorite: sender.isSelected)
        NotificationCenter.default.post(name: Foundation.Notification.Name.favoriteWebcamDidUpdate, object: webcam)
    }
    
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
                                                             url: strongSelf.avPlayerURL,
                                                             image: strongSelf.imageView.image,
                                                             fromView: strongSelf.shareButton)
        })
        
        let saveAction = UIAlertAction(title: "Sauvegarder",
                                       style: .default,
                                       handler: { [weak self] _ in
                                        guard let strongSelf = self else { return }
                                        
                                        switch strongSelf.webcam.contentType {
                                        case .image:
                                            strongSelf.exportImage()
                                        case .viewsurf:
                                            strongSelf.exportAVPlayerVideo()
                                        }
                                        
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
    
    // MARK: -
    
    fileprivate func clearAVPlayerObservers() {
        if let player = avPlayerController.player {
            player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        }
    }
    
    fileprivate func mediaLoadingDidFinish() {
        retryCount = Webcam.retryCount
        nvActivityIndicatorView.stopAnimating()
        nvActivityIndicatorView.isHidden = true
        shareButton.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        isDataLoaded = true
        
        updateZoom(andRestore: scrollView.contentOffset)
    }
    
    fileprivate func mediaLoadingDidFailed() {
        nvActivityIndicatorView.stopAnimating()
        nvActivityIndicatorView.isHidden = true
        brokenCameraView.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    fileprivate func fetchLastViewsurfMedia(handler: @escaping (String) -> (Void)) {
        guard let viewsurf = webcam.preferredViewsurf(), let lastURL = URL(string: "\(viewsurf)/last") else { return }
        
        let request = Alamofire.request(lastURL,
                                        method: .get,
                                        parameters: nil,
                                        encoding: URLEncoding.default,
                                        headers: ApiRequest.headers)
        request.validate()
        request.debugLog()
        
        request.responseString { [weak self] response in
            guard let strongSelf = self else { return }
            
            if let error = response.error, let statusCode = response.response?.statusCode {
                print("ERROR: \(statusCode) - \(error.localizedDescription)")
                strongSelf.handleError(statusCode: statusCode)
            } else if let mediaPath = response.result.value?.replacingOccurrences(of: "\n", with: "") {
                handler(mediaPath)
            }
        }
    }
    
    fileprivate func loadViewsurfVideo() {
        guard let viewsurf = webcam.preferredViewsurf() else { return }
        
        fetchLastViewsurfMedia { [weak self] mediaPath in
            guard let strongSelf = self else { return }
            
            if let videoURL = URL(string: "\(viewsurf)/\(mediaPath).mp4") {
                strongSelf.videoContainer.isHidden = false
                strongSelf.clearAVPlayerObservers()
                strongSelf.avPlayerURL = videoURL

                let player = AVPlayer(url: videoURL)
                player.addObserver(strongSelf,
                                   forKeyPath: #keyPath(AVPlayer.status),
                                   options: [.initial, .new],
                                   context: nil)
                
                strongSelf.avPlayerController.delegate = self
                strongSelf.avPlayerController.player = player
                strongSelf.avPlayerController.player?.play()
            } else {
                strongSelf.mediaLoadingDidFailed()
            }
        }
    }
    
    fileprivate func loadViewsurfPreview(force: Bool = false) {
        guard let viewsurf = webcam.preferredViewsurf() else { return }

        fetchLastViewsurfMedia { [weak self] mediaPath in
            guard let strongSelf = self else { return }
            
            if let previewURL = URL(string: "\(viewsurf)/\(mediaPath).jpg") {
                self?.loadImage(for: previewURL, force: force)
            } else {
                strongSelf.mediaLoadingDidFailed()
            }
        }
    }
    
    fileprivate func loadImage(for url: URL, force: Bool = false) {
        var options: KingfisherOptionsInfo = []
        
        if force {
            options.append(.forceRefresh)
        }
        
        imageView?.kf.setImage(
            with: url,
            placeholder: nil,
            options: options,
            progressBlock: nil) { [weak self] image, error, cacheType, url in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    print("ERROR: \(error.code) - \(error.localizedDescription)")
                    strongSelf.handleError(statusCode: error.code, force: force)
                } else {
                    strongSelf.mediaLoadingDidFinish()
                }
        }
    }
    
    fileprivate func handleError(statusCode: Int, force: Bool = false) {
        if statusCode != -999 && isReachable() {
            if retryCount > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    print("Retrying to download \(self?.webcam.title) ...")
                    self?.retryCount -= 1
                    self?.refresh(force: force)
                }
            } else {
                mediaLoadingDidFailed()
            }
        } else {
            nvActivityIndicatorView.stopAnimating()
            nvActivityIndicatorView.isHidden = true
            brokenConnectionView.isHidden = false
        }
    }
    
    // MARK: - Notification Center
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer {
            if player.status == .failed {
                handleError(statusCode: -1)
            } else if player.status == .readyToPlay {
                mediaLoadingDidFinish()
            }
        }
    }
    
    func onAvExportTimerTick() {
        guard let exporter = avExporter else { return }
        
        if exporter.status == AVAssetExportSessionStatus.completed ||
            exporter.status == AVAssetExportSessionStatus.cancelled ||
            exporter.status == AVAssetExportSessionStatus.failed ||
            fabs(1.0 - exporter.progress) < FLT_EPSILON
        {
            SVProgressHUD.dismiss()
            avExportTimer?.invalidate()
        } else {
            SVProgressHUD.showProgress(exporter.progress, status: "Sauvegarde en cours")
        }
    }
    
    func onDownloadManagerDidUpdateWebcam(notification: Notification) {
        guard let webcam = notification.object as? Webcam, webcam == self.webcam else { return }
        
        updateLastUpdateLabel()
    }
    
    // MARK: - Exports
    
    func exportImage() {
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    func exportAVPlayerVideo() {
        guard let webcamTitle = webcam.title, let url = avPlayerURL else { return }
        
        let asset = AVURLAsset(url: url)
        let filename = "\(webcamTitle)-\(Date().timeIntervalSince1970).mov"
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory().appending(filename))
        
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        avExporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480)
        avExporter?.outputURL = outputURL
        avExporter?.outputFileType = AVFileTypeQuickTimeMovie
        
        avExportTimer = Timer.scheduledTimer(timeInterval: 0.3,
                                             target: self,
                                             selector: #selector(onAvExportTimerTick),
                                             userInfo: nil,
                                             repeats: true)
        
        avExporter?.exportAsynchronously { [weak self] in
            guard let strongSelf = self else { return }
            
            SVProgressHUD.dismiss()
            
            if let error = strongSelf.avExporter?.error {
                strongSelf.showAlertView(for: error)
            } else if strongSelf.avExporter?.status == .completed {
                UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path,
                                                    strongSelf,
                                                    #selector(strongSelf.video(_:didFinishSavingWithError:contextInfo:)),
                                                    nil)
            }
        }
    }
    
    func video(_ video: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertView(for: error)
        } else {
            showAlertView(with: "Vidéo sauvegardée dans la bibliothèque")
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertView(for: error)
        } else {
            showAlertView(with: "Image sauvegardée dans la bibliothèque")
        }
    }
    
    // MARK: -
    
    func forceRefresh() {
        retryCount = Webcam.retryCount
        refresh(force: isReachable())
        AnalyticsManager.logEvent(button: "webcam_detail_refresh")
    }
    
    override func refresh(force: Bool = false) {
        imageView.image = nil
        brokenConnectionView.isHidden = true
        brokenCameraView.isHidden = true
        shareButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        isDataLoaded = false
        videoContainer.isHidden = true
        if !nvActivityIndicatorView.isAnimating {
            nvActivityIndicatorView.startAnimating()
        }
        nvActivityIndicatorView.isHidden = false
        
        switch webcam.contentType {
        case .image:
            if let image = webcam.preferredImage(), let url = URL(string: image) {
                loadImage(for: url, force: force)
            }
            
        case .viewsurf:
            if isReachable() {
                loadViewsurfVideo()
            } else {
                loadViewsurfPreview(force: force)
            }
        }
    }
    
    override func style() {
        super.style()
        
        nvActivityIndicatorView.color = UIColor.white.withAlphaComponent(0.9)
        nvActivityIndicatorView.type = .ballGridPulse
        
        avPlayerController.view.backgroundColor = UIColor.awDarkGray
    }
    
    override func translate() {
        super.translate()
        
        title = webcam.title
    }
    
    override func update() {
        super.update()
        
        lowQualityView.isHidden = !webcam.isLowQualityOnly()
        videoContainerBottomConstraint.constant = lowQualityView.isHidden ? 0 : lowQualityView.bounds.height
    }
    
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
        let complementaryVPadding = webcam.isLowQualityOnly() ? lastUpdateView.bounds.height / 2 : lastUpdateView.bounds.height
        let vPadding = max(0, (viewHeight - scrollView.zoomScale * imageHeight) / 2 + complementaryVPadding)
        
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

// MARK: - AVAssetResourceLoaderDelegate

extension WebcamDetailViewController: AVAssetResourceLoaderDelegate {
}

// MARK: - AVPlayerViewControllerDelegate

extension WebcamDetailViewController: AVPlayerViewControllerDelegate {
}

// MARK: - MFMailComposeViewControllerDelegate

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
