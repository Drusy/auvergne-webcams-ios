//
//  MapViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 14/02/2018.
//

import UIKit
import Mapbox

class MapViewController: AbstractRealmViewController {

    @IBOutlet weak var mapContainer: UIView!
    
    fileprivate var mapView: MGLMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
    }
    
    // MARK: -
    
    func setupMap() {
        mapView = MGLMapView(frame: mapContainer.bounds)
        mapContainer.addSubview(mapView!)
        mapContainer.fit(toSubview: mapView!)
        
        mapView?.delegate = self
        mapView?.showsUserLocation = true
        mapView?.layer.backgroundColor = UIColor.clear.cgColor
        mapView?.styleURL = MGLStyle.darkStyleURL()
        mapView?.attributionButton.alpha = 0
        mapView?.logoView.isHidden = false
    }
}


// MARK: - MGLMapViewDelegate

extension MapViewController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: 4500, pitch: 15, heading: 180)
        
        mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 1
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 4
    }
}
