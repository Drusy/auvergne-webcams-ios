//
//  ImageDownloaderUtils.swift
//  AuvergneWebcams
//
//  Created by Drusy on 06/12/2017.
//

import Foundation
import RealmSwift

class ImageDownloaderUtils {
    static func updateDate(for url: URL, with response: URLResponse?) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        guard let lastModifiedString = httpResponse.allHeaderFields["Last-Modified"] as? String else { return }
        
        var webcam: Webcam?
        let realm = try? Realm()
        
        // Managing Image content type
        webcam = realm?.objects(Webcam.self).filter("%K == %@ OR %K == %@",
                                                    #keyPath(Webcam.imageHD), url.absoluteString,
                                                    #keyPath(Webcam.imageLD), url.absoluteString).first
        // Managing Viewsurf content type
        if webcam == nil {
            var viewsurfURLAbsoluteString = url.deletingLastPathComponent().absoluteString
            viewsurfURLAbsoluteString.removeLast()
            webcam = realm?.objects(Webcam.self).filter("%K == %@ OR %K == %@",
                                                        #keyPath(Webcam.viewsurfHD), viewsurfURLAbsoluteString,
                                                        #keyPath(Webcam.viewsurfLD), viewsurfURLAbsoluteString).first
        }
        
        if let webcam = webcam {
            let dateFormatter = DateFormatterCache.shared.dateFormatter(withFormat: "E, d MMM yyyy HH:mm:ss 'GMT'",
                                                                        locale: Locale(identifier: "en_US"),
                                                                        timeZone: TimeZone(abbreviation: "GMT"))
            if let date = dateFormatter.date(from: lastModifiedString) {
                try? realm?.write {
                    webcam.lastUpdate = date
                }
            }
        }
    }
}
