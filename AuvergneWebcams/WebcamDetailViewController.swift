//
//  WebcamDetailViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

class WebcamDetailViewController: AbstractViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    var imageView: UIImageView?
    var webcam: Webcam
    
    init(webcam: Webcam) {
        self.webcam = webcam
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = webcam.image {
            imageView = UIImageView(image: webcam.image)
            
            scrollView = UIScrollView(frame: view.bounds)
            scrollView.backgroundColor = UIColor.black
            scrollView.contentSize = imageView!.bounds.size
            scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            scrollView.contentOffset = CGPoint(x: image.size.height / 2, y: image.size.width / 2)
            
            scrollView.addSubview(imageView!)
            view.addSubview(scrollView)
            
            scrollView.delegate = self
            
            setZoomScale()
            
            setupGestureRecognizer()

        }
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    // MARK: - 
    
    override func translate() {
        super.translate()
        
        title = webcam.title
    }
    
    override func update() {
        super.update()
    }
    
    // MARK: -
    
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
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

extension WebcamDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let imageView = imageView else { return }
        
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
}
