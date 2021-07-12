//
//  WeatherOneCallAPI.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 11/07/21.
//

import Foundation

class WeatherOneCallAPI: APIManager {
    
    func requestBuilder(from param: [String: Any]) -> URLRequest? {
        let appConfiguration = URLConfigurationProvider()
        let fullURL = URL(string: appConfiguration.baseURL)
        if var url = fullURL {
            print(url.absoluteString) // Prints: https://api.openweathermap.org/data/2.5/weather?
            if param.count > 0 {
                url = setQueryParams(parameters: param, url: url)
            }
            var urlRequest = URLRequest(url: url)
            setDefaultHeaders(request: &urlRequest)
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            return urlRequest
        }
        return nil
    }
    
    func responseBuilder(data: Data, response: HTTPURLResponse) throws -> WeatherModel {
        return try commonParser(data: data, response: response)
    }
}

//api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}

