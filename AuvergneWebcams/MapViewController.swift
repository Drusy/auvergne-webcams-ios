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

    private var selectedWebcam: UIView?
    private var currentWebcamCallout: WebcamCalloutView?
    
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
                let tapGesture = AnnotationTapGestureRecognizer(
                    id: id,
                    webcam: webcam,
                    target: self,
                    action: #selector(annotationViewDidSelect)
                )
                annotationView.addGestureRecognizer(tapGesture)

                try? mapView.viewAnnotations.add(annotationView, id: id, options: ViewAnnotationOptions(geometry: Geometry.point(Point(webcam.coordinate)), allowOverlap: true, selected: false))
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
        if let view = mapView.viewAnnotations.view(forId: sender.id),
           let options = mapView.viewAnnotations.options(for: view) {
            let isSelected = !(options.selected ?? false)
            try? mapView.viewAnnotations.update(view, options: ViewAnnotationOptions(selected: isSelected))

            if let selectedWebcam,
               view != selectedWebcam {
                try? mapView.viewAnnotations.update(selectedWebcam, options: ViewAnnotationOptions(selected: false))
            }
            currentWebcamCallout?.dismissCallout(animated: true)
            currentWebcamCallout = nil

            if isSelected {
                let callout = WebcamCalloutView(webcam: sender.webcam)
                callout.translatesAutoresizingMaskIntoConstraints = false
                callout.calloutDidTapped = { [weak self] in
                    if let currentWebcamCallout = self?.currentWebcamCallout {
                        self?.mapView.viewAnnotations.remove(currentWebcamCallout)
                    }
                    self?.annotationViewDidSelect(sender: sender)
                    self?.showWebcamDetail(webcam: sender.webcam)
                }

                try? mapView.viewAnnotations.add(callout, options: ViewAnnotationOptions(
                    geometry: Geometry.point(Point(sender.webcam.coordinate)),
                    allowOverlap: true,
                    anchor: .bottom,
                    offsetY: 14
                ))
                callout.setNeedsDisplay()

                selectedWebcam = view
                currentWebcamCallout = callout
            }
        }
    }

    private func showWebcamDetail(webcam: Webcam) {
        let webcamDetailViewController = WebcamDetailViewController(webcam: webcam)
        self.navigationController?.pushViewController(webcamDetailViewController, animated: true)
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

class AnnotationTapGestureRecognizer: UITapGestureRecognizer {
    let id: String
    let webcam: Webcam

    init(id: String, webcam: Webcam, target: Any?, action: Selector?) {
        self.id = id
        self.webcam = webcam
        super.init(target: target, action: action)
    }
}
