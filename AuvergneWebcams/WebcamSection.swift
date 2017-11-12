//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import Foundation
import ObjectMapper
import RealmSwift
import Crashlytics

class FavoriteWebcamSection: WebcamSection {
    var favoriteWebcams: Results<Webcam>?
    
    required convenience init?(map: Map) {
        self.init()
    }

    override func sortedWebcams() -> Results<Webcam> {
        return favoriteWebcams ?? super.sortedWebcams()
    }
}

class WebcamSection: Object, Mappable {
    
    static let weatherRefreshInterval: TimeInterval = 60 * 30 // 30mn
    static let weatherAcceptanceInterval: TimeInterval = 60 * 60 * 2 // 2h
    
    // Update from WS
    @objc dynamic var uid: Int = 0
    @objc dynamic var order: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var imageName: String?
    @objc dynamic var latitude: Double = -1
    @objc dynamic var longitude: Double = -1
    
    // Interval data
    @objc dynamic var lastWeatherUpdate: Date?
    @objc dynamic var temperature: Double = 0
    @objc dynamic var weatherID: Int = 0

    var webcams = List<Webcam>()
    var image: UIImage? {
        guard let name = imageName else { return nil }
        
        return UIImage(named: name)
    }
    
    // MARK: - 
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        var webcamsArray = [Webcam]()
        
        uid <- map["uid"]
        order <- map["order"]
        title <- map["title"]
        imageName <- map["imageName"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        webcamsArray <- map["webcams"]
        
        let realm = try? Realm()
        if let section = realm?.object(ofType: WebcamSection.self, forPrimaryKey: uid) {
            lastWeatherUpdate = section.lastWeatherUpdate
            temperature = section.temperature
            weatherID = section.weatherID
        }
        
        webcams.append(contentsOf: webcamsArray)
    }
    
    override static func primaryKey() -> String? {
        return #keyPath(WebcamSection.uid)
    }
    
    // MARK: - 
    
    func sortedWebcams() -> Results<Webcam> {
        return webcams.sorted(byKeyPath: #keyPath(Webcam.order), ascending: true)
    }
    
    func refreshWeatherIfNeeded(handler: @escaping ((WebcamSection, Error?) -> Void)) {
        guard latitude != -1, longitude != -1 else { return }
        
        let lastWeatherRefreshInterval = lastWeatherUpdate?.timeIntervalSinceReferenceDate ?? 0
        let interval = Date().timeIntervalSinceReferenceDate - lastWeatherRefreshInterval
        
        // Every hour max
        if interval >= WebcamSection.weatherRefreshInterval {
            
            let parameters = [
                "lat": latitude,
                "lon": longitude
            ]
            
            ApiRequest.startQuery(forType: OpenWeatherResponse.self, parameters: parameters) { [weak self] response in
                guard let strongSelf = self else { return }
                
                if let error = response.result.error {
                    print(error.localizedDescription)
                    Crashlytics.sharedInstance().recordError(error)
                    handler(strongSelf, error)
                } else if let openWeatherResponse = response.result.value {
                    let realm = try? Realm()
                    
                    try? realm?.write {
                        strongSelf.lastWeatherUpdate = Date()
                        
                        if let openWeatherTemperature = openWeatherResponse.temperature?.temperature {
                            strongSelf.temperature = openWeatherTemperature - 273.15
                        }
                        
                        if let openWeatherIconId = openWeatherResponse.weathers.first?.id {
                            strongSelf.weatherID = openWeatherIconId
                        }
                    }
                    
                    handler(strongSelf, nil)
                }
            }
        }
    }
    
    // http://openweathermap.org/weather-conditions
    func weatherImage() -> UIImage? {
        var image: UIImage?
        
        if weatherID >= 500 && weatherID < 600 {
            image = UIImage(named: "weather-rain")
        } else if weatherID >= 200 && weatherID < 300 {
            image = UIImage(named: "weather-thunderstorm")
        } else if weatherID >= 600 && weatherID < 700 {
            image = UIImage(named: "weather-snow")
        } else if weatherID == 800 {
            image = UIImage(named: "weather-sun")
        } else if weatherID == 801 || weatherID == 802 || weatherID == 803 {
            image = UIImage(named: "weather-cloudy")
        } else {
            image = UIImage(named: "weather-cloud")
        }
        
        return image
    }
    
    func webcamCountLabel() -> String {
        let count = sortedWebcams().count
        if count == 1 {
            return "1 webcam"
        } else {
            return "\(count) webcams"
        }
    }
}
