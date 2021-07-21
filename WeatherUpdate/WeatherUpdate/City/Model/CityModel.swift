//
//  CityModel.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 10/07/21.
//

import Foundation

// This is produced using Builder design Pattern (Inbuilt in Swift)

struct CityModel {
    
    var citySubTitle: String = ""
    var administrativeArea: String = ""
    var countryCode: String = ""
    var cityTitle: String = ""
    var latitude: Double
    var longitude: Double
    var id: Int64
    var isFavourite: Bool
    var isDefault: Bool
}
