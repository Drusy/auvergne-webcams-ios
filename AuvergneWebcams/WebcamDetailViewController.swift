//
//  WebcamDetailViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

class WebcamDetailViewController: AbstractViewController {

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
    }
    
    // MARK: - 
    
    override func translate() {
        super.translate()
        
        title = webcam.title
    }
    
    override func update() {
        super.update()
    }
}
