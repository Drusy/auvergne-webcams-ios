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

class DownloadManager {
    static let shared = DownloadManager()
    
    let realm = try! Realm()
    
    private init() {
        ImageDownloader.default.delegate = self
    }
    
    // MARK: -
    
    func bootstrapRealmDevelopmentData() {
        print(">>> Bootstraping developement configuration JSON")
        guard let path = Bundle.main.path(forResource: Configuration.localJSONConfigurationFileDev, ofType: "json") else { return }
        
        if let json = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) {
            if let webcamSectionsResponse = Mapper<WebcamSectionResponse>().map(JSONString: json) {
                // Delete all sections & webcams
                let sections = realm.objects(WebcamSection.self)
                let webcams = realm.objects(Webcam.self)
                
                try! realm.write {
                    realm.delete(sections)
                    realm.delete(webcams)
                    
                    realm.add(webcamSectionsResponse.sections, update: true)
                }
                QuickActionsService.shared.registerQuickActions()
            }
        }
    }
    
    func bootstrapRealmData() {
        print(">>> Bootstraping configuration JSON")
        guard let path = Bundle.main.path(forResource: Configuration.localJSONConfigurationFile, ofType: "json") else { return }
        
        if let json = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) {
            if let webcamSectionsResponse = Mapper<WebcamSectionResponse>().map(JSONString: json) {
                try! realm.write {
                    realm.add(webcamSectionsResponse.sections, update: true)
                }
                QuickActionsService.shared.registerQuickActions()
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
            
            var webcam: Webcam?
            
            // Managing Image content type
            webcam = self?.realm.objects(Webcam.self).filter("%K == %@ OR %K == %@",
                                                             #keyPath(Webcam.imageHD), url.absoluteString,
                                                             #keyPath(Webcam.imageLD), url.absoluteString).first
            // Managing Viewsurf content type
            if webcam == nil {
                var viewsurfURLAbsoluteString = url.deletingLastPathComponent().absoluteString
                viewsurfURLAbsoluteString = viewsurfURLAbsoluteString.substring(to: viewsurfURLAbsoluteString.index(before: viewsurfURLAbsoluteString.endIndex))
                webcam = self?.realm.objects(Webcam.self).filter("%K == %@ OR %K == %@",
                                                                 #keyPath(Webcam.viewsurfHD), viewsurfURLAbsoluteString,
                                                                 #keyPath(Webcam.viewsurfLD), viewsurfURLAbsoluteString).first
            }
            
            if let webcam = webcam {
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
}
