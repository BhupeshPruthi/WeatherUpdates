//
//  URLConfigurationProvider.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 11/07/21.
//

import Foundation

final class URLConfigurationProvider {
    
    lazy var baseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherBaseURL") as? String else {
            fatalError("base url can not be nil")
        }
        return apiBaseURL
    }()
    
    lazy var apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
            fatalError("Key can not be empty")
        }
        return key
    }()
}


// API Headers
struct APIHeaders {
    static var kContentType = "Content-Type"
    static var contentTypeValue = "application/json"
}

struct ServiceError: Error,Codable {
    let httpStatus: Int
    let message: String
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
