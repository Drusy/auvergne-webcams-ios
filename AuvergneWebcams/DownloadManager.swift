//
//  DownloadManager.swift
//  AuvergneWebcams
//
//  Created by Drusy on 23/02/2017.
//
//

import Foundation
import Kingfisher
import RealmSwift

extension Notification.Name {
    static let downloadManagerDidUpdateWebcam = Notification.Name("downloadManagerDidUpdateWebcam")
}

class DownloadManager {
    static let shared = DownloadManager()
    
    let realm = try! Realm()
    
    private init() {
        ImageDownloader.default.delegate = self
    }
    
    // MARK: - 
    
    func bootstrapRealmData() {
        let sections = [
            WebcamSection.pddSection(),
            WebcamSection.sancySection(),
            WebcamSection.lioranSection()
        ]
        try! realm.write {
            realm.add(sections, update: true)
        }
    }
}

// MARK: - ImageDownloaderDelegate

extension DownloadManager: ImageDownloaderDelegate {
    func imageDownloader(_ downloader: ImageDownloader, didDownload image: Image, for url: URL, with response: URLResponse?) {
        DispatchQueue.main.async { [weak self] in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            guard let lastModifiedString = httpResponse.allHeaderFields["Last-Modified"] as? String else { return }
            guard let webcam = self?.realm.objects(Webcam.self).filter("%K == %@ OR %K == %@",
                                                                       #keyPath(Webcam.imageHD), url.absoluteString,
                                                                       #keyPath(Webcam.imageLD), url.absoluteString).first else { return }
            
            let dateFormatter = DateFormatterCache.shared.dateFormatter(withFormat: "E, d MMM yyyy HH:mm:ss 'GMT'", locale: Locale(identifier: "en_US"))
            if let date = dateFormatter.date(from: lastModifiedString) {
                try? self?.realm.write {
                    webcam.lastUpdate = date
                }
                NotificationCenter.default.post(name: Foundation.Notification.Name.downloadManagerDidUpdateWebcam, object: webcam)
            }
        }
    }
}
