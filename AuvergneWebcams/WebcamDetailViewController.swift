//
//  WebcamDetailViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit
import Kingfisher

class WebcamDetailViewController: AbstractRefreshViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    var imageView: UIImageView?
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh-icon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(forceRefresh))
        
        // Prepare indicator
        imageView = UIImageView(frame: view.bounds)
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.black
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollView.addSubview(imageView!)
        view.addSubview(scrollView)
        
        // Tap to zoom
        setupGestureRecognizer()
        
        // Load image
        refresh()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if isDataLoaded {
            setZoomScale()
        } else {
            resetScrollviewInsets()
        }
    }
    
    // MARK: - 
    
    func forceRefresh() {
        refresh(force: true)
    }
    
    override func refresh(force: Bool = false) {
        if let image = webcam.preferedImage(), let url = URL(string: image) {
            let indicator = KFIndicator(.white)
            let options: KingfisherOptionsInfo = force ? [.forceRefresh] : []
            
            isDataLoaded = false
            resetScrollviewInsets()

            imageView?.kf.indicatorType = .custom(indicator: indicator)
            imageView?.kf.setImage(with: url,
                                   placeholder: nil,
                                   options: options,
                                   progressBlock: nil) { [weak self] image, error, cacheType, url in
                                    guard let image = image else { return }
                                    
                                    self?.set(image: image)
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
    
    func set(image: UIImage) {
        let bounds = CGRect(origin: CGPoint(x: 0, y: 0),
                            size: image.size)
        
        isDataLoaded = true
        imageView?.frame = bounds
        
        scrollView.contentSize = bounds.size
        scrollView.contentOffset = CGPoint(x: image.size.height / 2, y: image.size.width / 2)
        scrollView.delegate = self
        
        setZoomScale()
    }
    
    func resetScrollviewInsets() {
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
        scrollView.contentSize = view.bounds.size
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView?.layoutIfNeeded()
        
        imageView?.frame = view.bounds
        imageView?.layoutIfNeeded()
    }
    
    func setZoomScale() {
        guard let imageView = imageView else { return }
        
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = max(widthScale, heightScale)
    }
    
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
}

extension WebcamDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard isDataLoaded == true else { return }
        guard let imageView = imageView else { return }
        
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
}
