//
//  WeatherViewModel.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 11/07/21.
//

import Foundation

/*
 CityMo -> WeatherMo are two models used here for the UI updates
 CityModel is local model object to pass lat and long
 CoreData does not allow creatig instance of Mo, therefore CityModel Class will help in data navigation
 **/

struct WeatherViewModel {
    var cityMo: CityMO?
    var cityModel: CityModel? // For Fresh city Search, 
    var coreDataShared = CoreDataUtils.sharedUtils
    
     func getWeatherDataFor(completion: @escaping (CityMO?, ServiceError?) -> Void) {
        DispatchQueue.global().async {
            if let cityModel = self.cityModel {
                let apiHandler = WeatherOneCallAPI()
                let appConfiguration = URLConfigurationProvider()
                let param = ["lat": cityModel.latitude, "lon": cityModel.longitude, "appid": appConfiguration.apiKey] as [String: Any]

                let sessionManager = SessionManager(apiManager: apiHandler)
                sessionManager.loadAPIRequest(requestData: param) { (weatherModel, error) in
                    if let model = weatherModel {
                        coreDataShared.saveCity(cityModel: cityModel, weatherModel: model)
                        let city = coreDataShared.fetchCityForId(id: model.id)
                        completion(city, error)
                    } else {
                        let city = coreDataShared.fetchCityForId(id: Int(cityModel.id))
                        completion(city, error)
                    }
                }
            }
        }       
    }
}
