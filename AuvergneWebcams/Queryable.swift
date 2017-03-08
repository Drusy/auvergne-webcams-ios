//
//  Query.swift
//  AuvergneWebcams
//
//  Created by AuvergneWebcams on 16/11/2016.
//  Copyright © 2016 AuvergneWebcams. All rights reserved.
//

import Foundation
import Alamofire
import SwiftiumKit
import ObjectMapper
import RealmSwift

protocol Queryable: Mappable {
    static var complementaryHeaders: [String: String] { get }
    static var encoding: ParameterEncoding { get }
    static var webServiceMethod: HTTPMethod { get }
    static var webServiceScheme: String { get }
    static var webServiceHost: String { get }
    static var webServicePath: String { get }
    static var webServiceLastSegmentPath: String { get }
    static var isSecured: Bool { get }
    
    static func parameters() -> [String: Any]?
}

extension Queryable {
    static var complementaryHeaders: [String: String] { return [:] }
    static var encoding: ParameterEncoding { return URLEncoding.default }
    static var webServiceMethod: HTTPMethod { return .get }
    static var webServiceScheme: String { return "https" }
    static var webServicePath: String { return "/Drusy/auvergne-webcams-ios/master/resources/config/" }
    static var webServiceLastSegmentPath: String { preconditionFailure("This method must be overridden") }
    static var isSecured: Bool { return false }
    static var webServiceHost: String { return "raw.githubusercontent.com" }
    
    static func parameters() -> [String: Any]? {
        return nil
    }
}

