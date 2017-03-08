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

class WebcamSection: Object, Mappable {
    
    static let weatherRefreshInterval: TimeInterval = 60 * 10
    
    // Update from WS
    dynamic var uid: Int = 0
    dynamic var order: Int = 0
    dynamic var title: String?
    dynamic var imageName: String?
    dynamic var latitude: Double = -1
    dynamic var longitude: Double = -1
    
    // Interval data
    dynamic var lastWeatherUpdate: Date?
    dynamic var temperature: Double = 0
    dynamic var weatherID: Int = 0

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
        }
        
        webcams.append(contentsOf: webcamsArray)
    }
    
    override static func primaryKey() -> String? {
        return #keyPath(WebcamSection.uid)
    }
    
    // MARK: - 
    
    func refreshWeatherIfNeeded() {
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
                if let error = response.result.error {
                    print(error.localizedDescription)
                } else if let openWeatherResponse = response.result.value {
                    if let openWeatherTemperature = openWeatherResponse.temperature?.temperature {
                        self?.temperature = openWeatherTemperature
                    }
                    
                    if let openWeatherIconId = openWeatherResponse.weathers.first?.id {
                        self?.weatherID = openWeatherIconId
                    }
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
        } else if weatherID > 800 && weatherID < 900 {
            image = UIImage(named: "weather-cloudy")
        } else {
            image = UIImage(named: "weather-cloud")
        }
        
        return image
    }
    
    func webcamCountLabel() -> String {
        if webcams.count == 1 {
            return "1 webcam"
        } else {
            return "\(webcams.count) webcams"
        }
    }
}
