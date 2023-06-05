//
//  AbstractWebcamView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit
import AVFoundation
import Reachability
import Kingfisher
import Alamofire

public struct CGSizeProxy {
    fileprivate let base: CGSize
    init(proxy: CGSize) {
        base = proxy
    }
}

extension CGSize {
    public typealias CompatibleType = CGSizeProxy
    public var kf: CGSizeProxy {
        return CGSizeProxy(proxy: self)
    }
}

extension CGSizeProxy {
    func constrained(_ size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        return aspectWidth > size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
    }
    
    func filling(_ size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        return aspectWidth < size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
    }
    
    private var aspectRatio: CGFloat {
        return base.height == 0.0 ? 1.0 : base.width / base.height
    }
}

/// Processor for resizing images. Only CG-based images are supported in macOS.
struct ResizingContentModeImageProcessor: ImageProcessor {
    public enum ContentMode {
        case none
        case aspectFit
        case aspectFill
    }
    
    public let identifier: String
    
    /// Target size of output image should be.
    public let targetSize: CGSize
    
    /// Target content mode of output image should be.
    /// Default to ContentMode.none
    public let targetContentMode: ContentMode
    
    /// Initialize a `ResizingImageProcessor`
    ///
    /// - parameter targetSize: Target size of output image should be.
    /// - parameter contentMode: Target content mode of output image should be.
    ///
    /// - returns: An initialized `ResizingImageProcessor`.
    public init(targetSize: CGSize, contentMode: ContentMode = .none) {
        self.targetSize = targetSize
        self.targetContentMode = contentMode
        self.identifier = "com.onevcat.Kingfisher.ResizingImageProcessor(\(targetSize), \(targetContentMode))"
    }
    
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            var size: CGSize
            
            switch targetContentMode {
            case .none:
                size = targetSize
            case .aspectFill:
                size = image.size.kf.filling(targetSize)
            case .aspectFit:
                size = image.size.kf.constrained(targetSize)
            }
            
            return image.kf.resize(to: size)
        case .data(_):
            return DefaultImageProcessor.default.append(another: self).process(item: item, options: options)
        }
    }
}

class AbstractWebcamView: UIView {
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var brokenCameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHighlightOverlayView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var outdatedView: UIView!
    
    var retryCount = Webcam.retryCount
    
    var isHighlighted: Bool = false {
        didSet {
            let duration: TimeInterval = 0.2
            
            // Border animation
            let anim = CABasicAnimation(keyPath: "borderWidth")
            anim.fromValue = isHighlighted ? 0 : 1
            anim.toValue = isHighlighted ? 1 : 0
            anim.duration = duration
            anim.isRemovedOnCompletion = false
            anim.fillMode = kCAFillModeForwards
            imageView.layer.add(anim, forKey: anim.keyPath)
            
            let animationBlock = { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.imageViewHighlightOverlayView.alpha = strongSelf.isHighlighted ? 0.4 : 0.0
            }
            
            // Overlay animation
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: .beginFromCurrentState,
                           animations: animationBlock,
                           completion: nil)
            
        }
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageViewHighlightOverlayView.alpha = 0
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.awBlue.withAlphaComponent(0.3).cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    
    func configure(withWebcam webcam: Webcam) {
        reset()
        activityIndicator.startAnimating()
        imageView.layoutIfNeeded()
        
        switch webcam.contentType {
        case .image:
            if let image = webcam.preferredImage(), let url = URL(string: image) {
                loadImage(for: webcam, for: url)
            } else {
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
            }
            
        case .viewsurf:
            loadViewsurfPreview(for: webcam)
        case .video:
            loadVideoThumbnail(for: webcam)
        }
    }
    
    func reset() {
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        
        noDataView.isHidden = true
        brokenCameraView.isHidden = true
        outdatedView.isHidden = true

        activityIndicator.isHidden = false
    }
    
    // MARK: - 
    
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
                    self.handleError(for: webcam, statusCode: statusCode)
                }
            case .success(let value):
                let mediaPath = value.replacingOccurrences(of: "\n", with: "")
                if let previewURL = URL(string: "\(viewsurf)/\(mediaPath)_tn.jpg") {
                    self.loadImage(for: webcam, for: previewURL)
                } else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.brokenCameraView.isHidden = false
                }
            }
        }
    }
    
    fileprivate func loadImage(for webcam: Webcam, for url: URL) {
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: imageView.bounds.width * scale,
                                height: imageView.bounds.height * scale)
        let processor = ResizingContentModeImageProcessor(targetSize: targetSize, contentMode: .aspectFill)
        
        imageView.kf.setImage(
            with: url,
            options: [.processor(processor)],
            completionHandler: { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    print("ERROR: \(error.errorCode) - \(error.localizedDescription)")
                    self.handleError(for: webcam, statusCode: error.errorCode)
                case .success:
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.outdatedView.isHidden = webcam.isUpToDate()
                }
        })
    }

    fileprivate func loadVideoThumbnail(for webcam: Webcam) {
        guard let urlString = webcam.video,
            let url = URL(string: urlString) else { return }

        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    self.imageView.image = UIImage(cgImage: cgImage)
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    fileprivate func handleError(for webcam: Webcam, statusCode: Int) {
        let reachability: Reachability? = try? Reachability()
        let isReachable = (reachability == nil || (reachability != nil && reachability?.connection != .unavailable))
        
        if  statusCode != -999 && statusCode != 30000 {
            if isReachable {
                if retryCount > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        guard let strongSelf = self else { return }
                        
                        if let title = webcam.title {
                            print("Retrying to download \(title) ...")
                        }
                        strongSelf.retryCount -= 1
                        strongSelf.configure(withWebcam: webcam)
                    }
                } else {
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                    brokenCameraView.isHidden = false
                }
            } else {
                retryCount = Webcam.retryCount
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                imageView.image = nil
                noDataView.isHidden = false
            }
        }
    }
}
