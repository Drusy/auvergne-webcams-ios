//
//  MGLMapViewExtension.swift
//  AuvergneWebcams
//
//  Created by Drusy on 14/02/2018.
//

import Mapbox
import RealmSwift

class WebcamAnnotation: MGLPointAnnotation {
    var webcam: Webcam
    
    init(_ webcam: Webcam) {
        self.webcam = webcam
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MGLMapView {
    
    // MARK: - Open Explore
    
    func draw(_ section: WebcamSection) {
        section.sortedWebcams().forEach { webcam in
            draw(webcam)
        }
    }
    
    func draw(_ webcam: Webcam) {
        let annotation = WebcamAnnotation(webcam)
        
        annotation.title = webcam.title
        annotation.coordinate = CLLocationCoordinate2DMake(webcam.latitude,
                                                           webcam.longitude)
        
        addAnnotation(annotation)
    }
    
    // MARK: - Utils
    
    func fitToAnnotationBounds(animated: Bool = true) {
        guard let annotations = annotations else { return }
        
        showAnnotations(annotations, animated: animated)
    }
    
    func removeAllAnnotations() {
        guard let annotations = annotations else { return }
        
        removeAnnotations(annotations)
    }
    
    func removeAllPolylines() {
        guard let annotations = annotations else { return }
        
        let polylines = annotations.filter { $0 is MGLPolyline }
        removeAnnotations(polylines)
    }
    
    func removeAllPolygons() {
        guard let annotations = annotations else { return }
        
        let polygons = annotations.filter { $0 is MGLPolygon }
        removeAnnotations(polygons)
    }
    
    func removeAllPoints() {
        guard let annotations = annotations else { return }
        
        let points = annotations.filter { $0 is MGLPointAnnotation }
        removeAnnotations(points)
    }
}
