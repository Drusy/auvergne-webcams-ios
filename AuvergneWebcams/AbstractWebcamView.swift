//
//  AbstractWebcamView.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit
import Reachability
import Kingfisher

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
    
    public func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
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
            return (DefaultImageProcessor.default >> self).process(item: item, options: options)
        }
    }
}

class AbstractWebcamView: UIView {
    
    @IBOutlet var noDataView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewHighlightOverlayView: UIView!
    
    var isHighlighted: Bool = false {
        didSet {
            let duration: TimeInterval = 0.2
            
            // Shadow animation
//            let anim = CABasicAnimation(keyPath: "shadowColor")
//            anim.fromValue = isHighlighted ? UIColor.black.cgColor : UIColor.awBlue.cgColor
//            anim.toValue = isHighlighted ? UIColor.awBlue.cgColor : UIColor.black.cgColor
//            anim.duration = duration
//            anim.isRemovedOnCompletion = false
//            anim.fillMode = kCAFillModeForwards
//            shadowView.layer.add(anim, forKey: anim.keyPath)
            
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
        imageView.kf.indicatorType = .custom(indicator: KFIndicator(.white))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.awBlue.withAlphaComponent(0.3).cgColor
        imageView.kf.indicator?.view.layoutIfNeeded()
    }
    
    // MARK: -
    
    func configure(withWebcam webcam: Webcam) {
        noDataView.isHidden = true
        
        if let image = webcam.preferedImage(), let url = URL(string: image) {
            noDataView.isHidden = true
            imageView.layoutIfNeeded()
            
            let scale = UIScreen.main.scale
            let targetSize = CGSize(width: imageView.bounds.width * scale,
                                    height: imageView.bounds.height * scale)
            let processor = ResizingContentModeImageProcessor(targetSize: targetSize, contentMode: .aspectFill)
            imageView.kf.setImage(with: url, options: [.processor(processor)]) { [weak self] (image, error, cacheType, imageUrl) in
                if let error = error {
                    print("ERROR: \(error.code) - \(error.localizedDescription)")
                    
                    let reachability = Reachability()
                    let isReachable = (reachability == nil || (reachability != nil && reachability!.isReachable))
                    
                    if error.code != -999 && isReachable {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            print("Retrying to download \(imageUrl) ...")
                            self?.configure(withWebcam: webcam)
                        }
                    } else {
                        self?.noDataView.isHidden = false
                    }
                }
            }
        } else {
            imageView.image = nil
        }
    }
}
