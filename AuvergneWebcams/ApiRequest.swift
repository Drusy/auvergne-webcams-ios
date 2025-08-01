//
//  ApiRequest.swift
//  AuvergneWebcams
//
//  Created by AuvergneWebcams on 20/07/16.
//  Copyright © 2016 AuvergneWebcams. All rights reserved.
//

import Foundation

//import AlamofireObjectMapper
//import ObjectMapper
import Alamofire
import SwiftyUserDefaults
import SwiftiumKit

class ApiRequest {
    
    @discardableResult
    static func startStringQuery<T: Queryable>(forType type: T.Type, parameters: [String: Any]? = nil, handler: ((AFDataResponse<String>) -> Void)? = nil) -> Request {
        let request = startRequest(forType: type, parameters: parameters)

        request.responseString { (response: AFDataResponse<String>) in
            if let request = response.request {
                print("Request: \(request)")
            }

            if let statusCode = response.response?.statusCode {
                print("Status code: \(statusCode)")
            }

            switch response.result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let value):
                print("Value: \(value)")
            }

            handler?(response)
        }

        return request
    }
    
    @discardableResult
    static func startDataQuery<T: Queryable>(forType type: T.Type, parameters: [String: Any]? = nil, handler: ((AFDataResponse<Data>) -> Void)? = nil) -> Request {
        let request = startRequest(forType: type, parameters: parameters)
        
        request.responseData { (response: AFDataResponse<Data>) in
            handler?(response)
        }
        
        return request
    }
    
    @discardableResult
    static func startQuery<T: Queryable & Decodable>(forType type: T.Type, parameters: [String: Any]? = nil, handler: ((DataResponse<T, AFError>) -> Void)? = nil) -> Request {
        let request = startRequest(forType: type, parameters: parameters)

        request.responseDecodable { (response: DataResponse<T, AFError>) in
            handler?(response)
        }
        
        return request
    }
    
    // MARK: - Private
    
    static let headers: [String: String] = [
//        "Accept": "application/json",
        "Cache-Control": "no-cache",
        "Accept-Encoding": "gzip"
    ]
    
    fileprivate static func url(forType queryableType: Queryable.Type) -> String {
        var urlComponents: URLComponents = URLComponents()
        
        urlComponents.scheme = queryableType.webServiceScheme
        urlComponents.host = queryableType.webServiceHost
        urlComponents.path = "\(queryableType.webServicePath)\(queryableType.webServiceLastSegmentPath)"
        
        let webServiceURL: String = try! urlComponents.asURL().absoluteString
        
        return webServiceURL
    }
    
    fileprivate static func startRequest(forType queryableType: Queryable.Type, parameters: [String: Any]? = nil) -> DataRequest {
        let allHeaders = headers + queryableType.complementaryHeaders
        let urlConvertible = url(forType: queryableType)
        let queryableParameters = queryableType.parameters() ?? [:]
        let requestParameters = parameters ?? [:]
        let computedParameters = queryableParameters + requestParameters
        
        return Alamofire.Session.default.request(
                urlConvertible,
                method: queryableType.webServiceMethod,
                parameters: computedParameters,
                encoding: queryableType.encoding,
                headers: .init(allHeaders)
            )
            .validate()
            .debugLog()
    }
}
