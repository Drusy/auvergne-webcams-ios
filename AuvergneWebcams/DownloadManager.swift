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

class DownloadManager {
    static let shared = DownloadManager()
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    private init() {
        ImageDownloader.default.delegate = self
    }
    
    // MARK: -
    
    func bootstrapRealmDevelopmentData() {
        print(">>> Bootstraping developement configuration JSON")
        guard let path = Bundle.main.path(forResource: Configuration.localJSONConfigurationFileDev, ofType: "json") else { return }
        
        if let json = try? String(contentsOfFile: path, encoding: String.Encoding.utf8),
            let data = json.data(using: .utf8),
            let webcamSectionsResponse = try? JSONDecoder().decode(WebcamSectionResponse.self, from: data) {
            // Delete all sections & webcams
            let sections = realm.objects(WebcamSection.self)
            let webcams = realm.objects(Webcam.self)

            try! realm.write {
                realm.delete(sections)
                realm.delete(webcams)

                realm.add(webcamSectionsResponse.sections, update: .all)
            }
            QuickActionsService.shared.registerQuickActions()
        }
    }
    
    func bootstrapRealmData() {
        print(">>> Bootstraping configuration JSON")
        guard let path = Bundle.main.path(forResource: Configuration.localJSONConfigurationFile, ofType: "json") else { return }
        
        if let json = try? String(contentsOfFile: path, encoding: String.Encoding.utf8),
           let data = json.data(using: .utf8),
           let webcamSectionsResponse = try? JSONDecoder().decode(WebcamSectionResponse.self, from: data) {
            try! realm.write {
                realm.add(webcamSectionsResponse.sections, update: .all)
            }
            QuickActionsService.shared.registerQuickActions()
        }
    }
}

// MARK: - ImageDownloaderDelegate

extension DownloadManager: ImageDownloaderDelegate {
    func imageDownloader(_ downloader: ImageDownloader, didDownload image: KFCrossPlatformImage, for url: URL, with response: URLResponse?) {
        DispatchQueue.main.async {
            ImageDownloaderUtils.updateDate(for: url, with: response)
        }
    }
}
