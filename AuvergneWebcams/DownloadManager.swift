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
import ObjectMapper

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
    
    func bootstrapRealmDevelopmentData() {
        print(">>> Bootstraping developement configuration JSON")
        let path = Bundle.main.path(forResource: "aw-config-dev", ofType: "json")
        if let json = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8) {
            if let webcamSectionsResponse = Mapper<WebcamSectionResponse>().map(JSONString: json) {
                try! realm.write {
                    realm.add(webcamSectionsResponse.sections, update: true)
                }
            }
        }
    }
    
    func bootstrapRealmData() {
        print(">>> Bootstraping configuration JSON")
        let path = Bundle.main.path(forResource: "aw-config", ofType: "json")
        if let json = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8) {
            if let webcamSectionsResponse = Mapper<WebcamSectionResponse>().map(JSONString: json) {
                try! realm.write {
                    realm.add(webcamSectionsResponse.sections, update: true)
                }
            }
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
            
            let dateFormatter = DateFormatterCache.shared.dateFormatter(withFormat: "E, d MMM yyyy HH:mm:ss 'GMT'",
                                                                        locale: Locale(identifier: "en_US"),
                                                                        timeZone: TimeZone(abbreviation: "GMT"))
            if let date = dateFormatter.date(from: lastModifiedString) {
                try? self?.realm.write {
                    webcam.lastUpdate = date
                }
                NotificationCenter.default.post(name: Foundation.Notification.Name.downloadManagerDidUpdateWebcam, object: webcam)
            }
        }
    }
}
