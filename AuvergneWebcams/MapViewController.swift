//
//  MapViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 14/02/2018.
//

import UIKit
import Mapbox
import RealmSwift
import SwiftyUserDefaults

class MapViewController: AbstractRealmViewController {
    
    @IBOutlet weak var mapContainer: UIView!
    
    fileprivate var mapView: MGLMapView?
    fileprivate var webcams: Results<Webcam>
    fileprivate var subtitle: String?
    fileprivate var configureButton: UIBarButtonItem?
    fileprivate var isMapInitialized: Bool = false
    
    init(webcams: Results<Webcam>, subtitle: String? = nil) {
        self.webcams = webcams
        self.subtitle = subtitle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureButton = UIBarButtonItem(image: UIImage(named: "settings-icon"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(configure))
        navigationItem.rightBarButtonItem = configureButton!
        
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
        mapView?.attributionButton.tintColor = UIColor.white
        mapView?.setCenter(CLLocationCoordinate2D(latitude: 45.785931, longitude: 3.250595),
                           zoomLevel: 6,
                           animated: false)
        
        if let style = Defaults[\.mapboxStyle], let url = URL(string: style) {
            mapView?.styleURL = url
        } else {
            mapView?.styleURL = MGLStyle.streetsStyleURL
        }
    }
    
    override func translate() {
        super.translate()
        
        if let subtitle = subtitle {
            title = "Carte - \(subtitle)"
        } else {
            title = "Carte"
        }
    }
    
    // MARK: - Actions
    
    func setStyle(_ url: URL) {
        mapView?.styleURL = url
        Defaults[\.mapboxStyle] = url.absoluteString
    }
    
    @objc func configure() {
        let actionSheet = UIAlertController(
            title: "Style de la carte",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let cancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        let outdoor = UIAlertAction(title: "Extérieur", style: .default) { [weak self] _ in
            self?.setStyle(MGLStyle.outdoorsStyleURL)
        }
        let dark = UIAlertAction(title: "Vecteurs sombre", style: .default) { [weak self] _ in
            self?.setStyle(MGLStyle.darkStyleURL)
        }
        let light = UIAlertAction(title: "Vecteurs clair", style: .default) { [weak self] action in
            self?.setStyle(MGLStyle.lightStyleURL)
        }
        let satellite = UIAlertAction(title: "Satellite", style: .default) { [weak self] _ in
            self?.setStyle(MGLStyle.satelliteStreetsStyleURL)
        }
        let streets = UIAlertAction(title: "Routes", style: .default) { [weak self] _ in
            self?.setStyle(MGLStyle.streetsStyleURL)
        }
        
        actionSheet.addAction(outdoor)
        actionSheet.addAction(dark)
        actionSheet.addAction(light)
        actionSheet.addAction(satellite)
        actionSheet.addAction(streets)
        actionSheet.addAction(cancel)
        
        actionSheet.popoverPresentationController?.barButtonItem = configureButton
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - MGLMapViewDelegate

extension MapViewController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        guard isMapInitialized == false else { return }
        
        isMapInitialized = true
        webcams
            .filter { $0.latitude != -1 && $0.longitude != -1 }
            .forEach { webcam in
                mapView.draw(webcam)
        }
        mapView.fitToAnnotationBounds(animated: true)
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard let webcamAnnotation = annotation as? WebcamAnnotation else {
            return nil
        }
        
        let mapImageName: String? = webcamAnnotation.webcam.mapImageName ?? webcamAnnotation.webcam.section?.mapImageName
        let mapColor: String? = webcamAnnotation.webcam.section?.mapColor
        let reuseIdentifier = mapImageName ?? "default-reusable-identifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 2
            annotationView?.layer.borderColor = UIColor.white.cgColor
            
            if let mapImageName = mapImageName, let image = UIImage(named: mapImageName) {
                let imageView = UIImageView(image: image)
                let offset: CGFloat = 7
                
                imageView.contentMode = .scaleAspectFit
                
                annotationView?.addSubview(imageView)
                annotationView?.fit(toSubview: imageView,
                                    left: offset, right: offset,
                                    top: offset, bottom: offset)
                
            }
        }
        
        if let mapColor = mapColor, let color = UIColor(hex: mapColor) {
            annotationView?.backgroundColor = color
        } else {
            annotationView?.backgroundColor = UIColor.black
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return annotation is WebcamAnnotation
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        return WebcamCalloutView(representedObject: annotation)
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        
        mapView.deselectAnnotation(annotation, animated: true)
        
        if let webcamAnnotation = annotation as? WebcamAnnotation {
            let webcamDetail = WebcamDetailViewController(webcam: webcamAnnotation.webcam)
            navigationController?.pushViewController(webcamDetail, animated: true)
        }
    }
}
