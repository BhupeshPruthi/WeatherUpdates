//
//  SessionManager.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 11/07/21.
//

import Foundation

struct SessionManager<T: APIManager> {
    var apiManager: T
    var urlSession: URLSession
    
    init(apiManager: T, urlSession: URLSession = .shared) {
        self.apiManager = apiManager
        self.urlSession = urlSession
    }
    
    func loadAPIRequest(requestData: T.RequestType, completionHandler: @escaping (T.ResponseType?, ServiceError?) -> ()) {
        if let urlRequest = apiManager.requestBuilder(from: requestData) {
            print("***********Request Sent API ***********")

            urlSession.dataTask(with: urlRequest) { (data, response, error) in
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Response code:: \(httpResponse.statusCode)")
                    guard error == nil else {
                        completionHandler(nil, ServiceError(httpStatus: httpResponse.statusCode, message: "ServiceError : \(error?.localizedDescription ?? "Unknown Error")"))
                        return
                    }
                    
                    guard let responseData = data else {
                        completionHandler(nil, ServiceError(httpStatus: httpResponse.statusCode, message: "ServiceError : \(error?.localizedDescription ?? "Unknown Error")"))
                        return
                    }
                    
                    guard httpResponse.statusCode == 200 else {
                        completionHandler(nil, ServiceError(httpStatus: httpResponse.statusCode, message: "ServiceError : \(error?.localizedDescription ?? "Unknown Error")"))
                        return
                    }
                    
                    do {
                        print("***********Response received from API ***********")
                        let parsedResponse = try self.apiManager.responseBuilder(data: responseData, response: httpResponse)
                        completionHandler(parsedResponse, nil)
                    } catch {
                        completionHandler(nil, ServiceError(httpStatus:  httpResponse.statusCode, message: "ServiceError : \(error.localizedDescription)"))
                    }
                    
                } else {
                    if let message = error?.localizedDescription {
                        completionHandler(nil, ServiceError(httpStatus:  -1009 , message: "\(message)"))
                    } else {
                        completionHandler(nil, ServiceError(httpStatus: -101, message: "ServiceError : Unknown Error"))
                    }
                }
            }.resume()
        }
    }
}
