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

protocol Queryable: StaticMappable {
    static var complementaryHeaders: [String: String] { get }
    static var encoding: ParameterEncoding { get }
    static var webServiceMethod: HTTPMethod { get }
    static var webServiceScheme: String { get }
    static var webServiceHost: String { get }
    static var webServicePath: String { get }
    static var webServiceFragment: String { get }
    static var webServiceLastSegmentPath: String { get }
    static var isSecured: Bool { get }
    
    static func parameters() -> [String: Any]?
}

class QueryableEntity: NSObject, Queryable {

    // MARK: - StaticMappable
    
    class func objectForMapping(map: Map) -> BaseMappable? {
        return QueryableEntity()
    }
    
    func mapping(map: Map) {}
    
    // MARK: - Class
    
    class var complementaryHeaders: [String: String] { return [:] }
    class var encoding: ParameterEncoding { return URLEncoding.default }
    class var webServiceMethod: HTTPMethod { return .get }
    class var webServiceScheme: String { return "https" }
    class var webServiceFragment: String { return "/Drusy" }
    class var webServicePath: String { return "/auvergne-webcams-ios/master" }
    class var webServiceLastSegmentPath: String { preconditionFailure("This method must be overridden") }
    class var isSecured: Bool { return false }
    class var webServiceHost: String { return "raw.githubusercontent.com" }
    
    class func parameters() -> [String: Any]? {
        return nil
    }

    // MARK: -
    
    func realmObjects() -> [Object] {
        preconditionFailure("This method must be overridden")
    }
    
    func realmType() -> Object.Type {
        preconditionFailure("This method must be overridden")
    }
}

