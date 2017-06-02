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
import RealmSwift
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var webcamTitleLabel: UILabel!
    @IBOutlet var noFavoriteLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var errorButton: UIButton! {
        didSet {
            errorButton.titleLabel?.numberOfLines = 0
        }
    }

    var realm: Realm? = nil
    var completionHandler: ((NCUpdateResult) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Realm
        var config = Realm.Configuration()
        let realmPath: URL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.fr.openium.AuvergneWebcams")!
            .appendingPathComponent("db.realm")
        config.fileURL = realmPath
        Realm.Configuration.defaultConfiguration = config
        realm = try? Realm()
        
        // App link
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
        view.addGestureRecognizer(tapGesture)
        
        // Size
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .expanded:
            self.preferredContentSize = CGSize(width: maxSize.width, height: 300)
        case .compact:
            self.preferredContentSize = maxSize
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        guard let realm = realm else {
            onError()
            
            return
        }
        
        self.completionHandler = completionHandler
        let favoriteWebcams = Array(realm.objects(Webcam.self).filter("%K == true", #keyPath(Webcam.favorite)))
        
        if !favoriteWebcams.isEmpty {
            let favorite = favoriteWebcams[Int(arc4random_uniform(UInt32(favoriteWebcams.count)))]

            startLoading()
            
            webcamTitleLabel.text = favorite.title
            
            switch favorite.contentType {
            case .image:
                if let image = favorite.preferredImage(), let url = URL(string: image) {
                    loadImage(for: url)
                } else {
                    onError()
                }
                
            case .viewsurf:
                loadViewsurfPreview(for: favorite)
            }
        } else {
            onNoFavorite()
        }
    }
    
    // MARK: -
    
    fileprivate func onNoFavorite() {
        noFavoriteLabel.isHidden = false
        
        activityIndicator.isHidden = true
        contentView.isHidden = true
        errorButton.isHidden = true
        
        completionHandler?(NCUpdateResult.noData)
    }
    
    fileprivate func startLoading() {
        activityIndicator.isHidden = false
        
        contentView.isHidden = true
        noFavoriteLabel.isHidden = true
        errorButton.isHidden = true
    }
    
    fileprivate func onError() {
        errorButton.isHidden = false
        
        activityIndicator.isHidden = true
        contentView.isHidden = true
        noFavoriteLabel.isHidden = true
        
        completionHandler?(NCUpdateResult.failed)
    }
    
    fileprivate func onSuccess() {
        contentView.isHidden = false

        errorButton.isHidden = true
        activityIndicator.isHidden = true
        noFavoriteLabel.isHidden = true
        
        completionHandler?(NCUpdateResult.newData)
    }
    
    fileprivate func loadViewsurfPreview(for webcam: Webcam) {
        guard let viewsurf = webcam.preferredViewsurf(), let lastURL = URL(string: "\(viewsurf)/last") else {
            return
        }
        
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
                strongSelf.onError()
            } else if let mediaPath = response.result.value?.replacingOccurrences(of: "\n", with: "") {
                if let previewURL = URL(string: "\(viewsurf)/\(mediaPath).jpg") {
                    strongSelf.loadImage(for: previewURL)
                } else {
                    self?.onError()
                }
            }
        }
    }
    
    fileprivate func loadImage(for url: URL) {
        let options: KingfisherOptionsInfo = [.forceRefresh]
        
        imageView?.kf.setImage(
            with: url,
            placeholder: nil,
            options: options,
            progressBlock: nil) { [weak self] image, error, cacheType, url in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    print("ERROR: \(error.code) - \(error.localizedDescription)")
                    strongSelf.onError()
                } else {
                    strongSelf.onSuccess()
                }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onErrorTouched(_ sender: Any) {
        guard let completionHandler = completionHandler else { return }
        
        widgetPerformUpdate(completionHandler: completionHandler)
    }
    
    func onViewTapped() {
        guard let url = URL(string: "auvergne-webcams://") else { return }
        
        extensionContext?.open(url, completionHandler: nil)
    }
}
