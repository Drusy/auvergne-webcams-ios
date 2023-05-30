//
//  TodayViewController.swift
//  Widget
//
//  Created by Drusy on 02/06/2017.
//
//

import UIKit
import NotificationCenter
import Kingfisher
import AVFoundation
import RealmSwift
import Alamofire
import SwiftyUserDefaults
import NVActivityIndicatorView

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var outdatedView: UIVisualEffectView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var webcamTitleLabel: UILabel!
    @IBOutlet weak var noFavoriteLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nvActivityIndicatorView: NVActivityIndicatorView!
    @IBOutlet var shadowViews: [UIView]!
    @IBOutlet weak var errorButton: UIButton! {
        didSet {
            errorButton.titleLabel?.numberOfLines = 0
        }
    }

    var realm: Realm? = nil
    var completionHandler: ((NCUpdateResult) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Let's init the image downloader proxy
        ImageDownloader.default.delegate = self

        // Realm
        var config = Realm.Configuration()
        let realmPath: URL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.fr.openium.AuvergneWebcams")!
            .appendingPathComponent("db.realm")
        config.fileURL = realmPath
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config
        realm = try? Realm()
        
        // App link
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
        view.addGestureRecognizer(tapGesture)
        
        // Size
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        // Initial state
        errorButton.alpha = 0
        contentView.alpha = 0
        noFavoriteLabel.alpha = 0
        nvActivityIndicatorView.alpha = 0
        outdatedView.alpha = 0
        
        // Shadow
        shadowViews.forEach { view in
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 1, height: 1)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 4
        }
        
        // Loader
        nvActivityIndicatorView.color = UIColor.white
        nvActivityIndicatorView.type = .ballGridPulse
    }
    
    // MARK: -
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .expanded:
            self.preferredContentSize = CGSize(width: maxSize.width, height: 300)
        case .compact:
            self.preferredContentSize = maxSize
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.completionHandler = completionHandler
        guard let realm = realm else {
            onError()
            return
        }
        
        let favoriteWebcams = WebcamManager.shared.favoriteWebcams()
        if !favoriteWebcams.isEmpty {
            if let currentWebcamUid = Defaults[\.currentWidgetWebcamUid], let webcam = realm.object(ofType: Webcam.self, forPrimaryKey: currentWebcamUid) {
                if favoriteWebcams.contains(webcam) {
                    onShow(webcam)
                } else {
                    onShow(favoriteWebcams.first)
                }
            } else {
                onShow(favoriteWebcams.first)
            }
        } else {
            onNoFavorite()
        }
    }
    
    // MARK: -
    
    fileprivate func onShow(_ webcam: Webcam?) {
        guard let webcam = webcam else {
            onError()
            return
        }
        
        startLoading()
        webcamTitleLabel.text = webcam.title
        // https://forums.developer.apple.com/thread/121809
        webcamTitleLabel.textColor = .white
        Defaults[\.currentWidgetWebcamUid] = webcam.uid
        
        switch webcam.contentType {
        case .image:
            if let image = webcam.preferredImage(), let url = URL(string: image) {
                loadImage(for: url, webcam: webcam)
            } else {
                onError()
            }
            
        case .viewsurf:
            loadViewsurfPreview(for: webcam)
        case .video:
            loadVideoThumbnail(for: webcam)
        }
    }
    
    fileprivate func onNoFavorite() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.noFavoriteLabel.alpha = 1
                self?.contentView.alpha = 0
                self?.errorButton.alpha = 0
                self?.nvActivityIndicatorView.alpha = 0
                self?.outdatedView.alpha = 0
        },
            completion: { [weak self] _ in
                self?.nvActivityIndicatorView.stopAnimating()
                self?.completionHandler?(NCUpdateResult.noData)
        })
    }
    
    fileprivate func startLoading() {
        if !nvActivityIndicatorView.isAnimating {
            nvActivityIndicatorView.startAnimating()
        }
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.nvActivityIndicatorView.alpha = 1
                self?.contentView.alpha = 0
                self?.noFavoriteLabel.alpha = 0
                self?.errorButton.alpha = 0
            },
            completion: nil)
    }
    
    fileprivate func onError() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.errorButton.alpha = 1
                self?.contentView.alpha = 0
                self?.noFavoriteLabel.alpha = 0
                self?.nvActivityIndicatorView.alpha = 0
                self?.outdatedView.alpha = 0
            },
            completion: { [weak self] _ in
                self?.nvActivityIndicatorView.stopAnimating()
                self?.completionHandler?(NCUpdateResult.failed)
        })
    }
    
    fileprivate func onSuccess(webcam: Webcam) {
        previousButton.isHidden = true
        nextButton.isHidden = true
        
        let favorites = WebcamManager.shared.favoriteWebcams()
        if let uid = Defaults[\.currentWidgetWebcamUid] {
            if let index = favorites.index(where: { $0.uid == uid }) {
                if index > 0 {
                    previousButton.isHidden = false
                }
                if index < favorites.count - 1 {
                    nextButton.isHidden = false
                }
            }
        }
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.contentView.alpha = 1
                self?.errorButton.alpha = 0
                self?.noFavoriteLabel.alpha = 0
                self?.nvActivityIndicatorView.alpha = 0
                
                if webcam.isUpToDate() {
                    self?.outdatedView.alpha = 0
                } else {
                    self?.outdatedView.alpha = 1
                }
            },
            completion: { [weak self] _ in
                self?.nvActivityIndicatorView.stopAnimating()
                self?.completionHandler?(NCUpdateResult.newData)
        })
    }
    
    
    fileprivate func loadViewsurfPreview(for webcam: Webcam) {
        guard let viewsurf = webcam.preferredViewsurf(), let lastURL = URL(string: "\(viewsurf)/last") else {
            return
        }
        
        let request = Alamofire.Session.default
            .request(
                lastURL,
                method: .get,
                parameters: nil,
                encoding: URLEncoding.default,
                headers: .init(ApiRequest.headers)
            )
        request.validate()
        request.debugLog()
        
        request.responseString { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("ERROR: \(statusCode) - \(error.localizedDescription)")
                    self.onError()
                }
            case .success(let value):
                let mediaPath = value.replacingOccurrences(of: "\n", with: "")
                if let previewURL = URL(string: "\(viewsurf)/\(mediaPath)_tn.jpg") {
                    self.loadImage(for: previewURL, webcam: webcam)
                } else {
                    self.onError()
                }
            }
        }
    }

    fileprivate func loadVideoThumbnail(for webcam: Webcam) {
        guard let urlString = webcam.video,
            let url = URL(string: urlString) else { return }

        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            imageView.image = UIImage(cgImage: cgImage)
        } catch let error {
            print(error)
        }
    }
    
    fileprivate func loadImage(for url: URL, webcam: Webcam) {
        let options: KingfisherOptionsInfo = [.forceRefresh]
        
        imageView?.kf.setImage(
            with: url,
            placeholder: nil,
            options: options,
            progressBlock: nil) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    print("ERROR: \(error.errorCode) - \(error.localizedDescription)")
                    self.onError()
                case .success:
                    self.onSuccess(webcam: webcam)
                }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onPreviousTouched(_ sender: Any) {
        let favorites = WebcamManager.shared.favoriteWebcams()
        
        guard let uid = Defaults[\.currentWidgetWebcamUid] else { return }
        guard let index = favorites.index(where: { $0.uid == uid }) else { return }
        guard index > 0 else { return }
        
        onShow(favorites[index - 1])
    }
    
    @IBAction func onNextTouched(_ sender: Any) {
        let favorites = WebcamManager.shared.favoriteWebcams()

        guard let uid = Defaults[\.currentWidgetWebcamUid] else { return }
        guard let index = favorites.index(where: { $0.uid == uid }) else { return }
        guard index < favorites.count - 1 else { return }
        
        onShow(favorites[index + 1])
    }
    
    @IBAction func onErrorTouched(_ sender: Any) {
        guard let completionHandler = completionHandler else { return }
        
        widgetPerformUpdate(completionHandler: completionHandler)
    }
    
    @objc func onViewTapped() {
        guard let url = URL(string: "auvergne-webcams://") else { return }
        
        extensionContext?.open(url, completionHandler: nil)
    }
}

// MARK: - ImageDownloaderDelegate

extension TodayViewController: ImageDownloaderDelegate {
    func imageDownloader(_ downloader: ImageDownloader, didDownload image: KFCrossPlatformImage, for url: URL, with response: URLResponse?) {
        DispatchQueue.main.async {
            ImageDownloaderUtils.updateDate(for: url, with: response)
        }
    }
}

