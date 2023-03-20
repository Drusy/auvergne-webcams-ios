//
//  MapViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 14/02/2018.
//

import UIKit
import MapboxMaps
import RealmSwift
import SwiftyUserDefaults

class MapViewController: AbstractRealmViewController {
    
    @IBOutlet weak var mapContainer: UIView!
    
    private var mapView = MapView(frame: .zero)
    private var webcams: Results<Webcam>
    private var subtitle: String?
    private var configureButton: UIBarButtonItem?
    private var isMapInitialized: Bool = false
    
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
        mapContainer.addSubview(mapView)
        mapContainer.fit(toSubview: mapView)

        mapView.location.options.puckType = .puck2D()
        mapView.layer.backgroundColor = UIColor.clear.cgColor
        mapView.ornaments.attributionButton.tintColor = UIColor.white
        mapView.mapboxMap.setCamera(to: .init(
            center: CLLocationCoordinate2D(latitude: 45.785931, longitude: 3.250595),
            zoom: 6)
        )
        
        if let style = Defaults[\.mapboxStyle], let url = URL(string: style),
           let styleURI = StyleURI(url: url) {
            mapView.mapboxMap.loadStyleURI(styleURI)
        } else {
            mapView.mapboxMap.loadStyleURI(.streets)
        }

        mapView.mapboxMap.onNext(event: .mapLoaded, handler: { [weak self] _ in
            self?.drawWebcams()
        })
    }

    private func drawWebcams() {
        var annotationsIds = [String]()

        webcams
            .filter { $0.latitude != -1 && $0.longitude != -1 }
            .forEach { webcam in
                let annotationView = UIView()
                annotationView.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
                annotationView.layer.cornerRadius = 27/2

                if let mapColor = webcam.section?.mapColor,
                    let color = UIColor(hex: mapColor) {
                    annotationView.backgroundColor = color
                } else {
                    annotationView.backgroundColor = .black
                }

                annotationView.layer.borderColor = UIColor.white.cgColor
                annotationView.layer.borderWidth = 2

                if let imageName = webcam.section?.mapImageName,
                   let image = UIImage(named: imageName) {
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    annotationView.addSubview(imageView)
                    annotationView.fit(
                        toSubview: imageView,
                        left: 7, right: 7,
                        top: 7, bottom: 7
                    )
                }

                let id = UUID().uuidString
                let tapGesture = AnnotationTapGestureRecognizer(id: id, target: self, action: #selector(annotationViewDidSelect))
                annotationView.addGestureRecognizer(tapGesture)

                try? mapView.viewAnnotations.add(annotationView, id: id, options: ViewAnnotationOptions(geometry: Geometry.point(Point(webcam.coordinate)), allowOverlap: true))
                annotationsIds.append(id)
            }

        if let cameraOptions = mapView.viewAnnotations.camera(
            forAnnotations: annotationsIds,
            padding: .init(top: 16, left: 16, bottom: 16, right: 16)
        ) {
            mapView.camera.ease(to: cameraOptions, duration: 0.5)
        }
    }

    @objc
    private func annotationViewDidSelect(sender: AnnotationTapGestureRecognizer) {
        if let view = mapView.viewAnnotations.view(forId: sender.id) {
            try? mapView.viewAnnotations.update(view, options: ViewAnnotationOptions(selected: true))
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
    
    func setStyle(_ style: StyleURI) {
        mapView.mapboxMap.loadStyleURI(style)
        Defaults[\.mapboxStyle] = style.rawValue
    }
    
    @objc func configure() {
        let actionSheet = UIAlertController(
            title: "Style de la carte",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let cancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        let outdoor = UIAlertAction(title: "Extérieur", style: .default) { [weak self] _ in
            self?.setStyle(.outdoors)
        }
        let dark = UIAlertAction(title: "Vecteurs sombre", style: .default) { [weak self] _ in
            self?.setStyle(.dark)
        }
        let light = UIAlertAction(title: "Vecteurs clair", style: .default) { [weak self] action in
            self?.setStyle(.light)
        }
        let satellite = UIAlertAction(title: "Satellite", style: .default) { [weak self] _ in
            self?.setStyle(.satellite)
        }
        let streets = UIAlertAction(title: "Routes", style: .default) { [weak self] _ in
            self?.setStyle(.streets)
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

extension MapViewController: AnnotationInteractionDelegate {
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {

    }

//    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
//        guard isMapInitialized == false else { return }
//        
//        isMapInitialized = true
//        webcams
//            .filter { $0.latitude != -1 && $0.longitude != -1 }
//            .forEach { webcam in
//                mapView.draw(webcam)
//        }
//        mapView.fitToAnnotationBounds(animated: true)
//    }
//    
//    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        return nil
//    }
//    
//    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
//        guard let webcamAnnotation = annotation as? WebcamAnnotation else {
//            return nil
//        }
//        
//        let mapImageName: String? = webcamAnnotation.webcam.mapImageName ?? webcamAnnotation.webcam.section?.mapImageName
//        let mapColor: String? = webcamAnnotation.webcam.section?.mapColor
//        let reuseIdentifier = mapImageName ?? "default-reusable-identifier"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
//        
//        if annotationView == nil {
//            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
//            annotationView?.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
//            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
//            annotationView?.layer.borderWidth = 2
//            annotationView?.layer.borderColor = UIColor.white.cgColor
//            
//            if let mapImageName = mapImageName, let image = UIImage(named: mapImageName) {
//                let imageView = UIImageView(image: image)
//                let offset: CGFloat = 7
//                
//                imageView.contentMode = .scaleAspectFit
//                
//                annotationView?.addSubview(imageView)
//                annotationView?.fit(toSubview: imageView,
//                                    left: offset, right: offset,
//                                    top: offset, bottom: offset)
//                
//            }
//        }
//        
//        if let mapColor = mapColor, let color = UIColor(hex: mapColor) {
//            annotationView?.backgroundColor = color
//        } else {
//            annotationView?.backgroundColor = UIColor.black
//        }
//        
//        return annotationView
//    }
//    
//    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//        return annotation is WebcamAnnotation
//    }
//    
//    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
//        return WebcamCalloutView(representedObject: annotation)
//    }
//    
//    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
//        
//        mapView.deselectAnnotation(annotation, animated: true)
//        
//        if let webcamAnnotation = annotation as? WebcamAnnotation {
//            let webcamDetail = WebcamDetailViewController(webcam: webcamAnnotation.webcam)
//            navigationController?.pushViewController(webcamDetail, animated: true)
//        }
//    }
}

class AnnotationTapGestureRecognizer: UITapGestureRecognizer {
    let id: String

    init(id: String, target: Any?, action: Selector?) {
        self.id = id
        super.init(target: target, action: action)
    }
}
