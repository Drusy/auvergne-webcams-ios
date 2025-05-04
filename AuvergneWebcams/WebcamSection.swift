//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit
import RealmSwift
import FirebaseCrashlytics

class FavoriteWebcamSection: WebcamSection {
    var favoriteWebcams: Results<Webcam>?

    override func sortedWebcams() -> Results<Webcam> {
        return favoriteWebcams ?? super.sortedWebcams()
    }
}

class WebcamSection: Object, Decodable {
    
    static let weatherRefreshInterval: TimeInterval = 60 * 30 // 30mn
    static let weatherAcceptanceInterval: TimeInterval = 60 * 60 * 2 // 2h
    
    // Update from WS
    @objc dynamic var uid: Int = 0
    @objc dynamic var order: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var imageName: String?
    @objc dynamic var mapImageName: String?
    @objc dynamic var mapColor: String?
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

    enum CodingKeys: String, CodingKey {
        case uid
        case order
        case title
        case imageName
        case mapImageName
        case mapColor
        case latitude
        case longitude
        case webcams
    }
    
    override static func primaryKey() -> String? {
        return #keyPath(WebcamSection.uid)
    }

    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(Int.self, forKey: .uid)
        self.order = try container.decode(Int.self, forKey: .order)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
        self.mapImageName = try container.decodeIfPresent(String.self, forKey: .mapImageName)
        self.mapColor = try container.decodeIfPresent(String.self, forKey: .mapColor)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? -1
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? -1
        self.webcams = try container.decode(List<Webcam>.self, forKey: .webcams)
    }

    // MARK: - 
    
    func sortedWebcams() -> Results<Webcam> {
        return webcams.filter("%K = false", #keyPath(Webcam.isHidden)).sorted(byKeyPath: #keyPath(Webcam.order), ascending: true)
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
                guard let self = self else { return }

                switch response.result {
                case .failure(let error):
                    Crashlytics.crashlytics().record(error: error)
                    print(error.localizedDescription)
                    handler(self, error)
                case .success(let value):
                    let realm = try? Realm()

                    try? realm?.write {
                        self.lastWeatherUpdate = Date()

                        if let openWeatherTemperature = value.temperature?.temperature {
                            self.temperature = openWeatherTemperature - 273.15
                        }

                        if let openWeatherIconId = value.weathers.first?.id {
                            self.weatherID = openWeatherIconId
                        }
                    }

                    handler(self, nil)
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
    
    func shouldShowMap() -> Bool {
        return sortedWebcams().filter { $0.latitude != -1 && $0.longitude != -1 }.isEmpty == false
    }
}
