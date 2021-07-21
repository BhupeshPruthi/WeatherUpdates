//
//  WeatherModel.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 11/07/21.
//

import Foundation

struct WeatherModel: Codable {
    var coord: Coordinates
    var weather: [Weather]
    var visibility: Int
    var wind: Wind
    var dt: Int
    var sunrise: Sunrise
    var timezone: Int
    var id: Int  // City Id
    var name: String
    var main: Main
    enum CodingKeys: String, CodingKey {
        case coord, weather
        case visibility, wind
        case dt
        case sunrise = "sys"
        case timezone, id, name, main
    }
}

struct Coordinates: Codable {
    var latitude: Double
    var longitude: Double
    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

struct Weather: Codable {
    var id: Int
    var description: String
    var icon: String
}

struct Main: Codable {
    var temp: Double
    var feelLike: Double
    var tempMin: Double
    var tempMax: Double
    var pressure: Int
    var humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

struct Wind: Codable {
    var speed: Double
}

struct Sunrise: Codable {
    var sunrise: Int
    var sunset: Int
}

 /*
 {
    "coord":{
       "lon":-122.2551,
       "lat":37.8117
    },
    "weather":[
       {
          "id":800,
          "main":"Clear",
          "description":"clear sky",
          "icon":"01d"
       }
    ],
    "base":"stations",
    "main":{
       "temp":286.31,
       "feels_like":285.95,
       "temp_min":282.03,
       "temp_max":292.14,
       "pressure":1012,
       "humidity":87
    },
    "visibility":10000,
    "wind":{
       "speed":0.45,
       "deg":200,
       "gust":1.34
    },
    "clouds":{
       "all":7
    },
    "dt":1626010061,
    "sys":{
       "type":2,
       "id":2002415,
       "country":"US",
       "sunrise":1626008182,
       "sunset":1626060742
    },
    "timezone":-25200,
    "id":5378538,
    "name":"Oakland",
    "cod":200
 }
 **/
