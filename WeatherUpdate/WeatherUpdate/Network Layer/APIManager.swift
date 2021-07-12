//
//  APIManager.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 11/07/21.
//

import Foundation


/**
 The class provide Generic way to handle request and response
 Any new EndPoint can extend this class and implement requestBuilder and responseBuilder
 */

// MARK: - Request
protocol RequestManager {
    associatedtype RequestType
    func requestBuilder(from data:RequestType) -> URLRequest?
}

extension RequestManager {
    func setQueryParams(parameters:[String: Any], url: URL) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map { element in URLQueryItem(name: element.key, value: String(describing: element.value) ) }
        return components?.url ?? url
    }
    
    func setDefaultHeaders(request: inout URLRequest) {
        request.setValue(APIHeaders.contentTypeValue, forHTTPHeaderField: APIHeaders.kContentType)
    }
}

// MARK: - Response
protocol ResponseManager {
    associatedtype ResponseType
    func responseBuilder(data: Data, response: HTTPURLResponse) throws -> ResponseType
}

extension ResponseManager {
    func commonParser<T: Codable>(data: Data, response: HTTPURLResponse) throws -> T {
        print(T.self)
        let jsonDecoder = JSONDecoder()
        do {
            let body = try jsonDecoder.decode(T.self, from: data)
            if response.statusCode == 200 {
                return body
            } else {
                throw ServiceError(httpStatus: response.statusCode, message: "Unknown Error")
            }
        } catch  {
            throw ServiceError(httpStatus: response.statusCode, message: error.localizedDescription)
        }
    }
}

typealias APIManager = RequestManager & ResponseManager
